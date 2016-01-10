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
    var UIAccessibilityTraits: UInt64

    var UIAccessibilityTraitNone: UIAccessibilityTraits

    var UIAccessibilityTraitButton: UIAccessibilityTraits

    var UIAccessibilityTraitLink: UIAccessibilityTraits

    var UIAccessibilityTraitSearchField: UIAccessibilityTraits

    var UIAccessibilityTraitImage: UIAccessibilityTraits

    var UIAccessibilityTraitSelected: UIAccessibilityTraits

    var UIAccessibilityTraitPlaysSound: UIAccessibilityTraits

    var UIAccessibilityTraitKeyboardKey: UIAccessibilityTraits

    var UIAccessibilityTraitStaticText: UIAccessibilityTraits

    var UIAccessibilityTraitSummaryElement: UIAccessibilityTraits

    var UIAccessibilityTraitNotEnabled: UIAccessibilityTraits

    var UIAccessibilityTraitUpdatesFrequently: UIAccessibilityTraits

    var UIAccessibilityTraitHeader: UIAccessibilityTraits

    var UIAccessibilityNotifications: uint32_t

    var UIAccessibilityScreenChangedNotification: UIAccessibilityNotifications

    var UIAccessibilityLayoutChangedNotification: UIAccessibilityNotifications

    var UIAccessibilityAnnouncementNotification: UIAccessibilityNotifications

    var UIAccessibilityPageScrolledNotification: UIAccessibilityNotifications

extension NSObject {
    var isAccessibilityElement: Bool
    var accessibilityLabel: String
    var accessibilityHint: String
    var accessibilityValue: String
    var accessibilityTraits: UIAccessibilityTraits
    var accessibilityFrame: CGRect
    var accessibilityViewIsModal: Bool
    var accessibilityElementsHidden: Bool

    func isAccessibilityElement() -> Bool {
        return false
    }

    func setIsAccessibilityElement(isElement: Bool) {
    }

    func accessibilityLabel() -> String {
        return nil
    }

    func setAccessibilityLabel(label: String) {
    }

    func accessibilityHint() -> String {
        return nil
    }

    func setAccessibilityHint(hint: String) {
    }

    func accessibilityValue() -> String {
        return nil
    }

    func setAccessibilityValue(value: String) {
    }

    func accessibilityTraits() -> UIAccessibilityTraits {
        return .None
        // STUB
    }

    func setAccessibilityTraits(traits: UIAccessibilityTraits) {
    }

    func accessibilityFrame() -> CGRect {
        return CGRectNull
    }

    func setAccessibilityFrame(frame: CGRect) {
    }

    func accessibilityViewIsModal() -> Bool {
        return false
    }

    func setAccessibilityViewIsModal(isModal: Bool) {
    }

    func accessibilityElementsHidden() -> Bool {
        return false
    }

    func setAccessibilityElementsHidden(accessibilityElementsHidden: Bool) {
    }
}
extension NSObject {
    func accessibilityElementCount() -> Int {
        return 0
    }

    convenience override init(index: Int) {
        return nil
    }

    func indexOfAccessibilityElement(element: AnyObject) -> Int {
        return NSNotFound
    }
}
extension NSObject {
    func accessibilityElementDidBecomeFocused() {
    }

    func accessibilityElementDidLoseFocus() {
    }

    func accessibilityElementIsFocused() -> Bool {
        return false
    }
}
    var UIAccessibilityPostNotification

    var UIAccessibilityIsVoiceOverRunning: Bool

    let UIAccessibilityVoiceOverStatusChanged: String

enum UIAccessibilityScrollDirection : Int {
    case Right = 1
    case Left
    case Up
    case Down
    case Next
    case Previous
}

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

    var UIAccessibilityTraitNone: UIAccessibilityTraits = 0

    var UIAccessibilityTraitButton: UIAccessibilityTraits = 1

    var UIAccessibilityTraitLink: UIAccessibilityTraits = 2

    var UIAccessibilityTraitImage: UIAccessibilityTraits = 4

    var UIAccessibilityTraitSelected: UIAccessibilityTraits = 8

    var UIAccessibilityTraitPlaysSound: UIAccessibilityTraits = 16

    var UIAccessibilityTraitKeyboardKey: UIAccessibilityTraits = 32

    var UIAccessibilityTraitStaticText: UIAccessibilityTraits = 64

    var UIAccessibilityTraitSummaryElement: UIAccessibilityTraits = 128

    var UIAccessibilityTraitNotEnabled: UIAccessibilityTraits = 256

    var UIAccessibilityTraitUpdatesFrequently: UIAccessibilityTraits = 512

    var UIAccessibilityTraitSearchField: UIAccessibilityTraits = 1024

    var UIAccessibilityTraitHeader: UIAccessibilityTraits = 2048

    var UIAccessibilityScreenChangedNotification: UIAccessibilityNotifications = 1000

    var UIAccessibilityLayoutChangedNotification: UIAccessibilityNotifications = 1001

    var UIAccessibilityAnnouncementNotification: UIAccessibilityNotifications = 1002

    var UIAccessibilityPageScrolledNotification: UIAccessibilityNotifications = 1003

    let UIAccessibilityVoiceOverStatusChanged: String = "UIAccessibilityVoiceOverStatusChanged"

        return false