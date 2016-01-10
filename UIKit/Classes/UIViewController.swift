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

enum UIModalPresentationStyle : Int {
    case UIModalPresentationFullScreen = 0
    case UIModalPresentationPageSheet
    case UIModalPresentationFormSheet
    case UIModalPresentationCurrentContext
}

enum UIModalTransitionStyle : Int {
    case CoverVertical = 0
    case FlipHorizontal
    case CrossDissolve
    case PartialCurl
}

class UIViewController: UIResponder {
    override init(nibName: String, bundle nibBundle: NSBundle) {
        if (self.init()) {
            self.contentSizeForViewInPopover = CGSizeMake(320, 1100)
            self.hidesBottomBarWhenPushed = false
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveMemoryWarning", name: UIApplicationDidReceiveMemoryWarningNotification, object: UIApplication.sharedApplication())
        }
    }
    // won't load a nib no matter what you do!

    func isViewLoaded() -> Bool {
        return (view != nil)
    }

    override func loadView() {
        self.view = UIView(frame: CGRectMake(0, 0, 320, 480))
    }

    override func viewDidLoad() {
    }

    func viewDidUnload() {
    }

    override func viewWillAppear(animated: Bool) {
    }

    override func viewDidAppear(animated: Bool) {
    }

    override func viewWillDisappear(animated: Bool) {
    }

    override func viewDidDisappear(animated: Bool) {
    }

    func viewWillLayoutSubviews() {
    }

    func viewDidLayoutSubviews() {
    }

