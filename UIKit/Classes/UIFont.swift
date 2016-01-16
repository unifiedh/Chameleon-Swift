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

import CoreText
import Cocoa

var UIFontSystemFontName: String? = nil

var UIFontBoldSystemFontName: String? = nil

public class UIFont: NSObject {
    var font: CTFontRef

    public convenience init?(name fontName: String, size fontSize: CGFloat) {
		self.init(NSFont: NSFont(name: fontName, size: fontSize))
    }

    public class func familyNames() -> [String] {
        let collection = CTFontCollectionCreateFromAvailableFonts(nil)
        return getFontCollectionNames(collection, nameAttr: kCTFontFamilyNameAttribute as String)
    }

    public class func fontNamesForFamilyName(familyName: String) -> [String]? {
        var names: [String]? = nil
        let descriptor: CTFontDescriptorRef? = CTFontDescriptorCreateWithAttributes([
            String(kCTFontFamilyNameAttribute) : familyName
        ])
        if let descriptor = descriptor {
			let descriptors = [descriptor]
			let collection: CTFontCollectionRef = CTFontCollectionCreateWithFontDescriptors(descriptors, nil)
			names = getFontCollectionNames(collection, nameAttr: kCTFontNameAttribute as String)
		}
		return names
	}

    public class func systemFontOfSize(fontSize: CGFloat) -> UIFont {
        let systemFont = UIFontSystemFontName != nil ? AppKit.NSFont(name: UIFontSystemFontName!, size: fontSize) : AppKit.NSFont.systemFontOfSize(fontSize)
        return UIFont(NSFont: systemFont ?? AppKit.NSFont.systemFontOfSize(fontSize))!
    }

    public class func boldSystemFontOfSize(fontSize: CGFloat) -> UIFont {
        let systemFont = (UIFontBoldSystemFontName != nil) ? AppKit.NSFont(name: UIFontBoldSystemFontName!, size: fontSize) : AppKit.NSFont.boldSystemFontOfSize(fontSize)
        return UIFont(NSFont: systemFont ?? AppKit.NSFont.boldSystemFontOfSize(fontSize))!
    }

	public convenience init?(size fontSize: CGFloat) {
		let newFont: CTFontRef? = CTFontCreateCopyWithAttributes(font, fontSize, nil, nil)
		if let newFont = newFont {
			self.init(ctFont: newFont)
		} else {
			return nil
		}

	}

	public var fontName: String {
        get {
            return String(CTFontCopyPostScriptName(font))
        }
    }

    public var ascender: CGFloat {
        get {
            return CTFontGetAscent(font)
        }
    }

    public var descender: CGFloat {
        get {
            return -CTFontGetDescent(font)
        }
    }

    public var lineHeight: CGFloat {
        get {
            // this seems to compute heights that are very close to what I'm seeing on iOS for fonts at
            // the same point sizes. however there's still subtle differences between fonts on the two
            // platforms (iOS and Mac) and I don't know if it's ever going to be possible to make things
            // return exactly the same values in all cases.
            return ceil(self.ascender) - floor(self.descender) + ceil(CTFontGetLeading(font))
        }
    }

    public var pointSize: CGFloat {
        get {
            return CTFontGetSize(font)
        }
    }

    public var xHeight: CGFloat {
        get {
            return CTFontGetXHeight(font)
        }
    }

    public var capHeight: CGFloat {
        get {
            return CTFontGetCapHeight(font)
        }
    }

    public var familyName: String {
        get {
            return String(CTFontCopyFamilyName(font))
        }
    }

    public class func setSystemFontName(aName: String) {
        UIFontSystemFontName = aName
    }

    public class func setBoldSystemFontName(aName: String) {
        UIFontBoldSystemFontName = aName
    }

	private init(ctFont aFont: CTFontRef) {
		self.font = aFont
		super.init()
	}
	
	convenience init?(NSFont aFont: AppKit.NSFont) {
		let newFont: CTFontRef? = CTFontCreateWithName(aFont.fontName , aFont.pointSize, nil)
		if let newFont = newFont {
			self.init(ctFont: newFont)
			return
		}
		return nil
    }

    func NSFont() -> AppKit.NSFont? {
        return AppKit.NSFont(name: self.fontName, size: self.pointSize)
    }
}

private func getFontCollectionNames(collection: CTFontCollectionRef?, nameAttr: String) -> [String] {
	var names = Set<String>()
	if let collection = collection {
		if let descriptors = CTFontCollectionCreateMatchingFontDescriptors(collection) as? NSArray as? [CTFontDescriptorRef] {
			for descriptor in descriptors {
				if let name = CTFontDescriptorCopyAttribute(descriptor, nameAttr) as? NSString as? String {
					names.insert(name)
				}
			}
		}
	}
	
	return Array(names)
}
