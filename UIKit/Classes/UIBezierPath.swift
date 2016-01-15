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

public struct UIRectCorner : OptionSetType {
	public let rawValue: UInt
	
	public init(rawValue: UInt) {
		self.rawValue = rawValue
	}
	
    public static let TopLeft = UIRectCorner(rawValue: 1 << 0)
    public static let TopRight = UIRectCorner(rawValue: 1 << 1)
    public static let BottomLeft = UIRectCorner(rawValue: 1 << 2)
    public static let BottomRight = UIRectCorner(rawValue: 1 << 3)
    public static let AllCorners = UIRectCorner(rawValue: ~0)
}

public class UIBezierPath: NSObject, NSCopying {
	private var path: CGPathRef = CGPathCreateMutable()
	
    public convenience init(rect: CGRect) {
        let path: CGMutablePathRef = CGPathCreateMutable()
        CGPathAddRect(path, nil, rect)
        self.init()
        self.CGPath = path
    }

    public convenience init(ovalInRect rect: CGRect) {
        let path: CGMutablePathRef = CGPathCreateMutable()
        CGPathAddEllipseInRect(path, nil, rect)
		self.init()
		self.CGPath = path
    }

    public convenience init(roundedRect rect: CGRect, cornerRadius: CGFloat) {
		self.init(roundedRect: rect, byRoundingCorners: .AllCorners, cornerRadii: CGSizeMake(cornerRadius, cornerRadius))
    }

