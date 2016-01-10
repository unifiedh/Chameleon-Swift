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
enum UIRectCorner : Int {
    case TopLeft = 1 << 0
    case TopRight = 1 << 1
    case BottomLeft = 1 << 2
    case BottomRight = 1 << 3
    case AllCorners = ~0
}

class UIBezierPath: NSObject, NSCopying {
    class func bezierPath() -> UIBezierPath {
        var bezierPath: UIBezierPath = self()
        bezierPath->path = CGPathCreateMutable()
        return bezierPath
    }

    class func bezierPathWithRect(rect: CGRect) -> UIBezierPath {
        var path: CGMutablePathRef = CGPathCreateMutable()
        CGPathAddRect(path, nil, rect)
        var bezierPath: UIBezierPath = self()
        bezierPath->path = path
        return bezierPath
    }

    class func bezierPathWithOvalInRect(rect: CGRect) -> UIBezierPath {
        var path: CGMutablePathRef = CGPathCreateMutable()
        CGPathAddEllipseInRect(path, nil, rect)
        var bezierPath: UIBezierPath = self()
        bezierPath->path = path
        return bezierPath
    }

    class func bezierPathWithRoundedRect(rect: CGRect, cornerRadius: CGFloat) -> UIBezierPath {
        return self(roundedRect: rect, byRoundingCorners: .AllCorners, cornerRadii: CGSizeMake(cornerRadius, cornerRadius))
    }

