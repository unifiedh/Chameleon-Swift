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

class UIViewAdapter: UIScrollView {
    convenience override init(NSView aNSView: NSView) {
        let viewFrameSize: NSSize = aNSView ? aNSView.frame.size : NSZeroSize
        if (self = self(frame: CGRectMake(0, 0, viewFrameSize.width, viewFrameSize.height))) {
            self.NSView = aNSView
        }
    }
    var NSView: NSView {
        get {
            return self.NSView
        }
        set {
            if aNSView != view {
                self.resignFirstResponder()
                self._removeNSView()
                self.view = aNSView
                clipView.documentView = view
                self._updateNSViews()
            }
        }
    }
    var self.clipView: UINSClipView


    convenience override init(frame: CGRect) {
        if (self.init(frame: frame)) {
            self.clipView = UINSClipView(frame: NSMakeRect(0, 0, frame.size.width, frame.size.height), parentView: self)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "_hierarchyMayHaveChangedNotification:", name: UIViewHiddenDidChangeNotification, object: nil)
        }
    }

    func dealloc() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIViewHiddenDidChangeNotification, object: nil)
    }

    func _addNSView() {
        clipView.scrollToPoint(NSPointFromCGPoint(self.contentOffset))
        self.window.screen.UIKitView.addSubview(clipView)
        // all of these notifications are hacks to detect when views or superviews of this view move or change in ways that require
        // the actual NSView to get updated. it's not pretty, but I cannot come up with a better way at this point.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "_updateScrollViewAndFlashScrollbars", name: NSViewBoundsDidChangeNotification, object: clipView)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "_hierarchyMayHaveChangedNotification:", name: UIViewFrameDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "_hierarchyMayHaveChangedNotification:", name: UIViewBoundsDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "_hierarchyMayHaveChangedNotification:", name: UIViewDidMoveToSuperviewNotification, object: nil)
    }

    func _removeNSView() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSViewBoundsDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIViewFrameDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIViewBoundsDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIViewDidMoveToSuperviewNotification, object: nil)
        clipView.removeFromSuperview()
    }

    func _updateLayers() {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        var layer: CALayer = self.layer
        var clipLayer: CALayer = clipView.layer
        // always make sure it's at the very bottom
        layer.insertSublayer(clipLayer, atIndex: 0)
        // don't resize unless we have to
        if !CGRectEqualToRect(clipLayer.frame, layer.bounds) {
            clipLayer.frame = layer.bounds
        }
        CATransaction.commit()
    }

    func _updateScrollView() {
        let docRect: NSRect = clipView.documentRect()
        self.contentSize = CGSizeMake(docRect.size.width + docRect.origin.x, docRect.size.height + docRect.origin.y)
        self.contentOffset = NSPointToCGPoint(clipView.bounds.origin)
    }

    func _updateScrollViewAndFlashScrollbars() {
        self._updateScrollView()
        self._quickFlashScrollIndicators()
    }

    func _NSViewShouldBeVisible() -> Bool {
        if view && self.window {
            var v: UIView = self
            while v {
                if v.hidden {
                    return false
                }
                v = v.superview()
            }
            return true
        }
        else {
            return false
        }
    }

    func _updateNSViews() {
        if self._NSViewShouldBeVisible() {
            if clipView.superview() != self.window.screen.UIKitView {
                self._addNSView()
            }
            // translate the adapter's frame to the real NSWindow's coordinate space so that the NSView lines up correctly
            var window: UIWindow! = self.window
            let windowRect: CGRect = window.convertRect(self.frame, fromView: self.superview)
            let screenRect: CGRect = window.convertRect(windowRect, toWindow: nil)
            var desiredFrame: NSRect = NSRectFromCGRect(screenRect)
            clipView.frame = desiredFrame
            self._updateScrollView()
            self._updateLayers()
        }
        else {
            self._removeNSView()
        }
    }

    func _hierarchyMayHaveChangedNotification(note: NSNotification) {
        if self.isDescendantOfView(note.object) {
            self._updateNSViews()
        }
    }

    func layoutSubviews() {
        super.layoutSubviews()
        self._updateLayers()
    }

    func didMoveToWindow() {
        super.didMoveToWindow()
        self._updateNSViews()
    }

    func setContentOffset(theOffset: CGPoint, animated: Bool) {
        // rounding to avoid fuzzy images from subpixel alignment issues
        theOffset.x = roundf(theOffset.x)
        theOffset.y = roundf(theOffset.y)
        super.setContentOffset(theOffset, animated: animated)
        clipView.scrollToPoint(clipView.constrainScrollPoint(NSPointFromCGPoint(theOffset)))
    }

    func canBecomeFirstResponder() -> Bool {
        return self._NSViewShouldBeVisible() ? view.acceptsFirstResponder() : false
    }

    func becomeFirstResponder() -> Bool {
        self._updateNSViews()
        if super.becomeFirstResponder() {
            view.window().makeFirstResponder(view)
            return true
        }
        else {
            return false
        }
    }

    func resignFirstResponder() -> Bool {
        self._updateNSViews()
        let didResign: Bool = super.resignFirstResponder()
        if didResign && view.window().firstResponder() == view {
            view.window().makeFirstResponder(self.window.screen.UIKitView)
        }
        return didResign
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
import AppKit
import QuartzCore
import QuartzCore