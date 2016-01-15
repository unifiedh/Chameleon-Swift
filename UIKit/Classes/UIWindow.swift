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
import QuartzCore

    public typealias UIWindowLevel = CGFloat

let UIWindowLevelNormal: UIWindowLevel = 0

let UIWindowLevelStatusBar: UIWindowLevel = 1000

let UIWindowLevelAlert: UIWindowLevel = 2000

let UIWindowDidBecomeVisibleNotification: String = "UIWindowDidBecomeVisibleNotification"

let UIWindowDidBecomeHiddenNotification: String = "UIWindowDidBecomeHiddenNotification"

let UIWindowDidBecomeKeyNotification: String = "UIWindowDidBecomeKeyNotification"

let UIWindowDidResignKeyNotification: String = "UIWindowDidResignKeyNotification"

let UIKeyboardWillShowNotification: String = "UIKeyboardWillShowNotification"

let UIKeyboardDidShowNotification: String = "UIKeyboardDidShowNotification"

let UIKeyboardWillHideNotification: String = "UIKeyboardWillHideNotification"

let UIKeyboardDidHideNotification: String = "UIKeyboardDidHideNotification"

let UIKeyboardWillChangeFrameNotification: String = "UIKeyboardWillChangeFrameNotification"

let UIKeyboardFrameBeginUserInfoKey: String = "UIKeyboardFrameBeginUserInfoKey"

let UIKeyboardFrameEndUserInfoKey: String = "UIKeyboardFrameEndUserInfoKey"

let UIKeyboardAnimationDurationUserInfoKey: String = "UIKeyboardAnimationDurationUserInfoKey"

let UIKeyboardAnimationCurveUserInfoKey: String = "UIKeyboardAnimationCurveUserInfoKey"

// deprecated
let UIKeyboardCenterBeginUserInfoKey: String = "UIKeyboardCenterBeginUserInfoKey"

let UIKeyboardCenterEndUserInfoKey: String = "UIKeyboardCenterEndUserInfoKey"

let UIKeyboardBoundsUserInfoKey: String = "UIKeyboardBoundsUserInfoKey"

public class UIWindow: UIView {
    func convertPoint(var toConvert: CGPoint, toWindow: UIWindow?) -> CGPoint {
        if toWindow == self {
            return toConvert
        } else {
            // Convert to screen coordinates
            toConvert.x += self.frame.origin.x
            toConvert.y += self.frame.origin.y
            if let toWindow = toWindow {
                // Now convert the screen coords into the other screen's coordinate space
                toConvert = self.screen.convertPoint(toConvert, toScreen: toWindow.screen)
                // And now convert it from the new screen's space into the window's space
                toConvert.x -= toWindow.frame.origin.x
                toConvert.y -= toWindow.frame.origin.y
            }
            return toConvert
        }
    }

    func convertPoint(var toConvert: CGPoint, fromWindow: UIWindow?) -> CGPoint {
        if fromWindow == self {
            return toConvert
        }
        else {
            if let fromWindow = fromWindow {
                // Convert to screen coordinates
                toConvert.x += fromWindow.frame.origin.x
                toConvert.y += fromWindow.frame.origin.y
                // Change to this screen.
                toConvert = self.screen.convertPoint(toConvert, fromScreen: fromWindow.screen)
            }
            // Convert to window coordinates
            toConvert.x -= self.frame.origin.x
            toConvert.y -= self.frame.origin.y
            return toConvert
        }
    }

    func convertRect(toConvert: CGRect, fromWindow: UIWindow) -> CGRect {
        let convertedOrigin: CGPoint = self.convertPoint(toConvert.origin, fromWindow: fromWindow)
        return CGRectMake(convertedOrigin.x, convertedOrigin.y, toConvert.size.width, toConvert.size.height)
    }

    func convertRect(toConvert: CGRect, toWindow: UIWindow) -> CGRect {
        let convertedOrigin: CGPoint = self.convertPoint(toConvert.origin, toWindow: toWindow)
        return CGRectMake(convertedOrigin.x, convertedOrigin.y, toConvert.size.width, toConvert.size.height)
    }

    func makeKeyWindow() {
        if !self.isKeyWindow && self.screen {
            // this check is here because if the underlying screen's UIKitView is AppKit's keyWindow, then
            // we must resign it because UIKit thinks it's currently the key window, too, so we do that here.
            if self.screen.keyWindow.isKeyWindow() {
                self.screen.keyWindow.resignKeyWindow()
            }
            // now we set the screen's key window to ourself - note that this doesn't really make it the key
            // window yet from an external point of view...
            self.screen._setKeyWindow(self)
            // if it turns out we're now the key window, it means this window is ultimately within a UIKitView
            // that's the current AppKit key window, too, so we make it so. if we are NOT the key window, we
            // need to try to tell AppKit to make the UIKitView we're on the key window. If that works out,
            // we will get a notification and -becomeKeyWindow will be called from there, so we don't have to
            // do anything else in here.
            if self.isKeyWindow {
                self.becomeKeyWindow()
            }
            else {
                self.screen.UIKitView.window().makeFirstResponder(self.screen.UIKitView)
                self.screen.UIKitView.window().makeKeyWindow()
            }
        }
    }

