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

class UISplitViewController: UIViewController {
    weak var delegate: UISplitViewControllerDelegate {
        get {
            return self.delegate
        }
        set {
            self.delegate = newDelegate
            self.delegateHas.willPresentViewController = delegate.respondsToSelector("splitViewController:popoverController:willPresentViewController:")
            self.delegateHas.willHideViewController = delegate.respondsToSelector("splitViewController:willHideViewController:withBarButtonItem:forPopoverController:")
            self.delegateHas.willShowViewController = delegate.respondsToSelector("splitViewController:willShowViewController:invalidatingBarButtonItem:")
        }
    }

    var viewControllers: [AnyObject] {
        get {
            return self.viewControllers
        }
        set {
            assert(newControllers.count == 2)
            /*
                if (![newControllers isEqualToArray:_viewControllers]) {
                    for (UIViewController *c in _viewControllers) {
                        [c _setParentViewController:nil];
                    }
            
                    for (UIViewController *c in newControllers) {
                        [c _setParentViewController:self];
                    }
                    
                    if ([self isViewLoaded]) {
            
                        [(_UISplitViewControllerView *)self.view addViewControllers:_viewControllers];
            
                        for (UIViewController *c in newControllers) {
                            [c viewWillAppear:NO];
                        }
                        
                        for (UIViewController *c in _viewControllers) {
                            if ([c isViewLoaded]) {
                                [c.view removeFromSuperview];
                            }
                        }
            
                        for (UIViewController *c in newControllers) {
                            [c viewDidAppear:NO];
                        }
                    }
            
                    _viewControllers = [newControllers copy];
                }
                 */
        }
    }
    var self.delegateHas: struct{unsignedwillPresentViewController:1;unsignedwillHideViewController:1;unsignedwillShowViewController:1;}


    convenience override init(nibName: String, bundle nibBundle: NSBundle) {
        if (self.init(nibName: nibName, bundle: nibBundle)) {

        }
    }

    override func loadView() {
        self.view = UISplitViewControllerView(frame: CGRectMake(0, 0, 1024, 768))
        self.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    }
}
protocol UISplitViewControllerDelegate: NSObject {
    func splitViewController(svc: UISplitViewController, popoverController pc: UIPopoverController, willPresentViewController aViewController: UIViewController)

    func splitViewController(svc: UISplitViewController, willHideViewController aViewController: UIViewController, withBarButtonItem barButtonItem: UIBarButtonItem, forPopoverController pc: UIPopoverController)

    func splitViewController(svc: UISplitViewController, willShowViewController aViewController: UIViewController, invalidatingBarButtonItem button: UIBarButtonItem)
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
    let SplitterPadding: CGFloat = 3

class _UISplitViewControllerView: UIView {
    var dragging: Bool
    var leftPanel: UIView
    var rightPanel: UIView

    var leftWidth: CGFloat {
        get {
            return CGRectGetMaxX(leftPanel.frame)
        }
        set {
            if newWidth != leftPanel.frame.size.width {
                var leftFrame: CGRect = leftPanel.frame
                var rightFrame: CGRect = rightPanel.frame
                let height: CGFloat = self.bounds.size.height
                leftFrame.origin = CGPointZero
                leftFrame.size = CGSizeMake(newWidth, height)
                rightFrame.origin = CGPointMake(newWidth + 1, 0)
                rightFrame.size = CGSizeMake(max(self.bounds.size.width - newWidth - 1, 0), height)
                leftPanel.frame = leftFrame
                rightPanel.frame = rightFrame
            }
        }
    }


    func addViewControllers(viewControllers: [AnyObject]) {
        if viewControllers.count == 2 {
            var leftView: UIView = viewControllers[0].view!
            var rightView: UIView = viewControllers[1].view!
            leftView.autoresizingMask = rightView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            leftView.frame = leftPanel.bounds
            rightView.frame = rightPanel.bounds
            leftPanel.addSubview(leftView)
            rightPanel.addSubview(rightView)
        }
    }

    convenience override init(frame: CGRect) {
        if (self.init(frame: frame)) {
            leftPanel = UIView(frame: CGRectMake(0, 0, 320, frame.size.height))
            rightPanel = UIView(frame: CGRectMake(321, 0, max(0, frame.size.width - 321), frame.size.height))
            leftPanel.clipsToBounds = rightPanel.clipsToBounds = true
            leftPanel.autoresizingMask = .FlexibleHeight
            rightPanel.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            self.addSubview(leftPanel)
            self.addSubview(rightPanel)
            self.backgroundColor = UIColor.blackColor()
        }
    }

    func splitterHitRect() -> CGRect {
        return CGRectMake(self.leftWidth - SplitterPadding, 0, SplitterPadding + SplitterPadding + 1, self.bounds.size.height)
    }

    func hitTest(point: CGPoint, withEvent event: UIEvent) -> UIView {
        if CGRectContainsPoint(self.splitterHitRect(), point) {

        }
        else {
            return super.hitTest(point, withEvent: event)
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var point: CGPoint = touches.first!.locationInView(self)
        if CGRectContainsPoint(self.splitterHitRect(), point) {
            dragging = true
        }
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if dragging {
            var newWidth: CGFloat = touches.first!.locationInView(self).x
            newWidth = max(50, newWidth)
            newWidth = min(self.bounds.size.width - 50, newWidth)
            self.leftWidth = newWidth
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        dragging = false
    }

    func touchesCancelled(touches: Set<AnyObject>, withEvent event: UIEvent) {
        dragging = false
    }

    convenience override init(event: UIEvent) {
        var splitterRect: CGRect = self.splitterHitRect()
        var point: CGPoint = event.allTouches().first!.locationInView(self)
        if dragging && point.x < splitterRect.origin.x {
            return NSCursor.resizeLeftCursor()
        }
        else if dragging && point.x > splitterRect.origin.x + splitterRect.size.width {
            return NSCursor.resizeRightCursor()
        }
        else if dragging || CGRectContainsPoint(splitterRect, point) {
            return NSCursor.resizeLeftRightCursor()
        }
        else {
            return super.mouseCursorForEvent(event)
        }

    }
}