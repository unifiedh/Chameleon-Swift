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
import Cocoa
class UIFont: NSObject {
    var self.font: CTFontRef

    class func fontWithName(fontName: String, size fontSize: CGFloat) -> UIFont {
        return self(NSFont: NSFont(name: fontName, size: fontSize))
    }

    class func familyNames() -> [AnyObject] {
        var collection: CTFontCollectionRef = CTFontCollectionCreateFromAvailableFonts(nil)
        var names: [AnyObject] = getFontCollectionNames(collection, kCTFontFamilyNameAttribute)
        if collection != nil {
            CFRelease(collection)
        }
        return .s
    }

    class func fontNamesForFamilyName(familyName: String) -> [AnyObject] {
        var names: [AnyObject]? = nil
        var descriptor: CTFontDescriptorRef = CTFontDescriptorCreateWithAttributes([
            String(kCTFontFamilyNameAttribute) : familyName,
            nil : nil
        ]
 as! CFDictionaryRef)
        if descriptor != nil {
            var descriptors: CFArrayRef = CFArrayCreate(nil, descriptor as! AnyObject, 1, kCFTypeArrayCallBacks)
            if descriptors != nil {
                var collection: CTFontCollectionRef = CTFontCollectionCreateWithFontDescriptors(descriptors, nil)
                names = getFontCollectionNames(collection, kCTFontNameAttribute)
                if collection != nil {
                    CFRelease(collection)
                }
                CFRelease(descriptors)
            }
            CFRelease(descriptor)
        }
        return .s
    }

    class func systemFontOfSize(fontSize: CGFloat) -> UIFont {
        var systemFont: NSFont = UIFontSystemFontName ? NSFont(name: UIFontSystemFontName!, size: fontSize) : NSFont.systemFontOfSize(fontSize)
        return self(NSFont: systemFont)
    }

    class func boldSystemFontOfSize(fontSize: CGFloat) -> UIFont {
        var systemFont: NSFont = UIFontBoldSystemFontName ? NSFont(name: UIFontBoldSystemFontName!, size: fontSize) : NSFont.boldSystemFontOfSize(fontSize)
        return self(NSFont: systemFont)
    }

    func fontWithSize(fontSize: CGFloat) -> UIFont {
        var newFont: CTFontRef = CTFontCreateCopyWithAttributes(font, fontSize, nil, nil)
        if newFont != nil {
            var theFont: UIFont = self._fontWithCTFont(newFont)
            CFRelease(newFont)
            return theFont
        }
        else {
            return nil
        }
    }
    var fontName: String {
        get {
            return String(CFBridgingRelease(CTFontCopyPostScriptName(font)))
        }
    }

    var ascender: CGFloat {
        get {
            return CTFontGetAscent(font)
        }
    }

    var descender: CGFloat {
        get {
            return -CTFontGetDescent(font)
        }
    }

    var lineHeight: CGFloat {
        get {
            // this seems to compute heights that are very close to what I'm seeing on iOS for fonts at
            // the same point sizes. however there's still subtle differences between fonts on the two
            // platforms (iOS and Mac) and I don't know if it's ever going to be possible to make things
            // return exactly the same values in all cases.
            return ceilf(self.ascender) - floorf(self.descender) + ceilf(CTFontGetLeading(font))
        }
    }

    var pointSize: CGFloat {
        get {
            return CTFontGetSize(font)
        }
    }

    var xHeight: CGFloat {
        get {
            return CTFontGetXHeight(font)
        }
    }

    var capHeight: CGFloat {
        get {
            return CTFontGetCapHeight(font)
        }
    }

    var familyName: String {
        get {
            return String(CFBridgingRelease(CTFontCopyFamilyName(font)))
        }
    }

    class func setSystemFontName(aName: String) {
        UIFontSystemFontName = aName.copy()
    }

    class func setBoldSystemFontName(aName: String) {
        UIFontBoldSystemFontName = aName.copy()
    }

    class func _fontWithCTFont(aFont: CTFontRef) -> UIFont {
        var theFont: UIFont = UIFont()
        theFont->font = CFRetain(aFont)
        return theFont
    }

    class func fontWithNSFont(aFont: NSFont) -> UIFont {
        if aFont {
            var newFont: CTFontRef = CTFontCreateWithName(aFont.fontName() as! CFString, aFont.pointSize(), nil)
            if newFont != nil {
                var theFont: UIFont = self._fontWithCTFont(newFont)
                CFRelease(newFont)
                return theFont
            }
        }
        return nil
    }
        var names: NSMutableSet = NSMutableSet.set()
        if collection != nil {
            var descriptors: CFArrayRef = CTFontCollectionCreateMatchingFontDescriptors(collection)
            if descriptors != nil {
                var count: Int = CFArrayGetCount(descriptors)
                for var i = 0; i < count; i++ {
                    var descriptor: CTFontDescriptorRef = CFArrayGetValueAtIndex(descriptors, i) as! CTFontDescriptorRef
                    var name: AnyObject = CTFontDescriptorCopyAttribute(descriptor, .Attr)
                    if name != nil {
                        if CFGetTypeID(name) == CFStringGetTypeID() {
                            .s.append(String(name))
                        }
                        CFRelease(name)
                    }
                }
                CFRelease(descriptors)
            }
        }
        return .s.allObjects()

    func dealloc() {
        if font != nil {
            CFRelease(font)
        }
    }

    func NSFont() -> NSFont {
        return NSFont(name: self.fontName, size: self.pointSize)
    }
}
    var UIFontSystemFontName: String? = nil

    var UIFontBoldSystemFontName: String? = nil