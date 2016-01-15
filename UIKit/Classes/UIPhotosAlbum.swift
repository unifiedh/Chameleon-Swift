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
import AppKit
class UIPhotosAlbum: NSObject {
    class func sharedPhotosAlbum() -> UIPhotosAlbum {
        var album: UIPhotosAlbum? = nil
        if !album {
            album = self()
        }
        return album!
    }

    func writeImage(image: UIImage, completionTarget target: AnyObject, action: Selector, context: ) {
        if image != nil {
            var info: [NSObject : AnyObject] = [NSObject : AnyObject](minimumCapacity: 4)
            info["image"] = image
            if target && action {
                info["target"] = target
                info["action"] = NSStringFromSelector(action)
            }
            if context != nil {
                info["context"] = NSValue(pointer: context)
            }
            // deferring this partly because the save dialog is modal and partly because I don't think code is going
            // to expect the target/action to be sent before the save function even returns.
            self.performSelector("_writeImageWithInfo:", withObject: info, afterDelay: 0)
        }
    }

    func _writeImageWithInfo(info: [NSObject : AnyObject]) {
        var image: UIImage = (info["image"] as! UIImage)
        var error: NSError? = nil
        var panel: NSSavePanel = NSSavePanel.savePanel()
        panel.allowedFileTypes = ["png"]
        if NSFileHandlingPanelOKButton == panel.runModal() && panel.URL() {
            var imageData: NSData = UIImagePNGRepresentation(image)
            if imageData != nil {
                imageData.writeToURL(panel.URL(), options: NSDataWritingAtomic, error: error!)
            }
            else {
                error = NSError.errorWithDomain("could not generate png image", code: 2, userInfo: nil)
            }
        }
        else {
            error = NSError.errorWithDomain("save panel cancelled", code: 1, userInfo: nil)
        }
        var target: AnyObject = (info["target"] as! AnyObject)
        if target != nil {
            var action: Selector = NSSelectorFromString((info["action"] as! Selector))
            var context = info["context"].pointerValue()
            Void(ActionMethod)
            var method: ActionMethod = target.methodForSelector(action) as! ActionMethod
            method(target, action, image, error!, context)
        }
    }
}

