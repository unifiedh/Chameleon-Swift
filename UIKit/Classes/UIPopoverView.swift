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
import QuartzCore


class UIPopoverView: UIView {
	init(contentView aView: UIView, size aSize: CGSize) {
            self.contentView = aView
            var backgroundImage: UIImage = UIImage._popoverBackgroundImage()
            self.backgroundView = UIImageView(image: backgroundImage)
            self.arrowView = UIImageView(frame: CGRectZero)
            self.contentContainerView = UIView()
            self.contentContainerView.layer.cornerRadius = 3
            self.contentContainerView.clipsToBounds = true
            self.addSubview(backgroundView)
            self.addSubview(arrowView)
            self.addSubview(contentContainerView)
            contentContainerView.addSubview(contentView)
            self.contentSize = aSize
		super.init(frame: CGRectMake(0, 0, 320, 480))

    }

    func pointTo(point: CGPoint, inView view: UIView) {
        // This math here is excessive. I went through a lot of effort because of an earlier idea I had about how to
        // get this stuff to point correctly. I'm reasonably sure that wasn't really necessary, but I'm going to leave it
        // here for now. It's neat stuff.. :) It takes an origin point within the popover view and then creates a line
        // between it and the destination point. It then finds where that line intersects with the sides of the popover
        // frame and uses that intersection point as the place to put the arrow image. There is also logic here to clamp
        // the position of the arrow images so that they don't extend beyond the popover's chrome. Cool, but excessive. :)
        let myBounds: CGRect = self.bounds
        // arrowPoint and myCenter should both be in self's coordinate space
        let arrowPoint: CGPoint = self.convertPoint(point, fromView: view)
        var myCenter: CGPoint = CGPointMake(CGRectGetMidX(myBounds), CGRectGetMidY(myBounds))
        // inset the bounds so that the bounding lines are at the center points of the arrow images
        let bounds: CGRect = CGRectInset(myBounds, 11, 11)
        // check to see if the arrowPoint has any components that fall on lines which intersect the popover view itself.
        // if it does, then adjust myCenter accordingly - this makes the algorithm prefer a straight line whenever possible
        // which should ultimately look better - note that this was added well after all this complex math and is the
        // single simple thing which helps render most of the complex math moot. Sometimes the easy thing to do is not
        // the obvious thing if you're in the wrong frame of mind at the time. :/
        if arrowPoint.x > CGRectGetMinX(bounds) && arrowPoint.x < CGRectGetMaxX(bounds) {
            myCenter.x = arrowPoint.x
        }
        if arrowPoint.y > CGRectGetMinY(bounds) && arrowPoint.y < CGRectGetMaxY(bounds) {
            myCenter.y = arrowPoint.y
        }
        let topRight: CGPoint = CGPointMake(bounds.origin.x + bounds.size.width, bounds.origin.y)
        let bottomLeft: CGPoint = CGPointMake(bounds.origin.x, bounds.origin.y + bounds.size.height)
        let bottomRight: CGPoint = CGPointMake(bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height)
        let arrowLine: LineSegment = LineSegmentMake(arrowPoint, myCenter)
        let rightSide: LineSegment = LineSegmentMake(topRight, bottomRight)
        let topSide: LineSegment = LineSegmentMake(bounds.origin, topRight)
        let bottomSide: LineSegment = LineSegmentMake(bottomLeft, bottomRight)
        let leftSide: LineSegment = LineSegmentMake(bounds.origin, bottomLeft)
        var intersection: CGPoint = CGPointZero
        var bestIntersection: CGPoint = CGPointZero
        var bestDistance: CGFloat = CGFloat.max
        var closestEdge: CGRectEdge = .MinXEdge
        if LineSegmentsIntersect(arrowLine, rightSide, &intersection) {
            let distance: CGFloat = DistanceBetweenTwoPoints(intersection, arrowPoint)
            if distance < bestDistance {
                bestDistance = distance
                closestEdge = .MaxXEdge
                bestIntersection = intersection
            }
        }
        if LineSegmentsIntersect(arrowLine, topSide, &intersection) {
            let distance: CGFloat = DistanceBetweenTwoPoints(intersection, arrowPoint)
            if distance < bestDistance {
                bestDistance = distance
                closestEdge = .MinYEdge
                bestIntersection = intersection
            }
        }
        if LineSegmentsIntersect(arrowLine, bottomSide, &intersection) {
            let distance: CGFloat = DistanceBetweenTwoPoints(intersection, arrowPoint)
            if distance < bestDistance {
                bestDistance = distance
                closestEdge = .MaxYEdge
                bestIntersection = intersection
            }
        }
        if LineSegmentsIntersect(arrowLine, leftSide, &intersection) {
            let distance: CGFloat = DistanceBetweenTwoPoints(intersection, arrowPoint)
            if distance < bestDistance {
                //bestDistance = distance;  -- commented out to avoid a harmless analyzer warning
                closestEdge = .MinXEdge
                bestIntersection = intersection
            }
        }
        var clampVertical: Bool = false
        if closestEdge == .MaxXEdge {
            // right side
            self.arrowView?.image = UIImage._rightPopoverArrowImage()
            clampVertical = true
        }
        else if closestEdge == .MaxYEdge {
            // bottom side
            self.arrowView?.image = UIImage._bottomPopoverArrowImage()
            clampVertical = false
        }
        else if closestEdge == .MinYEdge {
            // top side
            self.arrowView?.image = UIImage._topPopoverArrowImage()
            clampVertical = false
        }
        else {
            // left side
            self.arrowView?.image = UIImage._leftPopoverArrowImage()
            clampVertical = true
        }

        // this will clamp where the arrow is positioned so that it doesn't slide off the edges of
        // the popover and look dumb and disconnected.
        let innerBounds: CGRect = myBounds.insetBy(dx: 42, dy: 42)
        if clampVertical {
            if bestIntersection.y < innerBounds.origin.y {
                bestIntersection.y = innerBounds.origin.y
            }
            else if bestIntersection.y > innerBounds.origin.y + innerBounds.size.height {
                bestIntersection.y = innerBounds.origin.y + innerBounds.size.height
            }
        }
        else {
            if bestIntersection.x < innerBounds.origin.x {
                bestIntersection.x = innerBounds.origin.x
            }
            else if bestIntersection.x > innerBounds.origin.x + innerBounds.size.width {
                bestIntersection.x = innerBounds.origin.x + innerBounds.size.width
            }
        }
        arrowView?.sizeToFit()
        self.arrowView?.center = bestIntersection
        var arrowFrame: CGRect = arrowView?.frame ?? .zero
        arrowFrame.origin.x = round(arrowFrame.origin.x)
        arrowFrame.origin.y = round(arrowFrame.origin.y)
        self.arrowView?.frame = arrowFrame
    }