    class func bezierPathWithRoundedRect(rect: CGRect, byRoundingCorners corners: UIRectCorner, cornerRadii: CGSize) -> UIBezierPath {
        var path: CGMutablePathRef = CGPathCreateMutable()
        let topLeft: CGPoint = rect.origin
        let topRight: CGPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect))
        let bottomRight: CGPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect))
        let bottomLeft: CGPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect))
        if corners & .TopLeft {
            CGPathMoveToPoint(path, nil, topLeft.x + cornerRadii.width, topLeft.y)
        }
        else {
            CGPathMoveToPoint(path, nil, topLeft.x, topLeft.y)
        }
        if corners & .TopRight {
            CGPathAddLineToPoint(path, nil, topRight.x - cornerRadii.width, topRight.y)
            CGPathAddCurveToPoint(path, nil, topRight.x, topRight.y, topRight.x, topRight.y + cornerRadii.height, topRight.x, topRight.y + cornerRadii.height)
        }
        else {
            CGPathAddLineToPoint(path, nil, topRight.x, topRight.y)
        }
        if corners & .BottomRight {
            CGPathAddLineToPoint(path, nil, bottomRight.x, bottomRight.y - cornerRadii.height)
            CGPathAddCurveToPoint(path, nil, bottomRight.x, bottomRight.y, bottomRight.x - cornerRadii.width, bottomRight.y, bottomRight.x - cornerRadii.width, bottomRight.y)
        }
        else {
            CGPathAddLineToPoint(path, nil, bottomRight.x, bottomRight.y)
        }
        if corners & .BottomLeft {
            CGPathAddLineToPoint(path, nil, bottomLeft.x + cornerRadii.width, bottomLeft.y)
            CGPathAddCurveToPoint(path, nil, bottomLeft.x, bottomLeft.y, bottomLeft.x, bottomLeft.y - cornerRadii.height, bottomLeft.x, bottomLeft.y - cornerRadii.height)
        }
        else {
            CGPathAddLineToPoint(path, nil, bottomLeft.x, bottomLeft.y)
        }
        if corners & .TopLeft {
            CGPathAddLineToPoint(path, nil, topLeft.x, topLeft.y + cornerRadii.height)
            CGPathAddCurveToPoint(path, nil, topLeft.x, topLeft.y, topLeft.x + cornerRadii.width, topLeft.y, topLeft.x + cornerRadii.width, topLeft.y)
        }
        else {
            CGPathAddLineToPoint(path, nil, topLeft.x, topLeft.y)
        }
        CGPathCloseSubpath(path)
        var bezierPath: UIBezierPath = self()
        bezierPath->path = path
        return bezierPath
    }

    class func bezierPathWithArcCenter(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool) -> UIBezierPath {
        var path: CGMutablePathRef = CGPathCreateMutable()
        CGPathAddArc(path, nil, center.x, center.y, radius, startAngle, endAngle, clockwise)
        var bezierPath: UIBezierPath = self()
        bezierPath->path = path
        return bezierPath
    }

    class func bezierPathWithCGPath(CGPath: CGPathRef) -> UIBezierPath {
        assert(CGPath != nil, "CGPath must not be NULL")
        var bezierPath: UIBezierPath = self()
        bezierPath.CGPath = CGPath
        return bezierPath
    }

    func moveToPoint(point: CGPoint) {
        var mutablePath: CGMutablePathRef = CGPathCreateMutableCopy(path)
        CGPathMoveToPoint(mutablePath, nil, point.x, point.y)
        self.CGPath = mutablePath
        CGPathRelease(mutablePath)
    }

    func addLineToPoint(point: CGPoint) {
        var mutablePath: CGMutablePathRef = CGPathCreateMutableCopy(path)
        CGPathAddLineToPoint(mutablePath, nil, point.x, point.y)
        self.CGPath = mutablePath
        CGPathRelease(mutablePath)
    }

    func addArcWithCenter(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool) {
        var mutablePath: CGMutablePathRef = CGPathCreateMutableCopy(path)
        CGPathAddArc(mutablePath, nil, center.x, center.y, radius, startAngle, endAngle, clockwise)
        self.CGPath = mutablePath
        CGPathRelease(mutablePath)
    }

    func addCurveToPoint(endPoint: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint) {
        var mutablePath: CGMutablePathRef = CGPathCreateMutableCopy(path)
        CGPathAddCurveToPoint(mutablePath, nil, endPoint.x, endPoint.y, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y)
        self.CGPath = mutablePath
        CGPathRelease(mutablePath)
    }

    func addQuadCurveToPoint(endPoint: CGPoint, controlPoint: CGPoint) {
        var mutablePath: CGMutablePathRef = CGPathCreateMutableCopy(path)
        CGPathAddQuadCurveToPoint(mutablePath, nil, endPoint.x, endPoint.y, controlPoint.x, controlPoint.y)
        self.CGPath = mutablePath
        CGPathRelease(mutablePath)
    }

    func closePath() {
        var mutablePath: CGMutablePathRef = CGPathCreateMutableCopy(path)
        CGPathCloseSubpath(mutablePath)
        self.CGPath = mutablePath
        CGPathRelease(mutablePath)
    }

    func removeAllPoints() {
        var mutablePath: CGMutablePathRef = CGPathCreateMutable()
        self.CGPath = mutablePath
        CGPathRelease(mutablePath)
    }

    func appendPath(bezierPath: UIBezierPath) {
        if bezierPath != nil {
            var mutablePath: CGMutablePathRef = CGPathCreateMutableCopy(path)
            CGPathAddPath(mutablePath, nil, bezierPath.CGPath)
            self.CGPath = mutablePath
            CGPathRelease(mutablePath)
        }
    }

    func setLineDash(pattern: CGFloat, count: Int, phase: CGFloat) {
        free(self.lineDashPattern)
        if pattern && count > 0 {
            let size: size_t = sizeof() * count
            self.lineDashPattern = malloc(size)
            bcopy(pattern, lineDashPattern, size)
        }
        else {
            self.lineDashPattern = nil
        }
        self.lineDashCount = count
        self.lineDashPhase = phase
    }

    func getLineDash(pattern: CGFloat, count: Int, phase: CGFloat) {
        if pattern && lineDashPattern && lineDashCount > 0 {
            let size: size_t = sizeof() * lineDashCount
            bcopy(lineDashPattern, pattern, size)
        }
        if count != 0 {
            count = lineDashCount
        }
        if phase != "" {
            phase = lineDashPhase
        }
    }

    func fill() {
        var context: CGContextRef = UIGraphicsGetCurrentContext()
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

    func fillWithBlendMode(blendMode: CGBlendMode, alpha: CGFloat) {
        var context: CGContextRef = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        CGContextSetAlpha(context, alpha)
        CGContextSetBlendMode(context, blendMode)
        self.fill()
        CGContextRestoreGState(context)
    }

    func stroke() {
        var context: CGContextRef = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        self._setContextPath()
        CGContextStrokePath(context)
        CGContextBeginPath(context)
        CGContextRestoreGState(context)
    }

    func strokeWithBlendMode(blendMode: CGBlendMode, alpha: CGFloat) {
        var context: CGContextRef = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        CGContextSetAlpha(context, alpha)
        CGContextSetBlendMode(context, blendMode)
        self.stroke()
        CGContextRestoreGState(context)
    }

    func addClip() {
        self._setContextPath()
        if usesEvenOddFillRule {
            CGContextEOClip(UIGraphicsGetCurrentContext)
        }
        else {
            CGContextClip(UIGraphicsGetCurrentContext)
        }
    }

    func containsPoint(point: CGPoint) -> Bool {
        return CGPathContainsPoint(path, nil, point, usesEvenOddFillRule)
    }

    func applyTransform(transform: CGAffineTransform) {
        var mutablePath: CGMutablePathRef = CGPathCreateMutable()
        CGPathAddPath(mutablePath, transform, path)
        self.CGPath = mutablePath
        CGPathRelease(mutablePath)
    }
    var CGPath: CGPathRef {
        get {
            return self.CGPath
        }
        set {
            assert(path != nil, "path must not be NULL")
            if path != path {
                if path != nil {
                    CGPathRelease(path)
                }
                self.path = CGPathCreateCopy(path)
            }
        }
    }

    var currentPoint: CGPoint {
        get {
            return CGPathGetCurrentPoint(path)
        }
    }

    var lineWidth: CGFloat
    var lineCapStyle: CGLineCap
    var lineJoinStyle: CGLineJoin
    var miterLimit: CGFloat
    var flatness: CGFloat
    var usesEvenOddFillRule: Bool
    var empty: Bool {
        get {
            return CGPathIsEmpty(path)
        }
    }

    var bounds: CGRect {
        get {
            return CGPathGetBoundingBox(path)
        }
    }
    var self.lineDashPattern: CGFloat
    var self.lineDashCount: Int
    var self.lineDashPhase: CGFloat


    convenience override init() {
        if (self.init()) {
            self.lineWidth = 1
            self.lineCapStyle = kCGLineCapButt
            self.lineJoinStyle = kCGLineJoinMiter
            self.miterLimit = 10
            self.flatness = 0.6
            self.usesEvenOddFillRule = false
            self.lineDashPattern = nil
            self.lineDashCount = 0
            self.lineDashPhase = 0
        }
    }

    func dealloc() {
        if path != nil {
            CGPathRelease(path)
        }
    }

    convenience override init(zone: NSZone) {
        var copy: UIBezierPath = self()
        copy.CGPath = self.CGPath
        copy.lineWidth = self.lineWidth
        copy.lineCapStyle = self.lineCapStyle
        copy.lineJoinStyle = self.lineJoinStyle
        copy.miterLimit = self.miterLimit
        copy.flatness = self.flatness
        copy.usesEvenOddFillRule = self.usesEvenOddFillRule
        var lineDashCount: Int = 0
        self.getLineDash(nil, count: lineDashCount, phase: nil)
        if lineDashCount > 0 {
            var lineDashPattern: CGFloat = malloc(sizeof() * lineDashCount)
            var lineDashPhase: CGFloat = 0
            self.getLineDash(lineDashPattern, count: nil, phase: lineDashPhase)
            copy.setLineDash(lineDashPattern, count: lineDashCount, phase: lineDashPhase)
            free(lineDashPattern)
        }
        return copy
    }

    func _setContextPath() {
        var context: CGContextRef = UIGraphicsGetCurrentContext()
        CGContextBeginPath(context)
        CGContextAddPath(context, path)
        CGContextSetLineWidth(context, lineWidth)
        CGContextSetLineCap(context, lineCapStyle)
        CGContextSetLineJoin(context, lineJoinStyle)
        CGContextSetMiterLimit(context, miterLimit)
        CGContextSetFlatness(context, flatness)
        CGContextSetLineDash(context, lineDashPhase, lineDashPhase, lineDashCount)
    }
}