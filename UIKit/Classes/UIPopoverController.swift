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
        //UIPopoverArrowDirectionUp = 1UL << 0, UIPopoverArrowDirectionDown = 1UL << 1, UIPopoverArrowDirectionLeft = 1UL << 2, UIPopoverArrowDirectionRight = 1UL << 3, UIPopoverArrowDirectionAny = [.Up, .Down, .Left, .Right], UIPopoverArrowDirectionUnknown = NSUIntegerMax}

@objc protocol UIPopoverControllerDelegate: NSObjectProtocol {
    optional func popoverControllerDidDismissPopover(popoverController: UIPopoverController)

    optional func popoverControllerShouldDismissPopover(popoverController: UIPopoverController) -> Bool
}

class UIPopoverController: NSObject {
    convenience override init(contentViewController viewController: UIViewController) {
        if (self = self()) {
            self.contentViewController = viewController
        }
    }

    func setContentViewController(controller: UIViewController, animated: Bool) {
        if controller != contentViewController {
            if self.isPopoverVisible() {
                popoverView.setContentView(controller.view!, animated: animated)
            }
            self.contentViewController = controller!
        }
    }

    func setPopoverContentSize(size: CGSize, animated: Bool) {
        self.popoverContentSize = size
    }

    func presentPopoverFromRect(rect: CGRect, inView view: UIView, permittedArrowDirections arrowDirections: UIPopoverArrowDirection, animated: Bool) {
        assert(isDismissing == false)
        assert(view != nil)
        assert(arrowDirections != .Unknown)
        assert(!CGRectIsNull(rect))
        assert(!CGRectEqualToRect(rect, CGRectZero))
        assert(view.window.screen.UIKitView.window() != nil)
        var viewNSWindow: NSWindow = view.window.screen.UIKitView.window()
        // only create new stuff if the popover isn't already visible
        if !self.isPopoverVisible() {
            assert(overlayWindow == nil)
            assert(popoverView == nil)
            assert(popoverWindow == nil)
            // build an overlay window which will capture any clicks on the main window the popover is being presented from and then dismiss it.
            // this overlay can also be used to implement the pass-through views of the popover, but I'm not going to do that right now since
            // we don't need it. attach the overlay window to the "main" window.
            var windowFrame: NSRect = viewNSWindow.frame
            var overlayContentRect: NSRect = NSMakeRect(0, 0, windowFrame.size.width, windowFrame.size.height)
            self.overlayWindow = NSWindow(contentRect: overlayContentRect, styleMask: NSBorderlessWindowMask, backing: NSBackingStoreBuffered, defer: true)
            overlayWindow.releasedWhenClosed = false
            overlayWindow.contentView = UIPopoverOverlayNSView(frame: overlayContentRect, popoverController: self)
            overlayWindow.ignoresMouseEvents = false
            overlayWindow.opaque = false
            overlayWindow.backgroundColor = NSColor.clearColor()
            overlayWindow.frameOrigin = windowFrame.origin
            viewNSWindow.addChildWindow(overlayWindow, ordered: NSWindowAbove)
            // now build the actual popover view which represents the popover's chrome, and since it's a UIView, we need to build a UIKitView 
            // as well to put it in our NSWindow...
            self.popoverView = UIPopoverView(contentView: contentViewController.view!, size: contentViewController.contentSizeForViewInPopover)
            popoverView.hidden = true
            var hostingView: UIKitView = UIKitView(frame: NSRectFromCGRect(popoverView.bounds))
            hostingView.UIWindow().addSubview(popoverView)
            // now finally make the actual popover window itself and attach it to the overlay window
            self.popoverWindow = UIPopoverNSWindow(contentRect: hostingView.bounds, styleMask: NSBorderlessWindowMask, backing: NSBackingStoreBuffered, defer: true)
            popoverWindow.releasedWhenClosed = false
            popoverWindow.alphaValue = 0
            // prevents a flash as the window moves from the wrong position into the right position
            popoverWindow.contentView = hostingView
            popoverWindow.popoverController = self
            popoverWindow.opaque = false
            popoverWindow.backgroundColor = NSColor.clearColor()
            overlayWindow.addChildWindow(popoverWindow, ordered: NSWindowAbove)
        }
        // cancel current touches (if any) to prevent the main window from losing track of events (such as if the user was holding down the mouse
        // button and a timer triggered the appearance of this popover. the window would possibly then not receive the mouseUp depending on how
        // all this works out... I first ran into this problem with NSMenus. A NSWindow is a bit different, but I think this makes sense here
        // too so premptively doing it to avoid potential problems.)
        UIApplicationInterruptTouchesInView(nil)
        // now position the popover window according to the passed in parameters.
        var windowRect: CGRect = view.convertRect(rect, toView: nil)
        var screenRect: CGRect = view.window.convertRect(windowRect, toWindow: nil)
        var desktopScreenRect: CGRect = view.window.screen.convertRect(screenRect, toScreen: nil)
        var pointTo: NSPoint = NSMakePoint(0, 0)
        // finally, let's show it!
        popoverWindow.frameOrigin = PopoverWindowOrigin(overlayWindow, NSRectFromCGRect(desktopScreenRect), NSSizeFromCGSize(popoverView.frame.size), arrowDirections, pointTo, popoverArrowDirection)
        popoverWindow.alphaValue = 1
        popoverView.hidden = false
        popoverWindow.makeFirstResponder(popoverWindow.contentView())
        popoverWindow.makeKeyWindow()
        // the window has to be visible before these coordinate conversions will work correctly (otherwise the UIScreen isn't attached to anything
        // and blah blah blah...)
        // finally, set the arrow position so it points to the right place and looks all purty.
        if popoverArrowDirection != .Unknown {
            var screenPointTo: CGPoint = view.window.screen.convertPoint(NSPointToCGPoint(pointTo), fromScreen: nil)
            var windowPointTo: CGPoint = view.window.convertPoint(screenPointTo, fromWindow: nil)
            var viewPointTo: CGPoint = view.convertPoint(windowPointTo, fromView: nil)
            popoverView.pointTo(viewPointTo, inView: view)
        }
        if animated {
            self.popoverView.transform = CGAffineTransformMakeScale(0.98, 0.98)
            self.popoverView.alpha = 0.4
            UIView.animateWithDuration(0.08, animations: {() -> Void in
                self.popoverView.transform = CGAffineTransformIdentity
            })
            UIView.animateWithDuration(0.1, animations: {() -> Void in
                self.popoverView.alpha = 1.0
            })
        }
    }

