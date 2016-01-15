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

import Cocoa


public class UIColor: NSObject {

    public final class func blackColor() -> UIColor {
		if BlackColor == nil {
			BlackColor = UIColor(NSColor: AppKit.NSColor.blackColor())!
		}
        return BlackColor!
    }

    public final class func darkGrayColor() -> UIColor {
		if DarkGrayColor == nil {
			DarkGrayColor = UIColor(NSColor: AppKit.NSColor.darkGrayColor())!
		}
        return DarkGrayColor!
    }

    public final class func lightGrayColor() -> UIColor {
		if LightGrayColor == nil {
			LightGrayColor = UIColor(NSColor: AppKit.NSColor.lightGrayColor())!
		}
        return LightGrayColor!
    }

    public final class func whiteColor() -> UIColor {
		if WhiteColor == nil {
			WhiteColor = UIColor(NSColor: AppKit.NSColor.whiteColor())!
		}
        return WhiteColor!
    }

    public final class func grayColor() -> UIColor {
		if GrayColor == nil {
			GrayColor = UIColor(NSColor: AppKit.NSColor.grayColor())!
		}
        return GrayColor!
    }

    public final class func redColor() -> UIColor {
		if RedColor == nil {
			RedColor = UIColor(NSColor: AppKit.NSColor.redColor())!
		}
        return RedColor!
    }

    public final class func greenColor() -> UIColor {
		if GreenColor == nil {
			GreenColor = UIColor(NSColor: AppKit.NSColor.greenColor())!
		}
        return GreenColor!
    }

    public final class func blueColor() -> UIColor {
		if BlueColor == nil {
			BlueColor = UIColor(NSColor: AppKit.NSColor.blueColor())!
		}
        return BlueColor!
    }

    public final class func cyanColor() -> UIColor {
		if CyanColor == nil {
			CyanColor = UIColor(NSColor: AppKit.NSColor.cyanColor())!
		}
        return CyanColor!
    }

    public final class func yellowColor() -> UIColor {
		if YellowColor == nil {
			YellowColor = UIColor(NSColor: AppKit.NSColor.yellowColor())!
		}
        return YellowColor!
    }

    public final class func magentaColor() -> UIColor {
		if MagentaColor == nil {
			MagentaColor = UIColor(NSColor: AppKit.NSColor.magentaColor())!
		}
		return MagentaColor!
    }

    public final class func orangeColor() -> UIColor {
		if OrangeColor == nil {
			OrangeColor = UIColor(NSColor: AppKit.NSColor.orangeColor())!
		}
		return OrangeColor!
    }

    public final class func purpleColor() -> UIColor {
		if PurpleColor == nil {
			PurpleColor = UIColor(NSColor: AppKit.NSColor.purpleColor())!
		}
		return PurpleColor!
    }

    public final class func brownColor() -> UIColor {
		if BrownColor == nil {
			BrownColor = UIColor(NSColor: AppKit.NSColor.brownColor())!
		}
		return BrownColor!
    }

    public final class func clearColor() -> UIColor {
		if ClearColor == nil {
			ClearColor = UIColor(NSColor: AppKit.NSColor.clearColor())!
		}
		return ClearColor!
    }

    public final class func lightTextColor() -> UIColor {
		if LightTextColor == nil {
			LightTextColor = UIColor(white: 1, alpha: 0.6)
		}
        return LightTextColor!
    }

    public final class func darkTextColor() -> UIColor {
        return self.blackColor()
    }

	internal init?(reps: [UIColorRep]) {
		if reps.count == 0 {
			representations = []
			return nil
		}
		representations = reps
		super.init()
	}

    public convenience init(white: CGFloat, alpha: CGFloat = 1) {
		self.init(NSColor: AppKit.NSColor(deviceWhite: white, alpha: alpha))!
    }

