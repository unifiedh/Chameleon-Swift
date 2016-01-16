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
public class UINavigationItem: NSObject {
	init(title: String) {
		self.title = title
		super.init()
    }

    func setLeftBarButtonItem(item: UIBarButtonItem, animated: Bool) {
        if leftBarButtonItem !== item {
            self.leftBarButtonItem = item
            NSNotificationCenter.defaultCenter().postNotificationName(UINavigationItemDidChange, object: self)
        }
    }

    func setRightBarButtonItem(item: UIBarButtonItem, animated: Bool) {
        if rightBarButtonItem !== item {
            self.rightBarButtonItem = item
            NSNotificationCenter.defaultCenter().postNotificationName(UINavigationItemDidChange, object: self)
        }
    }

    func setHidesBackButton(hidesBackButton: Bool, animated: Bool) {
        if _hidesBackButton != hidesBackButton {
            _hidesBackButton = hidesBackButton
            NSNotificationCenter.defaultCenter().postNotificationName(UINavigationItemDidChange, object: self)
        }
    }
    var title: String {
        get {
            return self.title
        }
        set(title) {
            if !title.isEqual(title) {
                self.title = title
                NSNotificationCenter.defaultCenter().postNotificationName(UINavigationItemDidChange, object: self)
            }
        }
    }

    var prompt: String {
        get {
            return self.prompt
        }
        set(prompt) {
            if !prompt.isEqual(prompt) {
                self.prompt = prompt
                NSNotificationCenter.defaultCenter().postNotificationName(UINavigationItemDidChange, object: self)
            }
        }
    }

    var backBarButtonItem: UIBarButtonItem {
        get {
            return self.backBarButtonItem
        }
        set(backBarButtonItem) {
            if self.backBarButtonItem !== backBarButtonItem {
                self.backBarButtonItem = backBarButtonItem
                NSNotificationCenter.defaultCenter().postNotificationName(UINavigationItemDidChange, object: self)
            }
        }
    }

    var leftBarButtonItem: UIBarButtonItem {
        get {
            return self.leftBarButtonItem
        }
        set(item) {
            if leftBarButtonItem !== item {
                self.leftBarButtonItem = item
                NSNotificationCenter.defaultCenter().postNotificationName(UINavigationItemDidChange, object: self)
            }
        }
    }

    var rightBarButtonItem: UIBarButtonItem {
        get {
            return self.rightBarButtonItem
        }
        set(item) {
            if rightBarButtonItem !== item {
                self.rightBarButtonItem = item
                NSNotificationCenter.defaultCenter().postNotificationName(UINavigationItemDidChange, object: self)
            }
        }
    }

    weak var titleView: UIView? {
        get {
            return self.titleView
        }
        set(titleView) {
            if titleView !== titleView {
                self.titleView = titleView
                NSNotificationCenter.defaultCenter().postNotificationName(UINavigationItemDidChange, object: self)
            }
        }
    }

	
	
	private var _hidesBackButton: Bool = false
    var hidesBackButton: Bool {
        get {
            return _hidesBackButton
        }
        set(hidesBackButton) {
			self.setHidesBackButton(hidesBackButton, animated: false)
        }
    }

    func setLeftBarButtonItem(item: UIBarButtonItem) {
        self.setLeftBarButtonItem(item, animated: false)
    }

    func setRightBarButtonItem(item: UIBarButtonItem) {
        self.setRightBarButtonItem(item, animated: false)
    }
}


internal let UINavigationItemDidChange: String = "UINavigationItemDidChange"