    func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: () -> Void) {
    }

    func dismissViewControllerAnimated(flag: Bool, completion: () -> Void) {
    }
    // these are deprecated on iOS 6

    override func presentModalViewController(modalViewController: UIViewController, animated: Bool) {
        /*
            if (!_modalViewController && _modalViewController != self) {
                _modalViewController = modalViewController;
                [_modalViewController _setParentViewController:self];
        
                UIWindow *window = self.view.window;
                UIView *selfView = self.view;
                UIView *newView = _modalViewController.view;
        
                newView.autoresizingMask = selfView.autoresizingMask;
                newView.frame = _wantsFullScreenLayout? window.screen.bounds : window.screen.applicationFrame;
        
                [window addSubview:newView];
                [_modalViewController viewWillAppear:animated];
        
                [self viewWillDisappear:animated];
                selfView.hidden = YES;		// I think the real one may actually remove it, which would mean needing to remember the superview, I guess? Not sure...
                [self viewDidDisappear:animated];
        
                [_modalViewController viewDidAppear:animated];
            }
             */
    }
    // works, but not exactly correctly.

    override func dismissModalViewControllerAnimated(animated: Bool) {
        /*
            // NOTE: This is not implemented entirely correctly - the actual dismissModalViewController is somewhat subtle.
            // There is supposed to be a stack of modal view controllers that dismiss in a specific way,e tc.
            // The whole system of related view controllers is not really right - not just with modals, but everything else like
            // navigationController, too, which is supposed to return the nearest nav controller down the chain and it doesn't right now.
        
            if (_modalViewController) {
                
                // if the modalViewController being dismissed has a modalViewController of its own, then we need to go dismiss that, too.
                // otherwise things can be left hanging around.
                if (_modalViewController.modalViewController) {
                    [_modalViewController dismissModalViewControllerAnimated:animated];
                }
                
                self.view.hidden = NO;
                [self viewWillAppear:animated];
                
                [_modalViewController.view removeFromSuperview];
                [_modalViewController _setParentViewController:nil];
                _modalViewController = nil;
        
                [self viewDidAppear:animated];
            } else {
                [self.parentViewController dismissModalViewControllerAnimated:animated];
            }
             */
    }
    // see comments in dismissModalViewController

    override func didReceiveMemoryWarning() {
    }
    // is called when UIApplicationDidReceiveMemoryWarningNotification is posted, which is currently only done by private API for.. fun, I guess?

    func setToolbarItems(toolbarItems: [AnyObject], animated: Bool) {
    }

    func setEditing(editing: Bool, animated: Bool) {
        self.editing = editing
    }

    func editButtonItem() -> UIBarButtonItem {
        // this should really return a fancy bar button item that toggles between edit/done and sends setEditing:animated: messages to this controller
        return nil
    }

    override func shouldAutorotateToInterfaceOrientation(interfaceOrientation: UIInterfaceOrientation) -> Bool {
        return (interfaceOrientation == .Portrait)
    }

    func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
    }

    override func willAnimateRotationToInterfaceOrientation(interfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
    }

    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
    }

    func isMovingFromParentViewController() -> Bool {
        // Docs don't say anything about being required to call super for -willMoveToParentViewController: and people
        // on StackOverflow seem to tell each other they can override the method without calling super. Based on that,
        // I have no freakin' idea how this method here is meant to know when to return YES...
        // I'm inclined to think that the docs are just unclear and that -willMoveToParentViewController: and
        // -didMoveToParentViewController: must have to do *something* for this to work without ambiguity.
        // Now that I think about it some more, I suspect that it is far better to assume the docs imply you must call
        // super when you override a method *unless* it says not to. If that assumption is sound, then in that case it
        // suggests that when overriding -willMoveToParentViewController: and -didMoveToParentViewController: you are
        // expected to call super anyway, which means I could put some implementation in the base class versions safely.
        // Generally docs do tend to say things like, "parent implementation does nothing" when they mean you can skip
        // the call to super, and the docs currently say no such thing for -will/didMoveToParentViewController:.
        // In all likely hood, all that would happen if you didn't call super from a -will/didMoveToParentViewController:
        // override is that -isMovingFromParentViewController and -isMovingToParentViewController would return the
        // wrong answer, and if you never use them, you'll never even notice that bug!
        return (appearanceTransitionStack > 0) && (parentageTransition == UIViewControllerParentageTransitionFromParent)
    }

    func isMovingToParentViewController() -> Bool {
        return (appearanceTransitionStack > 0) && (parentageTransition == UIViewControllerParentageTransitionToParent)
    }

    func isBeingPresented() -> Bool {
        // TODO
        return (appearanceTransitionStack > 0) && (false)
    }

    func isBeingDismissed() -> Bool {
        // TODO
        return (appearanceTransitionStack > 0) && (false)
    }

    func addChildViewController(childController: UIViewController) {
        assert(childController != nil, "cannot add nil child view controller")
        assert(childController.parentViewController == nil, "thou shalt have no other parent before me")
        if !childViewControllers {
            self.childViewControllers = [AnyObject](minimumCapacity: 1)
        }
        childController.willMoveToParentViewController(self)
        childViewControllers.append(childController)
        childController->parentViewController = self
    }

    func removeFromParentViewController() {
        assert(self.parentViewController != nil, "view controller has no parent")
        self._removeFromParentViewController()
        self.didMoveToParentViewController(nil)
    }

    func shouldAutomaticallyForwardRotationMethods() -> Bool {
        return true
    }

    func shouldAutomaticallyForwardAppearanceMethods() -> Bool {
        return true
    }

    func transitionFromViewController(fromViewController: UIViewController, toViewController: UIViewController, duration: NSTimeInterval, options: UIViewAnimationOptions, animations: () -> Void, completion: (finished: Bool) -> Void) {
        assert(fromViewController.parentViewController == toViewController.parentViewController && fromViewController.parentViewController != nil, "child controllers must share common parent")
        let animated: Bool = (duration > 0)
        fromViewController.beginAppearanceTransition(false, animated: animated)
        toViewController.beginAppearanceTransition(true, animated: animated)
        UIView.transitionWithView(self.view!, duration: duration, options: options, animations: {() -> Void in
            if animations != nil {
                animations()
            }
            self.view!.addSubview(toViewController.view!)
        }, completion: {(finished: Bool) -> Void in
            if completion != nil {
                completion(finished)
            }
            fromViewController.view!.removeFromSuperview()
            fromViewController.endAppearanceTransition()
            toViewController.endAppearanceTransition()
        })
    }

    override func beginAppearanceTransition(isAppearing: Bool, animated: Bool) {
        if appearanceTransitionStack == 0 || (appearanceTransitionStack > 0 && viewIsAppearing != isAppearing) {
            self.appearanceTransitionStack = 1
            self.appearanceTransitionIsAnimated = animated
            self.viewIsAppearing = isAppearing
            if self.shouldAutomaticallyForwardAppearanceMethods() {
                for child: UIViewController in self.childViewControllers {
                    if child.isViewLoaded() && child.view!.isDescendantOfView(self.view!) {
                        child.beginAppearanceTransition(isAppearing, animated: animated)
                    }
                }
            }
            if viewIsAppearing {
                self.view!
                // ensures the view is loaded before viewWillAppear: happens
                self.viewWillAppear(appearanceTransitionIsAnimated)
            }
            else {
                self.viewWillDisappear(appearanceTransitionIsAnimated)
            }
        }
        else {
            appearanceTransitionStack++
        }
    }
    // iOS 6+

    override func endAppearanceTransition() {
        if appearanceTransitionStack > 0 {
            appearanceTransitionStack--
            if appearanceTransitionStack == 0 {
                if self.shouldAutomaticallyForwardAppearanceMethods() {
                    for child: UIViewController in self.childViewControllers {
                        child.endAppearanceTransition()
                    }
                }
                if viewIsAppearing {
                    self.viewDidAppear(appearanceTransitionIsAnimated)
                }
                else {
                    self.viewDidDisappear(appearanceTransitionIsAnimated)
                }
            }
        }
    }
    // iOS 6+

    func willMoveToParentViewController(parent: UIViewController) {
        if parent != nil {
            self.parentageTransition = UIViewControllerParentageTransitionToParent
        }
        else {
            self.parentageTransition = UIViewControllerParentageTransitionFromParent
        }
    }

    func didMoveToParentViewController(parent: UIViewController) {
        self.parentageTransition = UIViewControllerParentageTransitionNone
    }
    var nibName: String {
        get {
            return nil
        }
    }

    var nibBundle: NSBundle {
        get {
            return nil
        }
    }

    var view: UIView {
        get {
            if self.isViewLoaded() {
                return view
            }
            else {
                let wereEnabled: Bool = UIView.areAnimationsEnabled()
                UIView.animationsEnabled = false
                self.loadView()
                self.viewDidLoad()
                UIView.animationsEnabled = wereEnabled
                return view
            }
        }
        set {
            if aView != view {
                view._setViewController(nil)
                self.view = aView
                view._setViewController(self)
            }
        }
    }

    var wantsFullScreenLayout: Bool
    var title: String {
        get {
            return self.title
        }
        set {
            if !title!.isEqual(title!) {
                self.title = title!.copy()
                self.navigationItem.title = title!
            }
        }
    }

    var interfaceOrientation: UIInterfaceOrientation {
        get {
            return .Portrait as! UIInterfaceOrientation
        }
    }

    var navigationItem: UINavigationItem {
        get {
            if !navigationItem {
                self.navigationItem = UINavigationItem(title: self.title)
            }
            return navigationItem
        }
    }

    var toolbarItems: [AnyObject] {
        get {
            return self.toolbarItems
        }
        set {
            if !toolbarItems.isEqual(theToolbarItems) {
                self.toolbarItems = theToolbarItems
                self.navigationController.toolbar.setItems(toolbarItems, animated: animated)
            }
        }
    }

    var editing: Bool {
        get {
            return self.editing
        }
        set {
            self.editing = editing
        }
    }

    var hidesBottomBarWhenPushed: Bool
    var contentSizeForViewInPopover: CGSize
    var modalInPopover: Bool
    var modalPresentationStyle: UIModalPresentationStyle
    var modalTransitionStyle: UIModalTransitionStyle
    var definesPresentationContext: Bool
    var providesPresentationContextTransitionStyle: Bool
    var parentViewController: UIViewController {
        get {
            return self.parentViewController
        }
    }

    var childViewControllers: [AnyObject] {
        get {
            return childViewControllers.copy()
        }
    }

    var presentingViewController: UIViewController {
        get {
            // TODO
            return nil
        }
    }

    var presentedViewController: UIViewController {
        get {
            // TODO
            return nil
        }
    }

    var navigationController: UINavigationController {
        get {
            return self._nearestParentViewControllerThatIsKindOf(UINavigationController)
        }
    }

    var splitViewController: UISplitViewController {
        get {
            return self._nearestParentViewControllerThatIsKindOf(UISplitViewController)
        }
    }

    var tabBarController: UITabBarController {
        get {
            return self.tabBarController
        }
    }

    var searchDisplayController: UISearchDisplayController {
        get {
            return self.searchDisplayController
        }
    }

    var modalViewController: UIViewController {
        get {
            return self.modalViewController
        }
    }

    var tabBarItem: UITabBarItem
    var self.view: UIView
    var self.navigationItem: UINavigationItem
    var self.childViewControllers: [AnyObject]
    var self.parentViewController: UIViewController
    var self.appearanceTransitionStack: Int
    var self.appearanceTransitionIsAnimated: Bool
    var self.viewIsAppearing: Bool
    var self.parentageTransition: _UIViewControllerParentageTransition


    convenience override init() {
        return self(nibName: nil, bundle: nil)
    }

    func dealloc() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidReceiveMemoryWarningNotification, object: UIApplication.sharedApplication())
        view._setViewController(nil)
    }

    func nextResponder() -> UIResponder {
        return view.superview
    }

    func defaultResponderChildViewController() -> UIViewController {
        return nil
    }

    func defaultResponder() -> UIResponder {
        return nil
    }

    func setToolbarItems(theToolbarItems: [AnyObject]) {
        self.setToolbarItems(theToolbarItems, animated: false)
    }

    func setEditing(editing: Bool) {
        self.setEditing(editing, animated: false)
    }

    convenience override init(c: AnyClass) {
        var controller: UIViewController = parentViewController
        while controller && !(controller is c) {
            controller = controller.parentViewController()
        }
        return controller
    }

    func description() -> String {
        return "<\(self.className()): \(self); title = \(self.title); view = \(self.view!)>"
    }

    func _removeFromParentViewController() {
        if parentViewController {
            parentViewController->childViewControllers.removeObject(self)
            if parentViewController->childViewControllers.count == 0 {
                self.parentViewController->childViewControllers = nil
            }
            self.parentViewController = nil
        }
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

enum UIViewControllerParentageTransition : Int {
    case _UIViewControllerParentageTransitionNone = 0
    case _UIViewControllerParentageTransitionToParent
    case _UIViewControllerParentageTransitionFromParent
}