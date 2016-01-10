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

// This will work for normal left-click long presses OR a right-click. The right-click will always
// be recognized as a long press regardless of how long the user holds down the right mouse button
// and it doesn't worry about allowableMovement and the other parameters that the regular long
// press would normally need to be worried about.
// Note that technically the long press gesture is continuous but a right click is discrete in Chameleon,
// so this is sort of a hack as it immediately switches to UIGestureRecognizerStateBegan in that case and
// ends up never switching to UIGestureRecognizerStateEnded. Since the right click "gesture" is discrete,
// it ends up getting aborted/reset before that happens. So if you want your long press recognizer to work
// with right clicks, make sure you take action when the state switches to UIGestureRecognizerStateBegan
// instead of UIGestureRecognizerStateEnded.
class UILongPressGestureRecognizer: UIGestureRecognizer {
    var minimumPressDuration: CFTimeInterval
    var allowableMovement: CGFloat
    var numberOfTapsRequired: Int
    var numberOfTouchesRequired: Int
    var self.beginLocation: CGPoint
    var self.waiting: Bool


    convenience override init(target: AnyObject, action: Selector) {
        if (self.init(target: target, action: action)) {
            self.allowableMovement = 10
            self.minimumPressDuration = 0.5
            self.numberOfTapsRequired = 0
            self.numberOfTouchesRequired = 1
        }
    }

    func _beginGesture() {
        self.waiting = false
        if self.state == .Possible {
            self.state = .Began
            UIApplicationSendStationaryTouches()
        }
    }

    func _cancelWaiting() {
        if waiting {
            self.waiting = false
            self.cancelPreviousPerformRequestsWithTarget(self, selector: "_beginGesture", object: nil)
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (event is UITouchEvent) {
            var touchEvent: UITouchEvent = event as! UITouchEvent
            if touchEvent.touchEventGesture == .RightClick {
                self.state = .Began
            }
            else if touchEvent.touchEventGesture == .None {
                if !waiting && self.state == .Possible && touchEvent.touch.tapCount >= self.numberOfTapsRequired {
                    self.beginLocation = touchEvent.touch.locationInView(self.view!)
                    self.waiting = true
                    self.performSelector("_beginGesture", withObject: nil, afterDelay: self.minimumPressDuration)
                }
            }
            else {
                self.state = .Failed
            }
        }
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var touch: UITouch = touches.first!
        let distance: CGFloat = DistanceBetweenTwoPoints(touch.locationInView(self.view!), beginLocation)
        if self.state == .Began || self.state == .Changed {
            if distance <= self.allowableMovement {
                self.state = .Changed
            }
            else {
                self.state = .Cancelled
            }
        }
        else if self.state == .Possible && distance > self.allowableMovement {
            self.state = .Failed
        }

    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if self.state == .Began || self.state == .Changed {
            self.state = .Ended
        }
        else {
            self._cancelWaiting()
        }
    }

    func touchesCancelled(touches: Set<AnyObject>, withEvent event: UIEvent) {
        if self.state == .Began || self.state == .Changed {
            self.state = .Cancelled
        }
        else {
            self._cancelWaiting()
        }
    }

    func reset() {
        self._cancelWaiting()
        super.reset()
    }
}


        var a: CGFloat = B.x - A.x
        var b: CGFloat = B.y - A.y
        return sqrtf((a * a) + (b * b))