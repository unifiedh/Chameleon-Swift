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

import QuartzCore

class UIImageView: UIView {
    convenience override init(image theImage: UIImage) {
        var frame: CGRect = CGRectZero
        if theImage {
            frame.size = theImage.size
        }
        if (self = self(frame: frame)) {
            self.image = theImage
        }
    }

    func startAnimating() {
        var images: [AnyObject] = highlighted ? highlightedAnimationImages : animationImages
        var animation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "contents")
        animation.calculationMode = kCAAnimationDiscrete
        animation.duration = self.animationDuration ?? (images.count * (1 / 30.0))
        animation.repeatCount = self.animationRepeatCount ?? HUGE_VALF
        animation.values = CGImagesWithUIImages(images)
        animation.removedOnCompletion = false
        animation.fillMode = kCAFillModeBoth
        self.layer.addAnimation(animation, forKey: "contents")
    }

    func stopAnimating() {
        self.layer.removeAnimationForKey("contents")
    }

    func isAnimating() -> Bool {
        return (self.layer(animationForKey: "contents") != nil)
    }
    var highlightedImage: UIImage {
        get {
            return self.highlightedImage
        }
        set {
            if highlightedImage != newImage {
                self.highlightedImage = newImage!
                if highlighted {
                    self.setNeedsDisplay()
                }
            }
        }
    }

    var highlighted: Bool {
        get {
            return self.highlighted
        }
        set {
            if h != highlighted {
                self.highlighted = h
                self.setNeedsDisplay()
                if self.isAnimating() {
                    self.startAnimating()
                }
            }
        }
    }

    var image: UIImage {
        get {
            return self.image
        }
        set {
            if image != newImage {
                self.image = newImage!
                if !highlighted || !highlightedImage {
                    self.setNeedsDisplay()
                }
            }
        }
    }

    var animationImages: [AnyObject]
    var highlightedAnimationImages: [AnyObject]
    var animationDuration: NSTimeInterval
    var animationRepeatCount: Int
    var self.drawMode: _UIImageViewDrawMode


    class func _instanceImplementsDrawRect() -> Bool {
        return false
    }

    convenience override init(frame: CGRect) {
        if (self.init(frame: frame)) {
            self.drawMode = UIImageViewDrawModeNormal
            self.userInteractionEnabled = false
            self.opaque = false
        }
    }

    func sizeThatFits(size: CGSize) -> CGSize {
        return image ? image.size : CGSizeZero
    }

    func _hasResizableImage() -> Bool {
        return (image.topCapHeight > 0 || image.leftCapWidth > 0)
    }

    func _setDrawMode(drawMode: _UIImageViewDrawMode) {
        if drawMode != drawMode {
            self.drawMode = drawMode
            self.setNeedsDisplay()
        }
    }

    func displayLayer(theLayer: CALayer) {
        super.displayLayer(theLayer)
        var displayImage: UIImage = (highlighted && highlightedImage) ? highlightedImage : image
        let scale: CGFloat = self.window.screen.scale
        let bounds: CGRect = self.bounds
        if displayImage && self.hasResizableImage && bounds.size.width > 0 && bounds.size.height > 0 {
            UIGraphicsBeginImageContextWithOptions(bounds.size, false, scale)
            displayImage.drawInRect(bounds)
            displayImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        // adjust the image if required.
        // this will likely only ever be used UIButton, but it seemed a good place for it.
        // I wonder how the real UIKit does this...
        if displayImage && (drawMode != UIImageViewDrawModeNormal) {
            var imageBounds: CGRect
            imageBounds.origin = CGPointZero
            imageBounds.size = displayImage.size
            UIGraphicsBeginImageContextWithOptions(imageBounds.size, false, scale)
            var blendMode: CGBlendMode = kCGBlendModeNormal
            var alpha: CGFloat = 1
            if drawMode == UIImageViewDrawModeDisabled {
                alpha = 0.5
            }
            else if drawMode == UIImageViewDrawModeHighlighted {
                UIColor.blackColor()(alphaComponent: 0.4).setFill()
                UIRectFill(imageBounds)
                blendMode = kCGBlendModeDestinationAtop
            }

            displayImage.drawInRect(imageBounds, blendMode: blendMode, alpha: alpha)
            displayImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        var bestRepresentation: UIImageRep = displayImage._bestRepresentationForProposedScale(scale)
        theLayer.contents = bestRepresentation.CGImage as! AnyObject
        if theLayer.respondsToSelector("setContentsScale:") {
            theLayer.contentsScale = bestRepresentation.scale
        }
    }

    func _displayIfNeededChangingFromOldSize(oldSize: CGSize, toNewSize newSize: CGSize) {
        if !CGSizeEqualToSize(newSize, oldSize) && self.hasResizableImage {
            self.setNeedsDisplay()
        }
    }

    func setFrame(newFrame: CGRect) {
        self._displayIfNeededChangingFromOldSize(self.frame.size, toNewSize: newFrame.size)
        super.frame = newFrame
    }

    func setBounds(newBounds: CGRect) {
        self._displayIfNeededChangingFromOldSize(self.bounds.size, toNewSize: newBounds.size)
        super.bounds = newBounds
    }
}
        var CGImages: [AnyObject] = [AnyObject](minimumCapacity: images.count)
        for img: UIImage in images {
            CGImages.append(img.CGImage as! AnyObject)
        }
        return CGImages