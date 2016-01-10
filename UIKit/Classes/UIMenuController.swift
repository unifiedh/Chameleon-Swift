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
    let UIMenuControllerWillShowMenuNotification: String

    let UIMenuControllerDidShowMenuNotification: String

    let UIMenuControllerWillHideMenuNotification: String

    let UIMenuControllerDidHideMenuNotification: String

    let UIMenuControllerMenuFrameDidChangeNotification: String

class UIMenuController: NSObject {
    class func sharedMenuController() -> UIMenuController {
        var controller: UIMenuController? = nil
        return controller ?? (controller = UIMenuController())
    }

    func setMenuVisible(menuVisible: Bool, animated: Bool) {
        let wasVisible: Bool = self.isMenuVisible()
        if menuVisible && !wasVisible {
            self.update()
            if enabledMenuItems.count > 0 {
                self.menu = NSMenu(title: "")
                menu.delegate = self
                menu.autoenablesItems = false
                menu.allowsContextMenuPlugIns = false
                for item: UIMenuItem in enabledMenuItems {
                    var theItem: NSMenuItem = NSMenuItem(title: item.title, action: "_didSelectMenuItem:", keyEquivalent: "")
                    theItem.target = self
                    theItem.representedObject = item
                    menu.addItem(theItem)
                }
                self.menuFrame.size = NSSizeToCGSize(menu.size())
                self.menuFrame.origin = menuLocation
                // this is offset so that it seems to be aligned on the right of the initial rect given to setTargetRect:inView:
                // I don't know if this is the best behavior yet or not.
                if rightAlignMenu {
                    self.menuFrame.origin.x -= menuFrame.size.width
                }
                // note that presenting an NSMenu is apparently modal. so, to pretend that it isn't, exactly, I'll delay the presentation
                // of the menu to the start of a new runloop. At least that way, code that may be expecting to run right after setting the
                // menu to visible would still run before the menu itself shows up on screen. Of course behavior is going to be pretty different
                // after that point since if the app is assuming it can keep on doing normal runloop stuff, it ain't gonna happen.
                // but since clicks outside of an NSMenu dismiss it, there's not a lot a user can do to an app to change state when a menu
                // is up in the first place.
                self.performSelector("_presentMenu", withObject: nil, afterDelay: 0)
            }
        }
        else if !menuVisible && wasVisible {
            // make it unhappen
            if animated {
                menu.cancelTracking()
            }
            else {
                menu.cancelTrackingWithoutAnimation()
            }
            self.menu = nil
        }

    }

    func setTargetRect(targetRect: CGRect, inView targetView: UIView) {
        // we have to have some window somewhere to use as a basis, so if there isn't a view, we'll just use the
        // keyWindow and go from there.
        self.window = targetView.window ?? UIApplication.sharedApplication().keyWindow
        // if the rect is CGRectNull, this is a fancy trigger in my OSX version to use the mouse position as the location for
        // the menu instead of the requiring a given rect. this is often a much better feel on OSX than the usual UIKit way is.
        if CGRectIsNull(targetRect) {
            self.rightAlignMenu = false
            // get the mouse position and use that as the origin of our target rect
            var mouseLocation: NSPoint = NSEvent.mouseLocation()
            var screenPoint: CGPoint = window.screen.convertPoint(NSPointToCGPoint(mouseLocation), fromScreen: nil)
            targetRect.origin = screenPoint
            targetRect.size = CGSizeZero
        }
        else {
            self.rightAlignMenu = true
            // this will ultimately position the menu under the lower right of the given rectangle.
            // but it is then shifted in setMenuVisible:animated: so that the menu is right-aligned with the given rect.
            // this is all rather strange, perhaps, but it made sense at the time. we'll see if it does in practice.
            targetRect.origin.x += targetRect.size.width
            targetRect.origin.y += targetRect.size.height
            // first convert to screen coord, otherwise assume it already is, I guess, only the catch with targetView being nil
            // is that the assumed screen might not be the keyWindow's screen, which is what I'm going to be assuming here.
            // but bah - who cares? :)
            if targetView != nil {
                targetRect = window.convertRect(window.convertRect(targetRect, fromView: targetView), toWindow: nil)
            }
        }
        // only the origin is being set here. the size isn't known until the menu is created, which happens in setMenuVisible:animated:
        // so that's where _menuFrame will actually be configured for now.
        self.menuLocation = targetRect.origin
    }
    // if targetRect is CGRectNull, the menu will appear wherever the mouse cursor was at the time this method was called

