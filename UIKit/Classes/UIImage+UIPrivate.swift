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

extension UIImage {
    class func _cacheImage(image: UIImage, forName name: String) {
        if image && name {
            imageCache![name] = image
        }
    }

    class func _cachedImageForName(name: String) -> UIImage {
        return (imageCache![name] as! String)
    }

    class func _backButtonImage() -> UIImage {
        return self._frameworkImageWithName("<UINavigationBar> back.png", leftCapWidth: 18, topCapHeight: 0)
    }

    class func _highlightedBackButtonImage() -> UIImage {
        return self._frameworkImageWithName("<UINavigationBar> back-highlighted.png", leftCapWidth: 18, topCapHeight: 0)
    }

    class func _toolbarButtonImage() -> UIImage {
        return self._frameworkImageWithName("<UIToolbar> button.png", leftCapWidth: 6, topCapHeight: 0)
    }

    class func _highlightedToolbarButtonImage() -> UIImage {
        return self._frameworkImageWithName("<UIToolbar> button-highlighted.png", leftCapWidth: 6, topCapHeight: 0)
    }

    class func _leftPopoverArrowImage() -> UIImage {
        return self._frameworkImageWithName("<UIPopoverView> arrow-left.png", leftCapWidth: 0, topCapHeight: 0)
    }

    class func _rightPopoverArrowImage() -> UIImage {
        return self._frameworkImageWithName("<UIPopoverView> arrow-right.png", leftCapWidth: 0, topCapHeight: 0)
    }

    class func _topPopoverArrowImage() -> UIImage {
        return self._frameworkImageWithName("<UIPopoverView> arrow-top.png", leftCapWidth: 0, topCapHeight: 0)
    }

    class func _bottomPopoverArrowImage() -> UIImage {
        return self._frameworkImageWithName("<UIPopoverView> arrow-bottom.png", leftCapWidth: 0, topCapHeight: 0)
    }

    class func _popoverBackgroundImage() -> UIImage {
        return self._frameworkImageWithName("<UIPopoverView> background.png", leftCapWidth: 23, topCapHeight: 23)
    }

    class func _roundedRectButtonImage() -> UIImage {
        return self._frameworkImageWithName("<UIRoundedRectButton> normal.png", leftCapWidth: 12, topCapHeight: 9)
    }

    class func _highlightedRoundedRectButtonImage() -> UIImage {
        return self._frameworkImageWithName("<UIRoundedRectButton> highlighted.png", leftCapWidth: 12, topCapHeight: 9)
    }

    class func _windowResizeGrabberImage() -> UIImage {
        return self._frameworkImageWithName("<UIScreen> grabber.png", leftCapWidth: 0, topCapHeight: 0)
    }

    class func _buttonBarSystemItemAdd() -> UIImage {
        return self._frameworkImageWithName("<UIBarButtonSystemItem> add.png", leftCapWidth: 0, topCapHeight: 0)
    }

    class func _buttonBarSystemItemReply() -> UIImage {
        return self._frameworkImageWithName("<UIBarButtonSystemItem> reply.png", leftCapWidth: 0, topCapHeight: 0)
    }

    class func _tabBarBackgroundImage() -> UIImage {
        return self._frameworkImageWithName("<UITabBar> background.png", leftCapWidth: 6, topCapHeight: 0)
    }

    class func _tabBarItemImage() -> UIImage {
        return self._frameworkImageWithName("<UITabBar> item.png", leftCapWidth: 8, topCapHeight: 0)
    }

    convenience override init(reps: [AnyObject]) {
        if reps.count == 0 {
            self = nil
        }
        else if (self.init()) {
            self.representations = reps.copy()
        }

    }

    func _bestRepresentationForProposedScale(scale: CGFloat) -> UIImageRep {
        var bestRep: UIImageRep? = nil
        for rep: UIImageRep in self._representations() {
            if rep.scale > scale {

            }
            else {
                bestRep = rep
            }
        }
        return bestRep ?? self._representations().lastObject()
    }

    func _drawRepresentation(rep: UIImageRep, inRect rect: CGRect) {
        rep.drawInRect(rect, fromRect: CGRectNull)
    }

    func _representations() -> [AnyObject] {
        return representations
    }

    func _isOpaque() -> Bool {
        for rep: UIImageRep in self._representations() {
            if !rep.opaque {
                return false
            }
        }
        return true
    }

    func _toolbarImage() -> UIImage {
        // NOTE.. I don't know where to put this, really, but it seems like the real UIKit reduces image size by 75% if they are too
        // big for a toolbar. That seems funky, but I guess here is as good a place as any to do that? I don't really know...
        var imageSize: CGSize = self.size
        var size: CGSize = CGSizeZero
        if imageSize.width > 24 || imageSize.height > 24 {
            size.height = imageSize.height * 0.75
            size.width = imageSize.width / imageSize.height * size.height
        }
        else {
            size = imageSize
        }
        var rect: CGRect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        UIColor(red: 101 / 255.0, green: 104 / 255.0, blue: 121 / 255.0, alpha: 1).setFill()
        UIRectFill(rect)
        self.drawInRect(rect, blendMode: kCGBlendModeDestinationIn, alpha: 1)
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    class func load() {
        imageCache = [NSObject : AnyObject]()
    }

    class func _frameworkImageWithName(name: String, leftCapWidth: Int, topCapHeight: Int) -> UIImage {
        var image: UIImage = self._cachedImageForName(name)
        if !image {
            var frameworkBundle: NSBundle = NSBundle.bundleWithIdentifier("org.chameleonproject.UIKit")
            var frameworkFile: String = frameworkBundle.resourcePath().stringByAppendingPathComponent(name)
            image = self.imageWithContentsOfFile(frameworkFile)!.stretchableImageWithLeftCapWidth(leftCapWidth, topCapHeight: topCapHeight)
            self._cacheImage(image, forName: name)
        }
        return image
    }
}
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
    var imageCache: [NSObject : AnyObject]? = nil