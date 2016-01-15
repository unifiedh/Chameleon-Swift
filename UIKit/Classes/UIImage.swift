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

enum UIImageOrientation : Int {
    case Up
    case Down
    // 180 deg rotation
    case Left
    // 90 deg CCW
    case Right
    // 90 deg CW
    case UpMirrored
    // as above but image mirrored along
    // other axis. horizontal flip
    case DownMirrored
    // horizontal flip
    case LeftMirrored
    // vertical flip
    case RightMirrored
}

public class UIImage: NSObject {
	
	init?(reps: [UIImageRep]) {
		if reps.count == 0 {
			return nil
		}
		self.representations = reps
		super.init()
	}

    var representations = [UIImageRep]()

    convenience init(name: String) {
        var img: UIImage = self._cachedImageForName(name)
        if !img {
            // as per the iOS docs, if it fails to find a match with the bare name, it re-tries by appending a png file extension
            img = self._imageNamed(name) ?? self._imageNamed(name.stringByAppendingPathExtension("png"))
            self._cacheImage(img, forName: name)
        }
        return img
    }
    // Note, this caches the images somewhat like iPhone OS 2ish in that it never releases them. :)

    convenience init?(data: NSData) {
		self.init(reps: [UIImageRep(data: data)])
    }

    convenience init(contentsOfFile path: String) {
    }

    convenience init(CGImage imageRef: CGImageRef) {
		self.init(CGImage: imageRef, scale: 1, orientation: .Up)
    }

    convenience override init(CGImage imageRef: CGImageRef, scale: CGFloat, orientation: UIImageOrientation) {
        return self._initWithRepresentations([UIImageRep(CGImage: imageRef, scale: scale)])
    }

    func stretchableImageWithLeftCapWidth(leftCapWidth: Int, topCapHeight: Int) -> UIImage {
        let size: CGSize = self.size
        if (leftCapWidth == 0 && topCapHeight == 0) || (leftCapWidth >= size.width && topCapHeight >= size.height) {

        }
        else if leftCapWidth <= 0 || leftCapWidth >= size.width {
            return UIThreePartImage(representations: self._representations(), capSize: min(topCapHeight, size.height), vertical: true)
        }
        else if topCapHeight <= 0 || topCapHeight >= size.height {
            return UIThreePartImage(representations: self._representations(), capSize: min(leftCapWidth, size.width), vertical: false)
        }
        else {
            return UINinePartImage(representations: self._representations(), leftCapWidth: leftCapWidth, topCapHeight: topCapHeight)
        }

    }

    func resizableImageWithCapInsets(capInsets: UIEdgeInsets) -> UIImage {
        return self.stretchableImageWithLeftCapWidth(capInsets.left, topCapHeight: capInsets.top)
    }
    // not correctly implemented
    // the draw methods will all check the scale of the current context and attempt to use the best representation it can

    func drawAtPoint(point: CGPoint, blendMode: CGBlendMode, alpha: CGFloat) {
        self.drawInRect(CGRect()
        rect.point
        rect.self.size, blendMode: blendMode, alpha: alpha)
    }

    func drawInRect(rect: CGRect, blendMode: CGBlendMode, alpha: CGFloat) {
        var ctx: CGContextRef = UIGraphicsGetCurrentContext()
        CGContextSaveGState(ctx)
        CGContextSetBlendMode(ctx, blendMode)
        CGContextSetAlpha(ctx, alpha)
        self.drawInRect(rect)
        CGContextRestoreGState(ctx)
    }

    func drawAtPoint(point: CGPoint) {
        self.drawInRect(CGRect()
        rect.point
        rect.self.size)
    }

    func drawInRect(rect: CGRect) {
        if rect.size.height > 0 && rect.size.width > 0 {
            self._drawRepresentation(self._bestRepresentationForProposedScale(UIGraphicsGetContextScaleFactor(UIGraphicsGetCurrentContext())), inRect: rect)
        }
    }
    var size: CGSize {
        get {
            var size: CGSize = CGSizeZero
            var rep: UIImageRep = representations.lastObject()
            let repSize: CGSize = rep.imageSize
            let scale: CGFloat = rep.scale
            size.width = floorf(repSize.width / scale)
            size.height = floorf(repSize.height / scale)
            return size
        }
    }

    var leftCapWidth: Int {
        get {
            return 0
        }
    }

    var topCapHeight: Int {
        get {
            return 0
        }
    }

    var imageOrientation: UIImageOrientation {
        get {
            return .Up
        }
    }

    // not implemented
    // note that these properties return always the 2x represention if it exists!
    var CGImage: CGImageRef {
        get {
            return self._bestRepresentationForProposedScale(2).CGImage
        }
    }

    var scale: CGFloat {
        get {
            return self._bestRepresentationForProposedScale(2).scale
        }
    }

    class func _imageNamed(name: String) -> UIImage {
        var bundle: NSBundle = NSBundle.mainBundle()
        var path: String = bundle.resourcePath().stringByAppendingPathComponent(name)
        var img: UIImage = self.imageWithContentsOfFile(path)!
        if !img {
            // if nothing is found, try again after replacing any underscores in the name with dashes.
            // I don't know why, but UIKit does something similar. it probably has a good reason and it might not be this simplistic, but
            // for now this little hack makes Ramp Champ work. :)
            path = bundle.resourcePath().stringByAppendingPathComponent(name.stringByDeletingPathExtension().stringByReplacingOccurrencesOfString("_", withString: "-")).stringByAppendingPathExtension(name.pathExtension())
            img = self.imageWithContentsOfFile(path)!
        }
        return img
    }

    convenience override init(contentsOfFile imagePath: String) {
        return self._initWithRepresentations(UIImageRep.imageRepsWithContentsOfFile(imagePath))
    }
}
    var UIImageWriteToSavedPhotosAlbum

    var UISaveVideoAtPathToSavedPhotosAlbum

    var UIVideoAtPathIsCompatibleWithSavedPhotosAlbum: Bool

// both of these use .CGImage to generate the image data - note what this means for multi-scale images!
    var UIImageJPEGRepresentation: NSData

    var UIImagePNGRepresentation: NSData


        UIPhotosAlbum.sharedPhotosAlbum().writeImage(image, completionTarget: completionTarget, action: completionSelector, context: contextInfo)

        return false

        image, CGFloat

    var data: CFMutableDataRef = CFDataCreateMutable(nil, 0)

    var dest: CGImageDestinationRef = CGImageDestinationCreateWithData(data, kUTTypeJPEG, 1, nil)

        CGImage, 
        var CFDictionaryRef): __bridge
                                compressionQuality

        CGImageDestinationFinalize(dest)
        CFRelease(dest)
        return data as! __bridge_transfer NSMutableData

        var data: CFMutableDataRef = CFDataCreateMutable(nil, 0)
        var dest: CGImageDestinationRef = CGImageDestinationCreateWithData(data, kUTTypePNG, 1, nil)
        CGImageDestinationAddImage(dest, image.CGImage, nil)
        CGImageDestinationFinalize(dest)
        CFRelease(dest)
        return data as! __bridge_transfer NSMutableData