    func makeKeyAndVisible() {
        self._makeVisible()
        self.makeKeyWindow()
    }

    func resignKeyWindow() {
        if self._firstResponder().respondsToSelector("resignKeyWindow") {
            self._firstResponder() as! AnyObject.resignKeyWindow()
        }
        NSNotificationCenter.defaultCenter().postNotificationName(UIWindowDidResignKeyNotification, object: self)
    }

    func becomeKeyWindow() {
        if self._firstResponder().respondsToSelector("becomeKeyWindow") {
            self._firstResponder() as! AnyObject.becomeKeyWindow()
        }
        NSNotificationCenter.defaultCenter().postNotificationName(UIWindowDidBecomeKeyNotification, object: self)
    }

    func sendEvent(event: UIEvent) {
        if (event is UITouchEvent) {
            self._processTouchEvent(event as! UITouchEvent)
        }
    }
    // this property returns YES only if the underlying screen's UIKitView is on the AppKit's key window
    // and this UIWindow was made key at some point in the past (and is still key from the point of view
    // of the underlying screen) which is of course rather different from the real UIKit.
    // this is done because unlike iOS, on OSX the user can change the key window at will at any time and
    // we need a way to reconnect key windows when they change. :/
    var keyWindow: Bool {
        get {
            // only return YES if we have a screen and our screen's UIKitView is on the AppKit key window
            if self.screen.keyWindow == self {
                return self.screen.UIKitView.window().isKeyWindow()
            }
            return false
        }
    }