    public convenience init(roundedRect rect: CGRect, byRoundingCorners corners: UIRectCorner, cornerRadii: CGSize) {
        let path: CGMutablePathRef = CGPathCreateMutable()
        let topLeft: CGPoint = rect.origin
        let topRight: CGPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect))
        let bottomRight: CGPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect))
        let bottomLeft: CGPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect))
        if corners.contains(.TopLeft) {
            CGPathMoveToPoint(path, nil, topLeft.x + cornerRadii.width, topLeft.y)
        } else {
            CGPathMoveToPoint(path, nil, topLeft.x, topLeft.y)
        }
        if corners.contains(.TopRight) {
            CGPathAddLineToPoint(path, nil, topRight.x - cornerRadii.width, topRight.y)
            CGPathAddCurveToPoint(path, nil, topRight.x, topRight.y, topRight.x, topRight.y + cornerRadii.height, topRight.x, topRight.y + cornerRadii.height)
        } else {
            CGPathAddLineToPoint(path, nil, topRight.x, topRight.y)
        }
        if corners.contains(.BottomRight) {
            CGPathAddLineToPoint(path, nil, bottomRight.x, bottomRight.y - cornerRadii.height)
            CGPathAddCurveToPoint(path, nil, bottomRight.x, bottomRight.y, bottomRight.x - cornerRadii.width, bottomRight.y, bottomRight.x - cornerRadii.width, bottomRight.y)
        } else {
            CGPathAddLineToPoint(path, nil, bottomRight.x, bottomRight.y)
        }
        if corners.contains(.BottomLeft) {
            CGPathAddLineToPoint(path, nil, bottomLeft.x + cornerRadii.width, bottomLeft.y)
            CGPathAddCurveToPoint(path, nil, bottomLeft.x, bottomLeft.y, bottomLeft.x, bottomLeft.y - cornerRadii.height, bottomLeft.x, bottomLeft.y - cornerRadii.height)
        } else {
            CGPathAddLineToPoint(path, nil, bottomLeft.x, bottomLeft.y)
        }
        if corners.contains(.TopLeft) {
            CGPathAddLineToPoint(path, nil, topLeft.x, topLeft.y + cornerRadii.height)
            CGPathAddCurveToPoint(path, nil, topLeft.x, topLeft.y, topLeft.x + cornerRadii.width, topLeft.y, topLeft.x + cornerRadii.width, topLeft.y)
        } else {
            CGPathAddLineToPoint(path, nil, topLeft.x, topLeft.y)
        }
        CGPathCloseSubpath(path)
		self.init()
        self.CGPath = path
    }

    public convenience init(arcCenter center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool) {
        let path: CGMutablePathRef = CGPathCreateMutable()
        CGPathAddArc(path, nil, center.x, center.y, radius, startAngle, endAngle, clockwise)
        self.init()
		self.CGPath = path
    }

	public convenience init(CGPath: CGPathRef) {
		self.init()
		self.CGPath = CGPath
	}

    public func moveToPoint(point: CGPoint) {
		let mutablePath: CGMutablePathRef = CGPathCreateMutableCopy(path)!
        CGPathMoveToPoint(mutablePath, nil, point.x, point.y)
        self.CGPath = mutablePath
    }

    public func addLineToPoint(point: CGPoint) {
		let mutablePath: CGMutablePathRef = CGPathCreateMutableCopy(path)!
        CGPathAddLineToPoint(mutablePath, nil, point.x, point.y)
        self.CGPath = mutablePath
    }

    public func addArcWithCenter(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool) {
		let mutablePath: CGMutablePathRef = CGPathCreateMutableCopy(path)!
        CGPathAddArc(mutablePath, nil, center.x, center.y, radius, startAngle, endAngle, clockwise)
        self.CGPath = mutablePath
    }

    public func addCurveToPoint(endPoint: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint) {
		let mutablePath: CGMutablePathRef = CGPathCreateMutableCopy(path)!
        CGPathAddCurveToPoint(mutablePath, nil, endPoint.x, endPoint.y, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y)
        self.CGPath = mutablePath
    }

    public func addQuadCurveToPoint(endPoint: CGPoint, controlPoint: CGPoint) {
		let mutablePath: CGMutablePathRef = CGPathCreateMutableCopy(path)!
        CGPathAddQuadCurveToPoint(mutablePath, nil, endPoint.x, endPoint.y, controlPoint.x, controlPoint.y)
        self.CGPath = mutablePath
    }

    public func closePath() {
		let mutablePath: CGMutablePathRef = CGPathCreateMutableCopy(path)!
        CGPathCloseSubpath(mutablePath)
        self.CGPath = mutablePath
    }

    public func removeAllPoints() {
        self.CGPath = CGPathCreateMutable()
    }

    public func appendPath(bezierPath: UIBezierPath?) {
        if let bezierPath = bezierPath {
            let mutablePath: CGMutablePathRef = CGPathCreateMutableCopy(path)!
            CGPathAddPath(mutablePath, nil, bezierPath.CGPath)
            self.CGPath = mutablePath
        }
    }

    public func setLineDash(pattern: UnsafePointer<CGFloat>, count: Int, phase: CGFloat) {
		lineDashPattern = []
        if pattern != nil && count > 0 {
            let size: size_t = sizeof(CGFloat) * count
			self.lineDashPattern = [CGFloat](count: count, repeatedValue: 0)
            bcopy(pattern, &lineDashPattern, size)
        }
        else {
            self.lineDashPattern = []
        }
        self.lineDashCount = count
        self.lineDashPhase = phase
    }

    public func getLineDash(pattern: UnsafeMutablePointer<CGFloat>, count: UnsafeMutablePointer<Int>, phase: UnsafeMutablePointer<CGFloat>) {
        if pattern != nil && lineDashPattern.count > 0 && lineDashCount > 0 {
            let size: size_t = sizeof(CGFloat) * lineDashCount
            bcopy(lineDashPattern, pattern, size)
        }
        if count != nil {
            count.memory = lineDashCount
        }
        if phase != nil {
            phase.memory = lineDashPhase
        }
    }

    public func fill() {
		let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        self._setContextPath()
        if usesEvenOddFillRule {
            CGContextEOFillPath(context)
        }
        else {
            CGContextFillPath(context)
        }
        CGContextBeginPath(context)
        CGContextRestoreGState(context)
    }

    public func fillWithBlendMode(blendMode: CGBlendMode, alpha: CGFloat) {
		let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        CGContextSetAlpha(context, alpha)
        CGContextSetBlendMode(context, blendMode)
        self.fill()
        CGContextRestoreGState(context)
    }

    public func stroke() {
		let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        self._setContextPath()
        CGContextStrokePath(context)
        CGContextBeginPath(context)
        CGContextRestoreGState(context)
    }

    public func strokeWithBlendMode(blendMode: CGBlendMode, alpha: CGFloat) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        CGContextSetAlpha(context, alpha)
        CGContextSetBlendMode(context, blendMode)
        self.stroke()
        CGContextRestoreGState(context)
    }

    public func addClip() {
        self._setContextPath()
        if usesEvenOddFillRule {
            CGContextEOClip(UIGraphicsGetCurrentContext())
        } else {
            CGContextClip(UIGraphicsGetCurrentContext())
        }
    }

    public func containsPoint(point: CGPoint) -> Bool {
        return CGPathContainsPoint(path, nil, point, usesEvenOddFillRule)
    }

    public func applyTransform(var transform: CGAffineTransform) {
        let mutablePath = CGPathCreateMutable()
        CGPathAddPath(mutablePath, &transform, path)
        self.CGPath = mutablePath
    }
    public var CGPath: CGPathRef {
        get {
            return self.path
        }
        set(path) {
			self.path = CGPathCreateCopy(path)!
        }
    }

    public var currentPoint: CGPoint {
        get {
            return CGPathGetCurrentPoint(path)
        }
    }

    public var lineWidth: CGFloat
    public var lineCapStyle: CGLineCap
    public var lineJoinStyle: CGLineJoin
    public var miterLimit: CGFloat
    public var flatness: CGFloat
    public var usesEvenOddFillRule: Bool
    public var empty: Bool {
        get {
            return CGPathIsEmpty(path)
        }
    }

    public var bounds: CGRect {
        get {
            return CGPathGetBoundingBox(path)
        }
    }
    var lineDashPattern: [CGFloat]
    var lineDashCount: Int
    var lineDashPhase: CGFloat


	public override required init() {
		self.lineWidth = 1
		self.lineCapStyle = CGLineCap.Butt
		self.lineJoinStyle = CGLineJoin.Miter
		self.miterLimit = 10
		self.flatness = 0.6
		self.usesEvenOddFillRule = false
		self.lineDashPattern = []
		self.lineDashCount = 0
		self.lineDashPhase = 0
		super.init()
    }

	public func copyWithZone(zone: NSZone) -> AnyObject {
        let copy: UIBezierPath = self.dynamicType.init()
        copy.CGPath = self.CGPath
        copy.lineWidth = self.lineWidth
        copy.lineCapStyle = self.lineCapStyle
        copy.lineJoinStyle = self.lineJoinStyle
        copy.miterLimit = self.miterLimit
        copy.flatness = self.flatness
        copy.usesEvenOddFillRule = self.usesEvenOddFillRule
        var lineDashCount: Int = 0
        self.getLineDash(nil, count: &lineDashCount, phase: nil)
        if lineDashCount > 0 {
            let lineDashPattern = UnsafeMutablePointer<CGFloat>.alloc(lineDashCount)
			var lineDashPhase: CGFloat = 0
            self.getLineDash(lineDashPattern, count: nil, phase: &lineDashPhase)
            copy.setLineDash(lineDashPattern, count: lineDashCount, phase: lineDashPhase)
			lineDashPattern.dealloc(lineDashCount)
        }
        return copy
    }

    func _setContextPath() {
        let context = UIGraphicsGetCurrentContext()
        CGContextBeginPath(context)
        CGContextAddPath(context, path)
        CGContextSetLineWidth(context, lineWidth)
        CGContextSetLineCap(context, lineCapStyle)
        CGContextSetLineJoin(context, lineJoinStyle)
        CGContextSetMiterLimit(context, miterLimit)
        CGContextSetFlatness(context, flatness)
        CGContextSetLineDash(context, lineDashPhase, &lineDashPhase, lineDashCount)
    }
}
