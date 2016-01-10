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

class UIAlertView: UIView {
    convenience override init(title: String, message: String, delegate: AnyObject, cancelButtonTitle: String, otherButtonTitles: String) {
        if (self.init(frame: CGRectZero)) {
            self.title = title!
            self.message = message
            self.delegate = delegate
            self.buttonTitles = [AnyObject](minimumCapacity: 1)
            if cancelButtonTitle {
                self.cancelButtonIndex = self.addButtonWithTitle(cancelButtonTitle)
            }
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
        }
    }

    func addButtonWithTitle(title: String) -> Int {
        buttonTitles.append(title!)
        return (buttonTitles.count - 1)
    }

    func buttonTitleAtIndex(buttonIndex: Int) -> String {
        return buttonTitles[buttonIndex]
    }

    func show() {
        // capture the current button configuration and build an NSAlert
        // we show it after letting the runloop finish because UIKit stuff is often written with the assumption
        // that showing an alert doesn't block the runloop. Kinda icky, but the same pattern is used for UIActionSheet
        // and the UIMenuController and I don't know there's a lot that I can do about it.
        // NSAlert does have a mode that doesn't block the runloop, but it has other drawbacks that I didn't like
        // so opting to do it this way here. :/
        var alert: NSAlert = NSAlert()
        var buttonOrder: [AnyObject] = [AnyObject](capacity: self.numberOfButtons)
        if self.title {
            alert.messageText = self.title
        }
        if self.message {
            alert.informativeText = self.message
        }
        for var buttonIndex = 0; buttonIndex < self.numberOfButtons; buttonIndex++ {
            if buttonIndex != self.cancelButtonIndex {
                alert.addButtonWithTitle(buttonTitles[buttonIndex])
                buttonOrder.append(Int(buttonIndex))
            }
        }
        if self.cancelButtonIndex >= 0 {
            var btn: NSButton = alert.addButtonWithTitle(buttonTitles[self.cancelButtonIndex])
            // only change the key equivelent if there's more than one button, otherwise we lose the "Return" key for triggering the default action
            if self.numberOfButtons > 1 {
                btn.keyEquivalent = "\033"
                // this should make the escape key trigger the cancel option
            }
            buttonOrder.append(Int(self.cancelButtonIndex))
        }
        if delegateHas.willPresentAlertView {
            delegate.willPresentAlertView(self)
        }
        self.performSelector("_showAlertWithOptions:", withObject: [
            "alert" : alert,
            "buttonOrder" : buttonOrder
        ]
, afterDelay: 0)
    }

    func dismissWithClickedButtonIndex(buttonIndex: Int, animated: Bool) {
    }
    // not implemented at the moment since I use NSAlert and runModal and this would present problems. :/
    var title: String
    var message: String
    weak var delegate: UIAlertViewDelegate {
        get {
            return self.delegate
        }
        set {
            self.delegate = newDelegate
            self.delegateHas.clickedButtonAtIndex = delegate.respondsToSelector("alertView:clickedButtonAtIndex:")
            self.delegateHas.alertViewCancel = delegate.respondsToSelector("alertViewCancel:")
            self.delegateHas.willPresentAlertView = delegate.respondsToSelector("willPresentAlertView:")
            self.delegateHas.didPresentAlertView = delegate.respondsToSelector("didPresentAlertView:")
            self.delegateHas.willDismissWithButtonIndex = delegate.respondsToSelector("alertView:willDismissWithButtonIndex:")
            self.delegateHas.didDismissWithButtonIndex = delegate.respondsToSelector("alertView:didDismissWithButtonIndex:")
        }
    }

    var cancelButtonIndex: Int
    var numberOfButtons: Int {
        get {
            return buttonTitles.count
        }
    }
    var self.buttonTitles: [AnyObject]
    var self.delegateHas: struct{unsignedclickedButtonAtIndex:1;unsignedalertViewCancel:1;unsignedwillPresentAlertView:1;unsigneddidPresentAlertView:1;unsignedwillDismissWithButtonIndex:1;unsigneddidDismissWithButtonIndex:1;}


    func _showAlertWithOptions(options: [NSObject : AnyObject]) {
        var alert: NSAlert = (options["alert"] as! NSAlert)
        var buttonOrder: [AnyObject] = (options["buttonOrder"] as! [AnyObject])
        if delegateHas.didPresentAlertView {
            delegate.didPresentAlertView(self)
        }
        var result: Int = alert.runModal()
        var buttonIndex: Int = -1
        switch result {
            case NSAlertFirstButtonReturn:
                buttonIndex = CInt(buttonOrder[0])!
            case NSAlertSecondButtonReturn:
                buttonIndex = CInt(buttonOrder[1])!
            case NSAlertThirdButtonReturn:
                buttonIndex = CInt(buttonOrder[2])!
            default:
                buttonIndex = CInt(buttonOrder[2 + (result - NSAlertThirdButtonReturn)])!
        }

        if delegateHas.clickedButtonAtIndex {
            delegate.alertView(self, clickedButtonAtIndex: buttonIndex)
        }
        if delegateHas.willDismissWithButtonIndex {
            delegate.alertView(self, willDismissWithButtonIndex: buttonIndex)
        }
        if delegateHas.didDismissWithButtonIndex {
            delegate.alertView(self, didDismissWithButtonIndex: buttonIndex)
        }
    }
}
protocol UIAlertViewDelegate: NSObject {
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int)

    func alertViewCancel(alertView: UIAlertView)
    // never called

    func willPresentAlertView(alertView: UIAlertView)
    // before animation and showing view

    func didPresentAlertView(alertView: UIAlertView)
    // after animation

    func alertView(alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int)
    // before animation and hiding view

    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int)
}

import AppKit
import AppKit
import AppKit