    var screen: UIScreen {
        get {
            return self.screen
        }
        set {
            if theScreen != screen {
                NSNotificationCenter.defaultCenter().removeObserver(self, name: UIScreenModeDidChangeNotification, object: screen)
                let wasHidden: Bool = self.hidden
                self._makeHidden()
                self.layer.removeFromSuperlayer()
                self.screen = theScreen
                screen._layer().addSublayer(self.layer)
                if !wasHidden {
                    self._makeVisible()
                }
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "_screenModeChangedNotification:", name: UIScreenModeDidChangeNotification, object: screen)
            }
        }
    }

    var windowLevel: UIWindowLevel {
        get {
            return self.layer.zPosition
        }
        set(level) {
            self.layer.zPosition = level
        }
    }

    var rootViewController: UIViewController {
        get {
            return self.rootViewController
        }
        set {
            if rootViewController != rootViewController {
                self.subviews.makeObjectsPerformSelector("removeFromSuperview")
                let was: Bool = UIView.areAnimationsEnabled()
                UIView.animationsEnabled = false
                self.rootViewController = rootViewController
                self.rootViewController.view.frame = self.bounds
                self.addSubview(rootViewController.view!)
                self.layoutIfNeeded()
                UIView.animationsEnabled = was
            }
        }
    }
    var firstResponder: UIResponder


    override init(frame theFrame: CGRect) {
            self.undoManager = NSUndoManager()
            self._makeHidden()
            // do this first because before the screen is set, it will prevent any visibility notifications from being sent.
            self.screen = UIScreen.mainScreen()
            self.opaque = false
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "_NSWindowDidBecomeKeyNotification:", name: NSWindowDidBecomeKeyNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "_NSWindowDidResignKeyNotification:", name: NSWindowDidResignKeyNotification, object: nil)
        super.init(frame: frame)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self._makeHidden()
        // I don't really like this here, but the real UIKit seems to do something like this on window destruction as it sends a notification and we also need to remove it from the app's list of windows
        // since UIView's dealloc is called after this one, it's hard ot say what might happen in there due to all of the subview removal stuff
        // so it's safer to make sure these things are nil now rather than potential garbage. I don't like how much work UIView's -dealloc is doing
        // but at the moment I don't see a good way around it...
        self.screen = nil
        self.undoManager = nil
        self.rootViewController = nil
    }

    internal func _firstResponder() -> UIResponder {
        return firstResponder
    }

    func _setFirstResponder(newFirstResponder: UIResponder) {
        self.firstResponder = newFirstResponder
    }

    func undoManager() -> NSUndoManager {
        return undoManager
    }

    func superview() -> UIView? {
        return nil
        // lies!
    }

    override func removeFromSuperview() {
        // does nothing
    }

    func window() -> UIWindow {
    }

    override func nextResponder() -> UIResponder {
        return UIApplication.sharedApplication()
    }

    override var frame: CGRect {
        didSet {
            self.rootViewController.view.frame = self.bounds
        }
    }

    func _screenModeChangedNotification(note: NSNotification) {
        var previousMode: UIScreenMode = (note.userInfo["_previousMode"] as! UIScreenMode)
        var newMode: UIScreenMode = screen.currentMode
        if !CGSizeEqualToSize(previousMode.size, newMode.size) {
            self._superviewSizeDidChangeFrom(previousMode.size, to: newMode.size)
        }
    }

    func _NSWindowDidBecomeKeyNotification(note: NSNotification) {
        var nativeWindow = note.object as? NSWindow
        // when the underlying screen's NSWindow becomes key, we can use the keyWindow property the screen itself
        // to know if this UIWindow should become key again now or not. If things match up, we fire off -becomeKeyWindow
        // again to let the app know this happened. Normally iOS doesn't run into situations where the user can change
        // the key window out from under the app, so this is going to be somewhat unusual UIKit behavior...
        if self.screen.UIKitView.window().isEqual(nativeWindow) {
            if self.screen.keyWindow == self {
                self.becomeKeyWindow()
            }
        }
    }

    func _NSWindowDidResignKeyNotification(note: NSNotification) {
        var nativeWindow = note.object as? NSWindow
        // if the resigned key window is the same window that hosts our underlying screen, then we need to resign
        // this UIWindow, too. note that it does NOT actually unset the keyWindow property for the UIScreen!
        // this is because if the user clicks back in the screen's window, we need a way to reconnect this UIWindow
        // as the key window, too, so that's how that is done.
        if self.screen.UIKitView.window().isEqual(nativeWindow) {
            if self.screen.keyWindow == self {
                self.resignKeyWindow()
            }
        }
    }

    func _makeHidden() {
        if !self.hidden {
            super.hidden = true
            if self.screen {
                self.screen._removeWindow(self)
                NSNotificationCenter.defaultCenter().postNotificationName(UIWindowDidBecomeHiddenNotification, object: self)
            }
        }
    }

    func _makeVisible() {
        if self.hidden {
            super.hidden = false
            if self.screen {
                self.screen._addWindow(self)
                NSNotificationCenter.defaultCenter().postNotificationName(UIWindowDidBecomeVisibleNotification, object: self)
            }
        }
    }

    func setHidden(hide: Bool) {
        if hide {
            self._makeHidden()
        }
        else {
            self._makeVisible()
        }
    }

    func _processTouchEvent(event: UITouchEvent) {
        // we only support a single touch, so there is a *lot* in here that would break or need serious changes
        // to properly support mulitouch. I still don't really like how all this works - especially with the
        // gesture recognizers, but I've been struggling to come up with a better way for far too long and just
        // have to deal with what I've got now.
        // if there's no touch for this window, return immediately
        if event.touch.window != self {
            return
        }
        // normally there'd be no need to retain the view here, but this works around a strange problem I ran into.
        // what can happen is, now that UIView's -removeFromSuperview will remove the view from the active touch
        // instead of just cancel the touch (which is how I had implemented it previously - which was wrong), the
        // situation can arise where, in response to a touch event of some kind, the view may remove itself from its
        // superview in some fashion, which means that the handling of the touchesEnded:withEvent: (or whatever)
        // methods could somehow result in the view itself being destroyed before the method is even finished running!
        // a strong reference here works around this problem since the view is kept alive until we're done with it.
        // If someone can figure out some other, better way to fix this without it having to have this hacky-feeling
        // stuff here, that'd be cool, but be aware that this is here for a reason and that the problem it prevents is
        // somewhat contrived but not uncommon.
        var view: UIView = event.touch.view!
        // first deliver new touches to all possible gesture recognizers
        if event.touch.phase == .Began {
            for var subview = view; subview != nil; subview = subview.superview() {
                for gesture: UIGestureRecognizer in subview.gestureRecognizers {
                    gesture._beginTrackingTouch(event.touch, withEvent: event)
                }
            }
        }
        var gestureRecognized: Bool = false
        var possibleGestures: Bool = false
        var delaysTouchesBegan: Bool = false
        var delaysTouchesEnded: Bool = false
        var cancelsTouches: Bool = false
        // then allow all tracking gesture recognizers to have their way with the touches in this event before
        // anything else is done.
        for gesture: UIGestureRecognizer in event.touch.gestureRecognizers {
            gesture._continueTrackingWithEvent(event)
            let recognized: Bool = (gesture.state == .Recognized || gesture.state == .Began)
            let possible: Bool = (gesture.state == .Possible)
            gestureRecognized |= recognized
            possibleGestures |= possible
            if recognized || possible {
                delaysTouchesBegan |= gesture.delaysTouchesBegan
                // special case for scroll views so that -delaysContentTouches works somewhat as expected
                // likely this is pretty wrong, but it should work well enough for most normal cases, I suspect.
                if (gesture.view! is UIScrollView) {
                    var scrollView: UIScrollView = gesture.view as! UIScrollView
                    if gesture.isEqual(scrollView.panGestureRecognizer) || gesture.isEqual(scrollView.scrollWheelGestureRecognizer) {
                        delaysTouchesBegan |= scrollView.delaysContentTouches
                    }
                }
            }
            if recognized {
                delaysTouchesEnded |= gesture.delaysTouchesEnded
                cancelsTouches |= gesture.cancelsTouchesInView
            }
        }
        if event.isDiscreteGesture {
            // this should prevent delivery of the "touches" down the responder chain in roughly the same way a normal non-
            // discrete gesture would based on the settings of the in-play gesture recognizers.
            if !gestureRecognized || (gestureRecognized && !cancelsTouches && !delaysTouchesBegan) {
                if event.touchEventGesture == .RightClick {
                    view.rightClick(event.touch, withEvent: event)
                }
                else if event.touchEventGesture == .ScrollWheel {
                    view.scrollWheelMoved(event.translation, withEvent: event)
                }
                else if event.touchEventGesture == .MouseMove {
                    view.mouseMoved(event.touch, withEvent: event)
                }
                else if event.touchEventGesture == .MouseEntered {
                    view.mouseEntered(event.touch.view!, withEvent: event)
                }
                else if event.touchEventGesture == .MouseExited {
                    view.mouseExited(event.touch.view!, withEvent: event)
                }
            }
        }
        else {
            if event.touch.phase == .Began {
                if (!gestureRecognized && !possibleGestures) || !delaysTouchesBegan {
                    view.touchesBegan(event.allTouches, withEvent: event)
                    event.touch.wasDeliveredToView = true
                }
            }
            else if delaysTouchesBegan && gestureRecognized && !event.touch.wasDeliveredToView {
                // if we were delaying touches began and a gesture gets recognized, and we never sent it to the view,
                // we need to throw it away and be sure we never send it to the view for the duration of the gesture
                // so we do this by marking it both delivered and cancelled without actually sending it to the view.
                event.touch.wasDeliveredToView = true
                event.touch.wasCancelledInView = true
            }
            else if delaysTouchesBegan && !gestureRecognized && !possibleGestures && !event.touch.wasDeliveredToView && event.touch.phase != .Cancelled {
                // need to fake-send a touches began using the cached time and location in the touch
                // a followup move or ended or cancelled touch will be sent below if necessary
                let currentTimestamp: NSTimeInterval = event.touch.timestamp
                let currentPhase: UITouchPhase = event.touch.phase
                let currentLocation: CGPoint = event.touch.locationOnScreen
                event.touch.timestamp = event.touch.beganPhaseTimestamp
                event.touch.locationOnScreen = event.touch.beganPhaseLocationOnScreen
                event.touch.phase = .Began
                view.touchesBegan(event.allTouches, withEvent: event)
                event.touch.wasDeliveredToView = true
                event.touch.phase = currentPhase
                event.touch.locationOnScreen = currentLocation
                event.touch.timestamp = currentTimestamp
            }

            if event.touch.phase != .Began && event.touch.wasDeliveredToView && !event.touch.wasCancelledInView {
                if event.touch.phase == .Cancelled {
                    view.touchesCancelled(event.allTouches, withEvent: event)
                    event.touch.wasCancelledInView = true
                }
                else if gestureRecognized && (cancelsTouches || (event.touch.phase == .Ended && delaysTouchesEnded)) {
                    // since we're supposed to cancel touches, mark it cancelled, send it to the view, and
                    // then change it back to whatever it was because there might be other gesture recognizers
                    // that are still using the touch for whatever reason and aren't going to expect it suddenly
                    // cancelled. (technically cancelled touches are, I think, meant to be a last resort..
                    // the sort of thing that happens when a phone call comes in or a modal window comes up)
                    let currentPhase: UITouchPhase = event.touch.phase
                    event.touch.phase = .Cancelled
                    view.touchesCancelled(event.allTouches, withEvent: event)
                    event.touch.wasCancelledInView = true
                    event.touch.phase = currentPhase
                }
                else if event.touch.phase == .Moved {
                    view.touchesMoved(event.allTouches, withEvent: event)
                }
                else if event.touch.phase == .Ended {
                    view.touchesEnded(event.allTouches, withEvent: event)
                }
            }
        }
        var newCursor: NSCursor = view.mouseCursorForEvent(event) ?? NSCursor.arrowCursor()
        if NSCursor.currentCursor() != newCursor {
            newCursor.set()
        }
    }
}