    func setContentView(aView: UIView?, animated: Bool) {
		contentView = aView
    }

    func setContentSize(aSize: CGSize, animated: Bool) {
        var frame: CGRect = self.frame
        frame.size = self.dynamicType.frameSizeForContentSize(aSize, withNavigationBar: false)
        UIView.animateWithDuration(animated ? 0.2 : 0, animations: {() -> Void in
            self.frame = frame
        })
    }
    var contentView: UIView? {
		willSet {
			contentView?.removeFromSuperview()
		}
		didSet {
			self.addSubview(contentView)
		}
    }

    var contentSize: CGSize {
        get {
            return contentContainerView.bounds.size
        }
        set {
			self.setContentSize(newValue, animated: false)
        }
    }
    var backgroundView: UIImageView?
    var arrowView: UIImageView?
    var contentContainerView: UIView


    class func insetForArrows() -> UIEdgeInsets {
        return UIEdgeInsetsMake(17, 12, 8, 12)
    }

    class func backgroundRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, self.insetForArrows())
    }

    class func contentRectForBounds(bounds: CGRect, withNavigationBar hasNavBar: Bool) -> CGRect {
        let navBarOffset: CGFloat = hasNavBar ? 32 : 0
        return UIEdgeInsetsInsetRect(CGRectMake(14, 9 + navBarOffset, bounds.size.width - 28, bounds.size.height - 28 - navBarOffset), self.insetForArrows())
    }

    class func frameSizeForContentSize(contentSize: CGSize, withNavigationBar hasNavBar: Bool) -> CGSize {
        var insets: UIEdgeInsets = self.insetForArrows()
        var frameSize: CGSize
        frameSize.width = contentSize.width + 28 + insets.left + insets.right
        frameSize.height = contentSize.height + 28 + (hasNavBar ? 32 : 0) + insets.top + insets.bottom
        return frameSize
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds: CGRect = self.bounds
        self.backgroundView?.frame = self.dynamicType.backgroundRectForBounds(bounds)
        self.contentContainerView.frame = self.dynamicType.contentRectForBounds(bounds, withNavigationBar: false)
        self.contentView?.frame = contentContainerView.bounds
    }
}



private struct LineSegment {
	var from: CGPoint
	var to: CGPoint
}

private func LineSegmentMake(from: CGPoint, _ to: CGPoint) -> LineSegment {
        var segment: LineSegment
        segment.from = from
        segment.to = to
        return segment
}

private func LineSegmentsIntersect(line1: LineSegment, _ line2: LineSegment, _ intersection: UnsafeMutablePointer<CGPoint>) -> Bool {
        /*
             E = B-A = ( Bx-Ax, By-Ay )
             F = D-C = ( Dx-Cx, Dy-Cy ) 
             P = ( -Ey, Ex )
             h = ( (A-C) * P ) / ( F * P )
             
             I = C + F*h
             */
        let A: CGPoint = line1.from
        let B: CGPoint = line1.to
        let C: CGPoint = line2.from
        let D: CGPoint = line2.to
        let E: CGPoint = CGPointMake(B.x - A.x, B.y - A.y)
        let F: CGPoint = CGPointMake(D.x - C.x, D.y - C.y)
        let P: CGPoint = CGPointMake(-E.y, E.x)
        let AC: CGPoint = CGPointMake(A.x - C.x, A.y - C.y)
        let h2: CGFloat = F.x * P.x + F.y * P.y
        // if h2 is 0, the lines are parallel
        if h2 != 0 {
            let h1: CGFloat = AC.x * P.x + AC.y * P.y
            let h: CGFloat = h1 / h2
            // if h is exactly 0 or 1, the lines touched on the end - we won't consider that an intersection
            if h > 0 && h < 1 {
                if intersection != nil {
                    let I: CGPoint = CGPointMake(C.x + F.x * h, C.y + F.y * h)
                    intersection.memory.x = I.x
                    intersection.memory.y = I.y
                }
                return true
            }
        }
        return false
}

private func DistanceBetweenTwoPoints(A: CGPoint, _ B: CGPoint) -> CGFloat {
        var a: CGFloat = B.x - A.x
        var b: CGFloat = B.y - A.y
        return sqrt((a * a) + (b * b))
}

