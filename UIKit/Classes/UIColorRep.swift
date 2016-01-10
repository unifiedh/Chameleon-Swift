/*
 * Copyright (c) 2012, The Iconfactory. All rights reserved.
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
class UIColorRep: NSObject {
    convenience override init(patternImageRepresentation patternImageRep: UIImageRep) {
        if !patternImageRep {
            self = nil
        }
        else if (self.init()) {
            self.patternImageRep = patternImageRep
        }

    }

    convenience override init(CGColor color: CGColorRef) {
        if !color {
            self = nil
        }
        else if (self.init()) {
            self.CGColor = CGColorRetain(color)
        }

    }
    var CGColor: CGColorRef {
        get {
            if !CGColor && patternImageRep {
                let imageSize: CGSize = patternImageRep.imageSize
                let scaler: CGFloat = 1 / patternImageRep.scale
                //const CGAffineTransform t = CGAffineTransformScale(CGAffineTransformMake(1, 0, 0, -1, 0, imageSize.height), scaler, scaler);
                let t: CGAffineTransform = CGAffineTransformMakeScale(scaler, scaler)
                let callbacks: CGPatternCallbacks = CGPatternCallbacks()
                callbacks.0
                callbacks.drawPatternImage
                callbacks.nil
                var pattern: CGPatternRef = CGPatternCreate(self as! Void, CGRectMake(0, 0, imageSize.width, imageSize.height), t, imageSize.width, imageSize.height, kCGPatternTilingConstantSpacing, true, callbacks)
                var space: CGColorSpaceRef = CGColorSpaceCreatePattern(nil)
                var components: CGFloat = CGFloat()
                components.1.0
                self.CGColor = CGColorCreateWithPattern(space, pattern, components)
                CGColorSpaceRelease(space)
                CGPatternRelease(pattern)
            }
            return CGColor
        }
    }

    var scale: CGFloat {
        get {
            return patternImageRep ? patternImageRep.scale : 1
        }
    }

    var patternImageRep: UIImageRep {
        get {
            return self.patternImageRep
        }
    }

    var opaque: Bool {
        get {
            if !patternImageRep && CGColor {
                return CGColorGetAlpha(CGColor) == 1
            }
            else {
                return patternImageRep.opaque
            }
        }
    }
    var self.CGColor: CGColorRef


    func dealloc() {
        CGColorRelease(self.CGColor)
    }
}
/*
 * Copyright (c) 2012, The Iconfactory. All rights reserved.
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
import UIKit
        var rep: UIImageRep = info as! UIColorRep.patternImageRep()
        UIGraphicsPushContext(ctx)
        CGContextSaveGState(ctx)
        let patternRect: CGRect = CGRect()
        patternRect.CGPointZero
        patternRect.rep.imageSize
        let deviceRect: CGRect = CGContextConvertRectToDeviceSpace(ctx, patternRect)
        // this attempts to detect a flipped context and then counter-flips it.
        // I don't like this because it seems like it shouldn't be necessary and that I'm missing something more fundamental.
        // If a pattern color is used as a backgroundColor on a UIView with no drawRect:, it will set the backgrounColor of
        // the view's layer directly with the CGColor (which is made from this pattern image). In that case, the pattern
        // appears flipped for reasons I don't fully understand unless I apply this counter-flip transform. If the UIView does
        // have a drawRect:, then the different way that the background color is set (UIView draws it directly into the
        // CGContext that Core Animation gives it before calling drawRect:), causes the pattern to appear right-side-up.
        if floorf(NSAppKitVersionNumber) != NSAppKitVersionNumber10_7 {
            if CGPointEqualToPoint(patternRect.origin, deviceRect.origin) {
                CGContextTranslateCTM(ctx, 0, patternRect.size.height)
                CGContextScaleCTM(ctx, 1, -1)
            }
        }
        rep.drawInRect(patternRect, fromRect: CGRectNull)
        CGContextRestoreGState(ctx)
        UIGraphicsPopContext()