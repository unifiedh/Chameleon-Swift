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

protocol UINavigationControllerDelegate: NSObject {
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool)

    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool)
}
class UINavigationController: UIViewController {
    convenience override init(rootViewController: UIViewController) {
        if (self.init(nibName: nil, bundle: nil)) {
            self.navigationBar = UINavigationBar()
            self.navigationBar.delegate = self
            self.toolbar = UIToolbar()
            self.toolbarHidden = true
            self.viewControllers = [rootViewController]
        }
    }

    func setViewControllers(newViewControllers: [AnyObject], animated: Bool) {
        assert(newViewControllers.count >= 1)
        if !newViewControllers.isEqualToArray(self.viewControllers) {
            // find the controllers we used to have that we won't be using anymore
            var removeViewControllers: [AnyObject] = self.viewControllers.mutableCopy()
            removeViewControllers.removeObjectsInArray(newViewControllers)
            // these view controllers are not in the new collection, so we must remove them as children
            // I'm pretty sure the real UIKit doesn't attempt to be so clever..
            for controller: UIViewController in removeViewControllers {
                controller!.willMoveToParentViewController(nil)
                controller!.removeFromParentViewController()
            }
            // reset the nav bar
            self.navigationBar.items = nil
            // add them back in one-by-one and only apply animation to the last one (if any)
            for controller: UIViewController in newViewControllers {
                self.pushViewController(controller!, animated: (animated && (controller == newViewControllers.lastObject())))
            }
        }
    }

    func pushViewController(viewController: UIViewController, animated: Bool) {
        assert(!(viewController is UITabBarController))
        assert(!self.viewControllers.containsObject(viewController))
        assert(viewController.parentViewController == nil || viewController.parentViewController == self)
        // this logic matches with the cleverness in setViewControllers which the real UIKit probably doens't do
        // and probably isn't necessary :)
        if viewController.parentViewController != self {
            // note that -addChildViewController will call -willMoveToParentViewController: and that
            // there's no matching call to -didMoveToParentViewController: here which is usually
            // required. In my tests, it seems like the real UIKit hardly ever correctly calls the
            // -didMoveToParentViewController: method on it's navigation controller children which
            // makes me slightly crazy inside. I blame legacy (since child containment wasn't added
            // until iOS 5), but it's still stupid.
            self.addChildViewController(viewController)
        }
        if animated {
            self._updateVisibleViewController(animated)
        }
        else {
            self._setNeedsDeferredUpdate()
        }
        navigationBar.pushNavigationItem(viewController.navigationItem, animated: animated)
    }

    func popViewControllerAnimated(animated: Bool) -> UIViewController {
        // don't allow popping the rootViewController
        if self.viewControllers.count <= 1 {
            return nil
        }
        var formerTopViewController: UIViewController = self.topViewController!
        // the real thing seems to only bother calling -willMoveToParentViewController:
        // here if the popped controller is the currently visible one. I have no idea why.
        // if you pop several in a row, the ones buried in the stack don't seem to get called.
        // it is possible that the real implementation is fancier and tracks if a child has
        // been fully ever added or not before making this determination, but I haven't
        // tried to test for that case yet since this was an easy thing to do to replicate
        // the real world behavior I was seeing at the time of this writing.
        if formerTopViewController == visibleViewController {
            formerTopViewController.willMoveToParentViewController(nil)
        }
        // the real thing seems to cheat here and removes the parent immediately even if animated
        formerTopViewController._removeFromParentViewController()
        // pop the nav bar - note that it's setting the delegate to nil and back because we use the nav bar's
        // -navigationBar:shouldPopItem: delegate method to determine when the user clicks the back button
        // but that method is also called when we do an animated pop like this, so this works around the cycle.
        // I don't love it.
        self.navigationBar.delegate = nil
        navigationBar.popNavigationItemAnimated(animated)
        self.navigationBar.delegate = self
        if animated {
            self._updateVisibleViewController(animated)
        }
        else {
            self._setNeedsDeferredUpdate()
        }
        return formerTopViewController
    }

