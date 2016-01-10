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
class UIImageRep: NSObject {
    class func imageRepsWithContentsOfFile(file: String) -> [AnyObject] {
    }

    convenience override init(CGImageSource source: CGImageSourceRef, imageIndex index: Int, scale: CGFloat) {
        if !source || CGImageSourceGetCount(source) <= index {
            self = nil
        }
        else if (self.init()) {
            CFRetain(source)
            self.imageSource = source
            self.imageSourceIndex = index
            self.scale = scale
        }

    }

    convenience override init(CGImage image: CGImageRef, scale: CGFloat) {
        if !image {
            self = nil
        }
        else if (self.init()) {
            self.scale = scale
            self.CGImage = CGImageRetain(image)
        }

    }

    convenience override init(data: NSData) {
        var src: CGImageSourceRef = data ? CGImageSourceCreateWithData(data as! CFDataRef, nil) : nil
        if src != nil {
            self = self(CGImageSource: src, imageIndex: 0, scale: 1)
            CFRelease(src)
        }
        else {
            self = nil
        }
    }
    // note that the cordinates for fromRect are in the image's *scaled* coordinate system, not in raw pixels
    // so for a 100x100px image with a scale of 2, the largest valid fromRect is of size 50x50.

    func drawInRect(rect: CGRect, fromRect: CGRect) {
        var image: CGImageRef = CGImageRetain(self.CGImage)
        var ctx: CGContextRef = UIGraphicsGetCurrentContext()
        CGContextSaveGState(ctx)
        CGContextTranslateCTM(ctx, rect.origin.x, rect.origin.y + rect.size.height)
        CGContextScaleCTM(ctx, 1, -1)
        rect.origin = CGPointZero
        if CGRectIsNull(fromRect) {
            CGContextDrawImage(ctx, rect, image)
        }
        else {
            fromRect.origin.x *= scale
            fromRect.origin.y *= scale
            fromRect.size.width *= scale
            fromRect.size.height *= scale
            var tempImage: CGImageRef = CGImageCreateWithImageInRect(image, fromRect)
            CGContextDrawImage(ctx, rect, tempImage)
            CGImageRelease(tempImage)
        }
        CGContextRestoreGState(ctx)
        CGImageRelease(image)
    }
    var imageSize: CGSize {
        get {
            var size: CGSize = CGSizeZero
            if CGImage {
                size.width = CGImageGetWidth(CGImage)
                size.height = CGImageGetHeight(CGImage)
            }
            else if imageSource != nil {
                var info: CFDictionaryRef = CGImageSourceCopyPropertiesAtIndex(imageSource, imageSourceIndex, nil)
                var width: CFNumberRef = CFDictionaryGetValue(info, kCGImagePropertyPixelWidth)
                var height: CFNumberRef = CFDictionaryGetValue(info, kCGImagePropertyPixelHeight)
                if width && height {
                    CFNumberGetValue(width, kCFNumberCGFloatType, size.width)
                    CFNumberGetValue(height, kCFNumberCGFloatType, size.height)
                }
                CFRelease(info)
            }
    
            return size
        }
    }

    var CGImage: CGImageRef {
        get {
            // lazy load if we only have an image source
            if !CGImage && imageSource {
                self.CGImage = CGImageSourceCreateImageAtIndex(imageSource, imageSourceIndex, nil)
                CFRelease(imageSource)
                self.imageSource = nil
            }
            return CGImage
        }
    }

    var loaded: Bool {
        get {
            return (CGImage != nil)
        }
    }

    var scale: CGFloat {
        get {
            return self.scale
        }
    }

    var opaque: Bool {
        get {
            var opaque: Bool = false
            if CGImage {
                var info: CGImageAlphaInfo = CGImageGetAlphaInfo(CGImage)
                opaque = (info == kCGImageAlphaNone) || (info == kCGImageAlphaNoneSkipLast) || (info == kCGImageAlphaNoneSkipFirst)
            }
            else if imageSource != nil {
                var info: CFDictionaryRef = CGImageSourceCopyPropertiesAtIndex(imageSource, imageSourceIndex, nil)
                opaque = CFDictionaryGetValue(info, kCGImagePropertyHasAlpha) != kCFBooleanTrue
                CFRelease(info)
            }
    
            return opaque
        }
    }
    var self.imageSource: CGImageSourceRef
    var self.imageSourceIndex: Int
    var self.CGImage: CGImageRef


    class func _imageRepsWithContentsOfMultiResolutionFile(imagePath: String) -> [AnyObject] {
        // Note - not currently supported, but it should be easy to add in multi-resolution TIFF support here
        // just check the file type initially and if it's a TIFF with multiple scale images in there, build the
        // representations from that and return them, otherwise return nil and +imageRepsWithContentsOfFile: will
        // try looking for the old-school multi-files.
        return nil
    }

    class func _imageRepsWithContentsOfFiles(imagePath: String) -> [AnyObject] {
        var reps: [AnyObject] = [AnyObject](minimumCapacity: 2)
        var src1X: CGImageSourceRef = CreateCGImageSourceWithFile(imagePath)
        var src2X: CGImageSourceRef = CreateCGImageSourceWithFile(imagePath.stringByDeletingPathExtension().stringByAppendingString("@2x").stringByAppendingPathExtension(imagePath.pathExtension()))
        if src1X != nil {
            var rep: UIImageRep = UIImageRep(CGImageSource: src1X, imageIndex: 0, scale: 1)
            if rep != nil {
                reps.append(rep)
            }
            CFRelease(src1X)
        }
        if src2X != nil {
            var rep: UIImageRep = UIImageRep(CGImageSource: src2X, imageIndex: 0, scale: 2)
            if rep != nil {
                reps.append(rep)
            }
            CFRelease(src2X)
        }
        return (reps.count > 0) ? reps : nil
    }

    class func imageRepsWithContentsOfFile(imagePath: String) -> [AnyObject] {
        return self._imageRepsWithContentsOfMultiResolutionFile(imagePath) ?? self._imageRepsWithContentsOfFiles(imagePath)
    }

    func dealloc() {
        if CGImage {
            CGImageRelease(CGImage)
        }
        if imageSource != nil {
            CFRelease(imageSource)
        }
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

        var macPath: String = imagePath.stringByDeletingPathExtension().stringByAppendingString("~mac").stringByAppendingPathExtension(imagePath.pathExtension())
        return CGImageSourceCreateWithURL(NSURL.fileURLWithPath(macPath) as! CFURLRef, nil) ?? CGImageSourceCreateWithURL(NSURL.fileURLWithPath(imagePath) as! CFURLRef, nil)