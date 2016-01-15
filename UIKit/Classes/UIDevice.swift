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
import IOKit
import SystemConfiguration

public let UIDeviceOrientationDidChangeNotification: String = "UIDeviceOrientationDidChangeNotification"

public enum UIDeviceOrientation : Int {
    case Unknown
    case Portrait
    case PortraitUpsideDown
    case LandscapeLeft
    case LandscapeRight
    case FaceUp
    case FaceDown
}

public enum UIUserInterfaceIdiom : Int {
    case Phone
    case Pad
    case Desktop
}

public func UI_USER_INTERFACE_IDIOM() -> UIUserInterfaceIdiom {
    return UIDevice.currentDevice().userInterfaceIdiom
}

//#define UI_USER_INTERFACE_IDIOM() \
//        UIDevice.currentDevice().respondsToSelector("userInterfaceIdiom")
//        UIDevice.currentDevice().userInterfaceIdiom():\

public func UIDeviceOrientationIsPortrait(orientation: UIDeviceOrientation) -> Bool {
    return orientation == .Portrait || orientation == .PortraitUpsideDown
}

public func UIDeviceOrientationIsLandscape(orientation: UIDeviceOrientation) -> Bool {
    return orientation == .LandscapeLeft || orientation == .LandscapeRight
}

public class UIDevice: NSObject {
    public class func currentDevice() -> UIDevice {
        return theDevice
    }

    // no effect
    func beginGeneratingDeviceOrientationNotifications() {
    }

    // no effect
    func endGeneratingDeviceOrientationNotifications() {
    }
    
    public var name: String? {
        get {
            return SCDynamicStoreCopyComputerName(nil, nil) as? NSString as? String
        }
    }

    // default is UIUserInterfaceIdiomDesktop (obviously real UIKit doesn't allow setting this!)
    public private(set) var userInterfaceIdiom: UIUserInterfaceIdiom
    // always returns UIDeviceOrientationPortrait
    public var orientation: UIDeviceOrientation {
        get {
            return .Portrait
        }
    }

    // always returns YES
    public var multitaskingSupported: Bool {
        get {
            return true
        }
    }

    public var systemName: String {
        get {
            return NSProcessInfo.processInfo().operatingSystemName()
        }
    }

    public var systemVersion: String {
        get {
            return NSProcessInfo.processInfo().operatingSystemVersionString
        }
    }

    public var model: String {
        get {
            return "Mac"
        }
    }

    public var generatesDeviceOrientationNotifications: Bool {
        get {
            return false
        }
    }

    override init() {
            self.userInterfaceIdiom = .Desktop
    }
}

private var theDevice: UIDevice = UIDevice()
