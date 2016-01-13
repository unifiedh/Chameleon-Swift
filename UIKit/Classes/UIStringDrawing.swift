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
import Foundation
import AppKit
enum UILineBreakMode : Int {
    case WordWrap = 0
    case CharacterWrap
    case Clip
    case HeadTruncation
    case TailTruncation
    case MiddleTruncation
}

enum UITextAlignment : Int {
    case Left
    case Center
    case Right
}

enum UIBaselineAdjustment : Int {
    case AlignBaselines
    case AlignCenters
    case None
}

    let UITextAttributeFont: String

    let UITextAttributeTextColor: String

    let UITextAttributeTextShadowColor: String

    let UITextAttributeTextShadowOffset: String

extension NSString {
    func sizeWithFont(font: UIFont) -> CGSize {
        return self.sizeWithFont(font, constrainedToSize: CGSizeMake(CGFLOAT_MAX, font.lineHeight))
    }

    func sizeWithFont(font: UIFont, forWidth width: CGFloat, lineBreakMode: UILineBreakMode) -> CGSize {
        return self.sizeWithFont(font, constrainedToSize: CGSizeMake(width, font.lineHeight), lineBreakMode: lineBreakMode)
    }

    func sizeWithFont(font: UIFont, constrainedToSize size: CGSize) -> CGSize {
        return self.sizeWithFont(font, constrainedToSize: size, lineBreakMode: .WordWrap)
    }

    func sizeWithFont(font: UIFont, constrainedToSize size: CGSize, lineBreakMode: UILineBreakMode) -> CGSize {
        var resultingSize: CGSize = CGSizeZero
        var lines: CFArrayRef = CreateCTLinesForString(self, size, font, lineBreakMode, resultingSize)
        if lines != nil {
            CFRelease(lines)
        }
        return resultingSize
    }

    func drawAtPoint(point: CGPoint, withFont font: UIFont) -> CGSize {
        return self.drawAtPoint(point, forWidth: CGFLOAT_MAX, withFont: font, lineBreakMode: .WordWrap)
    }

    func drawAtPoint(point: CGPoint, forWidth width: CGFloat, withFont font: UIFont, lineBreakMode: UILineBreakMode) -> CGSize {
        return self.drawAtPoint(point, forWidth: width, withFont: font, fontSize: font.pointSize(), lineBreakMode: lineBreakMode, baselineAdjustment: .None)
    }

    func drawAtPoint(point: CGPoint, forWidth width: CGFloat, withFont font: UIFont, fontSize: CGFloat, lineBreakMode: UILineBreakMode, baselineAdjustment: UIBaselineAdjustment) -> CGSize {
        var adjustedFont: UIFont = (font.pointSize() != fontSize) ? font(size: fontSize) : font
        return self.drawInRect(CGRectMake(point.x, point.y, width, adjustedFont.lineHeight), withFont: adjustedFont, lineBreakMode: lineBreakMode)
    }

    func drawInRect(rect: CGRect, withFont font: UIFont) -> CGSize {
        return self.drawInRect(rect, withFont: font, lineBreakMode: .WordWrap, alignment: .Left)
    }

    func drawInRect(rect: CGRect, withFont font: UIFont, lineBreakMode: UILineBreakMode) -> CGSize {
        return self.drawInRect(rect, withFont: font, lineBreakMode: lineBreakMode, alignment: .Left)
    }

    func drawInRect(rect: CGRect, withFont font: UIFont, lineBreakMode: UILineBreakMode, alignment: UITextAlignment) -> CGSize {
        var actualSize: CGSize = CGSizeZero
        var lines: CFArrayRef = CreateCTLinesForString(self, rect.size, font, lineBreakMode, actualSize)
        if lines != nil {
            let numberOfLines: CFIndex = CFArrayGetCount(lines)
            let fontLineHeight: CGFloat = font.lineHeight
            var textOffset: CGFloat = 0
            var ctx: CGContextRef = UIGraphicsGetCurrentContext()
            CGContextSaveGState(ctx)
            CGContextTranslateCTM(ctx, rect.origin.x, rect.origin.y + font.ascender)
            CGContextSetTextMatrix(ctx, CGAffineTransformMakeScale(1, -1))
            for var lineNumber = 0; lineNumber < numberOfLines; lineNumber++ {
                var line: CTLineRef = CFArrayGetValueAtIndex(lines, lineNumber)
                var flush: Float
                switch alignment {
                    case .Center:
                        flush = 0.5
                    case .Right:
                        flush = 1
                    default:
                        flush = 0
                }

                var penOffset: CGFloat = CTLineGetPenOffsetForFlush(line, flush, rect.size.width)
                CGContextSetTextPosition(ctx, penOffset, textOffset)
                CTLineDraw(line, ctx)
                textOffset += fontLineHeight
            }
            CGContextRestoreGState(ctx)
            CFRelease(lines)
        }
        // the real UIKit appears to do this.. so shall we.
        actualSize.height = min(actualSize.height, rect.size.height)
        return actualSize
    }
    // not yet implemented

