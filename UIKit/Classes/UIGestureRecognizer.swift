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
enum UIGestureRecognizerState : Int {
    case Possible
    case Began
    case Changed
    case Ended
    case Cancelled
    case Failed
    case Recognized = .Ended
}

protocol UIGestureRecognizerDelegate: NSObject {
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool
}
class UIGestureRecognizer: NSObject {
    convenience override init(target: AnyObject, action: Selector) {
        if (self.init()) {
            self.state = .Possible
            self.cancelsTouchesInView = true
            self.delaysTouchesBegan = false
            self.delaysTouchesEnded = true
            self.enabled = true
            self.registeredActions = [AnyObject](capacity: 1)
            self.trackingTouches = [AnyObject](capacity: 1)
            self.addTarget(target, action: action)
        }
    }

    func addTarget(target: AnyObject, action: Selector) {
        assert(target != nil, "target must not be nil")
        assert(action != nil, "action must not be NULL")
        var actionRecord: UIAction = UIAction()
        actionRecord.target = target
        actionRecord.action = action
        registeredActions.append(actionRecord)
    }

    func removeTarget(target: AnyObject, action: Selector) {
        var actionRecord: UIAction = UIAction()
        actionRecord.target = target
        actionRecord.action = action
        registeredActions.removeObject(actionRecord)
    }

    func requireGestureRecognizerToFail(otherGestureRecognizer: UIGestureRecognizer) {
    }

    func locationInView(view: UIView) -> CGPoint {
        // by default, this should compute the centroid of all the involved points
        // of course as of this writing, Chameleon only supports one point but at least
        // it may be semi-correct if that ever changes. :D YAY FOR COMPLEXITY!
        var x: CGFloat = 0
        var y: CGFloat = 0
        var k: CGFloat = 0
        for touch: UITouch in trackingTouches {
            let p: CGPoint = touch.locationInView(view)
            x += p.x
            y += p.y
            k++
        }
        if k > 0 {
            return CGPointMake(x / k, y / k)
        }
        else {
            return CGPointZero
        }
    }

    func numberOfTouches() -> Int {
        return trackingTouches.count
    }
    weak var delegate: UIGestureRecognizerDelegate {
        get {
            return self.delegate
        }
        set {
            if aDelegate != delegate {
                self.delegate = aDelegate
                self.delegateHas.shouldBegin = delegate.respondsToSelector("gestureRecognizerShouldBegin:")
                self.delegateHas.shouldReceiveTouch = delegate.respondsToSelector("gestureRecognizer:shouldReceiveTouch:")
                self.delegateHas.shouldRecognizeSimultaneouslyWithGestureRecognizer = delegate.respondsToSelector("gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:")
            }
        }
    }

    var delaysTouchesBegan: Bool
    var delaysTouchesEnded: Bool
    var cancelsTouchesInView: Bool
    var enabled: Bool
    var state: UIGestureRecognizerState {
        get {
            return self.state
        }
        set {
            if delegateHas.shouldBegin && state == .Possible && (state == .Recognized || state == .Began) {
                if !delegate.gestureRecognizerShouldBegin(self) {
                    state = .Failed
                }
            }
            // the docs didn't say explicitly if these state transitions were verified, but I suspect they are. if anything, a check like this
            // should help debug things. it also helps me better understand the whole thing, so it's not a total waste of time :)
            var StateTransition: struct{UIGestureRecognizerStatefromState,toState;BOOLshouldNotify;}
        }
    }

    var view: UIView {
        get {
            return self.view
        }
    }
    var self.registeredActions: [AnyObject]
    var self.trackingTouches: [AnyObject]
    var self.view: UIView
    var self.delegateHas: struct{unsignedshouldBegin:1;unsignedshouldReceiveTouch:1;unsignedshouldRecognizeSimultaneouslyWithGestureRecognizer:1;}


    func _setView(v: UIView) {
        if v != view {
            self.reset()
            // not sure about this, but I think it makes sense
            self.view = v
        }
    }

