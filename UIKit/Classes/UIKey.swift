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


/// NOTE: This does not come from Apple's UIKit and only exist to solve some current problems.
/// I have no idea what Apple will do with keyboard handling. If they ever expose that stuff publically,
/// then all of this should change to reflect the official API.
enum UIKeyType : Int {
	/// the catch-all/default... I wouldn't depend much on this at this point
    case Character
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

internal class UIKey: NSObject {
	init(NSEvent event: NSEvent) {
		self.keyCode = event.keyCode
		self.characters = event.charactersIgnoringModifiers ?? ""
		self.charactersWithModifiers = event.characters ?? ""
		self.`repeat` = event.ARepeat
		self.modifierFlags = event.modifierFlags
		super.init()
    }
    var type: UIKeyType {
        get {
            if keyCode == 53 {
                return .Escape
            }
            if characters.characters.count > 0 {
                switch (characters as NSString).characterAtIndex(0) {
				case unichar(NSUpArrowFunctionKey):
					return .UpArrow
				case unichar(NSDownArrowFunctionKey):
					return .DownArrow
				case unichar(NSLeftArrowFunctionKey):
					return .LeftArrow
				case unichar(NSRightArrowFunctionKey):
					return .RightArrow
				case unichar(NSEndFunctionKey):
					return .End
				case unichar(NSPageUpFunctionKey):
					return .PageUp
				case unichar(NSPageDownFunctionKey):
					return .PageDown
				case unichar(NSDeleteFunctionKey):
					return .Delete
				case unichar(NSInsertFunctionKey):
					return .Insert
				case unichar(NSHomeFunctionKey):
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

    let keyCode: UInt16

    let characters: String

    let charactersWithModifiers: String

    let `repeat`: Bool

    var capslockEnabled: Bool {
        get {
            return modifierFlags.contains(.AlphaShiftKeyMask)
        }
    }

    var shiftKeyPressed: Bool {
        get {
			return modifierFlags.contains(.ShiftKeyMask)
        }
    }

    var controlKeyPressed: Bool {
        get {
			return modifierFlags.contains(.ControlKeyMask)
        }
    }

    var optionKeyPressed: Bool {
        get {
			return modifierFlags.contains(.AlternateKeyMask)
        }
    }

    var commandKeyPressed: Bool {
        get {
			return modifierFlags.contains(.CommandKeyMask)
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
    let modifierFlags: NSEventModifierFlags

}

