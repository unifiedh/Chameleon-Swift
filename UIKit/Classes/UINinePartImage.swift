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

class UINinePartImage: UIImage {
    convenience override init(representations reps: [AnyObject], leftCapWidth: Int, topCapHeight: Int) {
        if (self = super._initWithRepresentations(reps)) {
            self.leftCapWidth = leftCapWidth
            self.topCapHeight = topCapHeight
        }
    }
    var self.leftCapWidth: Int
    var self.topCapHeight: Int


    func leftCapWidth() -> Int {
        return leftCapWidth
    }

    func topCapHeight() -> Int {
        return topCapHeight
    }

    func _drawRepresentation(rep: UIImageRep, inRect rect: CGRect) {
        let size: CGSize = self.size
        let stretchyWidth: CGFloat = (leftCapWidth < size.width) ? 1 : 0
        let stretchyHeight: CGFloat = (topCapHeight < size.height) ? 1 : 0
        let bottomCapHeight: CGFloat = size.height - topCapHeight - stretchyHeight
        let rightCapWidth: CGFloat = size.width - leftCapWidth - stretchyWidth
        //topLeftCorner
        rep.drawInRect(CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), leftCapWidth, topCapHeight), fromRect: CGRectMake(0, 0, leftCapWidth, topCapHeight))
        //topEdgeFill
        rep.drawInRect(CGRectMake(CGRectGetMinX(rect) + leftCapWidth, CGRectGetMinY(rect), rect.size.width - rightCapWidth - leftCapWidth, topCapHeight), fromRect: CGRectMake(leftCapWidth, 0, stretchyWidth, topCapHeight))
        //topRightCorner
        rep.drawInRect(CGRectMake(CGRectGetMaxX(rect) - rightCapWidth, CGRectGetMinY(rect), rightCapWidth, topCapHeight), fromRect: CGRectMake(size.width - rightCapWidth, 0, rightCapWidth, topCapHeight))
        //bottomLeftCorner
        rep.drawInRect(CGRectMake(CGRectGetMinX(rect), CGRectGetMaxY(rect) - bottomCapHeight, leftCapWidth, bottomCapHeight), fromRect: CGRectMake(0, size.height - bottomCapHeight, leftCapWidth, bottomCapHeight))
        //bottomEdgeFill
        rep.drawInRect(CGRectMake(CGRectGetMinX(rect) + leftCapWidth, CGRectGetMaxY(rect) - bottomCapHeight, rect.size.width - rightCapWidth - leftCapWidth, bottomCapHeight), fromRect: CGRectMake(leftCapWidth, size.height - bottomCapHeight, stretchyWidth, bottomCapHeight))
        //bottomRightCorner
        rep.drawInRect(CGRectMake(CGRectGetMaxX(rect) - rightCapWidth, CGRectGetMaxY(rect) - bottomCapHeight, rightCapWidth, bottomCapHeight), fromRect: CGRectMake(size.width - rightCapWidth, size.height - bottomCapHeight, rightCapWidth, bottomCapHeight))
        //leftEdgeFill
        rep.drawInRect(CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect) + topCapHeight, leftCapWidth, rect.size.height - bottomCapHeight - topCapHeight), fromRect: CGRectMake(0, topCapHeight, leftCapWidth, stretchyHeight))
        //rightEdgeFill
        rep.drawInRect(CGRectMake(CGRectGetMaxX(rect) - rightCapWidth, CGRectGetMinY(rect) + topCapHeight, rightCapWidth, rect.size.height - bottomCapHeight - topCapHeight), fromRect: CGRectMake(size.width - rightCapWidth, topCapHeight, rightCapWidth, stretchyHeight))
        //centerFill
        rep.drawInRect(CGRectMake(CGRectGetMinX(rect) + leftCapWidth, CGRectGetMinY(rect) + topCapHeight, rect.size.width - rightCapWidth - leftCapWidth, rect.size.height - bottomCapHeight - topCapHeight), fromRect: CGRectMake(leftCapWidth, topCapHeight, stretchyWidth, stretchyHeight))
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