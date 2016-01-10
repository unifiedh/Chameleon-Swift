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

    var UIScrollerWidthForBoundsSize: CGFloat

protocol _UIScrollerDelegate {
    func _UIScrollerDidBeginDragging(scroller: UIScroller, withEvent event: UIEvent)

    func _UIScroller(scroller: UIScroller, contentOffsetDidChange newOffset: CGFloat)

    func _UIScrollerDidEndDragging(scroller: UIScroller, withEvent event: UIEvent)
}
class UIScroller: UIView {
    // NOTE: UIScroller set's its own alpha to 0 when it is created, so it is NOT visible by default!
    // the flash/quickFlash methods alter its own alpha in order to fade in/out, etc.
    func flash() {
        self._fadeIn()
        if !alwaysVisible {
            self._fadeOutAfterDelay(1.5)
        }
    }

    func quickFlash() {
        self.alpha = 1
        if !alwaysVisible {
            self._fadeOutAfterDelay(0.5)
        }
    }
    var alwaysVisible: Bool {
        get {
            return self.alwaysVisible
        }
        set {
            self.alwaysVisible = v
            if alwaysVisible {
                self._fadeIn()
            }
            else if self.alpha > UIScrollerMinimumAlpha && !fadeTimer {
                self._fadeOut()
            }
    
        }
    }

    // if YES, -flash has no effect on the scroller's alpha, setting YES fades alpha to 1, setting NO fades it out if it was visible
    weak var delegate: _UIScrollerDelegate
    var contentSize: CGFloat {
        get {
            return self.contentSize
        }
        set {
            self.contentSize = newContentSize
            self.setNeedsDisplay()
        }
    }

    // used to calulate how big the slider knob should be (uses its own frame height/width and compares against this value)
    var contentOffset: CGFloat {
        get {
            return self.contentOffset
        }
        set {
            self.contentOffset = min(max(0, newOffset), contentSize)
            self.setNeedsDisplay()
        }
    }

    // set this after contentSize is set or else it'll normalize in unexpected ways
    var indicatorStyle: UIScrollViewIndicatorStyle {
        get {
            return self.indicatorStyle
        }
        set {
            self.indicatorStyle = style
            self.setNeedsDisplay()
        }
    }
    var self.dragOffset: CGFloat
    var self.draggingKnob: Bool
    var self.isVertical: Bool
    var self.lastTouchLocation: CGPoint
    var self.holdTimer: NSTimer
    var self.fadeTimer: NSTimer


    convenience override init(frame: CGRect) {
        if (self.init(frame: frame)) {
            self.opaque = false
            self.alpha = UIScrollerMinimumAlpha
            self.indicatorStyle = .Default
        }
    }

    func setFrame(frame: CGRect) {
        self.isVertical = (frame.size.height > frame.size.width)
        super.frame = frame
    }

    func _fadeOut() {
        fadeTimer.invalidate()
        self.fadeTimer = nil
        UIView.animateWithDuration(0.33, delay: 0, options: [.CurveEaseOut, .TransitionNone, .AllowUserInteraction, .BeginFromCurrentState], animations: {() -> Void in
            self.alpha = UIScrollerMinimumAlpha
        }, completion: { _ in })
    }

    func _fadeOutAfterDelay(time: NSTimeInterval) {
        fadeTimer.invalidate()
        self.fadeTimer = NSTimer.scheduledTimerWithTimeInterval(time, target: self, selector: "_fadeOut", userInfo: nil, repeats: false)
    }

    func _fadeIn() {
        fadeTimer.invalidate()
        self.fadeTimer = nil
        UIView.animateWithDuration(0.33, delay: 0, options: [.CurveEaseOut, .TransitionNone, .AllowUserInteraction, .BeginFromCurrentState], animations: {() -> Void in
            self.alpha = 1
        }, completion: { _ in })
    }

    func knobSize() -> CGFloat {
        let bounds: CGRect = self.bounds
        let dimension: CGFloat = max(bounds.size.width, bounds.size.height)
        let knobScale: CGFloat = min(1, (dimension / contentSize))
        return max((dimension * knobScale), 50)
    }

    func knobRect() -> CGRect {
        let bounds: CGRect = self.bounds
        let dimension: CGFloat = max(bounds.size.width, bounds.size.height)
        let maxContentSize: CGFloat = max(1, (contentSize - dimension))
        let knobSize: CGFloat = self.knobSize()
        let positionScale: CGFloat = min(1, (min(contentOffset, maxContentSize) / maxContentSize))
        let knobPosition: CGFloat = (dimension - knobSize) * positionScale
        if isVertical {
            return CGRectMake(bounds.origin.x, knobPosition, bounds.size.width, knobSize)
        }
        else {
            return CGRectMake(knobPosition, bounds.origin.y, knobSize, bounds.size.height)
        }
    }

