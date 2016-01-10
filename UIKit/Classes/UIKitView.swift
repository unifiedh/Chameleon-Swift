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
import Cocoa
class UIKitView: NSView {
    // returns the UIView (or nil) that successfully responds to a -hitTest:withEvent: at the given point.
    // the point is specified in this view's coordinate system (unlike NSView's hitTest method).
    func hitTestUIView(point: NSPoint) -> UIView {
        var sortedWindows: [AnyObject] = UIScreen.windows.mutableCopy()
        sortedWindows.sortUsingDescriptors([NSSortDescriptor(key: "windowLevel", ascending: false)])
        for window: UIWindow in sortedWindows {
            let windowPoint: CGPoint = window.convertPoint(point, fromWindow: nil)
            var hitView: UIView = window.hitTest(windowPoint, withEvent: nil)
            if hitView != nil {
                return hitView
            }
        }
        return nil
    }
    // this is an optional method
    // it will set the sharedApplication's delegate to appDelegate. if delay is >0, it will then look in the app bundle for
    // various default.png images (ideally it would replicate the search pattern that the iPad does, but for now it's just
    // uses Default-Landscape.png). If delay <= 0, it skips doing any launch stuff and just calls the delegate's
    // applicationDidFinishLaunching: method. It's up to the app delegate to create its own window, just as it is in the real
    // UIKit when not using a XIB.
    // ** IMPORTANT: appDelegate is *not* retained! **

    func launchApplicationWithDelegate(appDelegate: UIApplicationDelegate, afterDelay delay: NSTimeInterval) {
        UIApplication.sharedApplication().delegate = appDelegate
        if delay != 0.0f {
            var defaultImage: UIImage = UIImage(named: "Default-Landscape.png")
            var defaultImageView: UIImageView = UIImageView(image: defaultImage)
            defaultImageView.contentMode = .Center
            var defaultWindow: UIWindow = UIWindow as! UIWindow(frame: UIScreen.bounds)
            defaultWindow.userInteractionEnabled = false
            defaultWindow.screen = UIScreen
            defaultWindow.backgroundColor = UIColor.blackColor()
            // dunno..
            defaultWindow.opaque = true
            defaultWindow.addSubview(defaultImageView)
            defaultWindow.makeKeyAndVisible()
            self.performSelector("launchApplicationWithDefaultWindow:", withObject: defaultWindow, afterDelay: delay)
        }
        else {
            self.launchApplicationWithDefaultWindow(nil)
        }
    }
    // these are sort of hacks used internally. I don't know if there's much need for them from the outside, really.

    func cancelTouchesInView(view: UIView) {
        if touchEvent && touchEvent.touch.phase != .Ended && touchEvent.touch.phase != .Cancelled {
            if !view || view.isDescendantOfView(touchEvent.touch.view!) {
                self.touchEvent.touch.phase = .Cancelled
                self.touchEvent.touch.timestamp = NSDate.timeIntervalSinceReferenceDate()
                UIApplication.sharedApplication().sendEvent(touchEvent)
                touchEvent.endTouchEvent()
                self.touchEvent = nil
            }
        }
    }

    func sendStationaryTouches() {
        if touchEvent && touchEvent.touch.phase != .Ended && touchEvent.touch.phase != .Cancelled {
            self.touchEvent.touch.phase = .Stationary
            self.touchEvent.touch.timestamp = NSDate.timeIntervalSinceReferenceDate()
            UIApplication.sharedApplication().sendEvent(touchEvent)
        }
    }
    // this is an optional property to make it quick and easy to get a window to start adding views to.
    // created on-demand to be the size of the UIScreen.bounds, flexible width/height, and calls makeKeyAndVisible when it is first created
    var UIWindow: UIWindow {
        get {
            if !UIWindow {
                self.UIWindow = UIWindow(frame: UIScreen.bounds)
                self.UIWindow.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                self.UIWindow.screen = UIScreen
                UIWindow.makeKeyAndVisible()
            }
            return UIWindow
        }
    }

    // a UIKitView owns a single UIScreen. when the UIKitView is part of an NSWindow hierarchy, the UIScreen appears as a connected screen in
    // [UIScreen screens], etc.
    var UIScreen: UIScreen {
        get {
            return self.UIScreen
        }
    }
    var self.touchEvent: UITouchEvent
    var self.mouseMoveTouch: UITouch
    var self.UIWindow: UIWindow
    var self.trackingArea: NSTrackingArea
    var self.responderShim: UINSResponderShim


