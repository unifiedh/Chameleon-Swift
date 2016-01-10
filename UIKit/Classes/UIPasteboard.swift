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
class UIPasteboard: NSObject {
    class func generalPasteboard() -> UIPasteboard {
        var aPasteboard: UIPasteboard? = nil
        if !aPasteboard {
            aPasteboard = UIPasteboard(pasteboard: NSPasteboard.generalPasteboard())
        }
        return aPasteboard!
    }

    func addItems(items: [AnyObject]) {
        var objects: [AnyObject] = [AnyObject](minimumCapacity: items!.count)
        for item: [NSObject : AnyObject] in items! {
            objects.append(PasteBoardItemWithDictionary(item))
        }
        pasteboard.writeObjects(objects)
    }

    func setData(data: NSData, forPasteboardType pasteboardType: String) {
        if data && pasteboardType {
            pasteboard.clearContents()
            pasteboard.writeObjects([PasteBoardItemWithDictionary([
                pasteboardType : data
            ]
)])
        }
    }

    func setValue(value: AnyObject, forPasteboardType pasteboardType: String) {
        if pasteboardType && IsUIPasteboardPropertyListType(value) {
            pasteboard.clearContents()
            pasteboard.writeObjects([PasteBoardItemWithDictionary([
                pasteboardType : value
            ]
)])
        }
    }
    var URL: NSURL {
        get {
            return FirstObjectOrNil(self.URLs())
        }
        set {
            self.URLs = [aURL]
        }
    }

    var URLs: [AnyObject] {
        get {
            return self._objectsWithClasses([NSURL])
        }
        set {
            self._writeObjects(items!)
        }
    }

    var string: String {
        get {
            return FirstObjectOrNil(self.strings())
        }
        set {
            self.strings = [aString]
        }
    }

    var strings: [AnyObject] {
        get {
            return self._objectsWithClasses([String])
        }
        set {
            self._writeObjects(strings)
        }
    }

    var image: UIImage {
        get {
            return FirstObjectOrNil(self.images())
        }
        set {
            self.images = [anImage]
        }
    }

    var images: [AnyObject] {
        get {
            var rawImages: [AnyObject] = self._objectsWithClasses([NSImage])
            var images: [AnyObject] = [AnyObject](minimumCapacity: rawImages.count)
            for image: NSImage in rawImages {
                images.append(UIImage(NSImage: image)!)
            }
            return images
        }
        set {
            var items: [AnyObject] = [AnyObject](minimumCapacity: images.count)
            for image: UIImage in images {
                items.append(image.NSImage())
            }
            self._writeObjects(items)
        }
    }

    var color: UIColor {
        get {
            return FirstObjectOrNil(self.colors())
        }
        set {
            self.colors = [aColor]
        }
    }

    var colors: [AnyObject] {
        get {
            var rawColors: [AnyObject] = self._objectsWithClasses([NSColor])
            var colors: [AnyObject] = [AnyObject](minimumCapacity: rawColors.count)
            for color: NSColor in rawColors {
                colors.append(UIColor(NSColor: color))
            }
            return colors
        }
        set {
            var items: [AnyObject] = [AnyObject](minimumCapacity: colors.count)
            for color: UIColor in colors {
                items.append(color.NSColor())
            }
            self._writeObjects(items)
        }
    }

    var items: [AnyObject] {
        get {
            var items: [AnyObject] = [AnyObject](minimumCapacity: 0)
            for item: NSPasteboardItem in pasteboard.pasteboardItems() {
                var dict: [NSObject : AnyObject] = [NSObject : AnyObject](minimumCapacity: 0)
                for type: String in item.types() {
                    var object: AnyObject? = nil
                    if UTTypeConformsTo(type as! CFString, kUTTypeURL) {
                        object = NSURL(string: item.stringForType(type))!
                    }
                    else {
                        object = item.propertyListForType(type) ?? item.dataForType(type)
                    }
                    if object! {
                        dict[type] = object!
                    }
                }
                if dict.count > 0 {
                    items.append(dict)
                }
            }
            return items
        }
        set {
            pasteboard.clearContents()
            self.addItems(items)
        }
    }
    var self.pasteboard: NSPasteboard


    convenience override init(pasteboard aPasteboard: NSPasteboard) {
        if (self.init()) {
            self.pasteboard = aPasteboard!
        }
    }

    func _writeObjects(objects: [AnyObject]) {
        pasteboard.clearContents()
        pasteboard.writeObjects(objects)
    }

    convenience override init(types: [AnyObject]) {
        var options: [NSObject : AnyObject] = [NSObject : AnyObject]()
        return pasteboard.readObjectsForClasses(types, options: options)
    }
    // there's a good chance this won't work correctly for all cases and indeed it's very untested in its current incarnation
}


import AppKit
        return (items.count > 0) ? items[0] : nil

        return (object! is String) || (object! is [AnyObject]) || (object! is [NSObject : AnyObject]) || (object! is NSDate) || (object! is Int) || (object! is NSURL)

        var pasteboardItem: NSPasteboardItem = NSPasteboardItem()
        for type: String in item.allKeys() {
            var object: AnyObject = (item[type] as! AnyObject)
            if (object is NSData) {
                // this is a totally evil hack to support animated GIF.
                // for some reason just copying the data with the kUTTypeGIF to the pasteboard wasn't enough.
                // after much experimentation it would appear that building an NSAttributed string and embedding
                // the image into it is the way Safari does it so that pasting into iChat actually works.
                // this is really stupid. I don't know if this is really the best place for this or if there's a
                // more general rule for when something should be converted to an attributed string, but this
                // seemed to be the quickest way to get the job done at the time. Copying raw GIF NSData to the
                // pasteboard on iOS and tagging it as kUTTypeGIF seems to work just fine in the few places that
                // accept animated GIFs that I've tested so far on iOS so...... yeah.
                if UTTypeEqual(type as! CFString, kUTTypeGIF) {
                    var fileWrapper: NSFileWrapper = NSFileWrapper.initRegularFileWithContents(object)
                    fileWrapper.preferredFilename = "image.gif"
                    var attachment: NSTextAttachment = NSTextAttachment(fileWrapper: fileWrapper)
                    var str: NSAttributedString = NSAttributedString.attributedStringWithAttachment(attachment)
                    pasteboardItem.setData(str.RTFDFromRange(NSMakeRange(0, str.characters.count), documentAttributes: nil), forType: String(kUTTypeFlatRTFD))
                }
                pasteboardItem.setData(object, forType: type)
            }
            else if (object is NSURL) {
                pasteboardItem.setString(object.absoluteString(), forType: type)
            }
            else {
                pasteboardItem.setPropertyList(object, forType: type)
            }
        }
        return pasteboardItem