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
import QuartzCore
import Foundation
protocol UITextLayerContainerViewProtocol: NSObject {
    func window() -> UIWindow

    func layer() -> CALayer

    func isHidden() -> Bool

    func isDescendantOfView(view: UIView) -> Bool

    func becomeFirstResponder() -> Bool

    func resignFirstResponder() -> Bool
    func isScrollEnabled() -> Bool

    func setContentOffset(offset: CGPoint)

    func contentOffset() -> CGPoint

    func setContentSize(size: CGSize)

    func contentSize() -> CGSize
}
protocol UITextLayerTextDelegate: NSObject {
    func _textShouldBeginEditing() -> Bool

    func _textShouldEndEditing() -> Bool

    func _textDidEndEditing()

    func _textShouldChangeTextInRange(range: NSRange, replacementText text: String) -> Bool
    func _textDidChange()

    func _textDidChangeSelection()

    func _textDidReceiveReturnKey()
}
class UITextLayer: CALayer {
    convenience override init(container aView: UIView<UITextLayerContainerViewProtocol,UITextLayerTextDelegate>, isField: Bool) {
        if (self.init()) {
            self.masksToBounds = false
            self.containerView = aView
            self.textDelegateHas.didChange = containerView.respondsToSelector("_textDidChange")
            self.textDelegateHas.didChangeSelection = containerView.respondsToSelector("_textDidChangeSelection")
            self.textDelegateHas.didReturnKey = containerView.respondsToSelector("_textDidReceiveReturnKey")
            self.containerCanScroll = containerView.respondsToSelector("setContentOffset:") && containerView.respondsToSelector("contentOffset") && containerView.respondsToSelector("setContentSize:") && containerView.respondsToSelector("contentSize") && containerView.respondsToSelector("isScrollEnabled")
            self.clipView = UICustomNSClipView as! UICustomNSClipView(frame: NSMakeRect(0, 0, 100, 100))
            self.textView = UICustomNSTextView as! UICustomNSTextView(frame: clipView.frame, secureTextEntry: secureTextEntry, isField: isField)
            textView.delegate = self
            clipView.documentView = textView
            self.textAlignment = .Left
            self.setNeedsLayout()
        }
    }

    func setContentOffset(contentOffset: CGPoint) {
        var point: NSPoint = clipView.constrainScrollPoint(NSPointFromCGPoint(contentOffset))
        clipView.scrollToPoint(point)
    }

    func scrollRangeToVisible(range: NSRange) {
        textView.scrollRangeToVisible(range)
    }

    func becomeFirstResponder() -> Bool {
        if self.shouldBeVisible() && !clipView.superview() {
            self.addNSView()
        }
        self.changingResponderStatus = true
        let result: Bool = textView.window().makeFirstResponder(textView)
        self.changingResponderStatus = false
        return result
    }

    func resignFirstResponder() -> Bool {
        self.changingResponderStatus = true
        let result: Bool = textView.window().makeFirstResponder(containerView.window.screen.UIKitView)
        self.changingResponderStatus = false
        return result
    }

    func sizeThatFits(size: CGSize) -> CGSize {
        var rect: NSRect = textView.layoutManager.usedRectForTextContainer(textView.textContainer)
        return CGSizeMake(min(rect.size.width, size.width), rect.size.height)
    }
    var selectedRange: NSRange {
        get {
            return textView.selectedRange()
        }
        set {
            textView.selectedRange = range
        }
    }

    var text: String {
        get {
            return textView.string()
        }
        set {
            textView.string = newText ?? ""
            self.updateScrollViewContentSize()
        }
    }

    var textColor: UIColor {
        get {
            return self.textColor
        }
        set {
            if newColor != textColor {
                self.textColor = newColor
                textView.textColor = textColor.NSColor()
            }
        }
    }

    var font: UIFont {
        get {
            return self.font
        }
        set {
            assert(newFont != nil)
            if newFont != font {
                self.font = newFont
                textView.font = font.NSFont()
            }
        }
    }

    var editable: Bool {
        get {
            return self.editable
        }
        set {
            if editable != edit {
                self.editable = edit
                textView.editable = editable
            }
        }
    }

    var secureTextEntry: Bool {
        get {
            return self.secureTextEntry
        }
        set {
            if s != secureTextEntry {
                self.secureTextEntry = s
                textView.secureTextEntry = secureTextEntry
            }
        }
    }

