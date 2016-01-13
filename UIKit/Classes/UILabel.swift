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

class UILabel: UIView {
    func textRectForBounds(bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        if text.characters.count > 0 {
            var maxSize: CGSize = bounds.size
            if numberOfLines > 0 {
                maxSize.height = font.lineHeight * numberOfLines
            }
            var size: CGSize = text.sizeWithFont(font, constrainedToSize: maxSize, lineBreakMode: lineBreakMode)
            var rect = CGRect()
            rect.bounds.origin
            rect.size
            return rect
        }
        var rect = CGRect()
        rect.bounds.origin
        rect.CGRect()
        rect.0
        rect.0
        return rect
    }

    func drawTextInRect(rect: CGRect) {
        text.drawInRect(rect, withFont: font, lineBreakMode: lineBreakMode, alignment: textAlignment)
    }
    var text: String {
        get {
            return self.text
        }
        set {
            if text != newText {
                self.text = newText.copy()
                self.setNeedsDisplay()
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
                self.setNeedsDisplay()
            }
        }
    }

    var textColor: UIColor {
        get {
            return self.textColor
        }
        set {
            if newColor != textColor {
                self.textColor = newColor
                self.setNeedsDisplay()
            }
        }
    }

    var highlightedTextColor: UIColor
    var shadowColor: UIColor {
        get {
            return self.shadowColor
        }
        set {
            if newColor != shadowColor {
                self.shadowColor = newColor
                self.setNeedsDisplay()
            }
        }
    }

    var shadowOffset: CGSize {
        get {
            return self.shadowOffset
        }
        set {
            if !CGSizeEqualToSize(newOffset, shadowOffset) {
                self.shadowOffset = newOffset
                self.setNeedsDisplay()
            }
        }
    }

    var textAlignment: UITextAlignment {
        get {
            return self.textAlignment
        }
        set {
            if newAlignment != textAlignment {
                self.textAlignment = newAlignment
                self.setNeedsDisplay()
            }
        }
    }

    var lineBreakMode: UILineBreakMode {
        get {
            return self.lineBreakMode
        }
        set {
            if newMode != lineBreakMode {
                self.lineBreakMode = newMode
                self.setNeedsDisplay()
            }
        }
    }

    var enabled: Bool {
        get {
            return self.enabled
        }
        set {
            if newEnabled != enabled {
                self.enabled = newEnabled
                self.setNeedsDisplay()
            }
        }
    }

    var numberOfLines: Int {
        get {
            return self.numberOfLines
        }
        set {
            if lines != numberOfLines {
                self.numberOfLines = lines
                self.setNeedsDisplay()
            }
        }
    }

    // currently only supports 0 or 1
    var baselineAdjustment: UIBaselineAdjustment
    // not implemented
    var adjustsFontSizeToFitWidth: Bool
    // not implemented
    var minimumFontSize: CGFloat
    // not implemented
    var highlighted: Bool {
        get {
            return self.highlighted
        }
        set {
            if highlighted != highlighted {
                self.highlighted = highlighted
                self.setNeedsDisplay()
            }
        }
    }

    convenience override init(frame: CGRect) {
        if (self.init(frame: frame)) {
            self.userInteractionEnabled = false
            self.textAlignment = .Left
            self.lineBreakMode = .TailTruncation
            self.textColor = UIColor.blackColor()
            self.backgroundColor = UIColor.whiteColor()
            self.enabled = true
            self.font = UIFont.systemFontOfSize(17)
            self.numberOfLines = 1
            self.contentMode = .Left
            self.clipsToBounds = true
            self.shadowOffset = CGSizeMake(0, -1)
            self.baselineAdjustment = .AlignBaselines
        }
    }

    func drawRect(rect: CGRect) {
        if text.characters.count > 0 {
            CGContextSaveGState(UIGraphicsGetCurrentContext)
            let bounds: CGRect = self.bounds
            var drawRect: CGRect = CGRectZero
            // find out the actual size of the text given the size of our bounds
            var maxSize: CGSize = bounds.size
            if numberOfLines > 0 {
                maxSize.height = font.lineHeight * numberOfLines
            }
            drawRect.size = text.sizeWithFont(font, constrainedToSize: maxSize, lineBreakMode: lineBreakMode)
            // now vertically center it
            drawRect.origin.y = roundf((bounds.size.height - drawRect.size.height) / 2.0)
            // now position it correctly for the width
            // this might be cheating somehow and not how the real thing does it...
            // I didn't spend a ton of time investigating the sizes that it sends the drawTextInRect: method
            drawRect.origin.x = 0
            drawRect.size.width = bounds.size.width
            // if there's a shadow, let's set that up
            var offset: CGSize = shadowOffset
            // stupid version compatibilities..
            if floorf(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_6 {
                offset.height *= -1
            }
            CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), offset, 0, shadowColor.CGColor)
            // finally, draw the real label
            var drawColor: UIColor = (highlighted && highlightedTextColor) ? highlightedTextColor : textColor
            drawColor.setFill()
            self.drawTextInRect(drawRect)
            CGContextRestoreGState(UIGraphicsGetCurrentContext())
        }
    }

    func setFrame(newFrame: CGRect) {
        let redisplay: Bool = !CGSizeEqualToSize(newFrame.size, self.frame.size)
        super.frame = newFrame
        if redisplay {
            self.setNeedsDisplay()
        }
    }

    func sizeThatFits(size: CGSize) -> CGSize {
        size = CGSizeMake(((numberOfLines > 0) ? CGFLOAT_MAX : size.width), ((numberOfLines <= 0) ? CGFLOAT_MAX : (font.lineHeight * numberOfLines)))
        return text.sizeWithFont(font, constrainedToSize: size, lineBreakMode: lineBreakMode)
    }
}
