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
    var UIEdgeInsets: structUIEdgeInsets{CGFloattop,left,bottom,right;}

        var edgeInsets = UIEdgeInsets()
        edgeInsets.top
        edgeInsets.left
        edgeInsets.bottom
        edgeInsets.right
        return edgeInsets

        rect.origin.x += insets.left
        rect.origin.y += insets.top
        rect.size.width -= (insets.left + insets.right)
        rect.size.height -= (insets.top + insets.bottom)
        return rect

        return CGRectEqualToRect(CGRectMake(insets1.left, insets1.top, insets1.right, insets1.bottom), CGRectMake(insets2.left, insets2.top, insets2.right, insets2.bottom))

    let UIEdgeInsetsZero: UIEdgeInsets

    var UIOffset: structUIOffset{CGFloathorizontal,vertical;}

        var offset = UIOffset()
        offset.horizontal
        offset.vertical
        return offset

        return offset1.horizontal == offset2.horizontal && offset1.vertical == offset2.vertical

    let UIOffsetZero: UIOffset

    var NSStringFromCGPoint: String

    var NSStringFromCGRect: String

    var NSStringFromCGSize: String

    var NSStringFromCGAffineTransform: String

    var NSStringFromUIEdgeInsets: String

    var NSStringFromUIOffset: String

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

    class func valueWithUIEdgeInsets(insets: UIEdgeInsets) -> NSValue {
        return NSValue(bytes: insets, objCType: )
    }

    class func valueWithUIOffset(offset: UIOffset) -> NSValue {
        return NSValue(bytes: offset, objCType: )
    }

    func CGPointValue() -> CGPoint {
        return NSPointToCGPoint(self.pointValue())
    }

    func CGRectValue() -> CGRect {
        return NSRectToCGRect(self.rectValue())
    }

    func CGSizeValue() -> CGSize {
        return NSSizeToCGSize(self.sizeValue())
    }

    func UIEdgeInsetsValue() -> UIEdgeInsets {
        if strcmp(self.objCType) == 0 {
            var insets: UIEdgeInsets
            self.getValue(insets)
            return insets
        }
        return UIEdgeInsetsZero
    }

    func UIOffsetValue() -> UIOffset {
        if strcmp(self.objCType) == 0 {
            var offset: UIOffset
            self.getValue(offset)
            return offset
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

    let UIEdgeInsetsZero: UIEdgeInsets = UIEdgeInsets()
    UIEdgeInsetsZero.0
    UIEdgeInsetsZero.0
    UIEdgeInsetsZero.0
    UIEdgeInsetsZero.0

    let UIOffsetZero: UIOffset = UIOffset()
    UIOffsetZero.0
    UIOffsetZero.0

        return NSStringFromPoint(NSPointFromCGPoint(p))

        return NSStringFromRect(NSRectFromCGRect(r))

        return NSStringFromSize(NSSizeFromCGSize(s))

        return "[\(transform.a), \(transform.b), \(transform.c), \(transform.d), \(transform.tx), \(transform.ty)]"

        return "{\(insets.top), \(insets.left), \(insets.bottom), \(insets.right)}"

        return "{\(offset.horizontal), \(offset.vertical)}"