    func presentPopoverFromBarButtonItem(item: UIBarButtonItem, permittedArrowDirections arrowDirections: UIPopoverArrowDirection, animated: Bool) {
    }

    func dismissPopoverAnimated(animated: Bool) {
        if !isDismissing && self.isPopoverVisible() {
            self.isDismissing = true
            UIView.animateWithDuration(animated ? 0.2 : 0, animations: {() -> Void in
                self.popoverView.alpha = 0
            }, completion: {(finished: Bool) -> Void in
                self._destroyPopover()
            })
        }
    }
    weak var delegate: UIPopoverControllerDelegate?

    var contentViewController: UIViewController {
        get {
            return self.contentViewController
        }
        set {
            if controller != contentViewController {
                if self.isPopoverVisible() {
                    popoverView.setContentView(controller.view!, animated: animated)
                }
                self.contentViewController = controller!
            }
        }
    }

    var popoverVisible: Bool {
        get {
            return (popoverView || popoverWindow || overlayWindow)
        }
    }

    var passthroughViews: [AnyObject]
    var popoverArrowDirection: UIPopoverArrowDirection {
        get {
            return self.popoverArrowDirection
        }
    }

    var popoverContentSize: CGSize {
        get {
            return self.popoverContentSize
        }
        set {
            self.popoverContentSize = size
        }
    }
    var self.popoverView: UIPopoverView
    var self.popoverWindow: UIPopoverNSWindow
    var self.overlayWindow: NSWindow
    var self.isDismissing: Bool
    var self.delegateHas: struct{unsignedpopoverControllerDidDismissPopover:1;unsignedpopoverControllerShouldDismissPopover:1;}


    convenience override init() {
        if (self.init()) {
            self.popoverArrowDirection = .Unknown
        }
    }

    func dealloc() {
        self._destroyPopover()
    }

    func setContentViewController(viewController: UIViewController) {
        self.setContentViewController(viewController, animated: false)
    }

    func setPopoverContentSize(size: CGSize) {
        self.setPopoverContentSize(size, animated: false)
    }

    func _destroyPopover() {
        var parentWindow: NSWindow = overlayWindow.parentWindow()
        overlayWindow.removeChildWindow(popoverWindow)
        parentWindow.removeChildWindow(overlayWindow)
        popoverWindow.close()
        overlayWindow.close()
        self.popoverWindow = nil
        self.overlayWindow = nil
        self.popoverView = nil
        self.popoverArrowDirection = .Unknown
        parentWindow.makeKeyAndOrderFront(self)
        self.isDismissing = false
    }

