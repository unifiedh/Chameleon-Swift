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
import ApplicationServices
import QuartzCore

let UIScreenDidConnectNotification: String = "UIScreenDidConnectNotification"

let UIScreenDidDisconnectNotification: String = "UIScreenDidDisconnectNotification"

let UIScreenModeDidChangeNotification: String = "UIScreenModeDidChangeNotification"

class UIScreen: NSObject {
    class func mainScreen() -> UIScreen {
        return (allScreens.count > 0) ? allScreens[0].nonretainedObjectValue() : nil
    }

    class func screens() -> [AnyObject] {
        var screens: [AnyObject] = [AnyObject](minimumCapacity: allScreens.count)
        for v: NSValue in allScreens {
            screens.append(v.nonretainedObjectValue())
        }
        return screens
    }
    var bounds: CGRect {
        get {
            return layer.bounds
        }
    }

    var applicationFrame: CGRect {
        get {
            let statusBarHeight: Float = UIApplication.sharedApplication().statusBarHidden ? 0 : 20
            let size: CGSize = self.bounds.size
            return CGRectMake(0, statusBarHeight, size.width, size.height - statusBarHeight)
        }
    }

    var availableModes: [AnyObject] {
        get {
            return (self.currentMode) ? [self.currentMode] : nil
        }
    }

    // only ever returns the currentMode
    var currentMode: UIScreenMode
    // ignores any attempt to set this
    var scale: CGFloat {
        get {
            if UIKitView.window().respondsToSelector("backingScaleFactor") {
                return UIKitView.window().backingScaleFactor()
            }
            else {
                return 1
            }
        }
    }

    var brightness: CGFloat
    var self.grabber: UIImageView
    var self.layer: CALayer
    var self.windows: [AnyObject]
    var self.UIKitView: UIKitView
    var self.keyWindow: UIWindow


    class func initialize() {
        if self == UIScreen {
            self.allScreens = [AnyObject]()
        }
    }

    convenience override init() {
        if (self.init()) {
            self.layer = CALayer.layer
            self.layer.delegate = self
            // required to get the magic of the UIViewLayoutManager...
            self.layer.layoutManager = UIViewLayoutManager.layoutManager()
            self.windows = [AnyObject]()
            self.brightness = 1
            self.grabber = UIImageView(image: UIImage._windowResizeGrabberImage())
            self.grabber.layer.zPosition = 10000
            layer.addSublayer(grabber.layer)
        }
    }

    func dealloc() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        allScreens.removeObject(NSValue(nonretainedObject: self))
        self.layer.layoutManager = nil
        self.layer.delegate = nil
        grabber.layer.removeFromSuperlayer()
        layer.removeFromSuperlayer()
    }

    func _hasResizeIndicator() -> Bool {
        var realWindow: NSWindow = UIKitView.window()
        var contentView: NSView = realWindow.contentView()
        if UIKitView && realWindow && contentView && (realWindow.styleMask() & NSResizableWindowMask) && realWindow.showsResizeIndicator() && !NSEqualSizes(realWindow.minSize(), realWindow.maxSize()) {
            let myBounds: CGRect = NSRectToCGRect(UIKitView.bounds)
            let myLowerRight: CGPoint = CGPointMake(CGRectGetMaxX(myBounds), CGRectGetMaxY(myBounds))
            let contentViewBounds: CGRect = NSRectToCGRect(contentView.frame)
            let contentViewLowerRight: CGPoint = CGPointMake(CGRectGetMaxX(contentViewBounds), 0)
            let convertedPoint: CGPoint = NSPointToCGPoint(UIKitView.convertPoint(NSPointFromCGPoint(myLowerRight), toView: contentView))
            if CGPointEqualToPoint(convertedPoint, contentViewLowerRight) && realWindow.showsResizeIndicator() {
                return true
            }
        }
        return false
    }

    func _layoutSubviews() {
        if self._hasResizeIndicator() {
            let grabberSize: CGSize = grabber.frame.size
            let layerSize: CGSize = layer.bounds.size
            var grabberRect: CGRect = grabber.frame
            grabberRect.origin = CGPointMake(layerSize.width - grabberSize.width, layerSize.height - grabberSize.height)
            self.grabber.frame = grabberRect
            self.grabber.hidden = false
        }
        else if !grabber.hidden {
            self.grabber.hidden = true
        }

    }

    convenience override init(layer: CALayer, forKey event: String) {
        return NSNull()
    }

    func _layer() -> CALayer {
        return layer
    }

    func _UIKitViewFrameDidChange() {
        var userInfo: [NSObject : AnyObject] = (self.currentMode) ? [
            "_previousMode" : self.currentMode
        ]
 : nil
        self.currentMode = UIScreenMode.screenModeWithNSView(UIKitView)
        NSNotificationCenter.defaultCenter().postNotificationName(UIScreenModeDidChangeNotification, object: self, userInfo: userInfo)
    }

    func _NSScreenDidChange() {
        self.windows.makeObjectsPerformSelector("_didMoveToScreen")
    }

    func _setUIKitView(theView: AnyObject) {
        if UIKitView != theView {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: NSViewFrameDidChangeNotification, object: UIKitView)
            NSNotificationCenter.defaultCenter().removeObserver(self, name: NSWindowDidChangeScreenNotification, object: nil)
            if (self.UIKitView = theView) {
                allScreens.append(NSValue(nonretainedObject: self))
                self.currentMode = UIScreenMode.screenModeWithNSView(UIKitView)
                NSNotificationCenter.defaultCenter().postNotificationName(UIScreenDidConnectNotification, object: self)
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "_UIKitViewFrameDidChange", name: NSViewFrameDidChangeNotification, object: UIKitView)
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "_NSScreenDidChange", name: NSWindowDidChangeScreenNotification, object: UIKitView.window())
                self._NSScreenDidChange()
            }
            else {
                self.currentMode = nil
                allScreens.removeObject(NSValue(nonretainedObject: self))
                NSNotificationCenter.defaultCenter().postNotificationName(UIScreenDidDisconnectNotification, object: self)
            }
        }
    }

    func UIKitView() -> UIKitView {
        return UIKitView
    }

    func _addWindow(window: UIWindow) {
        windows.append(NSValue(nonretainedObject: window))
    }

    func _removeWindow(window: UIWindow) {
        if keyWindow == window {
            self.keyWindow = nil
        }
        windows.removeObject(NSValue(nonretainedObject: window))
    }

    func windows() -> [AnyObject] {
        return windows["nonretainedObjectValue"]
    }

    func keyWindow() -> UIWindow {
        return keyWindow
    }

    func _setKeyWindow(window: UIWindow) {
        assert(self.windows.containsObject(window), "cannot set key window to a window not on this screen")
        self.keyWindow = window
    }

    func description() -> String {
        return "<\(self.className()): \(self); bounds = \(NSStringFromCGRect(self.bounds)); mode = \(self.currentMode)>"
    }
}

    var self.allScreens: [AnyObject]? = nil