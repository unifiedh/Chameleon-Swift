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

enum UIButtonType : Int {
    case Custom = 0
    case RoundedRect
    case DetailDisclosure
    case InfoLight
    case InfoDark
    case ContactAdd
}

class UIButton: UIControl {
    var self.buttonType: UIButtonType

    convenience init(buttonType: UIButtonType) {
        switch buttonType {
            case .RoundedRect, .DetailDisclosure, .InfoLight, .InfoDark, .ContactAdd:
                return UIRoundedRectButton()
            default:
                return self()
        }

    }

    func setTitle(title: String, forState state: UIControlState) {
        self._setContent(title!, forState: state, type: UIButtonContentTypeTitle)
    }

    func setTitleColor(color: UIColor, forState state: UIControlState) {
        self._setContent(color, forState: state, type: UIButtonContentTypeTitleColor)
    }

    func setTitleShadowColor(color: UIColor, forState state: UIControlState) {
        self._setContent(color, forState: state, type: UIButtonContentTypeTitleShadowColor)
    }

    func setBackgroundImage(image: UIImage, forState state: UIControlState) {
        self._setContent(image!, forState: state, type: UIButtonContentTypeBackgroundImage)
    }

    func setImage(image: UIImage, forState state: UIControlState) {
        self.adjustedDisabledImage = self.adjustedHighlightImage = nil
        self._setContent(image!, forState: state, type: UIButtonContentTypeImage)
    }

    func titleForState(state: UIControlState) -> String {
        return self._normalContentForState(state, type: UIButtonContentTypeTitle)
    }

    func titleColorForState(state: UIControlState) -> UIColor {
        return self._normalContentForState(state, type: UIButtonContentTypeTitleColor)
    }

    func titleShadowColorForState(state: UIControlState) -> UIColor {
        return self._normalContentForState(state, type: UIButtonContentTypeTitleShadowColor)
    }

    func backgroundImageForState(state: UIControlState) -> UIImage {
        return self._normalContentForState(state, type: UIButtonContentTypeBackgroundImage)
    }

    func imageForState(state: UIControlState) -> UIImage {
        return self._normalContentForState(state, type: UIButtonContentTypeImage)
    }

    func backgroundRectForBounds(bounds: CGRect) -> CGRect {
        return bounds
    }

