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
    let UIDeviceOrientationDidChangeNotification: String

enum UIDeviceOrientation : Int {
    case Unknown
    case Portrait
    case PortraitUpsideDown
    case LandscapeLeft
    case LandscapeRight
    case FaceUp
    case FaceDown
}

enum UIUserInterfaceIdiom : Int {
    case Phone
    case Pad
    case Desktop
}

//#define UI_USER_INTERFACE_IDIOM() \
        UIDevice.currentDevice().respondsToSelector("userInterfaceIdiom")
        UIDevice.currentDevice().userInterfaceIdiom():\

//#define UIDeviceOrientationIsPortrait(orientation)  \
        .Portrait || 
        (orientation) == .PortraitUpsideDown)

//#define UIDeviceOrientationIsLandscape(orientation) \
        .LandscapeLeft || 
        (orientation) == .LandscapeRight)

class UIDevice: NSObject {
    class func currentDevice() -> UIDevice {
        return theDevice
    }

    func beginGeneratingDeviceOrientationNotifications() {
    }
    // no effect

    func endGeneratingDeviceOrientationNotifications() {
    }
    // no effect
    var name: String {
        get {
            return SCDynamicStoreCopyComputerName(nil, nil) as! __bridge_transfer NSString
        }
    }

    var userInterfaceIdiom: UIUserInterfaceIdiom
    // default is UIUserInterfaceIdiomDesktop (obviously real UIKit doesn't allow setting this!)
    var orientation: UIDeviceOrientation {
        get {
            return .Portrait
        }
    }

    // always returns UIDeviceOrientationPortrait
    var multitaskingSupported: Bool {
        get {
            return true
        }
    }

    // always returns YES
    var systemName: String {
        get {
            return NSProcessInfo.processInfo().operatingSystemName()
        }
    }

    var systemVersion: String {
        get {
            return NSProcessInfo.processInfo().operatingSystemVersionString()
        }
    }

    var model: String {
        get {
            return "Mac"
        }
    }

    var generatesDeviceOrientationNotifications: Bool {
        get {
            return false
        }
    }

    class func initialize() {
        if self == UIDevice {
            theDevice = UIDevice()
        }
    }

    convenience override init() {
        if (self.init()) {
            self.userInterfaceIdiom = .Desktop
        }
    }
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

import IOKit
import SystemConfiguration
    let UIDeviceOrientationDidChangeNotification: String = "UIDeviceOrientationDidChangeNotification"

    var theDevice: UIDevice