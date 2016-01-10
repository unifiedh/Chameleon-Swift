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
class UINSClipView: NSClipView {
    convenience override init(frame: NSRect, parentView aView: UIScrollView) {
        if (self.init(frame: frame)) {
            self.parentView = aView
            self.drawsBackground = false
            self.copiesOnScroll = false
            self.wantsLayer = true
            self.autoresizingMask = NSViewNotSizable
        }
    }
    var self.parentView: UIScrollView


    func isFlipped() -> Bool {
        return true
    }

    func isOpaque() -> Bool {
        return false
    }

    func scrollWheel(event: NSEvent) {
        if parentView.scrollEnabled {
            var offset: NSPoint = self.bounds.origin
            offset.x -= event.deltaX()
            offset.y -= event.deltaY()
            parentView._quickFlashScrollIndicators()
            parentView.setContentOffset(NSPointToCGPoint(offset), animated: false)
        }
        else {
            super.scrollWheel(event)
        }
    }

    func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        parentView.setNeedsLayout()
    }

    func viewWillDraw() {
        parentView.setNeedsLayout()
        super.viewWillDraw()
    }

    func setFrame(frame: NSRect) {
        super.frame = frame
        parentView.setNeedsLayout()
    }
    // this is used to fake out AppKit when the UIView that "owns" this NSView's layer is actually *behind* another UIView. Since the NSViews are
    // technically above all of the UIViews, they'd normally capture all clicks no matter what might happen to be obscuring them. That would obviously
    // be less than ideal. This makes it ideal. It is awesome.

    func hitTest(aPoint: NSPoint) -> NSView {
        var hitNSView: NSView = super.hitTest(aPoint)
        if hitNSView != nil {
            var screen: UIScreen = parentView.window.screen
            var didHitUIView: Bool = false
            if screen != nil {
                didHitUIView = (parentView == screen.UIKitView.hitTestUIView(aPoint))
            }
            if !didHitUIView {
                hitNSView = nil
            }
        }
        return hitNSView
    }
}

import AppKit