    func popToViewController(viewController: UIViewController, animated: Bool) -> [AnyObject] {
        var popped: [AnyObject] = [AnyObject]()
        if self.viewControllers.containsObject(viewController) {
            while self.topViewController != viewController {
                var poppedController: UIViewController = self.popViewControllerAnimated(animated)
                if poppedController != nil {
                    popped.append(poppedController)
                }
                else {

                }
            }
        }
        return popped
    }

    func popToRootViewControllerAnimated(animated: Bool) -> [AnyObject] {
        return self.popToViewController(self.viewControllers[0], animated: animated)
    }

    func setToolbarHidden(hidden: Bool, animated: Bool) {
    }
    // toolbar support is not really implemented yet

    func setNavigationBarHidden(navigationBarHidden: Bool, animated: Bool) {
    }
    // doesn't animate yet
    var viewControllers: [AnyObject] {
        get {
            return self.childViewControllers.copy()
        }
        set {
            assert(newViewControllers.count >= 1)
            if !newViewControllers.isEqualToArray(self.viewControllers) {
                // find the controllers we used to have that we won't be using anymore
                var removeViewControllers: [AnyObject] = self.viewControllers.mutableCopy()
                removeViewControllers.removeObjectsInArray(newViewControllers)
                // these view controllers are not in the new collection, so we must remove them as children
                // I'm pretty sure the real UIKit doesn't attempt to be so clever..
                for controller: UIViewController in removeViewControllers {
                    controller!.willMoveToParentViewController(nil)
                    controller!.removeFromParentViewController()
                }
                // reset the nav bar
                self.navigationBar.items = nil
                // add them back in one-by-one and only apply animation to the last one (if any)
                for controller: UIViewController in newViewControllers {
                    self.pushViewController(controller!, animated: (animated && (controller == newViewControllers.lastObject())))
                }
            }
        }
    }

    var visibleViewController: UIViewController {
        get {
            return self.visibleViewController
        }
    }

    var navigationBar: UINavigationBar {
        get {
            // always initiate an animated pop and return NO so that the nav bar itself doesn't take it upon itself
            // to pop the item, instead popViewControllerAnimated: will command it to do so later.
            self.popViewControllerAnimated(true)
            return false
        }
    }

    var toolbar: UIToolbar {
        get {
            return self.toolbar
        }
    }

    // toolbar support is not really implemented yet
    weak var delegate: UINavigationControllerDelegate
    var topViewController: UIViewController {
        get {
            return self.childViewControllers.lastObject()
        }
    }

