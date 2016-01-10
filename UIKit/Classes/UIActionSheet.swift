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

protocol UIActionSheetDelegate: NSObject {
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int)

    func willPresentActionSheet(actionSheet: UIActionSheet)

    func didPresentActionSheet(actionSheet: UIActionSheet)

    func actionSheet(actionSheet: UIActionSheet, willDismissWithButtonIndex buttonIndex: Int)

    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int)

    func actionSheetCancel(actionSheet: UIActionSheet)
}
enum UIActionSheetStyle : Int {
    case Automatic = -1
    case Default = .Default
    case BlackTranslucent = .BlackTranslucent
    case BlackOpaque = .BlackOpaque
}

class UIActionSheet: UIView {
    convenience override init(title: String, delegate: UIActionSheetDelegate, cancelButtonTitle: String, destructiveButtonTitle: String, otherButtonTitles: String) {
        if (self = self(frame: CGRectZero)) {
            self.delegate = delegate
            self.firstOtherButtonIndex = -1
            // sort of a hack to reset this because the addButtonWithTitle's above can change it's value :)
            if otherButtonTitles {
                self.addButtonWithTitle(otherButtonTitles)
                var buttonTitle: AnyObject? = nil
                var argumentList: va_list
                va_start(argumentList, otherButtonTitles)
                while  {

                }
                buttonTitle =
                argumentList, String * 
                                    self.addButtonWithTitle(buttonTitle!)

                va_end(argumentList)
            }
            if destructiveButtonTitle {
                self.destructiveButtonIndex = self.addButtonWithTitle(destructiveButtonTitle)
            }
            if cancelButtonTitle {
                self.cancelButtonIndex = self.addButtonWithTitle(cancelButtonTitle)
            }
        }
    }

    func addButtonWithTitle(title: String) -> Int {
        menuTitles.append(title ?? "")
        var index: Int = menuTitles.count - 1
        if firstOtherButtonIndex == -1 {
            self.firstOtherButtonIndex = index
        }
        return index
    }

    func showInView(view: UIView) {
        // Since we're using an NSMenu to represent UIActionSheet on OSX, I'm going to make the assumption that a showInView: is triggered from
        // a click somewhere. If it's triggered on a delay, that might be a problem. However for a typical app, I suspect that is generally
        // not the case. I can't think of a better behavior right now, so I'm going to fetch the current mouse position and translate coords
        // so that the menu presents from there.
        self.showFromRect(CGRectNull, inView: view, animated: true)
    }
    // menu will appear wherever the mouse cursor is

