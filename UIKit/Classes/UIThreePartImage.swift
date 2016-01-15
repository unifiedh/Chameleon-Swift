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

import Cocoa

class UIThreePartImage: UIImage {
	init(representations reps: [UIImageRep], capSize: Int, vertical isVertical: Bool) {
		self.capSize = capSize
		self.vertical = isVertical
		super.init(reps: reps)
    }
    var capSize: Int
    var vertical: Bool


    func leftCapWidth() -> Int {
        return vertical ? 0 : capSize
    }

    func topCapHeight() -> Int {
        return vertical ? capSize : 0
    }

    override func _drawRepresentation(rep: UIImageRep, inRect rect: CGRect) {
        let size: CGSize = self.size
        if (vertical && size.height >= rect.size.height) || (!vertical && size.width >= rect.size.width) {
            super._drawRepresentation(rep, inRect: rect)
        }
        else if vertical {
            let stretchyHeight: CGFloat = (CGFloat(capSize) < size.height) ? 1 : 0
            let bottomCapHeight: CGFloat = size.height - CGFloat(capSize) - stretchyHeight
            rep.drawInRect(CGRectMake(rect.minX, rect.minY, rect.size.width, CGFloat(capSize)), fromRect: CGRectMake(0, 0, size.width, CGFloat(capSize)))
            rep.drawInRect(CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect) + CGFloat(capSize), rect.size.width, rect.size.height - CGFloat(capSize) - bottomCapHeight), fromRect: CGRectMake(0, CGFloat(capSize), size.width, stretchyHeight))
            rep.drawInRect(CGRectMake(CGRectGetMinX(rect), CGRectGetMaxY(rect) - bottomCapHeight, rect.size.width, bottomCapHeight), fromRect: CGRectMake(0, size.height - bottomCapHeight, size.width, bottomCapHeight))
        }
        else {
            let stretchyWidth: CGFloat = (CGFloat(capSize) < size.width) ? 1 : 0
            let rightCapWidth: CGFloat = size.width - CGFloat(capSize) - stretchyWidth
            rep.drawInRect(CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), CGFloat(capSize), rect.size.height), fromRect: CGRectMake(0, 0, CGFloat(capSize), size.height))
            rep.drawInRect(CGRectMake(CGRectGetMinX(rect) + CGFloat(capSize), CGRectGetMinY(rect), rect.size.width - CGFloat(capSize) - rightCapWidth, rect.size.height), fromRect: CGRectMake(CGFloat(capSize), 0, stretchyWidth, size.height))
            rep.drawInRect(CGRectMake(CGRectGetMinX(rect) + rect.size.width - rightCapWidth, CGRectGetMinY(rect), rightCapWidth, rect.size.height), fromRect: CGRectMake(size.width - rightCapWidth, 0, rightCapWidth, size.height))
        }

    }
}
