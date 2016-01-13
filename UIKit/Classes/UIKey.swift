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
// NOTE: This does not come from Apple's UIKit and only exist to solve some current problems.
// I have no idea what Apple will do with keyboard handling. If they ever expose that stuff publically,
// then all of this should change to reflect the official API.
enum UIKeyType : Int {
    case Character
    // the catch-all/default... I wouldn't depend much on this at this point
    case UpArrow
    case DownArrow
    case LeftArrow
    case RightArrow
    case Return
    case Enter
    case Home
    case Insert
    case Delete
    case End
    case PageUp
    case PageDown
    case Escape
}

class UIKey: NSObject {
    convenience override init(NSEvent event: NSEvent) {
        if (self.init()) {
            self.keyCode = event.keyCode()
            self.characters = event.charactersIgnoringModifiers().copy()
            self.charactersWithModifiers = event.characters().copy()
            self.repeat = event.isARepeat()
            self.modifierFlags = event.modifierFlags()
        }
    }
    var type: UIKeyType {
        get {
            if keyCode == 53 {
                return .Escape
            }
            if characters.characters.count > 0 {
                switch characters.characterAtIndex(0) {
                    case NSUpArrowFunctionKey:
                        return .UpArrow
                    case NSDownArrowFunctionKey:
                        return .DownArrow
                    case NSLeftArrowFunctionKey:
                        return .LeftArrow
                    case NSRightArrowFunctionKey:
                        return .RightArrow
                    case NSEndFunctionKey:
                        return .End
                    case NSPageUpFunctionKey:
                        return .PageUp
                    case NSPageDownFunctionKey:
                        return .PageDown
                    case NSDeleteFunctionKey:
                        return .Delete
                    case NSInsertFunctionKey:
                        return .Insert
                    case NSHomeFunctionKey:
                        return .Home
                    case 0x000D:
                        return .Return
                    case 0x0003:
                        return .Enter
                }
            }
            return .Character
        }
    }

    var keyCode: UInt8 {
        get {
            return self.keyCode
        }
    }

    var characters: String {
        get {
            return self.characters
        }
    }

    var charactersWithModifiers: String {
        get {
            return self.charactersWithModifiers
        }
    }

    var repeat: Bool {
        get {
            return self.repeat
        }
    }

    var capslockEnabled: Bool {
        get {
            return (modifierFlags & NSAlphaShiftKeyMask) == NSAlphaShiftKeyMask
        }
    }

    var shiftKeyPressed: Bool {
        get {
            return (modifierFlags & NSShiftKeyMask) == NSShiftKeyMask
        }
    }

    var controlKeyPressed: Bool {
        get {
            return (modifierFlags & NSControlKeyMask) == NSControlKeyMask
        }
    }

    var optionKeyPressed: Bool {
        get {
            return (modifierFlags & NSAlternateKeyMask) == NSAlternateKeyMask
        }
    }

    var commandKeyPressed: Bool {
        get {
            return (modifierFlags & NSCommandKeyMask) == NSCommandKeyMask
        }
    }

    var action: Selector {
        get {
            if self.type == .Enter || (self.type == .Return && self.commandKeyPressed) {
                return "commitOperation:"
            }
            if self.type == .Escape || (self.commandKeyPressed && self.characters.isEqual(".")) {
                return "cancelOperation:"
            }
            return nil
        }
    }
    var self.modifierFlags: Int

}