    func sizeWithFont(font: UIFont, minFontSize: CGFloat, actualFontSize: CGFloat, forWidth width: CGFloat, lineBreakMode: UILineBreakMode) -> CGSize {
        return CGSizeZero
    }

    func drawAtPoint(point: CGPoint, forWidth width: CGFloat, withFont font: UIFont, minFontSize: CGFloat, actualFontSize: CGFloat, lineBreakMode: UILineBreakMode, baselineAdjustment: UIBaselineAdjustment) -> CGSize {
        return CGSizeZero
    }
}

    let UITextAttributeFont: String = "UITextAttributeFont"

    let UITextAttributeTextColor: String = "UITextAttributeTextColor"

    let UITextAttributeTextShadowColor: String = "UITextAttributeTextShadowColor"

    let UITextAttributeTextShadowOffset: String = "UITextAttributeTextShadowOffset"

        var lines: CFMutableArrayRef = CFArrayCreateMutable(nil, 0, kCFTypeArrayCallBacks)
        var drawSize: CGSize = CGSizeZero
        if font != nil {
            var attributes: CFMutableDictionaryRef = CFDictionaryCreateMutable(nil, 2, kCFTypeDictionaryKeyCallBacks, kCFTypeDictionaryValueCallBacks)
            CFDictionarySetValue(attributes, kCTFontAttributeName, font->font)
            CFDictionarySetValue(attributes, kCTForegroundColorFromContextAttributeName, kCFBooleanTrue)
            var attributedString: CFAttributedStringRef = CFAttributedStringCreate(nil, string as! CFString, attributes)
            var typesetter: CTTypesetterRef = CTTypesetterCreateWithAttributedString(attributedString)
            let stringLength: CFIndex = CFAttributedStringGetLength(attributedString)
            let lineHeight: CGFloat = font.lineHeight
            let capHeight: CGFloat = font.capHeight
            var start: CFIndex = 0
            var isLastLine: Bool = false
            while start < stringLength && !isLastLine {
                drawSize.height += lineHeight
                isLastLine = (drawSize.height + capHeight >= constrainedToSize.height)
                var usedCharacters: CFIndex = 0
                var line: CTLineRef? = nil
                if isLastLine && (lineBreakMode != .WordWrap && lineBreakMode != .CharacterWrap) {
                    if lineBreakMode == .Clip {
                        usedCharacters = CTTypesetterSuggestClusterBreak(typesetter, start, constrainedToSize.width)
                        line = CTTypesetterCreateLine(typesetter, CFRangeMake(start, usedCharacters))
                    }
                    else {
                        var truncType: CTLineTruncationType
                        if lineBreakMode == .HeadTruncation {
                            truncType = kCTLineTruncationStart
                        }
                        else if lineBreakMode == .TailTruncation {
                            truncType = kCTLineTruncationEnd
                        }
                        else {
                            truncType = kCTLineTruncationMiddle
                        }

                        usedCharacters = stringLength - start
                        var ellipsisString: CFAttributedStringRef = CFAttributedStringCreate(nil, CFSTR("…"), attributes)
                        var ellipsisLine: CTLineRef = CTLineCreateWithAttributedString(ellipsisString)
                        var tempLine: CTLineRef = CTTypesetterCreateLine(typesetter, CFRangeMake(start, usedCharacters))
                        line = CTLineCreateTruncatedLine(tempLine, constrainedToSize.width, truncType, ellipsisLine)
                        CFRelease(tempLine)
                        CFRelease(ellipsisLine)
                        CFRelease(ellipsisString)
                    }
                }
                else {
                    if lineBreakMode == .CharacterWrap {
                        usedCharacters = CTTypesetterSuggestClusterBreak(typesetter, start, constrainedToSize.width)
                    }
                    else {
                        usedCharacters = CTTypesetterSuggestLineBreak(typesetter, start, constrainedToSize.width)
                    }
                    line = CTTypesetterCreateLine(typesetter, CFRangeMake(start, usedCharacters))
                }
                if line! {
                    drawSize.width = max(drawSize.width, ceilf(CTLineGetTypographicBounds(line!, nil, nil, nil)))
                    CFArrayAppendValue(lines, line!)
                    CFRelease(line!)
                }
                start += usedCharacters
            }
            CFRelease(typesetter)
            CFRelease(attributedString)
            CFRelease(attributes)
        }
        if renderSize {
            renderSize = drawSize
        }
        return lines