    convenience override init(frame: NSRect) {
        if (self.init(frame: frame)) {
            self.mouseMoveTouch = UITouch()
            self.UIScreen = UIScreen()
            self.responderShim = UINSResponderShim()
            self.responderShim.delegate = self
            self.configureScreenLayer()
        }
    }

    override func awakeFromNib() {
        self.configureScreenLayer()
    }

    func configureScreenLayer() {
        self.wantsLayer = true
        var screenLayer: CALayer = UIScreen._layer()
        var myLayer: CALayer = self.layer
        myLayer.addSublayer(screenLayer)
        screenLayer.frame = myLayer.bounds
        screenLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable
    }

    func isFlipped() -> Bool {
        return true
    }

    func acceptsFirstResponder() -> Bool {
        // we want to accept, but we have to make sure one of our NSView children isn't already the first responder
        // because we don't want to let the mouse just steal that away here. If a pure-UIKit object gets clicked on
        // and decides to become first responder, it'll take it itself and things should sort itself out from there
        // (so stuff like a selected NSTextView would be resigned in the process of the new object becoming first
        // responder so we don't have to let AppKit handle it here in that case and returning NO should be okay
        // because by the time this is called again, the native AppKit control has already been told to resign)
        // the reason we can't just blindly accept first responder is that there are special situations like the
        // inputAccessoryViews which live inside our UIKitView and are implemented as UIKit code, but are often
        // used while the user has a native NSTextView as the first responder because they are typing in it. If
        // we didn't do this checking here, the click outside of the NSTextView would register as a click on this
        // UIKitView, and if we just returned YES here, AppKit would happily resign first responder from the text
        // view and set it for this UIKitView which causes the inputAccessoryView to disappear!
        var responder: NSResponder = self.window() as! NSWindow.firstResponder()
        while responder {
            if responder == self {
                return false
            }
            else {
                responder = responder.nextResponder()
            }
        }
        return true
    }

    func updateUIKitView() {
        UIScreen._setUIKitView((self.superview && self.window) ? self : nil)
    }

