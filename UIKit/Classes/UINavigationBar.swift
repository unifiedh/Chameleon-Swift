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

protocol UINavigationBarDelegate: NSObject {
    func navigationBar(navigationBar: UINavigationBar, shouldPushItem item: UINavigationItem) -> Bool

    func navigationBar(navigationBar: UINavigationBar, didPushItem item: UINavigationItem)

    func navigationBar(navigationBar: UINavigationBar, shouldPopItem item: UINavigationItem) -> Bool

    func navigationBar(navigationBar: UINavigationBar, didPopItem item: UINavigationItem)
}
class UINavigationBar: UIView {
    func setItems(items: [AnyObject], animated: Bool) {
        if !navStack.isEqualToArray(items!) {
            navStack.removeAllObjects()
            navStack.addObjectsFromArray(items!)
            self._setViewsWithTransition(UINavigationBarTransitionPush, animated: animated)
        }
    }

    func pushNavigationItem(item: UINavigationItem, animated: Bool) {
        var shouldPush: Bool = true
        if delegateHas.shouldPushItem {
            shouldPush = delegate.navigationBar(self, shouldPushItem: item)
        }
        if shouldPush {
            navStack.append(item)
            self._setViewsWithTransition(UINavigationBarTransitionPush, animated: animated)
            if delegateHas.didPushItem {
                delegate.navigationBar(self, didPushItem: item)
            }
        }
    }

    func popNavigationItemAnimated(animated: Bool) -> UINavigationItem {
        var previousItem: UINavigationItem = self.topItem
        if previousItem != nil {
            var shouldPop: Bool = true
            if delegateHas.shouldPopItem {
                shouldPop = delegate.navigationBar(self, shouldPopItem: previousItem)
            }
            if shouldPop {
                navStack.removeObject(previousItem)
                self._setViewsWithTransition(UINavigationBarTransitionPop, animated: animated)
                if delegateHas.didPopItem {
                    delegate.navigationBar(self, didPopItem: previousItem)
                }
                return previousItem
            }
        }
        return nil
    }

    func setBackgroundImage(backgroundImage: UIImage, forBarMetrics barMetrics: UIBarMetrics) {
    }

    func backgroundImageForBarMetrics(barMetrics: UIBarMetrics) -> UIImage {
        return nil
    }

    func setTitleVerticalPositionAdjustment(adjustment: CGFloat, forBarMetrics barMetrics: UIBarMetrics) {
    }

    func titleVerticalPositionAdjustmentForBarMetrics(barMetrics: UIBarMetrics) -> CGFloat {
        return 0
    }
    var delegate: AnyObject {
        get {
            return self.delegate
        }
        set {
            self.delegate = newDelegate
            self.delegateHas.shouldPushItem = delegate.respondsToSelector("navigationBar:shouldPushItem:")
            self.delegateHas.didPushItem = delegate.respondsToSelector("navigationBar:didPushItem:")
            self.delegateHas.shouldPopItem = delegate.respondsToSelector("navigationBar:shouldPopItem:")
            self.delegateHas.didPopItem = delegate.respondsToSelector("navigationBar:didPopItem:")
        }
    }

    var items: [AnyObject] {
        get {
            return self.items
        }
        set {
            if !navStack.isEqualToArray(items!) {
                navStack.removeAllObjects()
                navStack.addObjectsFromArray(items!)
                self._setViewsWithTransition(UINavigationBarTransitionPush, animated: animated)
            }
        }
    }

    var barStyle: UIBarStyle
    var topItem: UINavigationItem {
        get {
            return navStack.lastObject()
        }
    }

    var backItem: UINavigationItem {
        get {
            return (navStack.count <= 1) ? nil : navStack[navStack.count - 2]
        }
    }

    var tintColor: UIColor {
        get {
            return self.tintColor
        }
        set {
            if newColor != tintColor {
                self.tintColor = newColor
                self.setNeedsDisplay()
            }
        }
    }

    var titleTextAttributes: [NSObject : AnyObject]
    var self.navStack: [AnyObject]
    var self.leftView: UIView
    var self.centerView: UIView
    var self.rightView: UIView
    var self.delegateHas: struct{unsignedshouldPushItem:1;unsigneddidPushItem:1;unsignedshouldPopItem:1;unsigneddidPopItem:1;}


    class func _setBarButtonSize(view: UIView) {
        var frame: CGRect = view.frame
        frame.size = view.sizeThatFits(CGSizeMake(kMaxButtonWidth, kMaxButtonHeight))
        frame.size.height = kMaxButtonHeight
        frame.size.width = max(frame.size.width, kMinButtonWidth)
        view.frame = frame
    }