    func contentRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, contentEdgeInsets)
    }

    func titleRectForContentRect(contentRect: CGRect) -> CGRect {
        let state: UIControlState = self.state
        var inset: UIEdgeInsets = titleEdgeInsets
        inset.left += self._imageSizeForState(state).width
        return self._componentRectForSize(self._titleSizeForState(state), inContentRect: UIEdgeInsetsInsetRect(contentRect, inset), withState: state)
    }

    func imageRectForContentRect(contentRect: CGRect) -> CGRect {
        let state: UIControlState = self.state
        var inset: UIEdgeInsets = imageEdgeInsets
        inset.right += self.titleRectForContentRect(contentRect).size.width
        return self._componentRectForSize(self._imageSizeForState(state), inContentRect: UIEdgeInsetsInsetRect(contentRect, inset), withState: state)
    }
    var buttonType: UIButtonType {
        get {
            return self.buttonType
        }
    }

    var titleLabel: UILabel {
        get {
            return self.titleLabel
        }
    }

    var imageView: UIImageView {
        get {
            return self.imageView
        }
    }

    var reversesTitleShadowWhenHighlighted: Bool
    var adjustsImageWhenHighlighted: Bool
    var adjustsImageWhenDisabled: Bool
    var showsTouchWhenHighlighted: Bool
    // no effect
    var contentEdgeInsets: UIEdgeInsets
    var titleEdgeInsets: UIEdgeInsets
    var imageEdgeInsets: UIEdgeInsets
    var currentTitle: String {
        get {
            return titleLabel.text!
        }
    }

    var currentTitleColor: UIColor {
        get {
            return titleLabel.textColor
        }
    }

    var currentTitleShadowColor: UIColor {
        get {
            return titleLabel.shadowColor
        }
    }

    var currentImage: UIImage {
        get {
            return imageView.image
        }
    }

    var currentBackgroundImage: UIImage {
        get {
            return backgroundImageView.image
        }
    }
    var self.backgroundImageView: UIImageView
    var self.content: [NSObject : AnyObject]
    var self.adjustedHighlightImage: UIImage
    var self.adjustedDisabledImage: UIImage


    convenience override init(frame: CGRect) {
        if (self.init(frame: frame)) {
            self.buttonType = .Custom
            self.content = [NSObject : AnyObject]()
            self.titleLabel = UILabel()
            self.imageView = UIImageView()
            self.backgroundImageView = UIImageView()
            self.adjustsImageWhenHighlighted = true
            self.adjustsImageWhenDisabled = true
            self.showsTouchWhenHighlighted = false
            self.opaque = false
            self.titleLabel.lineBreakMode = .MiddleTruncation
            self.titleLabel.backgroundColor = UIColor.clearColor()
            self.titleLabel.textAlignment = .Left
            self.titleLabel.shadowOffset = CGSizeZero
            self.addSubview(backgroundImageView)
            self.addSubview(imageView)
            self.addSubview(titleLabel)
        }
    }

    func _defaultTitleColor() -> UIColor {
        return UIColor.whiteColor()
    }

    func _defaultTitleShadowColor() -> UIColor {
        return UIColor.whiteColor()
    }

    convenience override init(state: UIControlState, type: String) {
        return ((content[type] as! String)[Int(state)] as! String)
    }

    convenience override init(state: UIControlState, type: String) {
        return self._contentForState(state, type: type) ?? self._contentForState(.Normal, type: type)
    }

    func _updateContent() {
        let state: UIControlState = self.state
        self.titleLabel.text = self.titleForState(state)
        self.titleLabel.textColor = self.titleColorForState(state) ?? self._defaultTitleColor()
        self.titleLabel.shadowColor = self.titleShadowColorForState(state) ?? self._defaultTitleShadowColor()
        var image: UIImage = self._contentForState(state, type: UIButtonContentTypeImage)
        var backgroundImage: UIImage = self._contentForState(state, type: UIButtonContentTypeBackgroundImage)
        if !image {
            image = self.imageForState(state)
            // find the correct default image to show
            if adjustsImageWhenDisabled && state & .Disabled {
                imageView._setDrawMode(UIImageViewDrawModeDisabled)
            }
            else if adjustsImageWhenHighlighted && state & .Highlighted {
                imageView._setDrawMode(UIImageViewDrawModeHighlighted)
            }
            else {
                imageView._setDrawMode(UIImageViewDrawModeNormal)
            }
        }
        else {
            imageView._setDrawMode(UIImageViewDrawModeNormal)
        }
        if !backgroundImage {
            backgroundImage = self.backgroundImageForState(state)
            if adjustsImageWhenDisabled && state & .Disabled {
                backgroundImageView._setDrawMode(UIImageViewDrawModeDisabled)
            }
            else if adjustsImageWhenHighlighted && state & .Highlighted {
                backgroundImageView._setDrawMode(UIImageViewDrawModeHighlighted)
            }
            else {
                backgroundImageView._setDrawMode(UIImageViewDrawModeNormal)
            }
        }
        else {
            backgroundImageView._setDrawMode(UIImageViewDrawModeNormal)
        }
        self.imageView.image = image
        self.backgroundImageView.image = backgroundImage
        self.setNeedsLayout()
    }

    func _setContent(value: AnyObject, forState state: UIControlState, type: String) {
        var typeContent: [NSObject : AnyObject] = (content[type] as! [NSObject : AnyObject])
        if !typeContent {
            typeContent = [NSObject : AnyObject]()
            content[type] = typeContent
        }
        var key: Int = Int(state)
        if value != 0 {
            typeContent[key] = value
        }
        else {
            typeContent.removeObjectForKey(key)
        }
        self._updateContent()
    }

    func _backgroundSizeForState(state: UIControlState) -> CGSize {
        var backgroundImage: UIImage = self.backgroundImageForState(state)
        return backgroundImage ? backgroundImage.size : CGSizeZero
    }

    func _titleSizeForState(state: UIControlState) -> CGSize {
        var title: String = self.titleForState(state)
        return (title.characters.count > 0) ? title.sizeWithFont(titleLabel.font, constrainedToSize: CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)) : CGSizeZero
    }

    func _imageSizeForState(state: UIControlState) -> CGSize {
        var image: UIImage = self.imageForState(state)
        return image ? image.size : CGSizeZero
    }

    func _componentRectForSize(size: CGSize, inContentRect contentRect: CGRect, withState state: UIControlState) -> CGRect {
        var rect: CGRect
        rect.origin = contentRect.origin
        rect.size = size
        // clamp the right edge of the rect to the contentRect - this is what the real UIButton appears to do.
        if CGRectGetMaxX(rect) > CGRectGetMaxX(contentRect) {
            rect.size.width -= CGRectGetMaxX(rect) - CGRectGetMaxX(contentRect)
        }
        switch self.contentHorizontalAlignment {
            case .Center:
                rect.origin.x += floorf((contentRect.size.width / 2.0) - (rect.size.width / 2.0))
            case .Right:
                rect.origin.x += contentRect.size.width - rect.size.width
            case .Fill:
                rect.size.width = contentRect.size.width
            case .Left:
            // don't do anything - it's already left aligned

        }

        switch self.contentVerticalAlignment {
            case .Center:
                rect.origin.y += floorf((contentRect.size.height / 2.0) - (rect.size.height / 2.0))
            case .Bottom:
                rect.origin.y += contentRect.size.height - rect.size.height
            case .Fill:
                rect.size.height = contentRect.size.height
            case .Top:
            // don't do anything - it's already top aligned

        }

        return rect
    }

    func layoutSubviews() {
        super.layoutSubviews()
        let bounds: CGRect = self.bounds
        let contentRect: CGRect = self.contentRectForBounds(bounds)
        self.backgroundImageView.frame = self.backgroundRectForBounds(bounds)
        self.titleLabel.frame = self.titleRectForContentRect(contentRect)
        self.imageView.frame = self.imageRectForContentRect(contentRect)
    }

    func _stateDidChange() {
        super._stateDidChange()
        self._updateContent()
    }

    func sizeThatFits(size: CGSize) -> CGSize {
        let state: UIControlState = self.state
        let imageSize: CGSize = self._imageSizeForState(state)
        let titleSize: CGSize = self._titleSizeForState(state)
        var fitSize: CGSize
        fitSize.width = contentEdgeInsets.left + contentEdgeInsets.right + titleSize.width + imageSize.width
        fitSize.height = contentEdgeInsets.top + contentEdgeInsets.bottom + max(titleSize.height, imageSize.height)
        var background: UIImage = self.currentBackgroundImage()
        if background != nil {
            var backgroundSize: CGSize = background.size
            fitSize.width = max(fitSize.width, backgroundSize.width)
            fitSize.height = max(fitSize.height, backgroundSize.height)
        }
        return fitSize
    }

    func rightClick(touch: UITouch, withEvent event: UIEvent) {
        // I'm swallowing right clicks on buttons by default, which is why this is here.
        // This isn't a strong decision, but there's a few places in Twitterrific where passing a right click through a button doesn't feel right.
        // It also doesn't feel immediately right to treat a right-click on a button as a normal click event, either, so this seems to be a
        // decent way to avoid the problem in general and define a kind of "standard" behavior in this case.
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

    var UIButtonContentTypeTitle: String = "UIButtonContentTypeTitle"

    var UIButtonContentTypeTitleColor: String = "UIButtonContentTypeTitleColor"

    var UIButtonContentTypeTitleShadowColor: String = "UIButtonContentTypeTitleShadowColor"

    var UIButtonContentTypeBackgroundImage: String = "UIButtonContentTypeBackgroundImage"

    var UIButtonContentTypeImage: String = "UIButtonContentTypeImage"