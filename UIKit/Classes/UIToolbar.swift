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

import CoreGraphics

enum UIToolbarPosition : Int {
    case Any = 0
    case Bottom = 1
    case Top = 2
}

public class UIToolbar: UIView {
    func setItems(items: [AnyObject], animated: Bool) {
    }

    func backgroundImageForToolbarPosition(topOrBottom: UIToolbarPosition, barMetrics: UIBarMetrics) -> UIImage? {
        return nil
    }

    func setBackgroundImage(backgroundImage: UIImage, forToolbarPosition topOrBottom: UIToolbarPosition, barMetrics: UIBarMetrics) {
    }
    var barStyle: UIBarStyle {
        get {
            return self.barStyle
        }
        set(newStyle) {
            self.barStyle = newStyle
            // this is for backward compatibility - UIBarStyleBlackTranslucent is deprecated 
            if barStyle == .BlackTranslucent {
                self.translucent = true
            }
        }
    }

    var tintColor: UIColor?
    var items: [AnyObject] {
        get {
            return toolbarItems["item"]
        }
        set {
            if !self.items.isEqualToArray(newItems) {
                // if animated, fade old item views out, otherwise just remove them
                for toolbarItem: UIToolbarItem in toolbarItems {
                    var view: UIView = toolbarItem.view!
                    if view != nil {
                        UIView.animateWithDuration(animated ? 0.2 : 0, animations: {() -> Void in
                            view.alpha = 0
                        }, completion: {(finished: Bool) -> Void in
                            view.removeFromSuperview()
                        })
                    }
                }
                toolbarItems.removeAllObjects()
                for item: UIBarButtonItem in newItems {
                    var toolbarItem: UIToolbarItem = UIToolbarItem(barButtonItem: item)
                    toolbarItems.append(toolbarItem)
                    self.addSubview(toolbarItem.view!)
                }
                // if animated, fade them in
                if animated {
                    for toolbarItem: UIToolbarItem in toolbarItems {
                        var view: UIView = toolbarItem.view!
                        if view != nil {
                            view.alpha = 0
                            UIView.animateWithDuration(0.2, animations: {() -> Void in
                                view.alpha = 1
                            })
                        }
                    }
                }
            }
        }
    }

    var translucent: Bool
    var toolbarItems: [UIToolbarItem]


    override init(var frame: CGRect) {
        frame.size.height = kBarHeight
            self.toolbarItems = [UIToolbarItem]()
            self.barStyle = .Default
            self.translucent = false
            self.tintColor = nil
		super.init(frame: frame)
    }
    /*
    - (void)_updateItemViews
    {
        [_itemViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_itemViews removeAllObjects];
    
        NSUInteger numberOfFlexibleItems = 0;
        
        for (UIBarButtonItem *item in _items) {
            if ((item->_isSystemItem) && (item->_systemItem == UIBarButtonSystemItemFlexibleSpace)) {
                numberOfFlexibleItems++;
            }
        }
    
        const CGSize size = self.bounds.size;
        const CGFloat flexibleSpaceWidth = (numberOfFlexibleItems > 0)? MAX(0, size.width/numberOfFlexibleItems) : 0;
        CGFloat left = 0;
        
        for (UIBarButtonItem *item in _items) {
            UIView *view = item.customView;
    
            if (!view) {
                if (item->_isSystemItem && item->_systemItem == UIBarButtonSystemItemFlexibleSpace) {
                    left += flexibleSpaceWidth;
                } else if (item->_isSystemItem && item->_systemItem == UIBarButtonSystemItemFixedSpace) {
                    left += item.width;
                } else {
                    view = [[[UIToolbarButton alloc] initWithBarButtonItem:item] autorelease];
                }
            }
            
            if (view) {
                CGRect frame = view.frame;
                frame.origin.x = left;
                frame.origin.y = (size.height / 2.f) - (frame.size.height / 2.f);
                frame = CGRectStandardize(frame);
                
                view.frame = frame;
                left += frame.size.width;
                
                [self addSubview:view];
            }
        }
    }
    */

    func layoutSubviews() {
        super.layoutSubviews()
        var itemWidth: CGFloat = 0
        var numberOfFlexibleItems: Int = 0
        for toolbarItem: UIToolbarItem in toolbarItems {
            let width: CGFloat = toolbarItem.width
            if width >= 0 {
                itemWidth += width
            }
            else {
                numberOfFlexibleItems++
            }
        }
        let size: CGSize = self.bounds.size
        let flexibleSpaceWidth: CGFloat = (numberOfFlexibleItems > 0) ? ((size.width - itemWidth) / numberOfFlexibleItems) : 0
        let centerY: CGFloat = size.height / 2.0
        var x: CGFloat = 0
        for toolbarItem: UIToolbarItem in toolbarItems {
            var view: UIView = toolbarItem.view!
            let width: CGFloat = toolbarItem.width
            if view != nil {
                var frame: CGRect = view.frame
                frame.origin.x = x
                frame.origin.y = floorf(centerY - (frame.size.height / 2.0))
                view.frame = frame
            }
            if width < 0 {
                x += flexibleSpaceWidth
            }
            else {
                x += width
            }
        }
    }

    func setItems(items: [AnyObject]) {
        self.setItems(items, animated: false)
    }

    override public func drawRect(rect: CGRect) {
        let bounds: CGRect = self.bounds
        var color: UIColor = tintColor ?? UIColor(red: 21 / 255.0, green: 21 / 255.0, blue: 25 / 255.0, alpha: 1)
        color.setFill()
        UIRectFill(bounds)
        UIColor.blackColor().setFill()
        UIRectFill(CGRectMake(0, 0, bounds.size.width, 1))
    }

	public override var description: String {
        var barStyle: String = ""
        switch self.barStyle {
            case .Default:
                barStyle = "Default"
            case .Black:
                barStyle = "Black"
            case .BlackTranslucent:
                barStyle = "Black Translucent (Deprecated)"
        }

        return "<\(self.className): \(unsafeAddressOf(self)); barStyle = \(barStyle); tintColor = \(self.tintColor?.description ?? "Default"), isTranslucent = \(self.translucent ? "YES" : "NO")>"
    }

    public override func sizeThatFits(var size: CGSize) -> CGSize {
        size.height = kBarHeight
        return size
    }
}

    let kBarHeight: CGFloat = 28

public class UIToolbarItem: NSObject {
    public init(barButtonItem anItem: UIBarButtonItem) {
            self.item = anItem
            if !item.isSystemItem && item.customView != nil {
                self.view = item.customView
            }
            else if !item.isSystemItem || (item.systemItem != .FixedSpace && item.systemItem != .FlexibleSpace) {
                self.view = UIToolbarButton(barButtonItem: item)
            }
		super.init()
    }
    public var view: UIView?

    public let item: UIBarButtonItem

    public var width: CGFloat {
        get {
            if let view = view {
                return view.frame.size.width
            }
            else if item.isSystemItem && item.systemItem == .FixedSpace {
                return item.width
            }
            else {
                return -1
            }
    
        }
    }
}