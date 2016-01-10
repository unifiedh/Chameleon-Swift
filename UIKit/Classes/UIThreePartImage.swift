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

class UIThreePartImage: UIImage {
    convenience override init(representations reps: [AnyObject], capSize: Int, vertical isVertical: Bool) {
        if (self = super._initWithRepresentations(reps)) {
            self.capSize = capSize
            self.vertical = isVertical
        }
    }
    var self.capSize: Int
    var self.vertical: Bool


    func leftCapWidth() -> Int {
        return vertical ? 0 : capSize
    }

    func topCapHeight() -> Int {
        return vertical ? capSize : 0
    }

    func _drawRepresentation(rep: UIImageRep, inRect rect: CGRect) {
        let size: CGSize = self.size
        if (vertical && size.height >= rect.size.height) || (!vertical && size.width >= rect.size.width) {
            super._drawRepresentation(rep, inRect: rect)
        }
        else if vertical {
            let stretchyHeight: CGFloat = (capSize < size.height) ? 1 : 0
            let bottomCapHeight: CGFloat = size.height - capSize - stretchyHeight
            rep.drawInRect(CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), rect.size.width, capSize), fromRect: CGRectMake(0, 0, size.width, capSize))
            rep.drawInRect(CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect) + capSize, rect.size.width, rect.size.height - capSize - bottomCapHeight), fromRect: CGRectMake(0, capSize, size.width, stretchyHeight))
            rep.drawInRect(CGRectMake(CGRectGetMinX(rect), CGRectGetMaxY(rect) - bottomCapHeight, rect.size.width, bottomCapHeight), fromRect: CGRectMake(0, size.height - bottomCapHeight, size.width, bottomCapHeight))
        }
        else {
            let stretchyWidth: CGFloat = (capSize < size.width) ? 1 : 0
            let rightCapWidth: CGFloat = size.width - capSize - stretchyWidth
            rep.drawInRect(CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), capSize, rect.size.height), fromRect: CGRectMake(0, 0, capSize, size.height))
            rep.drawInRect(CGRectMake(CGRectGetMinX(rect) + capSize, CGRectGetMinY(rect), rect.size.width - capSize - rightCapWidth, rect.size.height), fromRect: CGRectMake(capSize, 0, stretchyWidth, size.height))
            rep.drawInRect(CGRectMake(CGRectGetMinX(rect) + rect.size.width - rightCapWidth, CGRectGetMinY(rect), rightCapWidth, rect.size.height), fromRect: CGRectMake(size.width - rightCapWidth, 0, rightCapWidth, size.height))
        }

    }
}