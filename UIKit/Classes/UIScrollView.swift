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

import QuartzCore

enum UIScrollViewIndicatorStyle : Int {
    case Default
    case Black
    case White
}

let UIScrollViewDecelerationRateNormal: CGFloat = 0.998

let UIScrollViewDecelerationRateFast: CGFloat = 0.99

@objc public protocol UIScrollViewDelegate: NSObjectProtocol {
    optional func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView)

    optional func scrollViewDidScroll(scrollView: UIScrollView)

    optional func scrollViewWillBeginDragging(scrollView: UIScrollView)

    optional func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool)

    optional func scrollViewWillBeginDecelerating(scrollView: UIScrollView)

    optional func scrollViewDidEndDecelerating(scrollView: UIScrollView)

    optional func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView

    optional func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView)

    optional func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView, atScale scale: CGFloat)

    optional func scrollViewDidZoom(scrollView: UIScrollView)

    optional func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool
}

public class UIScrollView: UIView {
	var verticalScroller: UIScroller
	var horizontalScroller: UIScroller
	var scrollAnimation: UIScrollViewAnimation?
	var scrollTimer: NSTimer?

    public func scrollRectToVisible(rect: CGRect, animated: Bool) {
        let contentRect: CGRect = CGRectMake(0, 0, contentSize.width, contentSize.height)
        let visibleRect: CGRect = self.bounds
        var goalRect: CGRect = CGRectIntersection(rect, contentRect)
        if !CGRectIsNull(goalRect) && !CGRectContainsRect(visibleRect, goalRect) {
            // clamp the goal rect to the largest possible size for it given the visible space available
            // this causes it to prefer the top-left of the rect if the rect is too big
            goalRect.size.width = min(goalRect.size.width, visibleRect.size.width)
            goalRect.size.height = min(goalRect.size.height, visibleRect.size.height)
            var offset: CGPoint = self.contentOffset
            if CGRectGetMaxY(goalRect) > CGRectGetMaxY(visibleRect) {
                offset.y += CGRectGetMaxY(goalRect) - CGRectGetMaxY(visibleRect)
            }
            else if CGRectGetMinY(goalRect) < CGRectGetMinY(visibleRect) {
                offset.y += CGRectGetMinY(goalRect) - CGRectGetMinY(visibleRect)
            }

            if CGRectGetMaxX(goalRect) > CGRectGetMaxX(visibleRect) {
                offset.x += CGRectGetMaxX(goalRect) - CGRectGetMaxX(visibleRect)
            }
            else if CGRectGetMinX(goalRect) < CGRectGetMinX(visibleRect) {
                offset.x += CGRectGetMinX(goalRect) - CGRectGetMinX(visibleRect)
            }

            self.setContentOffset(offset, animated: animated)
        }
    }

    public func setZoomScale(var scale: CGFloat, animated: Bool) {
        let zoomingView = self._zoomingView()
        scale = min(max(scale, minimumZoomScale), maximumZoomScale)
        if let zoomingView = zoomingView where self.zoomScale != scale {
            UIView.animateWithDuration(animated ? UIScrollViewAnimationDuration : 0, delay: 0, options: [.CurveEaseOut, .BeginFromCurrentState], animations: {() -> Void in
                zoomingView.transform = CGAffineTransformMakeScale(scale, scale)
                let size: CGSize = zoomingView.frame.size
                zoomingView.layer.position = CGPointMake(size.width / 2.0, size.height / 2.0)
                self.contentSize = size
            }, completion: { _ in })
        }
    }

    public func zoomToRect(rect: CGRect, animated: Bool) {
    }