    func update() {
        var app: UIApplication = UIApplication.sharedApplication()
        var firstResponder: UIResponder = app.keyWindow._firstResponder()
        var allItems: [AnyObject] = self._defaultMenuItems().arrayByAddingObjectsFromArray(menuItems)
        enabledMenuItems.removeAllObjects()
        if firstResponder != nil {
            for item: UIMenuItem in allItems {
                if firstResponder.canPerformAction(item.action, withSender: app) {
                    enabledMenuItems.append(item)
                }
            }
        }
    }
    var menuVisible: Bool {
        get {
            return (menu != nil)
        }
        set {
            let wasVisible: Bool = self.isMenuVisible()
            if menuVisible && !wasVisible {
                self.update()
                if enabledMenuItems.count > 0 {
                    self.menu = NSMenu(title: "")
                    menu.delegate = self
                    menu.autoenablesItems = false
                    menu.allowsContextMenuPlugIns = false
                    for item: UIMenuItem in enabledMenuItems {
                        var theItem: NSMenuItem = NSMenuItem(title: item.title, action: "_didSelectMenuItem:", keyEquivalent: "")
                        theItem.target = self
                        theItem.representedObject = item
                        menu.addItem(theItem)
                    }
                    self.menuFrame.size = NSSizeToCGSize(menu.size())
                    self.menuFrame.origin = menuLocation
                    // this is offset so that it seems to be aligned on the right of the initial rect given to setTargetRect:inView:
                    // I don't know if this is the best behavior yet or not.
                    if rightAlignMenu {
                        self.menuFrame.origin.x -= menuFrame.size.width
                    }
                    // note that presenting an NSMenu is apparently modal. so, to pretend that it isn't, exactly, I'll delay the presentation
                    // of the menu to the start of a new runloop. At least that way, code that may be expecting to run right after setting the
                    // menu to visible would still run before the menu itself shows up on screen. Of course behavior is going to be pretty different
                    // after that point since if the app is assuming it can keep on doing normal runloop stuff, it ain't gonna happen.
                    // but since clicks outside of an NSMenu dismiss it, there's not a lot a user can do to an app to change state when a menu
                    // is up in the first place.
                    self.performSelector("_presentMenu", withObject: nil, afterDelay: 0)
                }
            }
            else if !menuVisible && wasVisible {
                // make it unhappen
                if animated {
                    menu.cancelTracking()
                }
                else {
                    menu.cancelTrackingWithoutAnimation()
                }
                self.menu = nil
            }
    
        }
    }

    var menuItems: [AnyObject]
    // returned in screen coords of the screen that the view used in setTargetRect:inView: belongs to
    // there's always a value here, but it's not likely to be terribly reliable except immidately after
    // the menu is made visible. I have no intenstively tested what the real UIKit does in all the possible
    // situations. You have been warned.
    var menuFrame: CGRect {
        get {
            return self.menuFrame
        }
    }
    var self.enabledMenuItems: [AnyObject]
    var self.menu: NSMenu
    var self.menuLocation: CGPoint
    var self.rightAlignMenu: Bool
    var self.window: UIWindow


    class func _defaultMenuItems() -> [AnyObject] {
        var items: [AnyObject]? = nil
        if !items {
            items = [UIMenuItem(title: "Cut", action: "cut:"), UIMenuItem(title: "Copy", action: "copy:"), UIMenuItem(title: "Paste", action: "paste:"), UIMenuItem(title: "Delete", action: "delete:"), UIMenuItem(title: "Select", action: "select:"), UIMenuItem(title: "Select All", action: "selectAll:")]
        }
        return items!
    }

    convenience override init() {
        if (self.init()) {
            self.enabledMenuItems = [AnyObject]()
        }
    }

    func dealloc() {
        menu.cancelTracking()
        // this should never really happen since the controller is pretty much always a singleton, but... whatever.
    }

    func setMenuVisible(visible: Bool) {
        self.setMenuVisible(visible, animated: false)
    }

    func _presentMenu() {
        if menu && window {
            var theNSView: NSView = window.screen.UIKitView
            if theNSView != nil {
                menu.popUpMenuPositioningItem(nil, atLocation: NSPointFromCGPoint(menuFrame.origin), inView: theNSView)
                UIApplicationInterruptTouchesInView(nil)
            }
        }
    }

    func _didSelectMenuItem(sender: NSMenuItem) {
        // the docs say that it calls -update when it detects a touch in the menu, so I assume it does this to try to prevent actions being sent
        // that perhaps have just been un-enabled due to something else that happened since the menu first appeared. To replicate that, I'll just
        // call update again here to rebuild the list of allowed actions and then do one final check to make sure that the requested action has
        // not been disabled out from under us.
        self.update()
        var app: UIApplication = UIApplication.sharedApplication()
        var firstResponder: UIResponder = app.keyWindow._firstResponder()
        var selectedItem: UIMenuItem = sender.representedObject()
        // now spin through the enabled actions, make sure the selected one is still in there, and then send it if it is.
        if firstResponder && selectedItem {
            for item: UIMenuItem in enabledMenuItems {
                if item.action == selectedItem.action {
                    app.sendAction(item.action, to: firstResponder, from: app, forEvent: nil)
                }
            }
        }
    }

    func menuDidClose(menu: NSMenu) {
        if menu == menu {
            self.menu = nil
        }
    }
}

import AppKit
import AppKit
import AppKit
    let UIMenuControllerWillShowMenuNotification: String = "UIMenuControllerWillShowMenuNotification"

    let UIMenuControllerDidShowMenuNotification: String = "UIMenuControllerDidShowMenuNotification"

    let UIMenuControllerWillHideMenuNotification: String = "UIMenuControllerWillHideMenuNotification"

    let UIMenuControllerDidHideMenuNotification: String = "UIMenuControllerDidHideMenuNotification"

    let UIMenuControllerMenuFrameDidChangeNotification: String = "UIMenuControllerMenuFrameDidChangeNotification"