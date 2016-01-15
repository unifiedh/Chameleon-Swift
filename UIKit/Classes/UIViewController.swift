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

public class UIViewController: UIResponder {
	public init(nibName: String?, bundle nibBundle: NSBundle?) {
            self.contentSizeForViewInPopover = CGSizeMake(320, 1100)
            self.hidesBottomBarWhenPushed = false
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveMemoryWarning", name: UIApplicationDidReceiveMemoryWarningNotification, object: UIApplication.sharedApplication())
		super.init()
    }
    // won't load a nib no matter what you do!

    func isViewLoaded() -> Bool {
        return (view != nil)
    }

	func loadView() {
        self.view = UIView(frame: CGRectMake(0, 0, 320, 480))
    }

	func viewDidLoad() {
    }

    func viewDidUnload() {
    }

	func viewWillAppear(animated: Bool) {
    }

	func viewDidAppear(animated: Bool) {
    }

	func viewWillDisappear(animated: Bool) {
    }

	func viewDidDisappear(animated: Bool) {
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

	func presentModalViewController(modalViewController: UIViewController, animated: Bool) {
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

	func dismissModalViewControllerAnimated(animated: Bool) {
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

	func didReceiveMemoryWarning() {
    }
    // is called when UIApplicationDidReceiveMemoryWarningNotification is posted, which is currently only done by private API for.. fun, I guess?

    func setToolbarItems(toolbarItems: [UIToolbarItem], animated: Bool) {
		if toolbarItems == toolbarItems {
			self.toolbarItems = toolbarItems
			self.navigationController?.toolbar.setItems(toolbarItems, animated: animated)
		}
    }

    func setEditing(editing: Bool, animated: Bool) {
        _editing = editing
    }

    func editButtonItem() -> UIBarButtonItem? {
        // this should really return a fancy bar button item that toggles between edit/done and sends setEditing:animated: messages to this controller
        return nil
    }

	func shouldAutorotateToInterfaceOrientation(interfaceOrientation: UIInterfaceOrientation) -> Bool {
        return (interfaceOrientation == .Portrait)
    }

    func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
    }

	func willAnimateRotationToInterfaceOrientation(interfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
    }

	func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
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
        return (appearanceTransitionStack > 0) && (parentageTransition == .FromParent)
    }

    func isMovingToParentViewController() -> Bool {
        return (appearanceTransitionStack > 0) && (parentageTransition == .ToParent)
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
        assert(childController.parentViewController == nil, "thou shalt have no other parent before me")
        childController.willMoveToParentViewController(self)
        childViewControllers.append(childController)
        childController.parentViewController = self
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

    func transitionFromViewController(fromViewController: UIViewController, toViewController: UIViewController, duration: NSTimeInterval, options: UIViewAnimationOptions, animations: (() -> Void)?, completion: ((finished: Bool) -> Void)?) {
        assert(fromViewController.parentViewController == toViewController.parentViewController && fromViewController.parentViewController != nil, "child controllers must share common parent")
        let animated: Bool = (duration > 0)
        fromViewController.beginAppearanceTransition(false, animated: animated)
        toViewController.beginAppearanceTransition(true, animated: animated)
        UIView.transitionWithView(self.view!, duration: duration, options: options, animations: {() -> Void in
            if let animations = animations {
                animations()
            }
            self.view!.addSubview(toViewController.view!)
        }, completion: {(finished: Bool) -> Void in
            if let completion = completion {
                completion(finished: finished)
            }
            fromViewController.view!.removeFromSuperview()
            fromViewController.endAppearanceTransition()
            toViewController.endAppearanceTransition()
        })
    }

	func beginAppearanceTransition(isAppearing: Bool, animated: Bool) {
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
                _ = self.view
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

	func endAppearanceTransition() {
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

    func willMoveToParentViewController(parent: UIViewController?) {
        if parent != nil {
            self.parentageTransition = .ToParent
        }
        else {
            self.parentageTransition = .FromParent
        }
    }

    func didMoveToParentViewController(parent: UIViewController?) {
        //self.parentageTransition = .None
    }
    var nibName: String? {
        get {
            return nil
        }
    }

    var nibBundle: NSBundle? {
        get {
            return nil
        }
    }

    var view: UIView? {
        get {
            if self.isViewLoaded() {
                return _view!
            }
            else {
                let wereEnabled = UIView.areAnimationsEnabled()
                UIView.setAnimationsEnabled(false)
                self.loadView()
                self.viewDidLoad()
				UIView.setAnimationsEnabled(wereEnabled)
                return _view
            }
        }
        set(aView) {
            if aView !== view {
                self.view?.viewController = nil
                self.view = aView
                self.view?.viewController = self
            }
        }
    }

    var wantsFullScreenLayout: Bool
    var title: String {
		didSet {
			navigationItem.title = title
		}
    }

    var interfaceOrientation: UIInterfaceOrientation

	lazy var navigationItem: UINavigationItem = {
		return UINavigationItem(title: self.title)
	}()

	private var _toolbarItems: [UIToolbarItem]
    var toolbarItems: [UIToolbarItem] {
        get {
            return _toolbarItems
        }
        set(theToolbarItems) {
			setToolbarItems(theToolbarItems, animated: false)
        }
    }

	private var editing: Bool {
		get {
			return _editing
		}
		set {
			self.setEditing(editing, animated: false)
		}
	}
	
	public var _editing: Bool = false
	
    var hidesBottomBarWhenPushed: Bool
    var contentSizeForViewInPopover: CGSize
    var modalInPopover: Bool
    var modalPresentationStyle: UIModalPresentationStyle
    var modalTransitionStyle: UIModalTransitionStyle
    var definesPresentationContext: Bool
    var providesPresentationContextTransitionStyle: Bool
    weak var parentViewController: UIViewController?

    var childViewControllers = [UIViewController]()

    var presentingViewController: UIViewController? {
        get {
            // TODO
            return nil
        }
    }

    var presentedViewController: UIViewController? {
        get {
            // TODO
            return nil
        }
    }

    var navigationController: UINavigationController? {
        get {
            return self.nearestParentViewControllerThatIsKindOf(UINavigationController.self)
        }
    }

    var splitViewController: UISplitViewController? {
        get {
            return self.nearestParentViewControllerThatIsKindOf(UISplitViewController.self)
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
    var _view: UIView?
    var appearanceTransitionStack: Int = 0
    var appearanceTransitionIsAnimated: Bool = false
    var viewIsAppearing: Bool = false
    var parentageTransition: _UIViewControllerParentageTransition = .None


    public convenience override init() {
		self.init(nibName: nil, bundle: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidReceiveMemoryWarningNotification, object: UIApplication.sharedApplication())
        view?.viewController = nil
    }

    override func nextResponder() -> UIResponder? {
        return view?.superview
    }

    func defaultResponderChildViewController() -> UIViewController? {
        return nil
    }

    func defaultResponder() -> UIResponder? {
        return nil
    }
	
    func nearestParentViewControllerThatIsKindOf<T>(c: T.Type) -> T? {
		var controller = parentViewController
        while controller != nil && !(controller is T) {
            controller = controller!.parentViewController
        }
        return controller as? T
    }

	public override var description: String {
        return "<\(self.className): \(self); title = \(self.title); view = \(self.view!)>"
    }

    func _removeFromParentViewController() {
        if let parentViewController = parentViewController {
			if let idx = parentViewController.childViewControllers.indexOf(self) {
				parentViewController.childViewControllers.removeAtIndex(idx)
			}
            if parentViewController.childViewControllers.count == 0 {
                parentViewController.childViewControllers = []
            }
            self.parentViewController = nil
        }
    }
}

internal enum _UIViewControllerParentageTransition : Int {
    case None = 0
    case ToParent
    case FromParent
}