    public func setContentOffset(theOffset: CGPoint, animated: Bool) {
        if animated {
            var animation: UIScrollViewAnimationScroll? = nil
			animation = scrollAnimation as? UIScrollViewAnimationScroll
            if animation == nil || !CGPointEqualToPoint(theOffset, animation!.endContentOffset) {
                self._setScrollAnimation(UIScrollViewAnimationScroll(scrollView: self, fromContentOffset: self.contentOffset, toContentOffset: theOffset, duration: UIScrollViewAnimationDuration, curve: .Linear))
            }
        } else {
            self._contentOffset.x = round(theOffset.x)
            self._contentOffset.y = round(theOffset.y)
            self._updateBounds()
			delegate?.scrollViewDidScroll?(self)
        }
    }

    func flashScrollIndicators() {
        horizontalScroller.flash()
        verticalScroller.flash()
    }
    // does nothing
    var contentSize: CGSize {
        didSet(oldSize) {
            if !CGSizeEqualToSize(oldSize, contentSize) {
                self._confineContent()
            }
        }
    }

	private var _contentOffset: CGPoint = .zero
	
    var contentOffset: CGPoint {
        get {
            return _contentOffset
        }
		set {
			setContentOffset(newValue, animated: false)
		}
    }

	private var _contentInset: UIEdgeInsets
    var contentInset: UIEdgeInsets {
        get {
            return _contentInset
        }
        set(contentInset) {
            if !UIEdgeInsetsEqualToEdgeInsets(self.contentInset, contentInset) {
                let x: CGFloat = contentInset.left - contentInset.left
                let y: CGFloat = contentInset.top - contentInset.top
                _contentInset = contentInset
                self._contentOffset.x -= x
                self.contentOffset.y -= y
                self._updateBounds()
            }
        }
    }

    var scrollIndicatorInsets: UIEdgeInsets
    var indicatorStyle: UIScrollViewIndicatorStyle {
        didSet {
            self.horizontalScroller.indicatorStyle = indicatorStyle
            self.verticalScroller.indicatorStyle = indicatorStyle
        }
    }

    var showsHorizontalScrollIndicator: Bool {
        didSet {
            self.setNeedsLayout()
        }
    }

    var showsVerticalScrollIndicator: Bool {
		didSet {
			setNeedsLayout()
		}
    }

    var bounces: Bool
    var alwaysBounceVertical: Bool
    var alwaysBounceHorizontal: Bool
    var scrollEnabled: Bool {
        get {
            return self.panGestureRecognizer.enabled || self.scrollWheelGestureRecognizer.enabled
        }
        set(enabled) {
            self.panGestureRecognizer.enabled = enabled
            self.scrollWheelGestureRecognizer.enabled = enabled
            self._updateScrollers()
            self.setNeedsLayout()
        }
    }

    weak var delegate: UIScrollViewDelegate?

	/// no effect
    var scrollsToTop: Bool
    /// no effect
    var delaysContentTouches: Bool
	/// no effect
    var canCancelContentTouches: Bool
	/// no effect
    var directionalLockEnabled: Bool
	
	private(set) var dragging: Bool

	/// always returns `NO`
    var tracking: Bool {
        get {
            return false
        }
    }

    private(set) var decelerating: Bool

    var pagingEnabled: Bool
    var decelerationRate: CGFloat
    var maximumZoomScale: CGFloat
    var minimumZoomScale: CGFloat
    var zoomScale: CGFloat {
        get {
            //var zoomingView = self._zoomingView()
            // it seems weird to return the "a" component of the transform for this, but after some messing around with the real UIKit, I'm
            // reasonably certain that's how it is doing it.
			if let zoomingView = self._zoomingView() {
				return zoomingView.transform.a
			} else {
				return 1
			}
        }
        set(scalea) {
			setZoomScale(scalea, animated: false)
		}
    }

    private(set) var zooming: Bool

	/// always NO
	var zoomBouncing: Bool {
        get {
            return false
        }
    }
	
	/// no effect
    var bouncesZoom: Bool
	
    private(set) var panGestureRecognizer: UIPanGestureRecognizer

    private(set) var scrollWheelGestureRecognizer: UIScrollWheelGestureRecognizer

