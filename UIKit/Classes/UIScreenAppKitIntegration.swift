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

extension UIScreen {
    // the windows that make this screen their home
    //var windows: [AnyObject] {
    //    get {
    //        return self.windows
    //    }
    //}

    // the window from the -windows array which is this screen's key window. this is not really how iOS is likely to work
    // as iOS seems to track a single key window for the whole app, but on OSX the user can change the key window out from
    // under the app, so this entire thing has to be managed differently. my design here is that each screen has a potential
    // key window which is what is set when a UIWindow is told to become key. the app's keyWindow (as reported by UIApplication)
    // will be the keyWindow of the screen that's currently on the NSWindow that's key.... yeah... confusing, eh?
    //var keyWindow: UIWindow {
    //    get {
    //        return self.keyWindow
    //    }
    //}

    // the real NSView that the screen lives on (or nil if there isn't one)
    //var UIKitView: UIKitView {
    //    get {
    //        return self.UIKitView
    //    }
    //}

    // promotes this screen to the main screen
    // this only changes what [UIScreen mainScreen] returns in the future, it doesn't move anything between views, etc.

    func becomeMainScreen() {
        let entry: NSValue = NSValue(nonretainedObject: self)
		if let index = allScreens.indexOf(entry) {
			allScreens.removeAtIndex(index)
		}
		allScreens.insert(entry, atIndex: 0)
    }
    // Using a nil screen will convert to OSX screen coordinates.

    func convertPoint(toConvert: CGPoint, toScreen: UIScreen?) -> CGPoint {
        if toScreen == self {
            return toConvert
        }
        else {
            // Go all the way through OSX screen coordinates.
            var screenCoords: NSPoint = self.UIKitView.window().convertBaseToScreen(self.UIKitView.convertPoint(NSPointFromCGPoint(toConvert), toView: nil))
            if let toScreen = toScreen {
                // Now from there back to the toScreen's window's base
                return NSPointToCGPoint(toScreen.UIKitView.convertPoint(toScreen.UIKitView.window().convertScreenToBase(screenCoords), fromView: nil))
            }
            else {
                return NSPointToCGPoint(screenCoords)
            }
        }
    }

    func convertPoint(toConvert: CGPoint, fromScreen: UIScreen?) -> CGPoint {
        if fromScreen == self {
            return toConvert
        }
        else {
            var screenCoords: NSPoint
            if let fromScreen = fromScreen {
                // Go all the way through OSX screen coordinates.
                screenCoords = fromScreen.UIKitView.window().convertBaseToScreen(fromScreen.UIKitView.convertPoint(NSPointFromCGPoint(toConvert), toView: nil))
            }
            else {
                screenCoords = NSPointFromCGPoint(toConvert)
            }
            // Now from there back to the our screen
            return NSPointToCGPoint(self.UIKitView.convertPoint(self.UIKitView.window().convertScreenToBase(screenCoords), fromView: nil))
        }
    }

    func convertRect(toConvert: CGRect, toScreen: UIScreen) -> CGRect {
        let origin: CGPoint = self.convertPoint(CGPointMake(CGRectGetMinX(toConvert), CGRectGetMinY(toConvert)), toScreen: toScreen)
        let bottom: CGPoint = self.convertPoint(CGPointMake(CGRectGetMaxX(toConvert), CGRectGetMaxY(toConvert)), toScreen: toScreen)
        return CGRectStandardize(CGRectMake(origin.x, origin.y, bottom.x - origin.x, bottom.y - origin.y))
    }

    func convertRect(toConvert: CGRect, fromScreen: UIScreen) -> CGRect {
        let origin: CGPoint = self.convertPoint(CGPointMake(CGRectGetMinX(toConvert), CGRectGetMinY(toConvert)), fromScreen: fromScreen)
        let bottom: CGPoint = self.convertPoint(CGPointMake(CGRectGetMaxX(toConvert), CGRectGetMaxY(toConvert)), fromScreen: fromScreen)
        return CGRectStandardize(CGRectMake(origin.x, origin.y, bottom.x - origin.x, bottom.y - origin.y))
    }
}


private var allScreens = [NSValue]()
