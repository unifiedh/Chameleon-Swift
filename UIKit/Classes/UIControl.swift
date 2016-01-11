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

public struct UIControlEvents : OptionSetType {
    public let rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    static let TouchDown = UIControlEvents(rawValue: 1 << 0)
    static let TouchDownRepeat = UIControlEvents(rawValue: 1 << 1)
    static let TouchDragInside = UIControlEvents(rawValue: 1 << 2)
    static let TouchDragOutside = UIControlEvents(rawValue: 1 << 3)
    static let TouchDragEnter = UIControlEvents(rawValue: 1 << 4)
    static let TouchDragExit = UIControlEvents(rawValue: 1 << 5)
    static let TouchUpInside = UIControlEvents(rawValue: 1 << 6)
    static let TouchUpOutside = UIControlEvents(rawValue: 1 << 7)
    static let TouchCancel = UIControlEvents(rawValue: 1 << 8)
    static let ValueChanged = UIControlEvents(rawValue: 1 << 12)
    static let EditingDidBegin = UIControlEvents(rawValue: 1 << 16)
    static let EditingChanged = UIControlEvents(rawValue: 1 << 17)
    static let EditingDidEnd = UIControlEvents(rawValue: 1 << 18)
    static let EditingDidEndOnExit = UIControlEvents(rawValue: 1 << 19)
    static let AllTouchEvents = UIControlEvents(rawValue: 0x00000FFF)
    static let AllEditingEvents = UIControlEvents(rawValue: 0x000F0000)
    static let ApplicationReserved = UIControlEvents(rawValue: 0x0F000000)
    static let SystemReserved = UIControlEvents(rawValue: 0xF0000000)
    static let AllEvents = UIControlEvents(rawValue: 0xFFFFFFFF)
}

public struct UIControlState : OptionSetType {
    public let rawValue: UInt
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    public static let Normal = UIControlState(rawValue: 0)
    public static let Highlighted = UIControlState(rawValue: 1 << 0)
    public static let Disabled = UIControlState(rawValue: 1 << 1)
    public static let Selected = UIControlState(rawValue: 1 << 2)
    public static let Application = UIControlState(rawValue: 0x00FF0000)
    public static let Reserved = UIControlState(rawValue: 0xFF000000)
}

public enum UIControlContentHorizontalAlignment : Int {
    case Center = 0
    case Left = 1
    case Right = 2
    case Fill = 3
}

public enum UIControlContentVerticalAlignment : Int {
    case Center = 0
    case Top = 1
    case Bottom = 2
    case Fill = 3
}

public class UIControl: UIView {
    func addTarget(target: AnyObject, action: Selector, forControlEvents controlEvents: UIControlEvents) {
        var controlAction: UIControlAction = UIControlAction()
        controlAction.target = target
        controlAction.action = action
        controlAction.controlEvents = controlEvents
        registeredActions.append(controlAction)
    }

    func removeTarget(target: AnyObject, action: Selector, forControlEvents controlEvents: UIControlEvents) {
        var discard: [AnyObject] = [AnyObject]()
        for controlAction: UIControlAction in registeredActions {
            if controlAction.target == target && (action == nil || controlAction.controlEvents == controlEvents) {
                discard.append(controlAction)
            }
        }
        registeredActions.removeObjectsInArray(discard)
    }

    func actionsForTarget(target: AnyObject, forControlEvent controlEvent: UIControlEvents) -> [AnyObject] {
        var actions: [AnyObject] = [AnyObject]()
        for controlAction: UIControlAction in registeredActions {
            if (target == nil || controlAction.target == target) && (controlAction.controlEvents & controlEvent) {
                actions.append(NSStringFromSelector(controlAction.action))
            }
        }
        if actions.count == 0 {
            return nil
        }
        else {
            return actions
        }
    }

    func allTargets() -> Set<AnyObject> {
        return Set<AnyObject>.setWithArray(registeredActions["target"])
    }

    func allControlEvents() -> UIControlEvents {
        var allEvents: UIControlEvents = 0
        for controlAction: UIControlAction in registeredActions {
            allEvents |= controlAction.controlEvents
        }
        return allEvents
    }

