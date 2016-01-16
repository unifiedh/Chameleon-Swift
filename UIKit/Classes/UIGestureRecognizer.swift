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

public enum UIGestureRecognizerState : Int {
    case Possible
    case Began
    case Changed
    case Ended
    case Cancelled
    case Failed
    //case Recognized = .Ended
    
    public static let Recognized = UIGestureRecognizerState.Ended
}

@objc public protocol UIGestureRecognizerDelegate: NSObjectProtocol {
    optional func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool

    optional func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool

    optional func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool
}
public class UIGestureRecognizer: NSObject {
	private var delegateHas: DelegateHas = []
	
	private struct DelegateHas: OptionSetType {
		let rawValue: UInt8
		
		static var ShouldBegin = DelegateHas(rawValue: 1 << 0)
		static var ShouldReceiveTouch = DelegateHas(rawValue: 1 << 1)
		static var ShouldRecognizeSimultaneouslyWithGestureRecognizer = DelegateHas(rawValue: 1 << 2)
	}

    public init(target: NSObject, action: Selector) {
            self.state = .Possible
            self.cancelsTouchesInView = true
            self.delaysTouchesBegan = false
            self.delaysTouchesEnded = true
            self.enabled = true
            self.registeredActions = [UIAction]()
            self.trackingTouches = [UITouch]()
            self.addTarget(target, action: action)
            
            super.init()
    }

    public func addTarget(target: NSObject, action: Selector) {
        //assert(target != nil, "target must not be nil")
        assert(action != nil, "action must not be NULL")
        let actionRecord: UIAction = UIAction()
        actionRecord.target = target
        actionRecord.action = action
        registeredActions.append(actionRecord)
    }

    public func removeTarget(target: NSObject, action: Selector) {
        let actionRecord = UIAction()
        actionRecord.target = target
        actionRecord.action = action
		var location: Int?
		for (i, obj) in registeredActions.enumerate() {
			if obj == actionRecord {
				location = i
				break
			}
		}
		if let location = location {
			registeredActions.removeAtIndex(location)
		}
    }

    public func requireGestureRecognizerToFail(otherGestureRecognizer: UIGestureRecognizer) {
    }