    func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        self.updateUIKitView()
    }

    func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        self.updateUIKitView()
    }

    func updateTrackingAreas() {
        super.updateTrackingAreas()
        self.removeTrackingArea(trackingArea)
        self.trackingArea = NSTrackingArea(rect: self.bounds, options: NSTrackingCursorUpdate | NSTrackingMouseMoved | NSTrackingInVisibleRect | NSTrackingActiveInKeyWindow | NSTrackingMouseEnteredAndExited, owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea)
    }

    func launchApplicationWithDefaultWindow(defaultWindow: UIWindow) {
        var app: UIApplication = UIApplication.sharedApplication()
        var appDelegate: UIApplicationDelegate = app.delegate
        if appDelegate.respondsToSelector("application:didFinishLaunchingWithOptions:") {
            appDelegate.application(app, didFinishLaunchingWithOptions: nil)
        }
        else if appDelegate.respondsToSelector("applicationDidFinishLaunching:") {
            appDelegate.applicationDidFinishLaunching(app)
        }

        NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationDidFinishLaunchingNotification, object: app)
        if appDelegate.respondsToSelector("applicationDidBecomeActive:") {
            appDelegate.applicationDidBecomeActive(app)
        }
        NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationDidBecomeActiveNotification, object: app)
        defaultWindow.hidden = true
    }

    func setNextResponder(aResponder: NSResponder) {
        super.nextResponder = responderShim
        responderShim.nextResponder = aResponder
    }

    func responderForResponderShim(shim: UINSResponderShim) -> UIResponder {
        var keyWindow: UIWindow = UIScreen.keyWindow
        var responder: UIResponder = keyWindow._firstResponder()
        if !responder {
            var controller: UIViewController = keyWindow.rootViewController
            while controller {
                // for the sake of completeness, we check the controller's presentedViewController first, because such things are
                // supposed to kind of supercede the view controller itself - however we don't currently support them so it just
                // returns nil all the time anyway, but what the heck, eh?
                if controller.presentedViewController {
                    controller = controller.presentedViewController
                }
                else {
                    var childController: UIViewController = controller.defaultResponderChildViewController()
                    if childController != nil {
                        controller = childController
                    }
                    else {

                    }
                }
            }
            responder = controller.defaultResponder()
        }
        return responder
    }

    func touchForEvent(theEvent: NSEvent) -> UITouch {
        let location: NSPoint = self.convertPoint(theEvent.locationInWindow(), fromView: nil)
        var touch: UITouch = UITouch()
        touch.view = self.hitTestUIView(location)
        touch.locationOnScreen = NSPointToCGPoint(location)
        touch.timestamp = theEvent.timestamp()
        return touch
    }

    func updateTouchLocation(touch: UITouch, withEvent theEvent: NSEvent) {
        self.touchEvent.touch.locationOnScreen = NSPointToCGPoint(self.convertPoint(theEvent.locationInWindow(), fromView: nil))
        self.touchEvent.touch.timestamp = theEvent.timestamp()
    }

    func mouseDown(theEvent: NSEvent) {
        if theEvent.modifierFlags() & NSControlKeyMask {
            // I don't really like this, but it seemed to be necessary.
            // If I override the menuForEvent: method, when you control-click it *still* sends mouseDown:, so I don't
            // really win anything by overriding that since I'd still need a check in here to prevent that mouseDown: from being
            // sent to UIKit as a touch. That seems really wrong, IMO. A right click should be independent of a touch event.
            // soooo.... here we are. Whatever. Seems to work. Don't really like it.
            self.rightMouseDown(NSEvent.mouseEventWithType(NSRightMouseDown, location: theEvent.locationInWindow(), modifierFlags: 0, timestamp: theEvent.timestamp(), windowNumber: theEvent.windowNumber(), context: theEvent.context(), eventNumber: theEvent.eventNumber(), clickCount: theEvent.clickCount(), pressure: theEvent.pressure()))
            return
        }
        // this is a special case to cancel any existing touches (as far as the client code is concerned) if the left
        // mouse button is pressed mid-gesture. the reason is that sometimes when using a magic mouse a user will intend
        // to click but if their finger moves against the surface ever so slightly, it will trigger a touch gesture to
        // begin instead. without this, the fact that we're in a touch gesture phase effectively overrules everything
        // else and clicks end up not getting registered. I don't think it's right to allow clicks to pass through when
        // we're in a gesture state since that'd be somewhat like a multitouch scenerio on an actual iOS device and we
        // are not really supporting anything like that at the moment.
        if touchEvent != nil {
            self.touchEvent.touch.phase = .Cancelled
            self.updateTouchLocation(touchEvent.touch, withEvent: theEvent)
            UIApplication.sharedApplication().sendEvent(touchEvent)
            touchEvent.endTouchEvent()
            self.touchEvent = nil
        }
        if !touchEvent {
            self.touchEvent = UITouchEvent(touch: self.touchForEvent(theEvent))
            self.touchEvent.touchEventGesture = .None
            self.touchEvent.touch.tapCount = theEvent.clickCount()
            UIApplication.sharedApplication().sendEvent(touchEvent)
        }
    }

    func mouseUp(theEvent: NSEvent) {
        if touchEvent && touchEvent.touchEventGesture == .None {
            self.touchEvent.touch.phase = .Ended
            self.updateTouchLocation(touchEvent.touch, withEvent: theEvent)
            UIApplication.sharedApplication().sendEvent(touchEvent)
            touchEvent.endTouchEvent()
            self.touchEvent = nil
        }
    }

    func mouseDragged(theEvent: NSEvent) {
        if touchEvent && touchEvent.touchEventGesture == .None {
            self.touchEvent.touch.phase = .Moved
            self.updateTouchLocation(touchEvent.touch, withEvent: theEvent)
            UIApplication.sharedApplication().sendEvent(touchEvent)
        }
    }

    func beginGestureWithEvent(theEvent: NSEvent) {
        if !touchEvent {
            self.touchEvent = UITouchEvent(touch: self.touchForEvent(theEvent))
            self.touchEvent.touchEventGesture = .Begin
            UIApplication.sharedApplication().sendEvent(touchEvent)
        }
    }

    func endGestureWithEvent(theEvent: NSEvent) {
        if touchEvent && touchEvent.touchEventGesture != .None {
            self.touchEvent.touch.phase = .Ended
            self.updateTouchLocation(touchEvent.touch, withEvent: theEvent)
            UIApplication.sharedApplication().sendEvent(touchEvent)
            touchEvent.endTouchEvent()
            self.touchEvent = nil
        }
    }

    func rotateWithEvent(theEvent: NSEvent) {
        if touchEvent && (touchEvent.touchEventGesture == .Begin || touchEvent.touchEventGesture == .Rotate) {
            self.touchEvent.touch.phase = .Moved
            self.updateTouchLocation(touchEvent.touch, withEvent: theEvent)
            self.touchEvent.touchEventGesture = .Rotate
            self.touchEvent.rotation = theEvent.rotation()
            UIApplication.sharedApplication().sendEvent(touchEvent)
        }
    }

    func magnifyWithEvent(theEvent: NSEvent) {
        if touchEvent && (touchEvent.touchEventGesture == .Begin || touchEvent.touchEventGesture == .Pinch) {
            self.touchEvent.touch.phase = .Moved
            self.updateTouchLocation(touchEvent.touch, withEvent: theEvent)
            self.touchEvent.touchEventGesture = .Pinch
            self.touchEvent.magnification = theEvent.magnification()
            UIApplication.sharedApplication().sendEvent(touchEvent)
        }
    }

    func swipeWithEvent(theEvent: NSEvent) {
        // it seems as if the swipe gesture actually is discrete as far as OSX is concerned and does not occur between gesture begin/end messages
        // which is sort of different.. but.. here we go. :) As a result, I'll require there to not be an existing touchEvent in play before a
        // swipe gesture is recognized.
        if !touchEvent {
            var swipeEvent: UITouchEvent = UITouchEvent(touch: self.touchForEvent(theEvent))
            swipeEvent.touchEventGesture = .Swipe
            swipeEvent.translation = CGPointMake(theEvent.deltaX(), theEvent.deltaY())
            UIApplication.sharedApplication().sendEvent(swipeEvent)
            swipeEvent.endTouchEvent()
        }
    }

    func scrollWheel(theEvent: NSEvent) {
        var dx: Double
        var dy: Double
        var cgEvent: CGEventRef = theEvent.CGEvent()
        let isContinious: int64_t = CGEventGetIntegerValueField(cgEvent, kCGScrollWheelEventIsContinuous)
        if isContinious == 0 {
            var source: CGEventSourceRef = CGEventCreateSourceFromEvent(cgEvent)
            var pixelsPerLine: Double
            if source != nil {
                pixelsPerLine = CGEventSourceGetPixelsPerLine(source)
                CFRelease(source)
            }
            else {
                // docs often say things like, "the default is near 10" so it seems reasonable that if the source doesn't work
                // for some reason to fetch the pixels per line, then 10 is probably a decent fallback value. :)
                pixelsPerLine = 10
            }
            dx = CGEventGetDoubleValueField(cgEvent, kCGScrollWheelEventFixedPtDeltaAxis2) * pixelsPerLine
            dy = CGEventGetDoubleValueField(cgEvent, kCGScrollWheelEventFixedPtDeltaAxis1) * pixelsPerLine
        }
        else {
            dx = CGEventGetIntegerValueField(cgEvent, kCGScrollWheelEventPointDeltaAxis2)
            dy = CGEventGetIntegerValueField(cgEvent, kCGScrollWheelEventPointDeltaAxis1)
        }
        var translation: CGPoint = CGPointMake(-dx, -dy)
        // if this happens within an actual OSX gesture sequence, it is a pan touch gesture event
        // if it happens outside of a gesture, it is a normal mouse event instead
        // if it somehow happens during any other touch sequence, ignore it (someone might be click-dragging with the mouse and also using a wheel)
        if touchEvent != nil {
            if touchEvent.touchEventGesture == .Begin || touchEvent.touchEventGesture == .Pan {
                self.touchEvent.touch.phase = .Moved
                self.updateTouchLocation(touchEvent.touch, withEvent: theEvent)
                self.touchEvent.touchEventGesture = .Pan
                self.touchEvent.translation = translation
                UIApplication.sharedApplication().sendEvent(touchEvent)
            }
        }
        else {
            var mouseEvent: UITouchEvent = UITouchEvent(touch: self.touchForEvent(theEvent))
            mouseEvent.touchEventGesture = .ScrollWheel
            mouseEvent.translation = translation
            UIApplication.sharedApplication().sendEvent(mouseEvent)
            mouseEvent.endTouchEvent()
        }
    }

    func rightMouseDown(theEvent: NSEvent) {
        if !touchEvent {
            var mouseEvent: UITouchEvent = UITouchEvent(touch: self.touchForEvent(theEvent))
            mouseEvent.touchEventGesture = .RightClick
            mouseEvent.touch.tapCount = theEvent.clickCount()
            UIApplication.sharedApplication().sendEvent(mouseEvent)
            mouseEvent.endTouchEvent()
        }
    }

    func mouseMoved(theEvent: NSEvent) {
        if !touchEvent {
            let location: NSPoint = self.convertPoint(theEvent.locationInWindow(), fromView: nil)
            var currentView: UIView = self.hitTestUIView(location)
            var previousView: UIView = mouseMoveTouch.view!
            self.mouseMoveTouch.timestamp = theEvent.timestamp()
            self.mouseMoveTouch.locationOnScreen = NSPointToCGPoint(location)
            self.mouseMoveTouch.phase = .Moved
            if previousView && previousView != currentView {
                var moveEvent: UITouchEvent = UITouchEvent(touch: mouseMoveTouch)
                moveEvent.touchEventGesture = .MouseMove
                UIApplication.sharedApplication().sendEvent(moveEvent)
                moveEvent.endTouchEvent()
                var exitEvent: UITouchEvent = UITouchEvent(touch: mouseMoveTouch)
                exitEvent.touchEventGesture = .MouseExited
                UIApplication.sharedApplication().sendEvent(exitEvent)
                exitEvent.endTouchEvent()
            }
            self.mouseMoveTouch.view = currentView
            if currentView != nil {
                if currentView != previousView {
                    var enterEvent: UITouchEvent = UITouchEvent(touch: mouseMoveTouch)
                    enterEvent.touchEventGesture = .MouseEntered
                    UIApplication.sharedApplication().sendEvent(enterEvent)
                    enterEvent.endTouchEvent()
                }
                var moveEvent: UITouchEvent = UITouchEvent(touch: mouseMoveTouch)
                moveEvent.touchEventGesture = .MouseMove
                UIApplication.sharedApplication().sendEvent(moveEvent)
                moveEvent.endTouchEvent()
            }
        }
    }

    func mouseEntered(theEvent: NSEvent) {
        self.mouseMoved(theEvent)
    }

    func mouseExited(theEvent: NSEvent) {
        if !touchEvent {
            self.mouseMoveTouch.phase = .Moved
            self.updateTouchLocation(mouseMoveTouch, withEvent: theEvent)
            var moveEvent: UITouchEvent = UITouchEvent(touch: mouseMoveTouch)
            moveEvent.touchEventGesture = .MouseMove
            UIApplication.sharedApplication().sendEvent(moveEvent)
            moveEvent.endTouchEvent()
            var exitEvent: UITouchEvent = UITouchEvent(touch: mouseMoveTouch)
            exitEvent.touchEventGesture = .MouseExited
            UIApplication.sharedApplication().sendEvent(exitEvent)
            exitEvent.endTouchEvent()
            self.mouseMoveTouch.view = nil
        }
    }

    func keyDown(theEvent: NSEvent) {
        var key: UIKey = UIKey(NSEvent: theEvent)
        // this is not the correct way to handle keys.. iOS 7 finally added a way to handle key commands
        // but this was implemented well before that. for now, this gets what we want to happen to happen.    
        if key.action {
            self.doCommandBySelector(key.action)
        }
        else {
            super.keyDown(theEvent)
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

/*
 An older design of Chameleon had the singlular multi-touch event living in UIApplication because that made sense at the time.
 However it was needlessly awkward to send events from here to the UIApplication and then have to decode them all again, etc.
 It seemingly gained nothing. Also, while I don't know how UIKit would handle this situation, I'm not sure it makes sense to
 have a single multitouch sequence span multiple screens anyway. There are some cases where that might kinda make sense, but
 I'm having some doubts that this is how iOS would be setup anyway. (It's hard to really know without some deep digging since
 I don't know if iOS even supports touch events on any screen other than the main one anyway, but it doesn't matter right now.)
 
 The benefit of having it here is that this is right where the touches happen. There's no ambiguity about exactly which
 screen/NSView the event occured on, and there's no need to pass that info around deep into other parts of the code, either.
 It can be dealt with here and now and life can go on and things don't have to get weirdly complicated deep down the rabbit
 hole. In theory.
 */