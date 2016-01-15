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


public typealias UIAccessibilityNotifications = UInt32


public extension NSObject {
	/*
    public var isAccessibilityElement: Bool {
        get {
            return false
        }
        set {
            
        }
    }
    public var accessibilityLabel: String? {
        get {
            return nil
        }
        set {
            
        }
    }
    public var accessibilityHint: String? {
        get {
            return nil
        }
        set {
            
        }
    }
    public var accessibilityValue: String? {
        get {
            return nil
        }
        set {
            
        }
    }
    public var accessibilityTraits: UIAccessibilityTraits {
        get {
            return .None
        }
        set {
            
        }
    }
    public var accessibilityFrame: CGRect {
        get {
            return .null
        }
        set {
            
        }
    }
    public var accessibilityViewIsModal: Bool {
        get {
            return false
        }
        set {
            
        }
    }
    public var accessibilityElementsHidden: Bool {
        get {
            return false
        }
        set {
            
        }
    }*/
}

public extension NSObject {
    public var accessibilityElementCount: Int {
        return 0
    }

    public func accessibilityElementAtIndex(index: Int) -> AnyObject? {
        return nil
    }

    public func indexOfAccessibilityElement(element: AnyObject) -> Int {
        return NSNotFound
    }
}

public extension NSObject {
    public func accessibilityElementDidBecomeFocused() {
    }

    public func accessibilityElementDidLoseFocus() {
    }

    public func accessibilityElementIsFocused() -> Bool {
        return false
    }
}

public func UIAccessibilityPostNotification(notification: UIAccessibilityNotifications, argument: AnyObject) {
    
}

public func UIAccessibilityIsVoiceOverRunning() -> Bool {
    return false
}


public enum UIAccessibilityScrollDirection : Int {
    case Right = 1
    case Left
    case Up
    case Down
    case Next
    case Previous
}

public struct UIAccessibilityTraits: OptionSetType {
    public let rawValue: UInt64
    public init(rawValue: UInt64) {
        self.rawValue = rawValue
    }
    
    public static let None = UIAccessibilityTraits(rawValue: 0)
    public static let Button = UIAccessibilityTraits(rawValue: 1)
    public static let Link = UIAccessibilityTraits(rawValue: 2)
    public static let Image = UIAccessibilityTraits(rawValue: 4)
    public static let Selected = UIAccessibilityTraits(rawValue: 8)
    public static let PlaysSound = UIAccessibilityTraits(rawValue: 16)
    public static let KeyboardKey = UIAccessibilityTraits(rawValue: 32)
    public static let StaticText = UIAccessibilityTraits(rawValue: 64)
    public static let SummaryElement = UIAccessibilityTraits(rawValue: 128)
    public static let NotEnabled = UIAccessibilityTraits(rawValue: 256)
    public static let UpdatesFrequently = UIAccessibilityTraits(rawValue: 512)
    public static let SearchField = UIAccessibilityTraits(rawValue: 1024)
    public static let Header = UIAccessibilityTraits(rawValue: 2048)
}

public let UIAccessibilityScreenChangedNotification: UIAccessibilityNotifications = 1000

public let UIAccessibilityLayoutChangedNotification: UIAccessibilityNotifications = 1001

public let UIAccessibilityAnnouncementNotification: UIAccessibilityNotifications = 1002

public let UIAccessibilityPageScrolledNotification: UIAccessibilityNotifications = 1003

public let UIAccessibilityVoiceOverStatusChanged: String = "UIAccessibilityVoiceOverStatusChanged"

