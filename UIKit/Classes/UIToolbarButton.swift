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

class UIToolbarButton: UIButton {
    convenience override init(barButtonItem item: UIBarButtonItem) {
        assert(item != nil, "bar button item must not be nil")
        var frame: CGRect = CGRectMake(0, 0, 24, 24)
        if (self.init(frame: frame)) {
            var image: UIImage? = nil
            var title: String? = nil
            if item->isSystemItem {
                switch item->systemItem {
                    case .Add:
                        image = UIImage._buttonBarSystemItemAdd()
                    case .Reply:
                        image = UIImage._buttonBarSystemItemReply()
                    default:
                        break
                }
            }
            else {
                image = item.image._toolbarImage()
                title = item.title
                if item.style == .Bordered {
                    self.titleLabel.font = UIFont.systemFontOfSize(11)
                    self.setBackgroundImage(UIImage._toolbarButtonImage(), forState: .Normal)
                    self.setBackgroundImage(UIImage._highlightedToolbarButtonImage(), forState: .Highlighted)
                    self.contentEdgeInsets = UIEdgeInsetsMake(0, 7, 0, 7)
                    self.titleEdgeInsets = UIEdgeInsetsMake(4, 0, 0, 0)
                    self.clipsToBounds = true
                    self.contentVerticalAlignment = .Top
                }
            }
            self.setImage(image!, forState: .Normal)
            self.setTitle(title!, forState: .Normal)
            self.addTarget(item.target, action: item.action, forControlEvents: .TouchUpInside)
            // resize the view to fit according to the rules, which appear to be that if the width is set directly in the item, use that
            // value, otherwise size to fit - but cap the total height, I guess?
            var fitToSize: CGSize = frame.size
            if item.width > 0 {
                frame.size.width = item.width
            }
            else {
                frame.size.width = self.sizeThatFits(fitToSize).width
            }
            self.frame = frame
        }
    }

    func backgroundRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, UIToolbarButtonInset)
    }

    func contentRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, UIToolbarButtonInset)
    }

    func sizeThatFits(fitSize: CGSize) -> CGSize {
        fitSize = super.sizeThatFits(fitSize)
        fitSize.width += UIToolbarButtonInset.left + UIToolbarButtonInset.right
        fitSize.height += UIToolbarButtonInset.top + UIToolbarButtonInset.bottom
        return fitSize
    }
}

// I don't like most of this... the real toolbar button lays things out different than a default button.
// It also seems to have some padding built into it around the whole thing (even the background)
// It centers images vertical and horizontal if not bordered, but it appears to be top-aligned if it's bordered
// If you specify both an image and a title, these buttons stack them vertically which is unlike default UIButton behavior
// This is all a pain in the ass and wrong, but good enough for now, I guess
    var UIToolbarButtonInset: UIEdgeInsets = UIEdgeInsets()
    UIToolbarButtonInset.0
    UIToolbarButtonInset.4
    UIToolbarButtonInset.0
    UIToolbarButtonInset.4