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

class UITapGestureRecognizer: UIGestureRecognizer {
    var numberOfTapsRequired: Int
    var numberOfTouchesRequired: Int

    override init(target: AnyObject, action: Selector) {
        if (super.init(target: target, action: action)) {
            self.numberOfTapsRequired = 1
            self.numberOfTouchesRequired = 1
        }
    }

    func canBePreventedByGestureRecognizer(preventingGestureRecognizer: UIGestureRecognizer) -> Bool {
        // this logic is here based on a note in the docs for -canBePreventedByGestureRecognizer:
        // it may not be correct :)
        if (preventingGestureRecognizer is UITapGestureRecognizer) {
            return ((preventingGestureRecognizer as! UITapGestureRecognizer).numberOfTapsRequired > self.numberOfTapsRequired)
        }
        else {
            return super.canBePreventedByGestureRecognizer(preventingGestureRecognizer)
        }
    }

    func canPreventGestureRecognizer(preventedGestureRecognizer: UIGestureRecognizer) -> Bool {
        // this logic is here based on a note in the docs for -canPreventGestureRecognizer:
        // it may not be correct :)
        if (preventedGestureRecognizer is UITapGestureRecognizer) {
            return ((preventedGestureRecognizer as! UITapGestureRecognizer).numberOfTapsRequired <= self.numberOfTapsRequired)
        }
        else {
            return super.canPreventGestureRecognizer(preventedGestureRecognizer)
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var touch: UITouch = touches.first!
        if touch.tapCount >= self.numberOfTapsRequired {
            if self.state == .Possible {
                self.state = .Began
            }
            else if self.state == .Began {
                self.state = .Changed
            }
        }
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if self.state == .Began || self.state == .Changed {
            self.state = .Cancelled
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if self.state == .Began || self.state == .Changed {
            self.state = .Ended
        }
    }

    func touchesCancelled(touches: Set<AnyObject>, withEvent event: UIEvent) {
        if self.state == .Began || self.state == .Changed {
            self.state = .Cancelled
        }
    }
}