    func showFromRect(rect: CGRect, inView view: UIView, animated: Bool) {
        // If the rect is NULL, use that as a flag to indicate that the menu should be presented from wherever the mouse cursor is
        // instead of a specific place on screen. This is not really normal UIKit behavior, of course, but I think it makes sense
        // here on the Mac.
        if CGRectIsNull(rect) {
            // translate them thar points!
            var mouseLocation: NSPoint = NSEvent.mouseLocation()
            var screenPoint: CGPoint = view.window.screen.convertPoint(NSPointToCGPoint(mouseLocation), fromScreen: nil)
            var windowPoint: CGPoint = view.window.convertPoint(screenPoint, fromWindow: nil)
            var viewPoint: CGPoint = view.convertPoint(windowPoint, fromView: nil)
            self._showFromPoint(viewPoint, rightAligned: false, inView: view)
        }
        else {
            self._showFromPoint(CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height), rightAligned: true, inView: view)
        }
    }
    // if rect is CGRectNull, the menu will appear wherever the mouse cursor is

    func dismissWithClickedButtonIndex(buttonIndex: Int, animated: Bool) {
        if animated {
            menu.cancelTracking()
        }
        else {
            menu.cancelTrackingWithoutAnimation()
        }
        // kill off the menu
        self.menu = nil
        // remove ourself from the superview that we piggy-backed on
        self.removeFromSuperview()
    }
    // these are not yet implemented:

    func showFromToolbar(view: UIToolbar) {
    }

    func showFromTabBar(view: UITabBar) {
    }

    func showFromBarButtonItem(item: UIBarButtonItem, animated: Bool) {
    }
    var title: String
    weak var delegate: UIActionSheetDelegate {
        get {
            return self.delegate
        }
        set {
            self.delegate = newDelegate
            self.delegateHas.clickedButtonAtIndex = delegate.respondsToSelector("actionSheet:clickedButtonAtIndex:")
            self.delegateHas.willPresentActionSheet = delegate.respondsToSelector("willPresentActionSheet:")
            self.delegateHas.didPresentActionSheet = delegate.respondsToSelector("didPresentActionSheet:")
            self.delegateHas.willDismissWithButtonIndex = delegate.respondsToSelector("actionSheet:willDismissWithButtonIndex:")
            self.delegateHas.didDismissWithButtonIndex = delegate.respondsToSelector("actionSheet:didDismissWithButtonIndex:")
            self.delegateHas.actionSheetCancel = delegate.respondsToSelector("actionSheetCancel:")
        }
    }

    var actionSheetStyle: UIActionSheetStyle
    var visible: Bool {
        get {
            return (menu != nil)
        }
    }

    var destructiveButtonIndex: Int {
        get {
            return self.destructiveButtonIndex
        }
        set {
            if index != destructiveButtonIndex {
                if index >= 0 {
                    assert(index < menuTitles.count)
                }
                else {
                    index = -1
                }
                self.destructiveButtonIndex = index
            }
        }
    }

    var cancelButtonIndex: Int {
        get {
            return self.cancelButtonIndex
        }
        set {
            if index != cancelButtonIndex {
                if index >= 0 {
                    assert(index < menuTitles.count)
                }
                else {
                    index = -1
                }
                self.cancelButtonIndex = index
            }
        }
    }

    var firstOtherButtonIndex: Int {
        get {
            return self.firstOtherButtonIndex
        }
    }

    var numberOfButtons: Int {
        get {
            return menuTitles.count
        }
    }
    var self.menuTitles: [AnyObject]
    var self.separatorIndexes: [AnyObject]
    var self.menu: NSMenu
    var self.delegateHas: struct{unsignedclickedButtonAtIndex:1;unsignedwillPresentActionSheet:1;unsigneddidPresentActionSheet:1;unsignedwillDismissWithButtonIndex:1;unsigneddidDismissWithButtonIndex:1;unsignedactionSheetCancel:1;}


    convenience override init(frame: CGRect) {
        if (self.init(frame: frame)) {
            self.menuTitles = [AnyObject]()
            self.separatorIndexes = [AnyObject]()
            self.destructiveButtonIndex = -1
            self.cancelButtonIndex = -1
            self.firstOtherButtonIndex = -1
        }
    }

    func addSeparator() {
        separatorIndexes.append(Int(menuTitles.count))
    }

    func _showFromPoint(point: CGPoint, rightAligned: Bool, inView view: UIView) {
        view.addSubview(self)
        if !menu && self.window {
            self.menu = NSMenu(title: title ?? "")
            menu.autoenablesItems = false
            menu.allowsContextMenuPlugIns = false
            for var index = 0; index < menuTitles.count; index++ {
                if separatorIndexes.containsObject(Int(index)) {
                    menu.addItem(NSMenuItem.separatorItem())
                }
                // don't even bother putting a cancel menu item on there. I think on OSX it's always going to be pointless
                // as clicking outside of the menu is always the same thing as tapping the cancel button and that's just
                // how it's got to work, I think.
                if index != cancelButtonIndex {
                    var theItem: NSMenuItem = NSMenuItem(title: menuTitles[index], action: "_didSelectMenuItem:", keyEquivalent: "")
                    theItem.tag = index
                    theItem.target = self
                    menu.addItem(theItem)
                }
            }
            // convert the point from view's coordinate space to the underlying NSView's coordinate space
            var windowPoint: CGPoint = self.convertPoint(point, toView: nil)
            var screenPoint: CGPoint = self.window.convertPoint(windowPoint, toWindow: nil)
            // then offset it if desired
            if rightAligned {
                screenPoint.x -= menu.size().width
            }
            if delegateHas.willPresentActionSheet {
                delegate.willPresentActionSheet(self)
            }
            // note that presenting an NSMenu is apparently modal. so, to pretend that it isn't, exactly, I'll delay the presentation
            // of the menu to the start of a new runloop. At least that way, code that may be expecting to run right after setting the
            // menu to visible would still run before the menu itself shows up on screen. Of course behavior is going to be pretty different
            // after that point since if the app is assuming it can keep on doing normal runloop stuff, it ain't gonna happen.
            // but since clicks outside of an NSMenu dismiss it, there's not a lot a user can do to an app to change state when a menu
            // is up in the first place.
            self.performSelector("_actuallyPresentTheMenuFromPoint:", withObject: NSValue(CGPoint: screenPoint), afterDelay: 0)
        }
    }

    func _clickedButtonAtIndex(index: Int) {
        if delegateHas.clickedButtonAtIndex {
            delegate.actionSheet(self, clickedButtonAtIndex: index)
        }
        if index == cancelButtonIndex && delegateHas.actionSheetCancel {
            delegate.actionSheetCancel(self)
        }
        if delegateHas.willDismissWithButtonIndex {
            delegate.actionSheet(self, willDismissWithButtonIndex: index)
        }
        self.dismissWithClickedButtonIndex(index, animated: true)
        if delegateHas.didDismissWithButtonIndex {
            delegate.actionSheet(self, didDismissWithButtonIndex: index)
        }
    }

    func _didSelectMenuItem(item: NSMenuItem) {
        self._clickedButtonAtIndex(item.tag())
    }

    func _actuallyPresentTheMenuFromPoint(aPoint: NSValue) {
        // hard to say where best to put this, but I guess this makes some sense? I can't call it after it's actually
        // on screen because of the modal-ness of NSMenu
        if delegateHas.didPresentActionSheet {
            delegate.didPresentActionSheet(self)
        }
        // this goes modal... meh.
        var itemSelected: Bool = menu.popUpMenuPositioningItem(nil, atLocation: NSPointFromCGPoint(aPoint.CGPointValue), inView: self.window.screen.UIKitView)
        // because of the modal nature of NSMenu, if there's a touch active (like, being held down) when a menu is triggered, the modal NSMenu
        // takes over the event stream and so a mouseUp is never delivered to the UIKitView. This means it never gets to the app and it leaves
        // the "touch" tracking system in an inconsistent state. This triggers the touchesCancelled UIResponder stuff to allow UIKit code to clean
        // itself up after the menu is done.
        UIApplicationInterruptTouchesInView(nil)
        if !itemSelected {
            self._clickedButtonAtIndex(cancelButtonIndex)
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

import AppKit
import AppKit
import AppKit