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
class UIColor: NSObject {
    class func colorWithWhite(white: CGFloat, alpha: CGFloat) -> UIColor {
        return self(white: white, alpha: alpha)
    }

    class func colorWithHue(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) -> UIColor {
        return self(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }

    class func colorWithRed(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return self(red: red, green: green, blue: blue, alpha: alpha)
    }

    class func colorWithCGColor(ref: CGColorRef) -> UIColor {
        return self(CGColor: ref)
    }

    class func colorWithPatternImage(patternImage: UIImage) -> UIColor {
        return self(patternImage: patternImage)
    }

    class func blackColor() -> UIColor {
        return BlackColor ?? (BlackColor = self(NSColor: NSColor.blackColor()))
    }

    class func darkGrayColor() -> UIColor {
        return DarkGrayColor ?? (DarkGrayColor = self(NSColor: NSColor.darkGrayColor()))
    }

    class func lightGrayColor() -> UIColor {
        return LightGrayColor ?? (LightGrayColor = self(NSColor: NSColor.lightGrayColor()))
    }

    class func whiteColor() -> UIColor {
        return WhiteColor ?? (WhiteColor = self(NSColor: NSColor.whiteColor()))
    }

    class func grayColor() -> UIColor {
        return GrayColor ?? (GrayColor = self(NSColor: NSColor.grayColor()))
    }

    class func redColor() -> UIColor {
        return RedColor ?? (RedColor = self(NSColor: NSColor.redColor()))
    }

    class func greenColor() -> UIColor {
        return GreenColor ?? (GreenColor = self(NSColor: NSColor.greenColor()))
    }

    class func blueColor() -> UIColor {
        return BlueColor ?? (BlueColor = self(NSColor: NSColor.blueColor()))
    }

    class func cyanColor() -> UIColor {
        return CyanColor ?? (CyanColor = self(NSColor: NSColor.cyanColor()))
    }

    class func yellowColor() -> UIColor {
        return YellowColor ?? (YellowColor = self(NSColor: NSColor.yellowColor()))
    }

    class func magentaColor() -> UIColor {
        return MagentaColor ?? (MagentaColor = self(NSColor: NSColor.magentaColor()))
    }

    class func orangeColor() -> UIColor {
        return OrangeColor ?? (OrangeColor = self(NSColor: NSColor.orangeColor()))
    }

    class func purpleColor() -> UIColor {
        return PurpleColor ?? (PurpleColor = self(NSColor: NSColor.purpleColor()))
    }

    class func brownColor() -> UIColor {
        return BrownColor ?? (BrownColor = self(NSColor: NSColor.brownColor()))
    }

    class func clearColor() -> UIColor {
        return ClearColor ?? (ClearColor = self(NSColor: NSColor.clearColor()))
    }

    class func lightTextColor() -> UIColor {
        return LightTextColor ?? (LightTextColor = self(white: 1, alpha: 0.6))
    }

    class func darkTextColor() -> UIColor {
        return self.blackColor()
    }

    convenience override init(white: CGFloat, alpha: CGFloat) {
        return self(NSColor: NSColor(deviceWhite: white, alpha: alpha))
    }

    convenience override init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        return self(NSColor: NSColor(deviceHue: hue, saturation: saturation, brightness: brightness, alpha: alpha))
    }

