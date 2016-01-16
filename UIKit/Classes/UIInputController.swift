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

class UIInputController: NSObject {
    class func sharedInputController() -> UIInputController {
        var controller: UIInputController? = nil
        if !controller {
            controller = self()
        }
        return controller!
    }

    func setInputVisible(visible: Bool, animated: Bool) {
        self._repositionInputWindow()
        var fakeAnimationInfo: [NSObject : AnyObject] = [
            UIKeyboardFrameBeginUserInfoKey : NSValue(CGRect: inputWindow.frame),
            UIKeyboardFrameEndUserInfoKey : NSValue(CGRect: inputWindow.frame),
            UIKeyboardAnimationDurationUserInfoKey : Int(0),
            UIKeyboardAnimationCurveUserInfoKey : Int(.Linear)
        ]

        if visible {
            NSNotificationCenter.defaultCenter().postNotificationName(UIKeyboardWillShowNotification, object: nil, userInfo: fakeAnimationInfo)
        }
        else {
            NSNotificationCenter.defaultCenter().postNotificationName(UIKeyboardWillHideNotification, object: nil, userInfo: fakeAnimationInfo)
        }
        self.inputWindow.hidden = !visible
        if visible {
            NSNotificationCenter.defaultCenter().postNotificationName(UIKeyboardDidShowNotification, object: nil, userInfo: fakeAnimationInfo)
        }
        else {
            NSNotificationCenter.defaultCenter().postNotificationName(UIKeyboardDidHideNotification, object: nil, userInfo: fakeAnimationInfo)
        }
    }
    var inputAccessoryView: UIView? {
        get {
            return self.inputAccessoryView
        }
        set {
            if view != inputAccessoryView {
                inputAccessoryView.removeFromSuperview()
                self.inputAccessoryView = view
                inputWindow.addSubview(inputAccessoryView)
            }
        }
    }

    var inputView: UIView? {
        get {
            return self.inputView
        }
        set {
            if view != inputView {
                inputView.removeFromSuperview()
                self.inputView = view
                inputWindow.addSubview(inputView)
            }
        }
    }

    weak var keyInputResponder: UIResponder<UIKeyInput>
    var inputVisible: Bool {
        get {
            return !inputWindow.hidden
        }
        set {
            self._repositionInputWindow()
            var fakeAnimationInfo: [NSObject : AnyObject] = [
                UIKeyboardFrameBeginUserInfoKey : NSValue(CGRect: inputWindow.frame),
                UIKeyboardFrameEndUserInfoKey : NSValue(CGRect: inputWindow.frame),
                UIKeyboardAnimationDurationUserInfoKey : Int(0),
                UIKeyboardAnimationCurveUserInfoKey : Int(.Linear)
            ]
    
            if visible {
                NSNotificationCenter.defaultCenter().postNotificationName(UIKeyboardWillShowNotification, object: nil, userInfo: fakeAnimationInfo)
            }
            else {
                NSNotificationCenter.defaultCenter().postNotificationName(UIKeyboardWillHideNotification, object: nil, userInfo: fakeAnimationInfo)
            }
            self.inputWindow.hidden = !visible
            if visible {
                NSNotificationCenter.defaultCenter().postNotificationName(UIKeyboardDidShowNotification, object: nil, userInfo: fakeAnimationInfo)
            }
            else {
                NSNotificationCenter.defaultCenter().postNotificationName(UIKeyboardDidHideNotification, object: nil, userInfo: fakeAnimationInfo)
            }
        }
    }
    var self.inputWindow: UIWindow


    convenience override init() {
        if (self.init()) {
            self.inputWindow = UIWindow(frame: CGRectZero)
            self.inputWindow.windowLevel = UIWindowLevelStatusBar
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "_viewChangedNotification:", name: UIViewFrameDidChangeNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "_viewChangedNotification:", name: UIViewDidMoveToSuperviewNotification, object: nil)
        }
    }

    func dealloc() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    // finds the first real UIView that the current key window's first responder "belongs" to so we know where to display the input window

    func _referenceView() -> UIView {
        var firstResponder: UIResponder = self.keyInputResponder
        if firstResponder != nil {
            var currentResponder: UIResponder = firstResponder
            // find the first real UIView that this responder "belongs" to so we know where to display the input view from
            while currentResponder {
                if (currentResponder is UIView) {
                    return currentResponder as! UIView
                }
                else {
                    currentResponder = currentResponder.nextResponder()
                }
            }
        }
        return nil
    }

    func _repositionInputWindow() {
        var referenceView: UIView = self._referenceView()
        var containerView: UIView = ContainerForView(referenceView)
        var screen: UIScreen = containerView.window.screen
        if screen && containerView {
            self.inputWindow.screen = screen
            let viewFrameInWindow: CGRect = referenceView.convertRect(referenceView.bounds, toView: nil)
            let viewFrameInScreen: CGRect = referenceView.window.convertRect(viewFrameInWindow, toWindow: nil)
            let containerFrameInWindow: CGRect = containerView.convertRect(containerView.bounds, toView: nil)
            let containerFrameInScreen: CGRect = containerView.window.convertRect(containerFrameInWindow, toWindow: nil)
            let inputWidth: CGFloat = CGRectGetWidth(containerFrameInScreen)
            var inputHeight: CGFloat = 0
            if inputAccessoryView {
                let height: CGFloat = inputAccessoryView.frame.size.height
                self.inputAccessoryView.autoresizingMask = .None
                self.inputAccessoryView.frame = CGRectMake(0, inputHeight, inputWidth, height)
                inputHeight += height
            }
            if inputView != nil {
                let height: CGFloat = inputView.frame.size.height
                self.inputView.autoresizingMask = .None
                self.inputView.frame = CGRectMake(0, inputHeight, inputWidth, height)
                inputHeight += height
            }
            self.inputWindow.frame = CGRectMake(CGRectGetMinX(containerFrameInScreen), CGRectGetMaxY(viewFrameInScreen), inputWidth, inputHeight)
        }
    }

    func _viewChangedNotification(note: NSNotification) {
        if self.inputVisible {
            var view: UIView = note.object
            var referenceView: UIView = self._referenceView()
            if view == referenceView || ContainerForView(referenceView).isDescendantOfView(view) {
                self._repositionInputWindow()
            }
        }
    }

    func setInputVisible(inputVisible: Bool) {
        self.setInputVisible(inputVisible, animated: false)
    }
}

/*
        // find the reference view's "container" view, which I'm going to define as the nearest view of a UIViewController or a UIWindow.
        var containerView: UIView = view
        while containerView && !((containerView is UIWindow) || containerView._viewController()) {
            containerView = containerView.superview()
        }
        return containerView
*/