    public convenience init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
		self.init(NSColor: AppKit.NSColor(deviceHue: hue, saturation: saturation, brightness: brightness, alpha: alpha))!
    }

    public convenience init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
		self.init(`NSColor`: AppKit.NSColor(deviceRed: red, green: green, blue: blue, alpha: alpha))!
    }

    public convenience init?(CGColor ref: CGColorRef) {
		self.init(reps: [UIColorRep(CGColor: ref)])
    }

    public convenience init(patternImage: UIImage) {
        let imageReps = patternImage._representations()
        var colorReps = [UIColorRep]()
        for imageRep in imageReps {
            colorReps.append(UIColorRep(patternImageRepresentation: imageRep))
        }
		self.init(reps: colorReps)!
    }

    public func colorWithAlphaComponent(alpha: CGFloat) -> UIColor {
        let newColor: CGColorRef = CGColorCreateCopyWithAlpha(self.CGColor, alpha)!
        let resultingUIColor: UIColor = UIColor(CGColor: newColor)!
        return resultingUIColor
    }

    public func set() {
        setFill()
        setStroke()
    }

    public func setFill() {
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(ctx, self._bestRepresentationForProposedScale(_UIGraphicsGetContextScaleFactor(ctx)).CGColor)
    }

    public func setStroke() {
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(ctx, self._bestRepresentationForProposedScale(_UIGraphicsGetContextScaleFactor(ctx)).CGColor)
    }
	
    public var CGColor: CGColorRef {
        get {
            return self._bestRepresentationForProposedScale(1).CGColor
        }
    }
	let representations: [UIColorRep]

    internal func _bestRepresentationForProposedScale(scale: CGFloat) -> UIColorRep {
        var bestRep: UIColorRep? = nil
        for rep: UIColorRep in representations {
            if rep.scale > scale {

            }
            else {
                bestRep = rep
            }
        }
        return bestRep ?? representations.last!
    }

    internal func _isOpaque() -> Bool {
        for rep: UIColorRep in representations {
            if !rep.opaque {
                return false
            }
        }
        return true
    }


	override public var description: String {
        // The color space string this gets isn't exactly the same as Apple's implementation.
        // For instance, Apple's implementation returns UIDeviceRGBColorSpace for [UIColor redColor]
        // This implementation returns kCGColorSpaceDeviceRGB instead.
        // Apple doesn't actually define UIDeviceRGBColorSpace or any of the other responses anywhere public,
        // so there isn't any easy way to emulate it.
        var colorSpaceRef = CGColorGetColorSpace(self.CGColor)
        var colorSpace: String = (CGColorSpaceCopyName(colorSpaceRef) as? NSString as? String) ?? "Unknown"
        let numberOfComponents: size_t = CGColorGetNumberOfComponents(self.CGColor)
        let components = CGColorGetComponents(self.CGColor)
        var componentsString: NSMutableString = NSMutableString(string: "{")
        for var index = 0; index < numberOfComponents; index++ {
            if index != 0 {
                componentsString.appendString(", ")
            }
            componentsString.appendFormat("%.0f", components[index])
        }
        componentsString.appendString("}")
        return "<\(self.className): \(self); colorSpace = \(colorSpace); components = \(componentsString)>"
    }

    override public func isEqual(object: AnyObject?) -> Bool {
		if let color = object as? UIColor {
			return CGColorEqualToColor(self.CGColor, color.CGColor)
		} else {
			return false
		}
    }
}

extension UIColor {
	convenience init?(`NSColor` aColor: AppKit.NSColor) {
		guard let c = aColor.colorUsingColorSpace(NSColorSpace.deviceRGBColorSpace()) else {
			return nil
		}
		var components = [CGFloat](count: c.numberOfComponents, repeatedValue: 0)
		c.getComponents(&components)
		guard let color = CGColorCreate(c.colorSpace.CGColorSpace, components) else {
			return nil
		}
		self.init(`CGColor`: color)
	}
	
	func NSColor() -> AppKit.NSColor {
		let color: CGColorRef = self.CGColor
		let colorSpace = NSColorSpace(CGColorSpace: CGColorGetColorSpace(color)!)!
		let numberOfComponents: Int = CGColorGetNumberOfComponents(color)
		let components = CGColorGetComponents(color)
		let theColor = AppKit.NSColor(colorSpace: colorSpace, components: components, count: numberOfComponents)
		return theColor
	}
}

private var BlackColor: UIColor? = nil
private var DarkGrayColor: UIColor? = nil
private var LightGrayColor: UIColor? = nil
private var WhiteColor: UIColor? = nil
private var GrayColor: UIColor? = nil
private var RedColor: UIColor? = nil
private var GreenColor: UIColor? = nil
private var BlueColor: UIColor? = nil
private var CyanColor: UIColor? = nil
private var YellowColor: UIColor? = nil
private var MagentaColor: UIColor? = nil
private var OrangeColor: UIColor? = nil
private var PurpleColor: UIColor? = nil
private var BrownColor: UIColor? = nil
private var ClearColor: UIColor? = nil
private var LightTextColor: UIColor? = nil