    func locationOfTouch(touchIndex: Int, inView view: UIView) -> CGPoint {
        return trackingTouches[touchIndex].locationInView(view)
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

let NumberOfStateTransitions = 9
    let allowedTransitions: StateTransition = StateTransition()
    allowedTransitions.    // discrete gestures
StateTransition()
    allowedTransitions..Possible
    allowedTransitions..Recognized
    allowedTransitions.true
    allowedTransitions.StateTransition()
    allowedTransitions..Possible
    allowedTransitions..Failed
    allowedTransitions.false
    allowedTransitions.    // continuous gestures
StateTransition()
    allowedTransitions..Possible
    allowedTransitions..Began
    allowedTransitions.true
    allowedTransitions.StateTransition()
    allowedTransitions..Began
    allowedTransitions..Changed
    allowedTransitions.true
    allowedTransitions.StateTransition()
    allowedTransitions..Began
    allowedTransitions..Cancelled
    allowedTransitions.true
    allowedTransitions.StateTransition()
    allowedTransitions..Began
    allowedTransitions..Ended
    allowedTransitions.true
    allowedTransitions.StateTransition()
    allowedTransitions..Changed
    allowedTransitions..Changed
    allowedTransitions.true
    allowedTransitions.StateTransition()
    allowedTransitions..Changed
    allowedTransitions..Cancelled
    allowedTransitions.true
    allowedTransitions.StateTransition()
    allowedTransitions..Changed
    allowedTransitions..Ended
    allowedTransitions.true

    let transition: StateTransition? = nil

        t = 0
        t < NumberOfStateTransitions
        t++)
                    if allowedTransitions[t].fromState == state && allowedTransitions[t].toState == state {
                transition = allowedTransitions[t]
            }

        NSAssert2((transition != nil), "invalid state transition from %ld to %ld", state, state)
        if transition! {
            self.state = transition->toState
            if transition->shouldNotify {
                for actionRecord: UIAction in registeredActions {
                    // docs mention that the action messages are sent on the next run loop, so we'll do that here.
                    // note that this means that reset can't happen until the next run loop, either otherwise
                    // the state property is going to be wrong when the action handler looks at it, so as a result
                    // I'm also delaying the reset call (if necessary) below in -continueTrackingWithEvent:
                    actionRecord.target.performSelector(actionRecord.action, withObject: self, afterDelay: 0)
                }
            }
        }

        var reset
                    self.state = .Possible

        -

        return true

        return true

        void ignoreTouch:(UITouch)
        touch forEvent:(UIEvent)

        void touchesBegan:(Set<AnyObject>)
        touches withEvent:(UIEvent)

        void touchesMoved:(Set<AnyObject>)
        touches withEvent:(UIEvent)

        void touchesEnded:(Set<AnyObject>)
        touches withEvent:(UIEvent)

        void touchesCancelled:(Set<AnyObject>)
        touches withEvent:(UIEvent)

        void _beginTrackingTouch:(UITouch)
        touch withEvent:(UITouchEvent)

        if self.enabled {
            if !delegateHas.shouldReceiveTouch || delegate.gestureRecognizer(self, shouldReceiveTouch: touch) {
                touch._addGestureRecognizer(self)
                trackingTouches.append(touch)
            }
        }

        void _continueTrackingWithEvent:(UITouchEvent)

        var began: NSMutableSet = NSMutableSet()
        var moved: NSMutableSet = NSMutableSet()
        var ended: NSMutableSet = NSMutableSet()
        var cancelled: NSMutableSet = NSMutableSet()
        var multitouchSequenceIsEnded: Bool = true
        for touch: UITouch in trackingTouches {
            if touch.phase == .Began {
                multitouchSequenceIsEnded = false
                began.append(touch)
            }
            else if touch.phase == .Moved {
                multitouchSequenceIsEnded = false
                moved.append(touch)
            }
            else if touch.phase == .Stationary {
                multitouchSequenceIsEnded = false
            }
            else if touch.phase == .Ended {
                ended.append(touch)
            }
            else if touch.phase == .Cancelled {
                cancelled.append(touch)
            }
        }
        if state == .Possible || state == .Began || state == .Changed {
            if began.count {
                self.touchesBegan(began, withEvent: event)
            }
            if moved.count {
                self.touchesMoved(moved, withEvent: event)
            }
            if ended.count {
                self.touchesEnded(ended, withEvent: event)
            }
            if cancelled.count {
                self.touchesCancelled(cancelled, withEvent: event)
            }
        }
        // if all the touches are ended or cancelled, then the multitouch sequence must be over - so we can reset
        // our state back to normal and clear all the tracked touches, etc. to get ready for a new touch sequence
        // in the future.
        // this also applies to the special discrete gesture events because those events are only sent once!
        if multitouchSequenceIsEnded || event.isDiscreteGesture {
            // see note above in -setState: about the delay here!
            self.performSelector("reset", withObject: nil, afterDelay: 0)
        }

        void _endTrackingTouch:(UITouch)
        touch withEvent:(UITouchEvent)

        touch._removeGestureRecognizer(self)
        trackingTouches.removeObject(touch)

        var state: String = ""
        switch self.state {
            case .Possible:
                state = "Possible"
            case .Began:
                state = "Began"
            case .Changed:
                state = "Changed"
            case .Ended:
                state = "Ended"
            case .Cancelled:
                state = "Cancelled"
            case .Failed:
                state = "Failed"
        }

        return "<\(self.className()): \(self); state = \(state); view = \(self.view!)>"