    convenience override init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        return self(NSColor: NSColor(deviceRed: red, green: green, blue: blue, alpha: alpha))
    }

    convenience override init(CGColor ref: CGColorRef) {
        return self._initWithRepresentations([UIColorRep(CGColor: ref)])
    }

    convenience override init(patternImage: UIImage) {
        var imageReps: [AnyObject] = patternImage._representations()
        var colorReps: [AnyObject] = [AnyObject](minimumCapacity: imageReps.count)
        for imageRep: UIImageRep in imageReps {
            colorReps.append(UIColorRep(patternImageRepresentation: imageRep))
        }
        return self._initWithRepresentations(colorReps)
    }

    func colorWithAlphaComponent(alpha: CGFloat) -> UIColor {
        var newColor: CGColorRef = CGColorCreateCopyWithAlpha(self.CGColor, alpha)
        var resultingUIColor: UIColor = UIColor(CGColor: newColor)
        CGColorRelease(newColor)
        return resultingUIColor
    }

    func set() {
        self.setFill()
        self.setStroke()
    }

    func setFill() {
        var ctx: CGContextRef = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(ctx, self._bestRepresentationForProposedScale(UIGraphicsGetContextScaleFactor(ctx)).CGColor)
    }

    func setStroke() {
        var ctx: CGContextRef = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(ctx, self._bestRepresentationForProposedScale(UIGraphicsGetContextScaleFactor(ctx)).CGColor)
    }
    var CGColor: CGColorRef {
        get {
            return self._bestRepresentationForProposedScale(1).CGColor
        }
    }
    var self.representations: [AnyObject]


    convenience override init(NSColor aColor: NSColor) {
        if !aColor {
            self = nil
        }
        else {
            var c: NSColor = aColor.colorUsingColorSpace(NSColorSpace.deviceRGBColorSpace())
            var components: CGFloat
            c.getComponents(components)
            var color: CGColorRef = CGColorCreate(c.colorSpace().CGColorSpace(), components)
            self = self(CGColor: color)
            CGColorRelease(color)
        }
    }

    convenience init(NSColor c: NSColor) {
        return self(NSColor: c)
    }

    convenience override init(reps: [AnyObject]) {
        if reps.count == 0 {
            self = nil
        }
        else if (self.init()) {
            self.representations = reps.copy()
        }

    }

    func _bestRepresentationForProposedScale(scale: CGFloat) -> UIColorRep {
        var bestRep: UIColorRep? = nil
        for rep: UIColorRep in representations {
            if rep.scale > scale {

            }
            else {
                bestRep = rep
            }
        }
        return bestRep ?? representations.lastObject()
    }

    func _isOpaque() -> Bool {
        for rep: UIColorRep in representations {
            if !rep.opaque {
                return false
            }
        }
        return true
    }

    func NSColor() -> NSColor {
        var color: CGColorRef = self.CGColor
        var colorSpace: NSColorSpace = NSColorSpace(CGColorSpace: CGColorGetColorSpace(color))
        let numberOfComponents: Int = CGColorGetNumberOfComponents(color)
        let components: CGFloat = CGColorGetComponents(color)
        var theColor: NSColor = NSColor(colorSpace: colorSpace, components: components, count: numberOfComponents)
        return theColor
    }

    func description() -> String {
        // The color space string this gets isn't exactly the same as Apple's implementation.
        // For instance, Apple's implementation returns UIDeviceRGBColorSpace for [UIColor redColor]
        // This implementation returns kCGColorSpaceDeviceRGB instead.
        // Apple doesn't actually define UIDeviceRGBColorSpace or any of the other responses anywhere public,
        // so there isn't any easy way to emulate it.
        var colorSpaceRef: CGColorSpaceRef = CGColorGetColorSpace(self.CGColor)
        var colorSpace: String = "\(String(CFBridgingRelease(CGColorSpaceCopyName(colorSpaceRef))))"
        let numberOfComponents: size_t = CGColorGetNumberOfComponents(self.CGColor)
        let components: CGFloat = CGColorGetComponents(self.CGColor)
        var componentsString: NSMutableString = NSMutableString.stringWithString("{")
        for var index = 0; index < numberOfComponents; index++ {
            if index != 0 {
                componentsString.appendString(", ")
            }
            componentsString.appendFormat("%.0f", components[index])
        }
        componentsString.appendString("}")
        return "<\(self.className()): \(self); colorSpace = \(colorSpace); components = \(componentsString)>"
    }

    func isEqual(object: AnyObject) -> Bool {
        if !(object is self) {
            return false
        }
        var color: UIColor = object as! UIColor
        return CGColorEqualToColor(self.CGColor, color.CGColor)
    }
}

import AppKit
import AppKit
    var BlackColor: UIColor? = nil

    var DarkGrayColor: UIColor? = nil

    var LightGrayColor: UIColor? = nil

    var WhiteColor: UIColor? = nil

    var GrayColor: UIColor? = nil

    var RedColor: UIColor? = nil

    var GreenColor: UIColor? = nil

    var BlueColor: UIColor? = nil

    var CyanColor: UIColor? = nil

    var YellowColor: UIColor? = nil

    var MagentaColor: UIColor? = nil

    var OrangeColor: UIColor? = nil

    var PurpleColor: UIColor? = nil

    var BrownColor: UIColor? = nil

    var ClearColor: UIColor? = nil

    var LightTextColor: UIColor? = nil