    func sendActionsForControlEvents(controlEvents: UIControlEvents) {
        self._sendActionsForControlEvents(controlEvents, withEvent: nil)
    }

    func sendAction(action: Selector, to target: AnyObject, forEvent event: UIEvent) {
        UIApplication.sharedApplication().sendAction(action, to: target, from: self, forEvent: event)
    }

    func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        return true
    }

    func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        return true
    }

    func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
    }

    func cancelTrackingWithEvent(event: UIEvent) {
    }
    var state: UIControlState {
        get {
            var state: UIControlState = .Normal
            if highlighted {
                state |= .Highlighted
            }
            if !enabled {
                state |= .Disabled
            }
            if selected != nil {
                state |= .Selected
            }
            return state
        }
    }

    var enabled: Bool {
        get {
            return self.enabled
        }
        set {
            if newEnabled != enabled {
                self.enabled = newEnabled
                self._stateDidChange()
                self.userInteractionEnabled = enabled
            }
        }
    }

    var selected: Bool {
        get {
            return self.selected
        }
        set {
            if newSelected != selected {
                self.selected = newSelected
                self._stateDidChange()
            }
        }
    }

    var highlighted: Bool {
        get {
            return self.highlighted
        }
        set {
            if newHighlighted != highlighted {
                self.highlighted = newHighlighted
                self._stateDidChange()
            }
        }
    }

    var tracking: Bool {
        get {
            return self.tracking
        }
    }

    var touchInside: Bool {
        get {
            return self.touchInside
        }
    }

    var contentHorizontalAlignment: UIControlContentHorizontalAlignment
    var contentVerticalAlignment: UIControlContentVerticalAlignment
    var self.registeredActions: [AnyObject]


    convenience override init(frame: CGRect) {
        if (self.init(frame: frame)) {
            self.registeredActions = [AnyObject]()
            self.enabled = true
            self.contentHorizontalAlignment = .Center
            self.contentVerticalAlignment = .Center
        }
    }

    func _sendActionsForControlEvents(controlEvents: UIControlEvents, withEvent event: UIEvent) {
        for controlAction: UIControlAction in registeredActions {
            if controlAction.controlEvents & controlEvents {
                self.sendAction(controlAction.action, to: controlAction.target, forEvent: event)
            }
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var touch: UITouch = touches.first!
        self.touchInside = true
        self.tracking = self.beginTrackingWithTouch(touch, withEvent: event)
        self.highlighted = true
        if tracking {
            var currentEvents: UIControlEvents = .TouchDown
            if touch.tapCount > 1 {
                currentEvents |= .TouchDownRepeat
            }
            self._sendActionsForControlEvents(currentEvents, withEvent: event)
        }
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var touch: UITouch = touches.first!
        let wasTouchInside: Bool = touchInside
        self.touchInside = self.pointInside(touch.locationInView(self), withEvent: event)
        self.highlighted = touchInside
        if tracking {
            self.tracking = self.continueTrackingWithTouch(touch, withEvent: event)
            if tracking {
                var currentEvents: UIControlEvents = ((touchInside) ? .TouchDragInside : .TouchDragOutside)
                if !wasTouchInside && touchInside {
                    currentEvents |= .TouchDragEnter
                }
                else if wasTouchInside && !touchInside {
                    currentEvents |= .TouchDragExit
                }

                self._sendActionsForControlEvents(currentEvents, withEvent: event)
            }
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var touch: UITouch = touches.first!
        self.touchInside = self.pointInside(touch.locationInView(self), withEvent: event)
        self.highlighted = false
        if tracking {
            self.endTrackingWithTouch(touch, withEvent: event)
            self._sendActionsForControlEvents(((touchInside) ? .TouchUpInside : .TouchUpOutside), withEvent: event)
        }
        self.tracking = false
        self.touchInside = false
    }

    func touchesCancelled(touches: Set<AnyObject>, withEvent event: UIEvent) {
        self.highlighted = false
        if tracking {
            self.cancelTrackingWithEvent(event)
            self._sendActionsForControlEvents(.TouchCancel, withEvent: event)
        }
        self.touchInside = false
        self.tracking = false
    }

    func _stateDidChange() {
        self.setNeedsDisplay()
        self.setNeedsLayout()
    }
}