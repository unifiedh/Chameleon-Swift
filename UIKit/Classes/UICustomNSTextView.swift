/*
 * Copyright (c) 2011, The Iconfactory. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of The Iconfactory nor the names of its contributors may
 *    be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE ICONFACTORY BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
import AppKit

@objc protocol UICustomNSTextViewDelegate: NSTextViewDelegate {
    optional func textViewBecomeFirstResponder(textView: UICustomNSTextView) -> Bool

    optional func textViewResignFirstResponder(textView: UICustomNSTextView) -> Bool

    optional func textView(textView: UICustomNSTextView, shouldAcceptKeyDown event: NSEvent) -> Bool
}

class UICustomNSTextView: NSTextView, NSLayoutManagerDelegate {
	init(frame: NSRect, secureTextEntry isSecure: Bool, isField: Bool) {
            let maxSize: NSSize = NSMakeSize(LargeNumberForText, LargeNumberForText)
            // this is not ideal, I suspect... but it seems to work for now.
            // one behavior that's missing is that when a field resigns first responder,
            // it should really sort of turn back into a non-field that happens to have no word wrapping.
            // right now I have it scroll to the beginning of the line, at least, but even though the line break
            // mode is set to truncate on the tail, it doesn't do that because the underlying text container's size
            // has been sized to something bigger here. I tried to work around this by resetting the modes and such
            // on resignFirstResponder, but for some reason it just didn't seem to work reliably (especially when
            // the view was resized - it's like once you turn off setWidthTracksTextView, it doesn't want to turn
            // back on again). I'm likely missing something important, but it's not crazy important right now.
		super.init(frame: frame, textContainer: nil)

            if isField {
                self.fieldEditor = true
                self.horizontallyResizable = true
                self.verticallyResizable = false
                self.textContainer?.widthTracksTextView = false
                self.textContainer?.containerSize = maxSize
                self.textContainerInset = NSMakeSize(0, 0)
            }
            else {
                self.fieldEditor = false
                self.horizontallyResizable = false
                self.verticallyResizable = true
                self.autoresizingMask = .ViewWidthSizable
                self.textContainerInset = NSMakeSize(3, 8)
            }
            self.maxSize = maxSize
            self.drawsBackground = false
            self.richText = false
            self.usesFontPanel = false
            self.importsGraphics = false
            self.allowsImageEditing = false
            self.displaysLinkToolTips = false
            self.automaticDataDetectionEnabled = false
            // same color as iOS
            self.insertionPointColor = NSColor(calibratedRed: 62 / 255.0, green: 100 / 255.0, blue: 243 / 255.0, alpha: 1)
            self.layerContentsPlacement = .TopLeft
            // this is for a spell checking hack.. see below
            self.layoutManager?.delegate = self
    }

	required init?(coder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
    func reallyBecomeFirstResponder() -> Bool {
        return super.becomeFirstResponder()
    }

    func reallyResignFirstResponder() -> Bool {
        if fieldEditor {
            self.scrollRangeToVisible(NSMakeRange(0, 0))
        }
        self.selectedRange = NSMakeRange(0, 0)
        return super.resignFirstResponder()
    }

    @nonobjc func delegate() -> UICustomNSTextViewDelegate? {
        return super.delegate as! UICustomNSTextViewDelegate?
    }

    //func setDelegate(d: UICustomNSTextViewDelegate) {
    //    super.delegate = d
    //}
	var secureTextEntry: Bool {
		didSet {
			updateStyles()
		}
	}
    var isBecomingFirstResponder: Bool = false


    func updateStyles() {
        let style: NSMutableParagraphStyle = NSMutableParagraphStyle()
        style.setParagraphStyle(NSParagraphStyle.defaultParagraphStyle())
        if secureTextEntry {
            // being all super-paranoid here...
            self.automaticQuoteSubstitutionEnabled = false
            self.grammarCheckingEnabled = false
            self.automaticSpellingCorrectionEnabled = false
            self.continuousSpellCheckingEnabled = false
            self.automaticDashSubstitutionEnabled = false
            self.automaticTextReplacementEnabled = false
            self.smartInsertDeleteEnabled = false
            self.usesFindPanel = false
            self.allowsUndo = false
            self.layoutManager?.glyphGenerator = UIBulletGlyphGenerator()
            style.lineBreakMode = .ByCharWrapping
        }
        else {
            self.allowsUndo = true
            self.continuousSpellCheckingEnabled = true
            self.smartInsertDeleteEnabled = true
            self.usesFindPanel = true
            self.layoutManager?.glyphGenerator = NSGlyphGenerator.sharedGlyphGenerator()
        }
        if fieldEditor {
            style.lineBreakMode = .ByTruncatingTail
        }
        self.defaultParagraphStyle = style
    }

    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        if secureTextEntry && (menuItem.action == "copy:" || menuItem.action == "cut:") {
            return false
            // don't allow copying/cutting out from a secure field
        }
        else {
            return super.validateMenuItem(menuItem)
        }
    }

	override var selectionGranularity: NSSelectionGranularity {
		get {
        if secureTextEntry {
            return .SelectByCharacter
            // trying to avoid the secure one giving any hints about what's under it. :/
        }
        else {
            return super.selectionGranularity
        }
		}
		set {
			super.selectionGranularity = newValue
		}
    }

    override func startSpeaking(sender: AnyObject?) {
        // only allow speaking if it's not secure
        if !secureTextEntry {
            super.startSpeaking(sender)
        }
    }

	override func validRequestorForSendType(sendType: String, returnType: String) -> AnyObject? {
		if secureTextEntry {
			return nil
		} else {
			return super.validRequestorForSendType(sendType, returnType: returnType)
		}
	}

    override func menuForEvent(theEvent: NSEvent) -> NSMenu? {
        let menu = super.menuForEvent(theEvent)
        // screw it.. why not just remove everything from the context menu if it's a secure field? :)
        // it's possible that various key combos could still allow things like searching in spotlight which
        // then would revel the actual value of the password field, but at least those are sorta obscure :)
        if let menu = menu where secureTextEntry {
            let items = menu.itemArray
            for item in items {
                if item.action != "paste:" {
                    menu.removeItem(item)
                }
            }
        }
        return menu
    }

    override func becomeFirstResponder() -> Bool {
        self.isBecomingFirstResponder = true
        let result: Bool = self.delegate()?.textViewBecomeFirstResponder?(self) ?? false
        self.isBecomingFirstResponder = false
        return result
    }

    override func resignFirstResponder() -> Bool {
        if isBecomingFirstResponder {
            return false
        }
        return self.delegate()?.textViewResignFirstResponder?(self) ?? false
    }

    override func keyDown(event: NSEvent) {
        if delegate()?.textView?(self, shouldAcceptKeyDown: event) ?? true {
            super.keyDown(event)
        }
    }
    
    // TODO: Remove Spelling Check Hack
    // Starts Spelling Check Hack

    func setNeedsFakeSpellCheck() {
        if continuousSpellCheckingEnabled {
            NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: "forcedSpellCheck", object: nil)
            self.performSelector("forcedSpellCheck", withObject: nil, afterDelay: 0.5)
        }
    }

    override func didChangeText() {
        super.didChangeText()
        self.setNeedsFakeSpellCheck()
    }

    override func updateInsertionPointStateAndRestartTimer(flag: Bool) {
        super.updateInsertionPointStateAndRestartTimer(flag)
        self.setNeedsFakeSpellCheck()
    }

    func forcedSpellCheck() {
		self.checkTextInRange(NSMakeRange(0, (self.string! as NSString).length), types: self.enabledTextCheckingTypes, options: [:])
    }
    // Because drawing the misspelling underline squiggle doesn't seem to work when the text view is used on a layer-backed NSView, we have to draw them
    // ourselves. In an attempt to be pro-active about avoiding potential problems if Apple were to fix this in 10.7, I'm returning nil in this
    // NSLayoutManager delegate method which should mean that it won't even try draw any temporary attributes - even if it can some day.

    func layoutManager(layoutManager: NSLayoutManager, shouldUseTemporaryAttributes attrs: [String : AnyObject], forDrawingToScreen toScreen: Bool, atCharacterIndex charIndex: Int, effectiveRange effectiveCharRange: NSRangePointer) -> [String : AnyObject]? {
        return nil
    }
    // My attempt at drawing the underline dots as close to how stock OSX seems to draw them. It's not perfect, but to my eyes it's damn close.
    // This should not need to exist.

    func drawFakeSpellingUnderlinesInRect(rect: NSRect) {
        var lineDash: [CGFloat] = [0.75, 3.25]
        let underlinePath = NSBezierPath()
        underlinePath.setLineDash(&lineDash, count: 2, phase: 0)
        underlinePath.lineWidth = 2
        underlinePath.lineCapStyle = .RoundLineCapStyle
        let layout = layoutManager!
        var checkRange: NSRange = NSMakeRange(0, (self.string! as NSString).length)
        while checkRange.length > 0 {
            var effectiveRange: NSRange = NSMakeRange(checkRange.location, 0)
            if let spellingValue = layout.temporaryAttribute(NSSpellingStateAttributeName, atCharacterIndex: checkRange.location, longestEffectiveRange: &effectiveRange, inRange: checkRange) as? NSNumber {
                let spellingFlag: Int = spellingValue as Int
                if (spellingFlag & NSSpellingStateSpellingFlag) == NSSpellingStateSpellingFlag {
                    var count: Int = 0
                    let rects: NSRectArray = layout.rectArrayForCharacterRange(effectiveRange, withinSelectedCharacterRange: NSMakeRange(NSNotFound, 0), inTextContainer: self.textContainer!, rectCount: &count)
                    for i in 0..<count {
                        if NSIntersectsRect(rects[i], rect) {
                            underlinePath.moveToPoint(NSMakePoint(rects[i].origin.x, rects[i].origin.y + rects[i].size.height - 1.5))
                            underlinePath.relativeLineToPoint(NSMakePoint(rects[i].size.width, 0))
                        }
                    }
                }
            }
            checkRange.location = NSMaxRange(effectiveRange)
            checkRange.length = (self.string! as NSString).length - checkRange.location
        }
        NSColor.redColor().setStroke()
        underlinePath.stroke()
    }

    override func drawRect(rect: NSRect) {
        // This disables font smoothing. This is necessary because in this implementation, the NSTextView is always drawn with a transparent background
        // and layered on top of other views. It therefore cannot properly do subpixel rendering and the smoothing ends up looking like crap. Turning
        // the smoothing off is not as nice as properly smoothed text, of course, but at least its sorta readable. Yet another case of crap layer
        // support making things difficult. Amazingly, iOS fonts look fine when rendered without subpixel smoothing. Why?!
        let ctx = NSGraphicsContext.currentContext()?.CGContext
        CGContextSetShouldSmoothFonts(ctx, false)
        super.drawRect(rect)
        self.drawFakeSpellingUnderlinesInRect(rect)
    }
}

/// Any larger dimensions and the text could become blurry.
private let LargeNumberForText: CGFloat = 1.0e7
