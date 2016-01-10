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
import ApplicationServices
    var UIGraphicsPushContext

    var UIGraphicsPopContext

    var UIGraphicsGetCurrentContext: CGContextRef

    var self.UIGraphicsGetContextScaleFactor: CGFloat

    var UIGraphicsBeginImageContextWithOptions

    var UIGraphicsBeginImageContext

    var UIGraphicsGetImageFromCurrentImageContext: UIImage

    var UIGraphicsEndImageContext

    var UIRectClip

    var UIRectFill

    var UIRectFillUsingBlendMode

    var UIRectFrame

    var UIRectFrameUsingBlendMode

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
    var contextStack: [AnyObject]? = nil

    var imageContextStack: [AnyObject]? = nil

        if !contextStack {
            contextStack = [AnyObject](capacity: 1)
        }
        if NSGraphicsContext.currentContext() {
            contextStack!.append(NSGraphicsContext.currentContext())
        }
        NSGraphicsContext.currentContext = NSGraphicsContext.graphicsContextWithGraphicsPort(ctx as! Void, flipped: true)

        if contextStack!.lastObject() {
            NSGraphicsContext.currentContext = contextStack!.lastObject()
            contextStack!.removeLastObject()
        }

        return NSGraphicsContext.currentContext().graphicsPort()

        let rect: CGRect = CGContextGetClipBoundingBox(ctx)
        let deviceRect: CGRect = CGContextConvertRectToDeviceSpace(ctx, rect)
        let scale: CGFloat = deviceRect.size.height / rect.size.height
        return scale

        if scale == 0.0 {
            scale = UIScreen.mainScreen().scale ?? 1
        }
        let width: size_t = size.width * scale
        let height: size_t = size.height * scale
        if width > 0 && height > 0 {
            if !imageContextStack {
                imageContextStack = [AnyObject](capacity: 1)
            }
            imageContextStack!.append(Int(scale))
            var colorSpace: CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()
            var ctx: CGContextRef = CGBitmapContextCreate(nil, width, height, 8, 4 * width, colorSpace, (opaque ? kCGImageAlphaNoneSkipFirst : kCGImageAlphaPremultipliedFirst))
            CGContextConcatCTM(ctx, CGAffineTransformMake(1, 0, 0, -1, 0, height))
            CGContextScaleCTM(ctx, scale, scale)
            CGColorSpaceRelease(colorSpace)
            UIGraphicsPushContext(ctx)
            CGContextRelease(ctx)
        }

        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)

        if imageContextStack!.lastObject() {
            let scale: CGFloat = CFloat(imageContextStack!.lastObject())!
            var theCGImage: CGImageRef = CGBitmapContextCreateImage(UIGraphicsGetCurrentContext())
            var image: UIImage = UIImage.imageWithCGImage(theCGImage, scale: scale, orientation: .Up)
            CGImageRelease(theCGImage)
            return image
        }
        else {
            return nil
        }

        if imageContextStack!.lastObject() {
            imageContextStack!.removeLastObject()
            UIGraphicsPopContext()
        }

        CGContextClipToRect(UIGraphicsGetCurrentContext(), rect)

        UIRectFillUsingBlendMode(rect, kCGBlendModeCopy)

        var c: CGContextRef = UIGraphicsGetCurrentContext()
        CGContextSaveGState(c)
        CGContextSetBlendMode(c, blendMode)
        CGContextFillRect(c, rect)
        CGContextRestoreGState(c)

        CGContextStrokeRect(UIGraphicsGetCurrentContext(), rect)

        var c: CGContextRef = UIGraphicsGetCurrentContext()
        CGContextSaveGState(c)
        CGContextSetBlendMode(c, blendMode)
        UIRectFrame(rect)
        CGContextRestoreGState(c)