	override init(frame: CGRect) {
            self.contentOffset = CGPointZero
            self.contentSize = CGSizeZero
            self.contentInset = UIEdgeInsetsZero
            self.scrollIndicatorInsets = UIEdgeInsetsZero
            self.showsVerticalScrollIndicator = true
            self.showsHorizontalScrollIndicator = true
            self.maximumZoomScale = 1
            self.minimumZoomScale = 1
            self.scrollsToTop = true
            self.indicatorStyle = .Default
            self.delaysContentTouches = true
            self.canCancelContentTouches = true
            self.pagingEnabled = false
            self.bouncesZoom = false
            self.zooming = false
            self.alwaysBounceVertical = false
            self.alwaysBounceHorizontal = false
            self.bounces = true
            self.decelerationRate = UIScrollViewDecelerationRateNormal
            self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "_gestureDidChange:")
            self.addGestureRecognizer(panGestureRecognizer)
            self.scrollWheelGestureRecognizer = UIScrollWheelGestureRecognizer(target: self, action: "_gestureDidChange:")
            self.addGestureRecognizer(scrollWheelGestureRecognizer)
            self.verticalScroller = UIScroller()
            self.verticalScroller.delegate = self
            self.addSubview(verticalScroller)
            self.horizontalScroller = UIScroller()
            self.horizontalScroller.delegate = self
            self.addSubview(horizontalScroller)
            self.clipsToBounds = true
		super.init(frame: frame)
    }

    deinit {
        self.horizontalScroller.delegate = nil
        self.verticalScroller.delegate = nil
    }

    func _zoomingView() -> UIView? {
        return delegate?.viewForZoomingInScrollView?(self)
    }

    func _canScrollHorizontal() -> Bool {
        return self.scrollEnabled && (contentSize.width > self.bounds.size.width)
    }

    func _canScrollVertical() -> Bool {
        return self.scrollEnabled && (contentSize.height > self.bounds.size.height)
    }

    func _updateScrollers() {
        self.verticalScroller.contentSize = contentSize.height
        self.verticalScroller.contentOffset = contentOffset.y
        self.horizontalScroller.contentSize = contentSize.width
        self.horizontalScroller.contentOffset = contentOffset.x
        self.verticalScroller.hidden = !self._canScrollVertical()
        self.horizontalScroller.hidden = !self._canScrollHorizontal()
    }

    func _cancelScrollAnimation() {
        scrollTimer?.invalidate()
        self.scrollTimer = nil
        self.scrollAnimation = nil
            delegate?.scrollViewDidEndScrollingAnimation?(self)
        if decelerating {
            self.horizontalScroller.alwaysVisible = false
            self.verticalScroller.alwaysVisible = false
            self.decelerating = false
                delegate?.scrollViewDidEndDecelerating?(self)
        }
    }

    @objc func _updateScrollAnimation() {
        if scrollAnimation?.animate() ?? false {
            self._cancelScrollAnimation()
        }
    }

    func _setScrollAnimation(animation: UIScrollViewAnimation?) {
        self._cancelScrollAnimation()
        self.scrollAnimation = animation
        if scrollTimer == nil {
            self.scrollTimer = NSTimer.scheduledTimerWithTimeInterval(1 / NSTimeInterval(UIScrollViewScrollAnimationFramesPerSecond), target: self, selector: "_updateScrollAnimation", userInfo: nil, repeats: true)
        }
    }

    func _confinedContentOffset(var contentOffset: CGPoint) -> CGPoint {
        let scrollerBounds: CGRect = UIEdgeInsetsInsetRect(self.bounds, contentInset)
        if (contentSize.width - contentOffset.x) < scrollerBounds.size.width {
            contentOffset.x = (contentSize.width - scrollerBounds.size.width)
        }
        if (contentSize.height - contentOffset.y) < scrollerBounds.size.height {
            contentOffset.y = (contentSize.height - scrollerBounds.size.height)
        }
        contentOffset.x = max(contentOffset.x, 0)
        contentOffset.y = max(contentOffset.y, 0)
        if contentSize.width <= scrollerBounds.size.width {
            contentOffset.x = 0
        }
        if contentSize.height <= scrollerBounds.size.height {
            contentOffset.y = 0
        }
        return contentOffset
    }

    func _setRestrainedContentOffset(var offset: CGPoint) {
        let confinedOffset: CGPoint = self._confinedContentOffset(offset)
        let scrollerBounds: CGRect = UIEdgeInsetsInsetRect(self.bounds, contentInset)
        if !self.alwaysBounceHorizontal && contentSize.width <= scrollerBounds.size.width {
            offset.x = confinedOffset.x
        }
        if !self.alwaysBounceVertical && contentSize.height <= scrollerBounds.size.height {
            offset.y = confinedOffset.y
        }
        self.contentOffset = offset
    }

    func _confineContent() {
        self.contentOffset = self._confinedContentOffset(contentOffset)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds: CGRect = self.bounds
        let scrollerSize: CGFloat = UIScrollerWidthForBoundsSize(bounds.size)
        self.verticalScroller.frame = CGRectMake(bounds.origin.x + bounds.size.width - scrollerSize - scrollIndicatorInsets.right, bounds.origin.y + scrollIndicatorInsets.top, scrollerSize, bounds.size.height - scrollIndicatorInsets.top - scrollIndicatorInsets.bottom)
        self.horizontalScroller.frame = CGRectMake(bounds.origin.x + scrollIndicatorInsets.left, bounds.origin.y + bounds.size.height - scrollerSize - scrollIndicatorInsets.bottom, bounds.size.width - scrollIndicatorInsets.left - scrollIndicatorInsets.right, scrollerSize)
    }

	override public var frame: CGRect {
		didSet {
			self._confineContent()
		}
	}

    func _bringScrollersToFront() {
        super.bringSubviewToFront(horizontalScroller)
        super.bringSubviewToFront(verticalScroller)
    }

    override public func addSubview(subview: UIView?) {
        super.addSubview(subview)
        self._bringScrollersToFront()
    }

    public override func bringSubviewToFront(subview: UIView) {
        super.bringSubviewToFront(subview)
        self._bringScrollersToFront()
    }

    override func insertSubview(subview: UIView, atIndex index: Int) {
        super.insertSubview(subview, atIndex: index)
        self._bringScrollersToFront()
    }

    func _updateBounds() {
        var bounds: CGRect = self.bounds
        bounds.origin.x = contentOffset.x - contentInset.left
        bounds.origin.y = contentOffset.y - contentInset.top
        self.bounds = bounds
        self._updateScrollers()
        self.setNeedsLayout()
    }

    //func setContentOffset(theOffset: CGPoint) {
    //    self.setContentOffset(theOffset, animated: false)
    //}

    func _quickFlashScrollIndicators() {
        horizontalScroller.quickFlash()
        verticalScroller.quickFlash()
    }

    func _pageSnapAnimation() -> UIScrollViewAnimation? {
        let pageSize: CGSize = self.bounds.size
        let numberOfWholePages: CGSize = CGSizeMake(floor(contentSize.width / pageSize.width), floor(contentSize.height / pageSize.height))
        let currentRawPage: CGSize = CGSizeMake(contentOffset.x / pageSize.width, contentOffset.y / pageSize.height)
        let currentPage: CGSize = CGSizeMake(floor(currentRawPage.width), floor(currentRawPage.height))
        let currentPagePercentage: CGSize = CGSizeMake(1 - (currentRawPage.width - currentPage.width), 1 - (currentRawPage.height - currentPage.height))
        var finalContentOffset: CGPoint = CGPointZero
        // if currentPagePercentage is less than 50%, then go to the next page (if any), otherwise snap to the current page
        if currentPagePercentage.width < 0.5 && (currentPage.width + 1) < numberOfWholePages.width {
            finalContentOffset.x = pageSize.width * (currentPage.width + 1)
        }
        else {
            finalContentOffset.x = pageSize.width * currentPage.width
        }
        if currentPagePercentage.height < 0.5 && (currentPage.height + 1) < numberOfWholePages.height {
            finalContentOffset.y = pageSize.height * (currentPage.height + 1)
        }
        else {
            finalContentOffset.y = pageSize.height * currentPage.height
        }
        // quickly animate the snap (if necessary)
        if !CGPointEqualToPoint(finalContentOffset, contentOffset) {
            return UIScrollViewAnimationScroll(scrollView: self, fromContentOffset: contentOffset, toContentOffset: finalContentOffset, duration: UIScrollViewQuickAnimationDuration, curve: .QuadraticEaseOut)
        }
        else {
            return nil
        }
    }

    func _decelerationAnimationWithVelocity(var velocity: CGPoint) -> UIScrollViewAnimation? {
        let confinedOffset: CGPoint = self._confinedContentOffset(contentOffset)
        // if we've pulled up the content outside it's bounds, we don't want to register any flick momentum there and instead just
        // have the animation pull the content back into place immediately.
        if confinedOffset.x != contentOffset.x {
            velocity.x = 0
        }
        if confinedOffset.y != contentOffset.y {
            velocity.y = 0
        }
        if !CGPointEqualToPoint(velocity, CGPointZero) || !CGPointEqualToPoint(confinedOffset, contentOffset) {
            return UIScrollViewAnimationDeceleration(scrollView: self, velocity: velocity)
        } else {
            return nil
        }
    }

    func _beginDragging() {
        if !dragging {
            self.dragging = true
            self.horizontalScroller.alwaysVisible = true
            self.verticalScroller.alwaysVisible = true
            self._cancelScrollAnimation()
			delegate?.scrollViewWillBeginDragging?(self)
        }
    }

    func _endDraggingWithDecelerationVelocity(velocity: CGPoint) {
        if dragging {
            self.dragging = false
            let decelerationAnimation = pagingEnabled ? self._pageSnapAnimation() : self._decelerationAnimationWithVelocity(velocity)
			delegate?.scrollViewDidEndDragging?(self, willDecelerate: (decelerationAnimation != nil))
            if let decelerationAnimation = decelerationAnimation {
                self._setScrollAnimation(decelerationAnimation)
                self.horizontalScroller.alwaysVisible = true
                self.verticalScroller.alwaysVisible = true
                self.decelerating = true
				delegate?.scrollViewWillBeginDecelerating?(self)
            }
            else {
                self.horizontalScroller.alwaysVisible = false
                self.verticalScroller.alwaysVisible = false
                self._confineContent()
            }
        }
    }

    func _dragBy(delta: CGPoint) {
        if dragging {
            self.horizontalScroller.alwaysVisible = true
            self.verticalScroller.alwaysVisible = true
            let originalOffset: CGPoint = self.contentOffset
            var proposedOffset: CGPoint = originalOffset
            proposedOffset.x += delta.x
            proposedOffset.y += delta.y
            let confinedOffset: CGPoint = self._confinedContentOffset(proposedOffset)
            if self.bounces {
                var shouldHorizontalBounce: Bool = (fabs(proposedOffset.x - confinedOffset.x) > 0)
                var shouldVerticalBounce: Bool = (fabs(proposedOffset.y - confinedOffset.y) > 0)
                if shouldHorizontalBounce {
                    proposedOffset.x = originalOffset.x + (0.055 * delta.x)
                }
                if shouldVerticalBounce {
                    proposedOffset.y = originalOffset.y + (0.055 * delta.y)
                }
                self._setRestrainedContentOffset(proposedOffset)
            }
            else {
                self.contentOffset = confinedOffset
            }
        }
    }

    func _gestureDidChange(gesture: UIGestureRecognizer) {
        // the scrolling gestures are broken into two components due to the somewhat fundamental differences
        // in how they are handled by the system. The UIPanGestureRecognizer will only track scrolling gestures
        // that come from actual touch scroller devices. This does *not* include old fashioned mouse wheels.
        // the non-standard UIScrollWheelGestureRecognizer is a discrete recognizer which only responds to
        // non-gesture scroll events such as those from non-touch devices. HOWEVER the system sends momentum
        // scroll events *after* the touch gesture has ended which allows for us to distinguish the difference
        // here between actual touch gestures and the momentum gestures and thus feed them into the playing
        // deceleration animation as we receive them so that we can preserve the system's proper feel for that.
        // Also important to note is that with a legacy scroll device, each movement of the wheel is going to
        // trigger a beginDrag, dragged, endDragged sequence. I believe that's an acceptable compromise however
        // it might cause some potentially strange behavior in client code that is not expecting such rapid
        // state changes along these lines.
        // Another note is that only touch-based panning gestures will trigger calls to _dragBy: which means
        // that only touch devices can possibly pull the content outside of the scroll view's bounds while
        // active. An old fashioned wheel will not be able to do that and its scroll events are confined to
        // the bounds of the scroll view.
        // There are some semi-legacy devices like the magic mouse which 10.6 doesn't seem to consider a true
        // touch device, so it doesn't send the gestureBegin/ended stuff that's used to recognize such things
        // but it *will* send momentum events. This means that those devices on 10.6 won't give you the feeling
        // of being able to grab and pull your content away from the bounds like a proper touch trackpad will.
        // As of 10.7 it appears Apple fixed this and they do actually send the proper gesture events, so on
        // 10.7 the magic mouse should end up acting like any other touch input device as far as we're concerned.
        // Momentum scrolling doesn't work terribly well with how the paging stuff is now handled. Something
        // could be improved there. I'm not sure if the paging animation should just pretend it's longer to
        // kind of "mask" the OS' momentum events, or if a flag should be set, or if it should work so that
        // even in paging mode the deceleration and stuff happens like usual and it only snaps to the correct
        // page *after* the usual deceleration is done. I can't decide what might be best, but since we
        // don't use paging mode in Twitterrific at the moment, I'm not suffeciently motivated to worry about it. :)
        if gesture == panGestureRecognizer {
            if panGestureRecognizer.state == .Began {
                self._beginDragging()
            }
            else if panGestureRecognizer.state == .Changed {
                self._dragBy(panGestureRecognizer.translationInView(self))
                panGestureRecognizer.setTranslation(CGPointZero, inView: self)
            }
            else if panGestureRecognizer.state == .Ended {
                self._endDraggingWithDecelerationVelocity(panGestureRecognizer.velocityInView(self))
            }
        }
        else if gesture == scrollWheelGestureRecognizer {
            if scrollWheelGestureRecognizer.state == .Recognized {
                let delta: CGPoint = scrollWheelGestureRecognizer.translationInView(self)
                if decelerating {
                    // note that we might be "decelerating" but actually just snapping to a page boundary in paging mode,
                    // so we need to verify if we can actually send this message to the current animation or not.
                    // if we can't, then we'll just eat the scroll event and let the animation finish instead.
                    // additional note: the reason this is done this way at all is so that the system's momentum
                    // messages can be preserved perfectly rather than trying to emulate them myself. this results
                    // in a better feeling end product even if the bouncing at the edges isn't quite entirely right.
                    // see notes in UIScrollViewAnimationDeceleration.m for more.
                    // updated note: this used to be guarded by respondsToSelector: but I have instead added a blank
                    // implementation of -momentumScrollBy: to UIScrollAnimation's base class. If a specific animation
                    // cannot deal with a momentum scroll, then it will be ignored.
                    scrollAnimation?.momentumScrollBy(delta)
                }
                else {
                    var offset: CGPoint = self.contentOffset
                    offset.x += delta.x
                    offset.y += delta.y
                    offset = self._confinedContentOffset(offset)
                    if !CGPointEqualToPoint(offset, contentOffset) {
                        self._beginDragging()
                        self.contentOffset = offset
                        self._endDraggingWithDecelerationVelocity(CGPointZero)
                    }
                    self._quickFlashScrollIndicators()
                }
            }
        }

    }

	public override var description: String {
		return String(format:"<%@: %p; frame = (%.0f %.0f; %.0f %.0f); clipsToBounds = %@; layer = %@; contentOffset = {%.0f, %.0f}>", self.className, unsafeAddressOf(self), frame.origin.x, frame.origin.y, frame.size.width, frame.size.height, (clipsToBounds ? "YES" : "NO"), self.layer, contentOffset.x, contentOffset.y)
    }
    // after some experimentation, it seems UIScrollView blocks or captures the touch events that fall through and
    // I'm not entirely sure why, but something is certainly going on there so I'm replicating that here. since I
    // suspect it's just stopping everything from going through, I'm also capturing and ignoring some of the
    // mouse-related responder events added by Chameleon rather than passing them along the responder chain, too.

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    }

    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent) {
    }

    override func scrollWheelMoved(delta: CGPoint, withEvent event: UIEvent) {
    }

    override func rightClick(touch: UITouch, withEvent event: UIEvent) {
    }

    override func mouseMoved(touch: UITouch, withEvent event: UIEvent) {
        let point: CGPoint = touch.locationInView(self)
        let scrollerSize: CGFloat = UIScrollerWidthForBoundsSize(self.bounds.size)
        let shouldShowHorizontal: Bool = CGRectContainsPoint(CGRectInset(horizontalScroller.frame, -scrollerSize, -scrollerSize), point)
        let shouldShowVertical: Bool = CGRectContainsPoint(CGRectInset(verticalScroller.frame, -scrollerSize, -scrollerSize), point)
        let shouldShowScrollers: Bool = (shouldShowVertical || shouldShowHorizontal || decelerating)
        self.horizontalScroller.alwaysVisible = shouldShowScrollers
        self.verticalScroller.alwaysVisible = shouldShowScrollers
    }

    override func mouseExited(view: UIView, withEvent event: UIEvent) {
        if !decelerating {
            self.horizontalScroller.alwaysVisible = false
            self.verticalScroller.alwaysVisible = false
        }
    }

    convenience init?(event: UIEvent) {
        return nil
    }
}

extension UIScrollView: _UIScrollerDelegate {
	func _UIScrollerDidBeginDragging(scroller: UIScroller, withEvent event: UIEvent!) {
		self._beginDragging()
	}
	
	func _UIScroller(scroller: UIScroller, contentOffsetDidChange newOffset: CGFloat) {
		if scroller == verticalScroller {
			self.setContentOffset(CGPointMake(self.contentOffset.x, newOffset), animated: false)
		}
		else if scroller == horizontalScroller {
			self.setContentOffset(CGPointMake(newOffset, self.contentOffset.y), animated: false)
		}
		
	}
	
	func _UIScrollerDidEndDragging(scroller: UIScroller, withEvent event: UIEvent!) {
		var touch: UITouch = event.allTouches()!.first!
		let point: CGPoint = touch.locationInView(self)
		if !CGRectContainsPoint(scroller.frame, point) {
			scroller.alwaysVisible = false
		}
		self._endDraggingWithDecelerationVelocity(CGPointZero)
	}
}

    let UIScrollViewAnimationDuration: NSTimeInterval = 0.33

    let UIScrollViewQuickAnimationDuration: NSTimeInterval = 0.22

    let UIScrollViewScrollAnimationFramesPerSecond: Int = 60

