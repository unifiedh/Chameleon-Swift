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

class UITableViewSectionLabel: UILabel {
    class func sectionLabelWithTitle(title: String) -> UITableViewSectionLabel {
        var label: UITableViewSectionLabel = self()
        label.text = "  \(title)"
        label.font = UIFont.boldSystemFontOfSize(17)
        label.textColor = UIColor.whiteColor()
        label.shadowColor = UIColor(red: 100 / 255.0, green: 105 / 255.0, blue: 110 / 255.0, alpha: 1)
        label.shadowOffset = CGSizeMake(0, 1)
        return label
    }

    func drawRect(rect: CGRect) {
        let size: CGSize = self.bounds.size
        UIColor(red: 166 / 255.0, green: 177 / 255.0, blue: 187 / 255.0, alpha: 1).setFill()
        UIRectFill(CGRectMake(0.0, 0.0, size.width, 1.0))
        var startColor: UIColor = UIColor(red: 145 / 255.0, green: 158 / 255.0, blue: 171 / 255.0, alpha: 1)
        var endColor: UIColor = UIColor(red: 185 / 255.0, green: 193 / 255.0, blue: 201 / 255.0, alpha: 1)
        var colorSpace: CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()
        var locations: CGFloat = CGFloat()
        locations.0.0
        locations.1.0
        let colors = Void()
        colors.startColor.CGColor
        colors.endColor.CGColor
        var gradientColors: CFArrayRef = CFArrayCreate(nil, colors, 2, nil)
        var gradient: CGGradientRef = CGGradientCreateWithColors(colorSpace, gradientColors, locations)
        CGColorSpaceRelease(colorSpace)
        CGContextDrawLinearGradient(UIGraphicsGetCurrentContext(), gradient, CGPointMake(0.0, 1.0), CGPointMake(0.0, size.height - 1.0), 0)
        CGGradientRelease(gradient)
        CFRelease(gradientColors)
        UIColor(red: 153 / 255.0, green: 158 / 255.0, blue: 165 / 255.0, alpha: 1).setFill()
        UIRectFill(CGRectMake(0.0, size.height - 1.0, size.width, 1.0))
        super.drawRect(rect)
    }
}