    class func _backButtonWithTitle(title: String) -> UIButton {
        var backButton: UIButton = UIButton(type: .Custom)
        backButton.setBackgroundImage(UIImage._backButtonImage(), forState: .Normal)
        backButton.setBackgroundImage(UIImage._highlightedBackButtonImage(), forState: .Highlighted)
        backButton.setTitle((title ?? "Back"), forState: .Normal)
        backButton.titleLabel.font = UIFont.systemFontOfSize(11)
        backButton.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 7)
        backButton.addTarget(nil, action: "_backButtonTapped:", forControlEvents: .TouchUpInside)
        self._setBarButtonSize(backButton)
        return backButton
    }

    class func _viewWithBarButtonItem(item: UIBarButtonItem) -> UIView {
        if !item {
            return nil
        }
        if item.customView {
            self._setBarButtonSize(item.customView)
            return item.customView
        }
        else {
            var button: UIButton = UIButton(type: .Custom)
            button.setBackgroundImage(UIImage._toolbarButtonImage(), forState: .Normal)
            button.setBackgroundImage(UIImage._highlightedToolbarButtonImage(), forState: .Highlighted)
            button.setTitle(item.title, forState: .Normal)
            button.setImage(item.image, forState: .Normal)
            button.titleLabel.font = UIFont.systemFontOfSize(11)
            button.contentEdgeInsets = UIEdgeInsetsMake(0, 7, 0, 7)
            button.addTarget(item.target, action: item.action, forControlEvents: .TouchUpInside)
            self._setBarButtonSize(button)
            return button
        }
    }

    convenience override init(frame: CGRect) {
        frame.size.height = kBarHeight
        if (self.init(frame: frame)) {
            self.navStack = [AnyObject]()
            self.barStyle = .Default
            self.tintColor = UIColor(red: 21 / 255.0, green: 21 / 255.0, blue: 25 / 255.0, alpha: 1)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "_navigationItemDidChange:", name: UINavigationItemDidChange, object: nil)
        }
    }

    func dealloc() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func _backButtonTapped(sender: AnyObject) {
        self.popNavigationItemAnimated(true)
    }

    func _setViewsWithTransition(transition: _UINavigationBarTransition, animated: Bool) {
                    var previousViews: [AnyObject] = [AnyObject]()
            if leftView != nil {
                previousViews.append(leftView)
            }
            if centerView {
                previousViews.append(centerView)
            }
            if rightView != nil {
                previousViews.append(rightView)
            }
            if animated {
                var moveCenterBy: CGFloat = self.bounds.size.width - ((centerView) ? centerView.frame.origin.x : 0)
                var moveLeftBy: CGFloat = self.bounds.size.width * 0.33
                if transition == UINavigationBarTransitionPush {
                    moveCenterBy *= -1.0
                    moveLeftBy *= -1.0
                }
                UIView.animateWithDuration(kAnimationDuration * 0.8, delay: kAnimationDuration * 0.2, options: [.CurveEaseInOut, .TransitionNone], animations: {() -> Void in
                    self.leftView.alpha = 0
                    self.rightView.alpha = 0
                    self.centerView.alpha = 0
                }, completion: { _ in })
                UIView.animateWithDuration(kAnimationDuration, animations: {() -> Void in
                    if leftView != nil {
                        self.leftView.frame = CGRectOffset(leftView.frame, moveLeftBy, 0)
                    }
                    if centerView {
                        self.centerView.frame = CGRectOffset(centerView.frame, moveCenterBy, 0)
                    }
                }, completion: {(finished: Bool) -> Void in
                    previousViews.makeObjectsPerformSelector("removeFromSuperview")
                })
            }
            else {
                previousViews.makeObjectsPerformSelector("removeFromSuperview")
            }

        var topItem: UINavigationItem = self.topItem
        if topItem != nil {
            var backItem: UINavigationItem = self.backItem
            var leftFrame: CGRect = CGRectZero
            var rightFrame: CGRect = CGRectZero
            if backItem != nil {
                self.leftView = self._backButtonWithTitle(backItem.backBarButtonItem.title ?? backItem.title)
            }
            else {
                self.leftView = self._viewWithBarButtonItem(topItem.leftBarButtonItem)
            }
            if leftView != nil {
                leftFrame = leftView.frame
                leftFrame.origin = CGPointMake(kButtonEdgeInsets.left, kButtonEdgeInsets.top)
                self.leftView.frame = leftFrame
                self.addSubview(leftView)
            }
            self.rightView = self._viewWithBarButtonItem(topItem.rightBarButtonItem)
            if rightView != nil {
                self.rightView.autoresizingMask = .FlexibleLeftMargin
                rightFrame = rightView.frame
                rightFrame.origin.x = self.bounds.size.width - rightFrame.size.width - kButtonEdgeInsets.right
                rightFrame.origin.y = kButtonEdgeInsets.top
                self.rightView.frame = rightFrame
                self.addSubview(rightView)
            }
            self.centerView = topItem.titleView
            if !centerView {
                var titleLabel: UILabel = UILabel()
                titleLabel.text = topItem.title
                titleLabel.textAlignment = .Center
                titleLabel.backgroundColor = UIColor.clearColor()
                titleLabel.textColor = UIColor.whiteColor()
                titleLabel.font = UIFont.boldSystemFontOfSize(14)
                self.centerView = titleLabel
            }
            var centerFrame: CGRect = CGRectZero
            centerFrame.origin.y = kButtonEdgeInsets.top
            centerFrame.size.height = kMaxButtonHeight
            if leftView && rightView {
                centerFrame.origin.x = CGRectGetMaxX(leftFrame) + kButtonEdgeInsets.left
                centerFrame.size.width = CGRectGetMinX(rightFrame) - kButtonEdgeInsets.right - centerFrame.origin.x
            }
            else if leftView != nil {
                centerFrame.origin.x = CGRectGetMaxX(leftFrame) + kButtonEdgeInsets.left
                centerFrame.size.width = CGRectGetWidth(self.bounds) - centerFrame.origin.x - CGRectGetWidth(leftFrame) - kButtonEdgeInsets.right - kButtonEdgeInsets.right
            }
            else if rightView != nil {
                centerFrame.origin.x = CGRectGetWidth(rightFrame) + kButtonEdgeInsets.left + kButtonEdgeInsets.left
                centerFrame.size.width = CGRectGetWidth(self.bounds) - centerFrame.origin.x - CGRectGetWidth(rightFrame) - kButtonEdgeInsets.right - kButtonEdgeInsets.right
            }
            else {
                centerFrame.origin.x = kButtonEdgeInsets.left
                centerFrame.size.width = CGRectGetWidth(self.bounds) - kButtonEdgeInsets.left - kButtonEdgeInsets.right
            }

            self.centerView.autoresizingMask = .FlexibleWidth
            self.centerView.frame = centerFrame
            self.insertSubview(centerView, atIndex: 0)
            if animated {
                var moveCenterBy: CGFloat = self.bounds.size.width - ((centerView) ? centerView.frame.origin.x : 0)
                var moveLeftBy: CGFloat = self.bounds.size.width * 0.33
                if transition == UINavigationBarTransitionPush {
                    moveLeftBy *= -1.0
                    moveCenterBy *= -1.0
                }
                var destinationLeftFrame: CGRect = leftView ? leftView.frame : CGRectZero
                var destinationCenterFrame: CGRect = centerView ? centerView.frame : CGRectZero
                if leftView != nil {
                    self.leftView.frame = CGRectOffset(leftView.frame, -moveLeftBy, 0)
                }
                if centerView {
                    self.centerView.frame = CGRectOffset(centerView.frame, -moveCenterBy, 0)
                }
                self.leftView.alpha = 0
                self.rightView.alpha = 0
                self.centerView.alpha = 0
                UIView.animateWithDuration(kAnimationDuration, animations: {() -> Void in
                    self.leftView.frame = destinationLeftFrame
                    self.centerView.frame = destinationCenterFrame
                })
                UIView.animateWithDuration(kAnimationDuration * 0.8, delay: kAnimationDuration * 0.2, options: [.CurveEaseInOut, .TransitionNone], animations: {() -> Void in
                    self.leftView.alpha = 1
                    self.rightView.alpha = 1
                    self.centerView.alpha = 1
                }, completion: { _ in })
            }
        }
        else {
            self.leftView = self.centerView = self.rightView = nil
        }
    }

    func setItems(items: [AnyObject]) {
        self.setItems(items!, animated: false)
    }

    func _navigationItemDidChange(note: NSNotification) {
        if note.object == self.topItem || note.object == self.backItem {
            // this is going to remove & re-add all the item views. Not ideal, but simple enough that it's worth profiling.
            // next step is to add animation support-- that will require changing _setViewsWithTransition:animated:
            //  such that it won't perform any coordinate translations, only fade in/out
            self._setViewsWithTransition(UINavigationBarTransitionNone, animated: false)
        }
    }

    func drawRect(rect: CGRect) {
        let bounds: CGRect = self.bounds
        // I kind of suspect that the "right" thing to do is to draw the background and then paint over it with the tintColor doing some kind of blending
        // so that it actually doesn "tint" the image instead of define it. That'd probably work better with the bottom line coloring and stuff, too, but
        // for now hardcoding stuff works well enough.
        self.tintColor.setFill()
        UIRectFill(bounds)
    }

    func sizeThatFits(size: CGSize) -> CGSize {
        size.height = kBarHeight
        return size
    }
}

    let kButtonEdgeInsets: UIEdgeInsets = UIEdgeInsets()
    kButtonEdgeInsets.2
    kButtonEdgeInsets.2
    kButtonEdgeInsets.2
    kButtonEdgeInsets.2

    let kMinButtonWidth: CGFloat = 30

    let kMaxButtonWidth: CGFloat = 200

    let kMaxButtonHeight: CGFloat = 24

    let kBarHeight: CGFloat = 28

    let kAnimationDuration: NSTimeInterval = 0.33

enum UINavigationBarTransition : Int {
    case _UINavigationBarTransitionNone = 0
    case _UINavigationBarTransitionPush
    case _UINavigationBarTransitionPop
}