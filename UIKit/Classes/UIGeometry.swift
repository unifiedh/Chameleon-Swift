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
import ApplicationServices

/// specify amount to inset (positive) for each of the edges. values can be negative to 'outset'
public struct UIEdgeInsets {
    public var top: CGFloat = 0
    public var left: CGFloat = 0
    public var bottom: CGFloat = 0
    public var right: CGFloat = 0
    
    public static let zero = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    public func insetRect(var rect: CGRect) -> CGRect {
        rect.origin.x    += self.left;
        rect.origin.y    += self.top;
        rect.size.width  -= (self.left + self.right);
        rect.size.height -= (self.top  + self.bottom);
        return rect;
    }
}

extension UIEdgeInsets: Equatable {
    
}

public func ==(lhs: UIEdgeInsets, rhs: UIEdgeInsets) -> Bool {
    return CGRect(x: lhs.left, y: lhs.top, width: lhs.right, height: lhs.bottom) ==
        CGRect(x: rhs.left, y: rhs.top, width: rhs.right, height: rhs.bottom)
}

public func UIEdgeInsetsMake(top: CGFloat, _ left: CGFloat, _ bottom: CGFloat, _ right: CGFloat)-> UIEdgeInsets {
    return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
}

public func UIEdgeInsetsInsetRect(rect: CGRect, _ insets: UIEdgeInsets) -> CGRect {
    return insets.insetRect(rect)
}

public func UIEdgeInsetsEqualToEdgeInsets(insets1: UIEdgeInsets, _ insets2: UIEdgeInsets) -> Bool {
    return insets1 == insets2;
}

public var UIEdgeInsetsZero: UIEdgeInsets {
    return .zero
}

public struct UIOffset {
    public var horizontal: CGFloat = 0
    public var vertical: CGFloat = 0
    
    public static let zero = UIOffset(horizontal: Double(0), vertical: 0)
}

extension UIOffset {
    public init(horizontal: Double, vertical: Double) {
        self.horizontal = CGFloat(horizontal)
        self.vertical = CGFloat(vertical)
    }
    
    public init(horizontal: Int, vertical: Int) {
        self.horizontal = CGFloat(horizontal)
        self.vertical = CGFloat(vertical)
    }
}

extension UIOffset: Equatable {
    
}

public func ==(rhs: UIOffset, lhs: UIOffset) -> Bool {
    return rhs.horizontal == lhs.horizontal && rhs.vertical == lhs.vertical
}

func UIOffsetEqualToOffset(offset1: UIOffset, _ offset2: UIOffset) -> Bool {
    return offset1 == offset2
}

public var UIOffsetZero: UIOffset {
    return .zero
}

public func NSStringFromCGPoint(p: CGPoint) -> String {
    return NSStringFromPoint(NSPointFromCGPoint(p))
}

public func NSStringFromCGRect(r: CGRect) -> String {
    return NSStringFromRect(NSRectFromCGRect(r))
}

public func NSStringFromCGSize(s: CGSize) -> String {
    return NSStringFromSize(NSSizeFromCGSize(s));
}

public func NSStringFromCGAffineTransform(transform: CGAffineTransform) -> String {
    return "[\(transform.a), \(transform.b), \(transform.c), \(transform.d), \(transform.tx), \(transform.ty)]"
}

public func NSStringFromUIEdgeInsets(insets: UIEdgeInsets) -> String {
    return "{\(insets.top), \(insets.left), \(insets.bottom), \(insets.right)}"
}

public func NSStringFromUIOffset(offset: UIOffset) -> String {
    return "{\(offset.horizontal), \(offset.vertical)}"
}

extension NSValue {
    class func valueWithCGPoint(point: CGPoint) -> NSValue {
        return NSValue(point: NSPointFromCGPoint(point))
    }

    class func valueWithCGRect(rect: CGRect) -> NSValue {
        return NSValue(rect: NSRectFromCGRect(rect))
    }

    class func valueWithCGSize(size: CGSize) -> NSValue {
        return NSValue(size: NSSizeFromCGSize(size))
    }

    class func valueWithUIEdgeInsets(var insets: UIEdgeInsets) -> NSValue {
        return NSValue(bytes: &insets, objCType: "{UIEdgeInsets=dddd}")
    }

    class func valueWithUIOffset(var offset: UIOffset) -> NSValue {
        return NSValue(bytes: &offset, objCType: "{UIOffset=dd}")
    }

    func CGPointValue() -> CGPoint {
        return NSPointToCGPoint(self.pointValue)
    }

    func CGRectValue() -> CGRect {
        return NSRectToCGRect(self.rectValue)
    }

    func CGSizeValue() -> CGSize {
        return NSSizeToCGSize(self.sizeValue)
    }

    func UIEdgeInsetsValue() -> UIEdgeInsets {
        if strcmp(self.objCType, "{UIEdgeInsets=dddd}") == 0 {
            var insets = UIEdgeInsets()
            self.getValue(&insets)
            return insets
        } else if strcmp(self.objCType, "{UIEdgeInsets=ffff}") == 0 {
            var tmpFloat: [Float] = [0,0,0,0]
            self.getValue(&tmpFloat)
            return UIEdgeInsets(top: CGFloat(tmpFloat[0]), left: CGFloat(tmpFloat[1]), bottom: CGFloat(tmpFloat[2]), right: CGFloat(tmpFloat[3]))
        }

        return UIEdgeInsetsZero
    }

    func UIOffsetValue() -> UIOffset {
        if strcmp(self.objCType, "{UIOffset=dd}") == 0 {
            var offset = UIOffset()
            self.getValue(&offset)
            return offset
        } else if strcmp(self.objCType, "{UIOffset=ff}") == 0 {
            var tmpFloats: [Float] = [0,0]
            self.getValue(&tmpFloats)
            return UIOffset(horizontal: CGFloat(tmpFloats[0]), vertical: CGFloat(tmpFloats[1]))
        }

        return UIOffsetZero
    }
}

extension NSCoder {
    func encodeCGPoint(point: CGPoint, forKey key: String) {
        self.encodePoint(NSPointFromCGPoint(point), forKey: key)
    }

    func decodeCGPointForKey(key: String) -> CGPoint {
        return NSPointToCGPoint(self.decodePointForKey(key))
    }

    func encodeCGRect(rect: CGRect, forKey key: String) {
        self.encodeRect(NSRectFromCGRect(rect), forKey: key)
    }

    func decodeCGRectForKey(key: String) -> CGRect {
        return NSRectToCGRect(self.decodeRectForKey(key))
    }
}

