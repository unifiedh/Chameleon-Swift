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
import AppKit
protocol UICustomNSClipViewBehaviorDelegate {
    // the point should be in the clip view's superview coordinate space - aka the "screen" coordinate space because if everything
    // is being done correctly, this view is never nested inside any other kind of NSView.
    func hitTestForClipViewPoint(point: NSPoint) -> Bool
    // return NO if scroll wheel events should be ignored, otherwise return YES

    func clipViewShouldScroll() -> Bool
}
class UICustomNSClipView: NSClipView {
    convenience override init(frame: NSRect) {
        if (self.init(frame: frame)) {
            self.drawsBackground = false
            self.wantsLayer = true
        }
    }
    // A layer parent is just a layer that UICustonNSClipView will attempt to always remain a sublayer of.
    // Circumventing AppKit for fun and profit!
    // The hitDelegate is for faking out the NSView's usual hitTest: checks to handle cases where UIViews are above
    // the UIView that's displaying this layer.
    weak var parentLayer: CALayer
    weak var behaviorDelegate: UICustomNSClipViewBehaviorDelegate

    func scrollWheel(event: NSEvent) {
        if self.behaviorDelegate.clipViewShouldScroll() {
            var offset: NSPoint = self.bounds.origin
            offset.x += event.deltaX()
            offset.y -= event.deltaY()
            offset.x = floor(offset.x)
            offset.y = floor(offset.y)
            self.scrollToPoint(self.constrainScrollPoint(offset))
        }
        else {
            self.nextResponder().scrollWheel(event)
        }
    }

    func fixupTheLayer() {
        if self.superview() && self.parentLayer {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0)
            var layer: CALayer = self.layer
            if self.parentLayer != layer.superlayer {
                self.parentLayer.addSublayer(layer)
            }
            if !CGRectEqualToRect(layer.frame, self.parentLayer.bounds) {
                layer.frame = self.parentLayer.bounds
            }
            CATransaction.commit()
        }
    }

    func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        self.fixupTheLayer()
    }

    func viewWillDraw() {
        super.viewWillDraw()
        self.fixupTheLayer()
    }

    func setFrame(frame: NSRect) {
        super.frame = frame
        self.fixupTheLayer()
    }

    func viewDidUnhide() {
        super.viewDidUnhide()
        self.fixupTheLayer()
    }

    func hitTest(aPoint: NSPoint) -> NSView {
        var hit: NSView = super.hitTest(aPoint)
        if hit && self.behaviorDelegate {
            // call out to the text layer via a delegate or something and ask if this point should be considered a hit or not.
            // if not, then we set hit to nil, otherwise we return it like normal.
            // the purpose of this is to make the NSView act invisible/hidden to clicks when it's visually behind other UIViews.
            // super tricky, eh?
            if !self.behaviorDelegate.hitTestForClipViewPoint(aPoint) {
                hit = nil
            }
        }
        return hit
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

import AppKit
import QuartzCore
import QuartzCore