    func setContentOffsetWithLastTouch() {
        let bounds: CGRect = self.bounds
        let dimension: CGFloat = isVertical ? bounds.size.height : bounds.size.width
        let maxContentOffset: CGFloat = contentSize - dimension
        let knobSize: CGFloat = self.knobSize()
        let point: CGFloat = isVertical ? lastTouchLocation.y : lastTouchLocation.x
        let knobPosition: CGFloat = min(max(0, point - dragOffset), (dimension - knobSize))
        let contentOffset: CGFloat = (knobPosition / (dimension - knobSize)) * maxContentOffset
        self.contentOffset = contentOffset
    }

    func pageUp() {
        if isVertical {
            self.contentOffset = contentOffset - self.bounds.size.height
        }
        else {
            self.contentOffset = contentOffset - self.bounds.size.width
        }
    }

    func pageDown() {
        if isVertical {
            self.contentOffset = contentOffset + self.bounds.size.height
        }
        else {
            self.contentOffset = contentOffset + self.bounds.size.width
        }
    }

    func autoPageContent() {
        let knobRect: CGRect = self.knobRect()
        if !CGRectContainsPoint(knobRect, lastTouchLocation) && CGRectContainsPoint(self.bounds, lastTouchLocation) {
            var shouldPageUp: Bool
            if isVertical {
                shouldPageUp = (lastTouchLocation.y < knobRect.origin.y)
            }
            else {
                shouldPageUp = (lastTouchLocation.x < knobRect.origin.x)
            }
            if shouldPageUp {
                self.pageUp()
            }
            else {
                self.pageDown()
            }
            delegate._UIScroller(self, contentOffsetDidChange: contentOffset)
        }
    }

    func startHoldPaging() {
        holdTimer.invalidate()
        self.holdTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "autoPageContent", userInfo: nil, repeats: true)
    }

    func drawRect(rect: CGRect) {
        var knobRect: CGRect = self.knobRect()
        if isVertical {
            knobRect.origin.y += 2
            knobRect.size.height -= 4
            knobRect.origin.x += 1
            knobRect.size.width -= 3
        }
        else {
            knobRect.origin.y += 1
            knobRect.size.height -= 3
            knobRect.origin.x += 2
            knobRect.size.width -= 4
        }
        var path: UIBezierPath = UIBezierPath(roundedRect: knobRect, cornerRadius: 4)
        if indicatorStyle == .Black {
            UIColor.blackColor()(alphaComponent: 0.5).setFill()
        }
        else if indicatorStyle == .White {
            UIColor.whiteColor()(alphaComponent: 0.5).setFill()
        }
        else {
            UIColor.blackColor()(alphaComponent: 0.5).setFill()
            UIColor.whiteColor()(alphaComponent: 0.3).setStroke()
            path.lineWidth = 1.8
            path.stroke()
        }

        path.fill()
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.lastTouchLocation = touches.first!.locationInView(self)
        let knobRect: CGRect = self.knobRect()
        if CGRectContainsPoint(knobRect, lastTouchLocation) {
            if isVertical {
                self.dragOffset = lastTouchLocation.y - knobRect.origin.y
            }
            else {
                self.dragOffset = lastTouchLocation.x - knobRect.origin.x
            }
            self.draggingKnob = true
            delegate._UIScrollerDidBeginDragging(self, withEvent: event)
        }
        else if UIScrollerGutterEnabled {
            delegate._UIScrollerDidBeginDragging(self, withEvent: event)
            if UIScrollerJumpToSpotThatIsClicked {
                self.dragOffset = self.knobSize() / 2.0
                self.draggingKnob = true
                self.setContentOffsetWithLastTouch()
                delegate._UIScroller(self, contentOffsetDidChange: contentOffset)
            }
            else {
                self.autoPageContent()
                self.holdTimer = NSTimer.scheduledTimerWithTimeInterval(0.33, target: self, selector: "startHoldPaging", userInfo: nil, repeats: false)
            }
        }

    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.lastTouchLocation = touches.first!.locationInView(self)
        if draggingKnob {
            self.setContentOffsetWithLastTouch()
            delegate._UIScroller(self, contentOffsetDidChange: contentOffset)
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if draggingKnob {
            self.draggingKnob = false
            delegate._UIScrollerDidEndDragging(self, withEvent: event)
        }
        else if holdTimer {
            delegate._UIScrollerDidEndDragging(self, withEvent: event)
            holdTimer.invalidate()
            self.holdTimer = nil
        }

    }

    func hitTest(point: CGPoint, withEvent event: UIEvent) -> UIView {
        var hit: UIView = super.hitTest(point, withEvent: event)
        // if the gutter is disabled, then we pretend the view is invisible to events if the user clicks in the gutter
        // otherwise the scroller would capture those clicks and things wouldn't work as expected.
        if hit == self && !UIScrollerGutterEnabled && !CGRectContainsPoint(self.knobRect(), point) {
            hit = nil
        }
        return hit
    }
}

    let self.UIScrollerGutterEnabled: Bool = false

    let self.UIScrollerJumpToSpotThatIsClicked: Bool = false

// _UIScrollerGutterEnabled must be YES for this to have any meaning
    let self.UIScrollerMinimumAlpha: CGFloat = 0

        let minViewSize: CGFloat = 50
        if boundsSize.width <= minViewSize || boundsSize.height <= minViewSize {
            return 6
        }
        else {
            return 10
        }