    func _closePopoverWindowIfPossible() {
        if !isDismissing && self.isPopoverVisible() {
            let shouldDismiss: Bool = delegateHas.popoverControllerShouldDismissPopover ? delegate.popoverControllerShouldDismissPopover(self) : true
            if shouldDismiss {
                self.dismissPopoverAnimated(true)
                if delegateHas.popoverControllerDidDismissPopover {
                    delegate.popoverControllerDidDismissPopover(self)
                }
            }
        }
    }
}
/*
        return (size1.width <= size2.width) && (size1.height <= size2.height)

        // 1) define a set of possible quads around fromRect that the popover could appear in
        // 2) eliminate quads based on arrow direction restrictions and sizes
        // 3) the first quad that is large enough "wins"
        var screenRect: NSRect = inWindow.screen().visibleFrame()
        var bottomQuad: NSRect = NSMakeRect(screenRect.origin.x, screenRect.origin.y, screenRect.size.width, fromRect.origin.y - screenRect.origin.y)
        var topQuad: NSRect = NSMakeRect(screenRect.origin.x, fromRect.origin.y + fromRect.size.height, screenRect.size.width, screenRect.size.height - fromRect.origin.y - fromRect.size.height - screenRect.origin.y)
        var leftQuad: NSRect = NSMakeRect(screenRect.origin.x, screenRect.origin.y, fromRect.origin.x - screenRect.origin.x, screenRect.size.height - screenRect.origin.y)
        var rightQuad: NSRect = NSMakeRect(fromRect.origin.x + fromRect.size.width, screenRect.origin.y, screenRect.size.width - fromRect.origin.x - fromRect.size.width - screenRect.origin.x, screenRect.size.height - screenRect.origin.y)
        pointTo->x = fromRect.origin.x + (fromRect.size.width / 2.0)
        pointTo->y = fromRect.origin.y + (fromRect.size.height / 2.0)
        var origin: NSPoint
        origin.x = fromRect.origin.x + (fromRect.size.width / 2.0) - (popoverSize.width / 2.0)
        origin.y = fromRect.origin.y + (fromRect.size.height / 2.0) - (popoverSize.height / 2.0)
        let minimumPadding: CGFloat = 40
        let allowTopOrBottom: Bool = (pointTo->x >= NSMinX(screenRect) + minimumPadding && pointTo->x <= NSMaxX(screenRect) - minimumPadding)
        let allowLeftOrRight: Bool = (pointTo->y >= NSMinY(screenRect) + minimumPadding && pointTo->y <= NSMaxY(screenRect) - minimumPadding)
        let allowTopQuad: Bool = ((arrowDirections & .Down) != 0) && topQuad.size.width > 0 && topQuad.size.height > 0 && allowTopOrBottom
        let allowBottomQuad: Bool = ((arrowDirections & .Up) != 0) && bottomQuad.size.width > 0 && bottomQuad.size.height > 0 && allowTopOrBottom
        let allowLeftQuad: Bool = ((arrowDirections & .Right) != 0) && leftQuad.size.width > 0 && leftQuad.size.height > 0 && allowLeftOrRight
        let allowRightQuad: Bool = ((arrowDirections & .Left) != 0) && rightQuad.size.width > 0 && rightQuad.size.height > 0 && allowLeftOrRight
        let arrowPadding: CGFloat = 8
        // the arrow images are slightly larger to account for shadows, but the arrow point needs to be up against the rect exactly so this helps with that
        if allowBottomQuad && SizeIsLessThanOrEqualSize(popoverSize, bottomQuad.size) {
            pointTo->y = fromRect.origin.y
            origin.y = fromRect.origin.y - popoverSize.height + arrowPadding
            arrowDirection = .Up
        }
        else if allowRightQuad && SizeIsLessThanOrEqualSize(popoverSize, rightQuad.size) {
            pointTo->x = fromRect.origin.x + fromRect.size.width
            origin.x = pointTo->x - arrowPadding
            arrowDirection = .Left
        }
        else if allowLeftQuad && SizeIsLessThanOrEqualSize(popoverSize, leftQuad.size) {
            pointTo->x = fromRect.origin.x
            origin.x = fromRect.origin.x - popoverSize.width + arrowPadding
            arrowDirection = .Right
        }
        else if allowTopQuad && SizeIsLessThanOrEqualSize(popoverSize, topQuad.size) {
            pointTo->y = fromRect.origin.y + fromRect.size.height
            origin.y = pointTo->y - arrowPadding
            arrowDirection = .Down
        }
        else {
            arrowDirection = .Unknown
        }

        var windowRect: NSRect
        windowRect.origin = origin
        windowRect.size = popoverSize
        if NSMaxX(windowRect) > NSMaxX(screenRect) {
            windowRect.origin.x = NSMaxX(screenRect) - popoverSize.width
        }
        if NSMinX(windowRect) < NSMinX(screenRect) {
            windowRect.origin.x = NSMinX(screenRect)
        }
        if NSMaxY(windowRect) > NSMaxY(screenRect) {
            windowRect.origin.y = NSMaxY(screenRect) - popoverSize.height
        }
        if NSMinY(windowRect) < NSMinY(screenRect) {
            windowRect.origin.y = NSMinY(screenRect)
        }
        windowRect.origin.x = roundf(windowRect.origin.x)
        windowRect.origin.y = roundf(windowRect.origin.y)
        return windowRect.origin
*/
