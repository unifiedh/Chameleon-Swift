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

// OSX's native swipe gesture doesn't seem to support the idea of varying numbers of touches involved in
// the gesture, so this will recognize for any OSX swipe regardless of touch count!
enum UISwipeGestureRecognizerDirection : Int {
    case Right = 1 << 0
    case Left = 1 << 1
    case Up = 1 << 2
    case Down = 1 << 3
}

class UISwipeGestureRecognizer: UIGestureRecognizer {
    var direction: UISwipeGestureRecognizerDirection
    var numberOfTouchesRequired: Int

    convenience override init(target: AnyObject, action: Selector) {
        if (self.init(target: target, action: action)) {
            self.direction = .Right
            self.numberOfTouchesRequired = 1
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if self.state == .Possible {
            if (event is UITouchEvent) {
                var touchEvent: UITouchEvent = event as! UITouchEvent
                if touchEvent.touchEventGesture == .Swipe {
                    if direction == .Left && touchEvent.translation.x > 0 {
                        self.state = .Recognized
                    }
                    else if direction == .Right && touchEvent.translation.x < 0 {
                        self.state = .Recognized
                    }
                    else if direction == .Up && touchEvent.translation.y > 0 {
                        self.state = .Recognized
                    }
                    else if direction == .Down && touchEvent.translation.y < 0 {
                        self.state = .Recognized
                    }
                    else {
                        self.state = .Failed
                    }
                }
                else {
                    self.state = .Failed
                }
            }
        }
    }
}