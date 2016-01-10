//
//  SSSegmentedControl.h
//  SSToolkit
//
//  Created by Sam Soffes on 2/7/11.
//  Copyright 2011 Sam Soffes. All rights reserved.
//
// Limitiations:
// - Removing and inserting items is not supported
// - Setting item width is not supported
// - Setting item content offset is not supported

enum UISegmentedControlStyle : Int {
    case Plain
    // large plain
    case Bordered
    // large bordered
    case Bar
    // small button/nav bar style. tintable
    case Bezeled
}

enum ObjCEnum66 : Int {
    case UISegmentedControlNoSegment = -1
}

enum UISegmentedControlSegment : Int {
    case Any = 0
    case Left = 1
    case Center = 2
    case Right = 3
    case Alone = 4
}

class UISegmentedControl: UIControl {
    var segmentedControlStyle: UISegmentedControlStyle
    // stub
    var tintColor: UIColor
    // stub
    var numberOfSegments: Int {
        get {
            return segments.count
        }
    }

    var selectedSegmentIndex: Int {
        get {
            return self.selectedSegmentIndex
        }
        set {
            if selectedSegmentIndex == index {
                return
            }
            self.selectedSegmentIndex = index
            self.setNeedsDisplay()
            self.sendActionsForControlEvents(.ValueChanged)
        }
    }

    var momentary: Bool

    convenience override init(items: [AnyObject]) {
        if (self = self(frame: CGRectZero)) {
            var index: Int = 0
            for item: AnyObject in items {
                if (item is String) {
                    self.setTitle(item, forSegmentAtIndex: Int(index))
                    index++
                }
                else if (item is UIImage) {
                    self.setImage(item, forSegmentAtIndex: Int(index))
                    index++
                }
            }
        }
    }

    func setTitle(title: String, forSegmentAtIndex segment: Int) {
        if Int(self.numberOfSegments() - 1) < Int(segment) {
            segments.append(title)
        }
        else {
            segments[segment] = title
        }
        self.setNeedsDisplay()
    }

    func titleForSegmentAtIndex(segment: Int) -> String {
        if self.numberOfSegments() - 1 >= segment {
            return nil
        }
        var item: AnyObject = segments[segment]
        if (item is String) {
            return item
        }
        return nil
    }

    func setImage(image: UIImage, forSegmentAtIndex segment: Int) {
        if Int(self.numberOfSegments() - 1) < Int(segment) {
            segments.append(image)
        }
        else {
            segments[segment] = image
        }
        self.setNeedsDisplay()
    }

    func imageForSegmentAtIndex(segment: Int) -> UIImage {
        if self.numberOfSegments() - 1 >= segment {
            return nil
        }
        var item: AnyObject = segments[segment]
        if (item is UIImage) {
            return item
        }
        return nil
    }

    func setEnabled(enabled: Bool, forSegmentAtIndex segment: Int) {
        self._setMetaValue(Int(enabled), forKey: kSSSegmentedControlEnabledKey, segmentIndex: segment)
    }

    func isEnabledForSegmentAtIndex(segment: Int) -> Bool {
        var value: Int = self._metaValueForKey(kSSSegmentedControlEnabledKey, segmentIndex: segment)
        if !value {
            return true
        }
        return CBool(value)!
    }

    func setTitleTextAttributes(attributes: [NSObject : AnyObject], forState state: UIControlState) {
    }

    func titleTextAttributesForState(state: UIControlState) -> [NSObject : AnyObject] {
        return nil
    }
    var self.segments: [AnyObject]
    var self.segmentMeta: [NSObject : AnyObject]
    var self.buttonImage: UIImage
    var self.highlightedButtonImage: UIImage
    var self.dividerImage: UIImage
    var self.highlightedDividerImage: UIImage
    var self.font: UIFont
    var self.textColor: UIColor
    var self.disabledTextColor: UIColor
    var self.textShadowColor: UIColor
    var self.textShadowOffset: CGSize
    var self.textEdgeInsets: UIEdgeInsets


    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var touch: UITouch = touches.first!
        var x: CGFloat = touch.locationInView(self).x
        // Ignore touches that don't matter
        if x < 0 || x > self.frame.size.width {
            return
        }
        var index: Int = Int(floorf(x as! CGFloat / (self.frame.size.width / self.numberOfSegments() as! CGFloat)))
        if self.isEnabledForSegmentAtIndex(index) {
            self.selectedSegmentIndex = Int(index)
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !momentary {
            return
        }
        self.selectedSegmentIndex = .UISegmentedControlNoSegment
        self.setNeedsDisplay()
    }

