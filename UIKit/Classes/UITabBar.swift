//
//  UITabBar.h
//  UIKit
//
//  Created by Peter Steinberger on 23.03.11.
//
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

protocol UITabBarDelegate: NSObject {
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem)
    // stub

    func tabBar(tabBar: UITabBar, willBeginCustomizingItems items: [AnyObject])
    // called before customize sheet is shown. items is current item list

    func tabBar(tabBar: UITabBar, didBeginCustomizingItems items: [AnyObject])
    // called after customize sheet is shown. items is current item list

    func tabBar(tabBar: UITabBar, willEndCustomizingItems items: [AnyObject], changed: Bool)
    // called before customize sheet is hidden. items is new item list

    func tabBar(tabBar: UITabBar, didEndCustomizingItems items: [AnyObject], changed: Bool)
}
class UITabBar: UIView {
    func setItems(items: [AnyObject], animated: Bool) {
    }

    func beginCustomizingItems(items: [AnyObject]) {
    }

    func endCustomizingAnimated(animated: Bool) -> Bool {
        return true
    }

    func isCustomizing() -> Bool {
        return false
    }
    weak var delegate: UITabBarDelegate
    var items: [AnyObject]
    var selectedItem: UITabBarItem {
        get {
            if selectedItemIndex >= 0 {
                return items[selectedItemIndex]
            }
            return nil
        }
    }
    var self.selectedItemIndex: Int


    convenience override init(frame rect: CGRect) {
        if (self.init(frame: rect)) {
            rect.size.height = TABBAR_HEIGHT
            // tabbar is always fixed
            self.selectedItemIndex = -1
            var backgroundImage: UIImage = UIImage._popoverBackgroundImage()
            var backgroundView: UIImageView = UIImageView(image: backgroundImage)
            backgroundView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
            backgroundView.frame = rect
            self.addSubview(backgroundView)
        }
    }

    func description() -> String {
        return "<\(self.className()): \(self); selectedItem = \(self.selectedItem); items = \(self.items); delegate = \(self.delegate)>"
    }
}

import QuartzCore
let TABBAR_HEIGHT = 60.0