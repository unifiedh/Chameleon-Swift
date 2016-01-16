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

import CoreGraphics
import Foundation

final class UINinePartImage: UIImage {
    init?(representations reps: [UIImageRep], leftCapWidth: Int, topCapHeight: Int) {
		lcw = leftCapWidth
		tch = topCapHeight
		super.init(reps: reps)
    }
	private let lcw: Int
	private let tch: Int
	override var leftCapWidth: Int {
		get {
			return lcw
		}
	}
	override var topCapHeight: Int {
		get {
			return tch
		}
	}

    override func _drawRepresentation(rep: UIImageRep, inRect rect: CGRect) {
        let size: CGSize = self.size
        let stretchyWidth: CGFloat = (CGFloat(leftCapWidth) < size.width) ? 1 : 0
        let stretchyHeight: CGFloat = (CGFloat(topCapHeight) < size.height) ? 1 : 0
        let bottomCapHeight: CGFloat = size.height - CGFloat(topCapHeight) - stretchyHeight
        let rightCapWidth: CGFloat = size.width - CGFloat(leftCapWidth) - stretchyWidth
        //topLeftCorner
        rep.drawInRect(CGRect(x: rect.minX, y: rect.minY, width: CGFloat(leftCapWidth), height: CGFloat(topCapHeight)), fromRect: CGRect(x: 0, y: 0, width: CGFloat(leftCapWidth), height: CGFloat(topCapHeight)))
        //topEdgeFill
        rep.drawInRect(CGRect(x: rect.minX + CGFloat(leftCapWidth), y: rect.minY, width: rect.width - rightCapWidth - CGFloat(leftCapWidth), height: CGFloat(topCapHeight)), fromRect: CGRect(x: CGFloat(leftCapWidth), y: 0, width: stretchyWidth, height: CGFloat(topCapHeight)))
        //topRightCorner
        rep.drawInRect(CGRect(x: rect.maxX - rightCapWidth, y: rect.minY, width: rightCapWidth, height: CGFloat(topCapHeight)), fromRect: CGRect(x: size.width - rightCapWidth, y: 0, width: rightCapWidth, height: CGFloat(topCapHeight)))
        //bottomLeftCorner
        rep.drawInRect(CGRect(x: rect.minX, y: rect.maxY - bottomCapHeight, width: CGFloat(leftCapWidth), height: bottomCapHeight), fromRect: CGRect(x: 0, y: size.height - bottomCapHeight, width: CGFloat(leftCapWidth), height: bottomCapHeight))
        //bottomEdgeFill
        rep.drawInRect(CGRect(x: rect.minX + CGFloat(leftCapWidth), y: rect.maxY - bottomCapHeight, width: rect.width - rightCapWidth - CGFloat(leftCapWidth), height: bottomCapHeight), fromRect: CGRect(x: CGFloat(leftCapWidth), y: size.height - bottomCapHeight, width: stretchyWidth, height: bottomCapHeight))
        //bottomRightCorner
        rep.drawInRect(CGRect(x: rect.maxX - rightCapWidth, y: rect.maxY - bottomCapHeight, width: rightCapWidth, height: bottomCapHeight), fromRect: CGRect(x: size.width - rightCapWidth, y: size.height - bottomCapHeight, width: rightCapWidth, height: bottomCapHeight))
        //leftEdgeFill
        rep.drawInRect(CGRect(x: rect.minX, y: rect.minY + CGFloat(topCapHeight), width: CGFloat(leftCapWidth), height: rect.height - bottomCapHeight - CGFloat(topCapHeight)), fromRect: CGRect(x: 0, y: CGFloat(topCapHeight), width: CGFloat(leftCapWidth), height: stretchyHeight))
        //rightEdgeFill
        rep.drawInRect(CGRect(x: rect.maxX - rightCapWidth, y: rect.minY + CGFloat(topCapHeight), width: rightCapWidth, height: rect.height - bottomCapHeight - CGFloat(topCapHeight)), fromRect: CGRect(x: size.width - rightCapWidth, y: CGFloat(topCapHeight), width: rightCapWidth, height: stretchyHeight))
        //centerFill
        rep.drawInRect(CGRect(x: rect.minX + CGFloat(leftCapWidth), y: rect.minY + CGFloat(topCapHeight), width: rect.width - rightCapWidth - CGFloat(leftCapWidth), height: rect.height - bottomCapHeight - CGFloat(topCapHeight)), fromRect: CGRect(x: CGFloat(leftCapWidth), y: CGFloat(topCapHeight), width: stretchyWidth, height: stretchyHeight))
    }
}