    var navigationBarHidden: Bool {
        get {
            return self.navigationBarHidden
        }
        set {
            if hide != navigationBarHidden {
                self.navigationBarHidden = hide
                if animated && !isUpdating {
                    var startTransform: CGAffineTransform = hide ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0, -navigationBar.frame.size.height)
                    var endTransform: CGAffineTransform = hide ? CGAffineTransformMakeTranslation(0, -navigationBar.frame.size.height) : CGAffineTransformIdentity
                    var contentRect: CGRect
                    self._getNavbarRect(nil, contentRect: contentRect, toolbarRect: nil, forBounds: self.view.bounds)
                    self.navigationBar.transform = startTransform
                    self.navigationBar.hidden = false
                    UIView.animateWithDuration(0.15, animations: {() -> Void in
                        self.visibleViewController.view.frame = contentRect
                        self.navigationBar.transform = endTransform
                    }, completion: {(finished: Bool) -> Void in
                        self.navigationBar.transform = CGAffineTransformIdentity
                        self.navigationBar.hidden = navigationBarHidden
                    })
                }
                else {
                    self.navigationBar.hidden = navigationBarHidden
                }
            }
        }
    }

    var toolbarHidden: Bool {
        get {
            return toolbarHidden || self.topViewController.hidesBottomBarWhenPushed
        }
        set {
            if hide != toolbarHidden {
                self.toolbarHidden = hide
                if animated && !isUpdating {
                    var startTransform: CGAffineTransform = hide ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0, toolbar.frame.size.height)
                    var endTransform: CGAffineTransform = hide ? CGAffineTransformMakeTranslation(0, toolbar.frame.size.height) : CGAffineTransformIdentity
                    var contentRect: CGRect
                    self._getNavbarRect(nil, contentRect: contentRect, toolbarRect: nil, forBounds: self.view.bounds)
                    self.toolbar.transform = startTransform
                    self.toolbar.hidden = false
                    UIView.animateWithDuration(0.15, animations: {() -> Void in
                        self.visibleViewController.view.frame = contentRect
                        self.toolbar.transform = endTransform
                    }, completion: {(finished: Bool) -> Void in
                        self.toolbar.transform = CGAffineTransformIdentity
                        self.toolbar.hidden = toolbarHidden
                    })
                }
                else {
                    self.toolbar.hidden = toolbarHidden
                }
            }
        }
    }
    var self.visibleViewController: UIViewController
    var self.needsDeferredUpdate: Bool
    var self.isUpdating: Bool
    var self.toolbarHidden: Bool


    func dealloc() {
        self.navigationBar.delegate = nil
    }

    override func loadView() {
        self.view = UIView(frame: CGRectMake(0, 0, 320, 480))
        self.view.clipsToBounds = true
        var navbarRect: CGRect
        var contentRect: CGRect
        var toolbarRect: CGRect
        self._getNavbarRect(navbarRect, contentRect: contentRect, toolbarRect: toolbarRect, forBounds: self.view.bounds)
        self.toolbar.frame = toolbarRect
        self.navigationBar.frame = navbarRect
        self.visibleViewController.view.frame = contentRect
        self.toolbar.autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin]
        self.navigationBar.autoresizingMask = [.FlexibleWidth, .FlexibleBottomMargin]
        self.visibleViewController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.view!.addSubview(visibleViewController.view!)
        self.view!.addSubview(navigationBar)
        self.view!.addSubview(toolbar)
    }

    func shouldAutomaticallyForwardAppearanceMethods() -> Bool {
        return false
    }

    func _setNeedsDeferredUpdate() {
        self.needsDeferredUpdate = true
        self.view!.setNeedsLayout()
    }

    func _getNavbarRect(navbarRect: CGRect, contentRect: CGRect, toolbarRect: CGRect, forBounds bounds: CGRect) {
        let navbar: CGRect = CGRectMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetWidth(bounds), navigationBar.frame.size.height)
        let toolbar: CGRect = CGRectMake(CGRectGetMinX(bounds), CGRectGetMaxY(bounds) - toolbar.frame.size.height, CGRectGetWidth(bounds), toolbar.frame.size.height)
        var content: CGRect = bounds
        if !self.navigationBarHidden {
            content.origin.y += CGRectGetHeight(navbar)
            content.size.height -= CGRectGetHeight(navbar)
        }
        if !self.toolbarHidden {
            content.size.height -= CGRectGetHeight(toolbar)
        }
        if navbarRect {
            navbarRect = navbar
        }
        if toolbarRect {
            toolbarRect = toolbar
        }
        if contentRect != nil {
            contentRect = content
        }
    }

    func _updateVisibleViewController(animated: Bool) {
        self.isUpdating = true
        var newVisibleViewController: UIViewController = self.topViewController!
        var oldVisibleViewController: UIViewController = visibleViewController
        let isPushing: Bool = (oldVisibleViewController.parentViewController != nil)
        let wasToolbarHidden: Bool = self.toolbarHidden
        let wasNavbarHidden: Bool = self.navigationBarHidden
        oldVisibleViewController.beginAppearanceTransition(false, animated: animated)
        newVisibleViewController.beginAppearanceTransition(true, animated: animated)
        self.delegate.navigationController(self, willShowViewController: newVisibleViewController, animated: animated)
        self.visibleViewController = newVisibleViewController
        let bounds: CGRect = self.view.bounds
        var navbarRect: CGRect
        var contentRect: CGRect
        var toolbarRect: CGRect
        self._getNavbarRect(navbarRect, contentRect: contentRect, toolbarRect: toolbarRect, forBounds: bounds)
        self.toolbar.transform = CGAffineTransformIdentity
        self.toolbar.frame = toolbarRect
        self.navigationBar.transform = CGAffineTransformIdentity
        self.navigationBar.frame = navbarRect
        newVisibleViewController.view.transform = CGAffineTransformIdentity
        newVisibleViewController.view.frame = contentRect
        let inStartTransform: CGAffineTransform = isPushing ? CGAffineTransformMakeTranslation(bounds.size.width, 0) : CGAffineTransformMakeTranslation(-bounds.size.width, 0)
        let outEndTransform: CGAffineTransform = isPushing ? CGAffineTransformMakeTranslation(-bounds.size.width, 0) : CGAffineTransformMakeTranslation(bounds.size.width, 0)
        var toolbarEndTransform: CGAffineTransform = CGAffineTransformIdentity
        var navbarEndTransform: CGAffineTransform = CGAffineTransformIdentity
        if wasToolbarHidden && !toolbarHidden {
            self.toolbar.transform = inStartTransform
            self.toolbar.hidden = false
            self.toolbar.items = newVisibleViewController.toolbarItems
        }
        else if !wasToolbarHidden && toolbarHidden {
            toolbarEndTransform = outEndTransform
            self.toolbar.transform = CGAffineTransformIdentity
            self.toolbar.hidden = false
        }
        else {
            toolbar.setItems(newVisibleViewController.toolbarItems, animated: animated)
        }

        if wasNavbarHidden && !navigationBarHidden {
            self.navigationBar.transform = inStartTransform
            self.navigationBar.hidden = false
        }
        else if !wasNavbarHidden && navigationBarHidden {
            navbarEndTransform = outEndTransform
            self.navigationBar.transform = CGAffineTransformIdentity
            self.navigationBar.hidden = false
        }

        newVisibleViewController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.view!.insertSubview(newVisibleViewController.view!, atIndex: 0)
        newVisibleViewController.view.transform = inStartTransform
        UIView.animateWithDuration(animated ? 0.33 : 0, animations: {() -> Void in
            oldVisibleViewController.view.transform = outEndTransform
            newVisibleViewController.view.transform = CGAffineTransformIdentity
            self.toolbar.transform = toolbarEndTransform
            self.navigationBar.transform = navbarEndTransform
        }, completion: {(finished: Bool) -> Void in
            oldVisibleViewController.view!.removeFromSuperview()
            self.toolbar.hidden = toolbarHidden
            self.navigationBar.hidden = navigationBarHidden
            oldVisibleViewController.endAppearanceTransition()
            newVisibleViewController.endAppearanceTransition()
            // not sure if this is safe or not, really, but the real one must do something along these lines?
            // it could perform this check in a variety of ways, though, with subtly different results so I'm
            // not sure what's best. this seemed generally safest.
            if oldVisibleViewController && isPushing {
                oldVisibleViewController.didMoveToParentViewController(nil)
            }
            else {
                newVisibleViewController.didMoveToParentViewController(self)
            }
            self.delegate.navigationController(self, didShowViewController: newVisibleViewController, animated: animated)
        })
        self.isUpdating = false
    }

    func viewWillLayoutSubviews() {
        if needsDeferredUpdate {
            self.needsDeferredUpdate = false
            self._updateVisibleViewController(false)
        }
    }

    func setViewControllers(newViewControllers: [AnyObject]) {
        self.setViewControllers(newViewControllers, animated: false)
    }

    func setToolbarHidden(hidden: Bool) {
        self.setToolbarHidden(hidden, animated: false)
    }

    func setContentSizeForViewInPopover(newSize: CGSize) {
        self.topViewController.contentSizeForViewInPopover = newSize
    }

    func contentSizeForViewInPopover() -> CGSize {
        return self.topViewController.contentSizeForViewInPopover
    }

    func setNavigationBarHidden(navigationBarHidden: Bool) {
        self.setNavigationBarHidden(navigationBarHidden, animated: false)
    }

    func defaultResponderChildViewController() -> UIViewController {
        return self.topViewController!
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

extension UIViewController {
    func _removeFromParentViewController() {
    }
}