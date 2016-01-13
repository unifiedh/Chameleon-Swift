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

enum UIActivityIndicatorViewStyle : Int {
    case WhiteLarge
    case White
    case Gray
}

class UIActivityIndicatorView: UIView {
    convenience override init(activityIndicatorStyle style: UIActivityIndicatorViewStyle) {
        var frame: CGRect = CGRectZero
        frame.size = .Size(style)
        if (self.init(frame: frame)) {
            self.animating = false
            self.activityIndicatorViewStyle = style
            self.hidesWhenStopped = true
            self.opaque = false
            self.contentMode = .Center
        }
    }

    func startAnimating() {
                    self.animating = true
            self.hidden = false
            self.performSelectorOnMainThread("_startAnimation", withObject: nil, waitUntilDone: false)

    }

    func stopAnimating() {
                    self.animating = false
            self.performSelectorOnMainThread("_stopAnimation", withObject: nil, waitUntilDone: false)

    }

    func isAnimating() -> Bool {
                    return animating

    }
    var hidesWhenStopped: Bool {
        get {
                        return hidesWhenStopped
    
        }
        set {
                        self.hidesWhenStopped = hides
                if hidesWhenStopped {
                    self.hidden = !animating
                }
                else {
                    self.hidden = false
                }
    
        }
    }

    var activityIndicatorViewStyle: UIActivityIndicatorViewStyle {
        get {
                        return activityIndicatorViewStyle
    
        }
        set {
                        if activityIndicatorViewStyle != style {
                    self.activityIndicatorViewStyle = style
                    self.setNeedsDisplay()
                    if animating != nil {
                        self.startAnimating()
                        // this will reset the images in the animation if it was already animating
                    }
                }
    
        }
    }

    var color: UIColor
    var self.animating: Bool
    var self.activityIndicatorViewStyle: UIActivityIndicatorViewStyle
    var self.hidesWhenStopped: Bool


    convenience override init(frame: CGRect) {
        if (self = self(activityIndicatorStyle: .White)) {
            self.frame = frame
        }
    }

    func sizeThatFits(aSize: CGSize) -> CGSize {
        return .Size(self.activityIndicatorViewStyle)
    }

    func _startAnimation() {
                    let numberOfFrames: Int = 12
            let animationDuration: CFTimeInterval = 0.8
            var images: [AnyObject] = [AnyObject](capacity: numberOfFrames)
            for var frameNumber = 0; frameNumber < numberOfFrames; frameNumber++ {
                images.append(UIActivityIndicatorViewFrameImage(activityIndicatorViewStyle, self.color, frameNumber, numberOfFrames, self.contentScaleFactor).CGImage as! AnyObject)
            }
            var animation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "contents")
            animation.calculationMode = kCAAnimationDiscrete
            animation.duration = animationDuration
            animation.repeatCount = HUGE_VALF
            animation.values = images
            animation.removedOnCompletion = false
            animation.fillMode = kCAFillModeBoth
            self.layer.addAnimation(animation, forKey: "contents")

    }

    func _stopAnimation() {
                    self.layer.removeAnimationForKey("contents")
            self.layer.contents = UIActivityIndicatorViewFrameImage(self.activityIndicatorViewStyle, self.color, 0, 1, self.contentScaleFactor).CGImage as! AnyObject
            if self.hidesWhenStopped {
                self.hidden = true
            }

    }

    func didMoveToWindow() {
        if !self.isAnimating {
            self._stopAnimation()
            // resets the contents to the first frame if needed
        }
    }
}
        if style == .WhiteLarge {
            return CGSizeMake(37, 37)
        }
        else {
            return CGSizeMake(20, 20)
        }

        let frameSize: CGSize = .Size(style)
        let radius: CGFloat = frameSize.width / 2.0
        let TWOPI: CGFloat = M_PI * 2.0
        let numberOfTeeth: CGFloat = 12
        let toothWidth: CGFloat = (style == .WhiteLarge) ? 3.5 : 2
        if !toothColor {
            toothColor = (style == .Gray) ? UIColor.grayColor() : UIColor.whiteColor()
        }
        UIGraphicsBeginImageContextWithOptions(frameSize, false, scale)
        var c: CGContextRef = UIGraphicsGetCurrentContext()
        // first put the origin in the center of the frame. this makes things easier later
        CGContextTranslateCTM(c, radius, radius)
        // now rotate the entire thing depending which frame we're trying to generate
        CGContextRotateCTM(c, frame / numberOfFrames as! CGFloat * TWOPI)
        // draw all the teeth
        for var toothNumber = 0; toothNumber < numberOfTeeth; toothNumber++ {
            // set the correct color for the tooth, dividing by more than the number of teeth to prevent the last tooth from being too translucent
            let alpha: CGFloat = 0.3 + ((toothNumber / numberOfTeeth) * 0.7)
            toothColor(alphaComponent: alpha).setFill()
            // position and draw the tooth
            CGContextRotateCTM(c, 1 / numberOfTeeth * TWOPI)
            UIBezierPath(roundedRect: CGRectMake(-toothWidth / 2.0, -radius, toothWidth, ceilf(radius * 0.54)), cornerRadius: toothWidth / 2.0).fill()
        }
        // hooray!
        var frameImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return frameImage