    convenience override init(frame: CGRect) {
        if (self.init(frame: frame)) {
            self.backgroundColor = UIColor.clearColor()
            self.segments = [AnyObject]()
            self.momentary = false
            // TODO: add images
            self.buttonImage = UIImage(named: "UISegmentBarButton.png").stretchableImageWithLeftCapWidth(6, topCapHeight: 0)
            self.highlightedButtonImage = UIImage(named: "UISegmentBarButtonHighlighted.png").stretchableImageWithLeftCapWidth(6, topCapHeight: 0)
            self.dividerImage = UIImage(named: "UISegmentBarDivider.png")
            self.highlightedDividerImage = UIImage(named: "UISegmentBarDividerHighlighted.png")
            self.selectedSegmentIndex = .UISegmentedControlNoSegment
            self.font = UIFont.boldSystemFontOfSize(12.0)
            self.textColor = UIColor.whiteColor()
            self.disabledTextColor = UIColor(white: 0.561, alpha: 1.0)
            self.textShadowColor = UIColor(white: 0.0, alpha: 0.5)
            self.textShadowOffset = CGSizeMake(0.0, -1.0)
            self.textEdgeInsets = UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0)
        }
    }

    func drawRect(frame: CGRect) {
        var dividerWidth: CGFloat = 1.0
        var count: Int = Int(self.numberOfSegments())
        var size: CGSize = frame.size
        var segmentWidth: CGFloat = roundf((size.width - count - 1) / count as! CGFloat)
        var context: CGContextRef = UIGraphicsGetCurrentContext()
        for var i = 0; i < count; i++ {
            CGContextSaveGState(context)
            var item: AnyObject = segments[Int(i)]
            var enabled: Bool = self.isEnabledForSegmentAtIndex(Int(i))
            var x: CGFloat = (segmentWidth * i as! CGFloat + ((i as! CGFloat + 1) * dividerWidth))
            // Draw dividers
            if i > 0 {
                var p: Int = i - 1
                var dividerImage: UIImage? = nil
                // Selected divider
                if (p >= 0 && p == selectedSegmentIndex) || i == selectedSegmentIndex {
                    dividerImage = highlightedDividerImage
                }
                else {
                    dividerImage = dividerImage!
                }
                dividerImage!.drawInRect(CGRectMake(x - 1.0, 0.0, dividerWidth, size.height))
            }
            var segmentRect: CGRect = CGRectMake(x, 0.0, segmentWidth, size.height)
            CGContextClipToRect(context, segmentRect)
            // Background
            var backgroundImage: UIImage? = nil
            var backgroundRect: CGRect = segmentRect
            if selectedSegmentIndex == i {
                backgroundImage = highlightedButtonImage
            }
            else {
                backgroundImage = buttonImage
            }
            var capWidth: CGFloat = backgroundImage.leftCapWidth
            // First segment
            if i == 0 {
                backgroundRect.size.width += capWidth
            }
            else if i == count - 1 {
                backgroundRect = CGRectMake(backgroundRect.origin.x - capWidth, backgroundRect.origin.y, backgroundRect.size.width + capWidth, backgroundRect.size.height)
            }
            else {
                backgroundRect = CGRectMake(backgroundRect.origin.x - capWidth, backgroundRect.origin.y, backgroundRect.size.width + capWidth + capWidth, backgroundRect.size.height)
            }

            backgroundImage!.drawInRect(backgroundRect)
            // Strings
            if (item is String) {
                var string: String = String(item)
                var textSize: CGSize = string.sizeWithFont(font, constrainedToSize: CGSizeMake(segmentWidth, size.height), lineBreakMode: .TailTruncation)
                var textRect: CGRect = CGRectMake(x, roundf((size.height - textSize.height) / 2.0), segmentWidth, size.height)
                textRect = UIEdgeInsetsInsetRect(textRect, textEdgeInsets)
                if enabled {
                    textShadowColor.set()
                    string.drawInRect(CGRectOffset(textRect, textShadowOffset.width, textShadowOffset.height), withFont: font, lineBreakMode: .TailTruncation, alignment: .Center)
                    textColor.set()
                }
                else {
                    disabledTextColor.set()
                }
                string.drawInRect(textRect, withFont: font, lineBreakMode: .TailTruncation, alignment: .Center)
            }
            else if (item is UIImage) {
                var image: UIImage = item as! UIImage
                var imageSize: CGSize = image.size
                var imageRect: CGRect = CGRectMake(x + roundf((segmentRect.size.width - imageSize.width) / 2.0), roundf((segmentRect.size.height - imageSize.height) / 2.0), imageSize.width, imageSize.height)
                image.drawInRect(imageRect, blendMode: kCGBlendModeNormal, alpha: enabled ? 1.0 : 0.5)
            }

            CGContextRestoreGState(context)
        }
    }

    func willMoveToSuperview(newSuperview: UIView) {
        super.willMoveToSuperview(newSuperview)
        if newSuperview {
            self.addObserver(self, forKeyPath: "buttonImage", options: .New, context: nil)
            self.addObserver(self, forKeyPath: "highlightedButtonImage", options: .New, context: nil)
            self.addObserver(self, forKeyPath: "dividerImage", options: .New, context: nil)
            self.addObserver(self, forKeyPath: "highlightedDividerImage", options: .New, context: nil)
            self.addObserver(self, forKeyPath: "font", options: .New, context: nil)
            self.addObserver(self, forKeyPath: "textColor", options: .New, context: nil)
            self.addObserver(self, forKeyPath: "disabledTextColor", options: .New, context: nil)
            self.addObserver(self, forKeyPath: "textShadowColor", options: .New, context: nil)
            self.addObserver(self, forKeyPath: "textShadowOffset", options: .New, context: nil)
            self.addObserver(self, forKeyPath: "textEdgeInsets", options: .New, context: nil)
        }
        else {
            self.removeObserver(self, forKeyPath: "buttonImage")
            self.removeObserver(self, forKeyPath: "highlightedButtonImage")
            self.removeObserver(self, forKeyPath: "dividerImage")
            self.removeObserver(self, forKeyPath: "highlightedDividerImage")
            self.removeObserver(self, forKeyPath: "font")
            self.removeObserver(self, forKeyPath: "textColor")
            self.removeObserver(self, forKeyPath: "disabledTextColor")
            self.removeObserver(self, forKeyPath: "textShadowColor")
            self.removeObserver(self, forKeyPath: "textShadowOffset")
            self.removeObserver(self, forKeyPath: "textEdgeInsets")
        }
    }

    func _metaForSegmentIndex(index: Int) -> [NSObject : AnyObject] {
        if !segmentMeta {
            return nil
        }
        var key: String = "\(UInt(index))"
        return (segmentMeta[key] as! String)
    }

    convenience override init(key: String, segmentIndex index: Int) {
        var meta: [NSObject : AnyObject] = self._metaForSegmentIndex(index)
        return (meta[key] as! String)
    }

    func _setMetaValue(value: AnyObject, forKey key: String, segmentIndex index: Int) {
        var meta: [NSObject : AnyObject] = self._metaForSegmentIndex(index)
        if !meta {
            meta = [NSObject : AnyObject]()
        }
        meta[key] = value
        if !segmentMeta {
            self.segmentMeta = [NSObject : AnyObject]()
        }
        segmentMeta["\(UInt(index))"] = meta
        self.setNeedsDisplay()
    }

    func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: ) {
        if (keyPath == "buttonImage") || (keyPath == "highlightedButtonImage") || (keyPath == "dividerImage") || (keyPath == "highlightedDividerImage") || (keyPath == "font") || (keyPath == "textColor") || (keyPath == "textShadowColor") || (keyPath == "textShadowOffset") || (keyPath == "textEdgeInsets") {
            self.setNeedsDisplay()
            return
        }
        super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
    }
}
//
//  SSSegmentedControl.m
//  SSToolkit
//
//  Created by Sam Soffes on 2/7/11.
//  Copyright 2011 Sam Soffes. All rights reserved.
//

    var kSSSegmentedControlEnabledKey: String = "enabled"