    public func locationInView(view: UIView) -> CGPoint {
        // by default, this should compute the centroid of all the involved points
        // of course as of this writing, Chameleon only supports one point but at least
        // it may be semi-correct if that ever changes. :D YAY FOR COMPLEXITY!
        var x: CGFloat = 0
        var y: CGFloat = 0
        var k: CGFloat = 0
        for touch in trackingTouches {
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

    public func numberOfTouches() -> Int {
        return trackingTouches.count
    }
    public weak var delegate: UIGestureRecognizerDelegate? {
        didSet {
            if oldValue !== delegate {
				if delegate?.gestureRecognizerShouldBegin == nil {
					delegateHas.remove(.ShouldBegin)
				} else {
					delegateHas.insert(.ShouldBegin)
				}
            }
        }
    }

    public private(set) var delaysTouchesBegan: Bool
    public private(set) var delaysTouchesEnded: Bool
    public var cancelsTouchesInView: Bool
    public var enabled: Bool
    private var _state:UIGestureRecognizerState = .Failed
    public var state: UIGestureRecognizerState {
        get {
            return _state
        }
        set(state) {
            if delegateHas.contains(.ShouldBegin) && state == .Possible && (state == .Recognized || state == .Began) {
                if !(delegate?.gestureRecognizerShouldBegin?(self) ?? false) {
                    _state = .Failed
                }
            }
            // the docs didn't say explicitly if these state transitions were verified, but I suspect they are. if anything, a check like this
            // should help debug things. it also helps me better understand the whole thing, so it's not a total waste of time :)
            struct StateTransition {
                var fromState: UIGestureRecognizerState
                var toState: UIGestureRecognizerState
                var shouldNotify: Bool
                
                static let allowedStates: [StateTransition] = [
                    
                    // discrete gestures
                    StateTransition(fromState: .Possible, toState: .Recognized,	shouldNotify: true),
                    StateTransition(fromState: .Possible, toState: .Failed,		shouldNotify: false),
                    
                    // continuous gestures
                    StateTransition(fromState: .Possible,	toState: .Began,		shouldNotify: true),
                    StateTransition(fromState: .Began,		toState: .Changed,		shouldNotify: true),
                    StateTransition(fromState: .Began,		toState: .Cancelled,	shouldNotify: true),
                    StateTransition(fromState: .Began,		toState: .Ended,		shouldNotify: true),
                    StateTransition(fromState: .Changed,	toState: .Changed,		shouldNotify: true),
                    StateTransition(fromState: .Changed,	toState: .Cancelled,	shouldNotify: true),
                    StateTransition(fromState: .Changed,	toState: .Ended,		shouldNotify: true)
                ]
            }
            
            var transition: StateTransition?
            
            for aTransition in StateTransition.allowedStates {
                if (aTransition.fromState == _state && aTransition.toState == state) {
                    transition = aTransition
                    break;
                }
            }
            
            if let transition = transition {
                _state = transition.toState
				
				if transition.shouldNotify {
					for actionRecord in registeredActions {
						// docs mention that the action messages are sent on the next run loop, so we'll do that here.
						// note that this means that reset can't happen until the next run loop, either otherwise
						// the state property is going to be wrong when the action handler looks at it, so as a result
						// I'm also delaying the reset call (if necessary) below in -continueTrackingWithEvent:
						actionRecord.target?.performSelector(actionRecord.action!, withObject: self, afterDelay: 0)
					}
				}

            } else {
                assert(false, "invalid state transition from \(_state.rawValue) to \(state.rawValue)")
            }
            //var StateTransition: struct{UIGestureRecognizerState fromState,toState;BOOLshouldNotify;}
        }
    }

    var registeredActions: [UIAction]
    var trackingTouches: [UITouch]
    public internal(set) weak var view: UIView?

    internal func _setView(v: UIView) {
        if v != view {
            self.reset()
            // not sure about this, but I think it makes sense
            self.view = v
        }
    }

    public func locationOfTouch(touchIndex: Int, inView view: UIView) -> CGPoint {
        return trackingTouches[touchIndex].locationInView(view)
    }
    
    public override var description: String {
        var state = "";
        switch (self.state) {
        case .Possible:
            state = "Possible";
            
        case .Began:
            state = "Began";
            
        case .Changed:
            state = "Changed";
            
        case .Ended:
            state = "Ended";
            
        case .Cancelled:
            state = "Cancelled";
            
        case .Failed:
            state = "Failed";
        }
        return "<\(self.className): \(unsafeAddressOf(self)); state = \(state); view = \(self.view!)>"
    }
	
	public func reset() {
		// note - this is also supposed to ignore any currently tracked touches
		// the touches themselves may not have gone away, so we don't just remove them from tracking, I think,
		// but instead just mark them as ignored by this gesture until the touches eventually end themselves.
		// in any case, this isn't implemented right now because we only have a single touch and so far I
		// haven't needed it.
		
		_state = .Possible;
	}
	
	public func canPreventGestureRecognizer(preventedGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true;
	}
	
	public func canBePreventedByGestureRecognizer(preventingGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true;
	}
	
	public final func ignoreTouch(touch: UITouch, forEvent event: UIEvent) {
		
	}
	
	public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
	
	}
	
	public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
		
	}
	
	public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent) {
		
	}
	
	public func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent) {
		
	}

	internal func _beginTrackingTouch(touch: UITouch, withEvent event: UITouchEvent) {

		if enabled {
			if !delegateHas.contains(.ShouldReceiveTouch) || delegate!.gestureRecognizer!(self, shouldReceiveTouch: touch) {
				touch._addGestureRecognizer(self)
				trackingTouches.append(touch)
			}
		}
	}

	internal func _continueTrackingWithEvent(event: UITouchEvent) {
		var began = Set<UITouch>()
		var moved = Set<UITouch>()
		var ended = Set<UITouch>()
		var cancelled = Set<UITouch>()
		var multitouchSequenceIsEnded: Bool = true
		for touch in trackingTouches {
			if touch.phase == .Began {
				multitouchSequenceIsEnded = false
				began.insert(touch)
			}
			else if touch.phase == .Moved {
				multitouchSequenceIsEnded = false
				moved.insert(touch)
			}
			else if touch.phase == .Stationary {
				multitouchSequenceIsEnded = false
			}
			else if touch.phase == .Ended {
				ended.insert(touch)
			}
			else if touch.phase == .Cancelled {
				cancelled.insert(touch)
			}
		}
		if state == .Possible || state == .Began || state == .Changed {
			if began.count > 0 {
				self.touchesBegan(began, withEvent: event)
			}
			if moved.count > 0 {
				self.touchesMoved(moved, withEvent: event)
			}
			if ended.count > 0 {
				self.touchesEnded(ended, withEvent: event)
			}
			if cancelled.count > 0 {
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
		
	}

	internal func _endTrackingTouch(touch: UITouch, withEvent event: UITouchEvent) {
		touch._removeGestureRecognizer(self)
		var location: Int?
		for (i, obj) in trackingTouches.enumerate() {
			if obj == touch {
				location = i
				break
			}
		}
		if let location = location {
			trackingTouches.removeAtIndex(location)
		}
	}
}
