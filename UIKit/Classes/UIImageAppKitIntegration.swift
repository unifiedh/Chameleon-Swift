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

extension UIImage {
    convenience init(theImage: NSImage) {
        return self(NSImage: theImage)
    }

    convenience override init(NSImage theImage: NSImage) {
        var rect1X: NSRect = NSMakeRect(0, 0, theImage.size().width, theImage.size().height)
        var rect2X: NSRect = NSMakeRect(0, 0, theImage.size().width * 2, theImage.size().height * 2)
        var theImageRep1X: NSImageRep = theImage.bestRepresentationForRect(rect1X, context: nil, hints: nil)
        var theImageRep2X: NSImageRep = theImage.bestRepresentationForRect(rect2X, context: nil, hints: nil)
        if theImageRep1X == theImageRep2X {
            theImageRep2X = nil
        }
        var rep1: UIImageRep = UIImageRepFromNSImageRep(theImageRep1X, rect1X, 1)
        var rep2: UIImageRep = UIImageRepFromNSImageRep(theImageRep2X, rect2X, 2)
        var reps: [AnyObject] = [AnyObject](minimumCapacity: 2)
        if rep1 != nil {
            reps.append(rep1)
        }
        if rep2 != nil {
            reps.append(rep2)
        }
        return self._initWithRepresentations(reps)
    }

    func NSImage() -> NSImage {
        var cached: NSImage = objc_getAssociatedObject(self, UIImageAssociatedNSImageKey)
        if !cached {
            cached = NSImage(size: NSSizeFromCGSize(self.size))
            for rep: UIImageRep in self._representations() {
                cached.addRepresentation(NSBitmapImageRep(CGImage: rep.CGImage))
            }
            objc_setAssociatedObject(self, UIImageAssociatedNSImageKey, cached, OBJC_ASSOCIATION_RETAIN)
        }
        return cached
    }
    /*
     this is a hack to support screen scale factor changes (retina) which iOS doesn't
     have a decent way to support as far as I can tell.
     
     these will build a UIImage object from multiple source UIImages that are already
     at different scales and when the resulting UIImage is drawn, it should choose the
     correct one based on the scale of the underlying context at the time it is drawn.
     
     pass an array of UIImage objects at different scales that represent the same image.
     
     each image must have a different .scale property value, no duplicates allowed!
     
     each image must be the same size as compared to the others:
     - eg: <scale=2, size=100x100> and <scale=1, size=50x50>
     
     NOTE: internally, UIImage already loads both @1x and @2x versions of image files if
     they are present (-initWithNSImage: does something similar), so for the most part you
     probably don't need this. the primary purpose of this is if you are custom drawing
     something using something like UIGraphicsBeginImageContext() and don't know what the
     scale factor of the window might currently be now or in the future.
     
     EXAMPLE:
     
     // render @1x
     UIGraphicsBeginImageContextWithOptions(size, NO, 1);
     .. draw stuff ..
     UIImage *image1x = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
     
     // render @2x
     UIGraphicsBeginImageContextWithOptions(size, NO, 2);
     .. draw stuff ..
     UIImage *image2x = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
     
     // put them together
     UIImage *finalImage = [UIImage imageWithScaledImages:@[image1, image2]];
     */

    convenience init(images: [AnyObject]) {
        return self(scaledImages: images)
    }

    convenience override init(scaledImages images: [AnyObject]) {
        var reps: [AnyObject] = [AnyObject](minimumCapacity: images.count)
        var scaleFactors: NSMutableSet = NSMutableSet.setWithCapacity(images.count)
        for img: UIImage in images {
            var scale: Int = Int(img.scale)
            assert(CGSizeEqualToSize(img.size, images.lastObject().size()))
            assert(!scaleFactors.containsObject(scale))
            scaleFactors.append(scale)
            reps.append(UIImageRep(CGImage: img.CGImage, scale: img.scale))
        }
        return self._initWithRepresentations(reps)
    }
}
    let UIImageAssociatedNSImageKey: Character = "UIImageAssociatedNSImageKey"

        return UIImageRep(CGImage: rep.CGImageForProposedRect(rect, context: nil, hints: nil), scale: scale)