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

// NOTE: This will only match the scroll gestures on touch input devices. If you also
// need classic wheel mice, you have to use UIScrollWheelGestureRecognizer as well.
// Additional note: This will not register the system's automatically generated
// momentum scroll events - those will come through by way of the classic wheel
// recognizer as well. They are handled differently because OSX sends them outside
// of the gestureBegin/gestureEnded sequence. This turned out to be somewhat handy
// for UIScrollView but it certainly might make using the gesture recognizer in
// a standalone setting somewhat more annoying. We'll have to see how it plays out.
class UIPanGestureRecognizer: UIGestureRecognizer {
    func translationInView(view: UIView) -> CGPoint {
        return translation
    }

    func setTranslation(translation: CGPoint, inView view: UIView) {
        self.velocity = CGPointZero
        self.translation = translation
    }

    func velocityInView(view: UIView) -> CGPoint {
        return velocity
    }
    var maximumNumberOfTouches: Int
    var minimumNumberOfTouches: Int
    var self.translation: CGPoint
    var self.velocity: CGPoint
    var self.lastMovementTime: NSTimeInterval


    convenience override init(target: AnyObject, action: Selector) {
        if (self.init(target: target, action: action)) {
            self.minimumNumberOfTouches = 1
            self.maximumNumberOfTouches = NSUIntegerMax
            self.translation = CGPointZero
            self.velocity = CGPointZero
        }
    }

    func _translate(delta: CGPoint, withEvent event: UIEvent) -> Bool {
        let timeDiff: NSTimeInterval = event.timestamp - lastMovementTime
        if !CGPointEqualToPoint(delta, CGPointZero) && timeDiff > 0 {
            self.translation.x += delta.x
            self.translation.y += delta.y
            self.velocity.x = delta.x / timeDiff
            self.velocity.y = delta.y / timeDiff
            self.lastMovementTime = event.timestamp
            return true
        }
        else {
            return false
        }
    }

    func reset() {
        super.reset()
        self.translation = CGPointZero
        self.velocity = CGPointZero
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if self.state == .Possible {
            if (event is UITouchEvent) {
                var touchEvent: UITouchEvent = event as! UITouchEvent
                if touchEvent.touchEventGesture != .Begin {
                    self.state = .Failed
                }
            }
        }
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (event is UITouchEvent) {
            var touchEvent: UITouchEvent = event as! UITouchEvent
            if touchEvent.touchEventGesture == .Pan {
                if self.state == .Possible {
                    self.lastMovementTime = touchEvent.timestamp
                    self.setTranslation(touchEvent.translation, inView: touchEvent.touch.view!)
                    self.state = .Began
                }
                else if self._translate(touchEvent.translation, withEvent: event) {
                    self.state = .Changed
                }
            }
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if self.state == .Began || self.state == .Changed {
            if (event is UITouchEvent) {
                var touchEvent: UITouchEvent = event as! UITouchEvent
                self._translate(touchEvent.translation, withEvent: touchEvent)
                self.state = .Ended
            }
            else {
                self.state = .Cancelled
            }
        }
    }

    func touchesCancelled(touches: Set<AnyObject>, withEvent event: UIEvent) {
        if self.state == .Began || self.state == .Changed {
            self.state = .Cancelled
        }
    }
}