    var textAlignment: UITextAlignment {
        get {
            switch textView.alignment() {
                case NSCenterTextAlignment:
                    return .Center
                case NSRightTextAlignment:
                    return .Right
                default:
                    return .Left
            }
    
        }
        set {
            switch textAlignment {
                case .Left:
                    textView.alignment = NSLeftTextAlignment
                case .Center:
                    textView.alignment = NSCenterTextAlignment
                case .Right:
                    textView.alignment = NSRightTextAlignment
            }
    
        }
    }
    var self.containerView: UIView<UITextLayerContainerViewProtocol,UITextLayerTextDelegate>
    var self.containerCanScroll: Bool
    var self.textView: UICustomNSTextView
    var self.clipView: UICustomNSClipView
    var self.changingResponderStatus: Bool
    var self.textDelegateHas: struct{unsigneddidChange:1;unsigneddidChangeSelection:1;unsigneddidReturnKey:1;}


    func dealloc() {
        textView.delegate = nil
        self.removeNSView()
    }
    // Need to prevent Core Animation effects from happening... very ugly otherwise.

    func actionForKey(aKey: String) -> CAAction {
        return nil
    }

    func addNSView() {
        if containerCanScroll {
            clipView.scrollToPoint(NSPointFromCGPoint(containerView.contentOffset()))
        }
        else {
            clipView.scrollToPoint(NSZeroPoint)
        }
        self.clipView.parentLayer = self
        self.clipView.behaviorDelegate = self
        containerView.window.screen.UIKitView.addSubview(clipView)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateScrollViewContentOffset", name: NSViewBoundsDidChangeNotification, object: clipView)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hierarchyDidChangeNotification:", name: UIViewFrameDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hierarchyDidChangeNotification:", name: UIViewBoundsDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hierarchyDidChangeNotification:", name: UIViewDidMoveToSuperviewNotification, object: nil)
    }

    func removeNSView() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSViewBoundsDidChangeNotification, object: clipView)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIViewFrameDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIViewBoundsDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIViewDidMoveToSuperviewNotification, object: nil)
        self.clipView.parentLayer = nil
        self.clipView.behaviorDelegate = nil
        clipView.removeFromSuperview()
    }

    func updateScrollViewContentSize() {
        if containerCanScroll {
            // also update the content size in the UIScrollView
            let docRect: NSRect = clipView.documentRect()
            containerView.contentSize = CGSizeMake(docRect.size.width + docRect.origin.x, docRect.size.height + docRect.origin.y)
        }
    }

    func shouldBeVisible() -> Bool {
        return (containerView.window() && (self.superlayer == containerView.layer) && !self.hidden && !containerView.isHidden())
    }

    func updateNSViews() {
        if self.shouldBeVisible() {
            if !clipView.superview() {
                self.addNSView()
            }
            var window: UIWindow! = containerView.window()
            let windowRect: CGRect = window.convertRect(self.frame, fromView: containerView)
            let screenRect: CGRect = window.convertRect(windowRect, toWindow: nil)
            var desiredFrame: NSRect = NSRectFromCGRect(screenRect)
            clipView.frame = desiredFrame
            self.updateScrollViewContentSize()
        }
        else {
            self.removeNSView()
        }
    }

    func layoutSublayers() {
        self.updateNSViews()
        super.layoutSublayers()
    }

    func removeFromSuperlayer() {
        super.removeFromSuperlayer()
        self.updateNSViews()
    }

    func setHidden(hide: Bool) {
        if hide != self.hidden {
            super.hidden = hide
            self.updateNSViews()
        }
    }

    func hierarchyDidChangeNotification(note: NSNotification) {
        if containerView.isDescendantOfView(note.object) {
            if self.shouldBeVisible() {
                self.setNeedsLayout()
            }
            else {
                self.removeNSView()
            }
        }
    }

    func updateScrollViewContentOffset() {
        if containerCanScroll {
            containerView.contentOffset = NSPointToCGPoint(clipView.bounds.origin)
        }
    }
    // this is used to fake out AppKit when the UIView that owns this layer/editor stuff is actually *behind* another UIView. Since the NSViews are
    // technically above all of the UIViews, they'd normally capture all clicks no matter what might happen to be obscuring them. That would obviously
    // be less than ideal. This makes it ideal. Awesome.

    func hitTestForClipViewPoint(point: NSPoint) -> Bool {
        var screen: UIScreen = containerView.window().screen
        if screen != nil {
            return (containerView == screen.UIKitView.hitTestUIView(point))
        }
        return false
    }

    func clipViewShouldScroll() -> Bool {
        return containerCanScroll && containerView.isScrollEnabled()
    }

    func textShouldBeginEditing(aTextObject: NSText) -> Bool {
        return containerView._textShouldBeginEditing()
    }

    func textShouldEndEditing(aTextObject: NSText) -> Bool {
        return containerView._textShouldEndEditing()
    }

    func textDidEndEditing(aNotification: NSNotification) {
        containerView._textDidEndEditing()
    }

    func textDidChange(aNotification: NSNotification) {
        if textDelegateHas.didChangeSelection {
            // IMPORTANT! see notes about why this hack exists down in -textViewDidChangeSelection:!
            NSObject.cancelPreviousPerformRequestsWithTarget(containerView, selector: "_textDidChangeSelection", object: nil)
        }
        if textDelegateHas.didChange {
            containerView._textDidChange()
        }
    }

    func textViewDidChangeSelection(aNotification: NSNotification) {
        if textDelegateHas.didChangeSelection {
            // this defers the sending of the selection change delegate message. the reason is that on the real iOS, Apple does not appear to send
            // the selection changing delegate messages when text is actually changing. since I can't find a decent way to check here if text is
            // actually changing or if the cursor is just moving, I'm deferring the actual sending of this message. above in -textDidChange:, it
            // cancels the deferred send if it ends up that text actually changed. this only works if -textDidChange: is sent after
            // -textViewDidChangeSelection: which appears to be the case, but I don't think this is documented anywhere so this could possibly
            // break someday. anyway, the end result of this nasty hack is that UITextLayer shouldn't send out the selection changing notifications
            // while text is being changed, which mirrors how the real UIKit appears to work in this regard. note that the real UIKit also appears
            // to NOT send the selection change notification if you had multiple characters selected and then typed a single character thus
            // replacing the selected text with the single new character. happily this hack appears to function the same way.
            containerView.performSelector("_textDidChangeSelection", withObject: nil, afterDelay: 0)
        }
    }

    func textView(aTextView: NSTextView, shouldChangeTextInRange affectedCharRange: NSRange, replacementString: String) -> Bool {
        // always prevent newlines when in field editing mode. this seems like a heavy-handed way of doing it, but it's also easy and quick.
        // it should really probably be in the UICustomNSTextView class somewhere and not here, but this works okay, too, I guess.
        // this is also being done in doCommandBySelector: below, but it's done here as well to prevent pasting stuff in with newlines in it.
        // seems like a hack, I dunno.
        if textView.isFieldEditor() && (replacementString.rangeOfCharacterFromSet(NSCharacterSet.newlineCharacterSet()).location != NSNotFound) {
            return false
        }
        else {
            return containerView._textShouldChangeTextInRange(affectedCharRange, replacementText: replacementString)
        }
    }

    func textView(aTextView: NSTextView, doCommandBySelector aSelector: Selector) -> Bool {
        // this makes sure there's no newlines added when in field editing mode.
        // it also allows us to handle when return/enter is pressed differently for fields. Dunno if there's a better way or not.
        if textView.isFieldEditor() && ((aSelector == "insertNewline:" || (aSelector == "insertNewlineIgnoringFieldEditor:"))) {
            if textDelegateHas.didReturnKey {
                containerView._textDidReceiveReturnKey()
            }
            return true
        }
        return false
    }

    func textViewBecomeFirstResponder(aTextView: UICustomNSTextView) -> Bool {
        if changingResponderStatus {
            return aTextView.reallyBecomeFirstResponder()
        }
        else {
            return containerView.becomeFirstResponder()
        }
    }

    func textViewResignFirstResponder(aTextView: UICustomNSTextView) -> Bool {
        if changingResponderStatus {
            return aTextView.reallyResignFirstResponder()
        }
        else {
            return containerView.resignFirstResponder()
        }
    }

    func textView(aTextView: UICustomNSTextView, shouldAcceptKeyDown theNSEvent: NSEvent) -> Bool {
        var key: UIKey = UIKey(NSEvent: theNSEvent)
        if key.action {
            aTextView.doCommandBySelector(key.action)
            return false
        }
        else {
            return true
        }
    }

    func removeNSView() {
    }
}

import AppKit
import AppKit