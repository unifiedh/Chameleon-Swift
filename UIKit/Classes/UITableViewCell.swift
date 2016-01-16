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

public enum UITableViewCellAccessoryType : Int {
    case None
    case DisclosureIndicator
    case DetailDisclosureButton
    case Checkmark
}

public enum UITableViewCellSeparatorStyle : Int {
    case None
    case SingleLine
    case SingleLineEtched
}

public enum UITableViewCellStyle : Int {
    case Default
    case Value1
    case Value2
    case Subtitle
}

public enum UITableViewCellSelectionStyle : Int {
    case None
    case Blue
    case Gray
}

public enum UITableViewCellEditingStyle : Int {
    case None
    case Delete
    case Insert
}

public class UITableViewCell: UIView {
    convenience init(style: UITableViewCellStyle, reuseIdentifier: String) {
            self.style = style
            self.reuseIdentifier = reuseIdentifier
		self.init(frame: CGRectMake(0, 0, 320, UITableViewDefaultRowHeight))
	}

    override func setSelected(selected: Bool, animated: Bool) {
        if selected != selected && selectionStyle != .None {
            self.selected = selected
            self._updateSelectionState()
        }
    }

    func setHighlighted(highlighted: Bool, animated: Bool) {
        if highlighted != highlighted && selectionStyle != .None {
            self.highlighted = highlighted
            self._updateSelectionState()
        }
    }

    func prepareForReuse() {
    }
	lazy var contentView: UIView = {
		var acontentView = UIView()
		self.addSubview(acontentView)
		self.layoutIfNeeded()

		return acontentView
	}()

	lazy var textLabel: UILabel = {
		let atextLabel = UILabel()
		atextLabel.backgroundColor = UIColor.clearColor()
		atextLabel.textColor = UIColor.blackColor()
		atextLabel.highlightedTextColor = UIColor.whiteColor()
		atextLabel.font = UIFont.boldSystemFontOfSize(17)
		self.contentView.addSubview(atextLabel)
		self.layoutIfNeeded()

		return atextLabel
	}()

    var detailTextLabel: UILabel {
        get {
            return self.detailTextLabel
        }
    }

	lazy var imageView: UIImageView = {
		let aimageView = UIImageView()
		aimageView.contentMode = .Center
		self.contentView.addSubview(aimageView)
		self.layoutIfNeeded()

		return aimageView
	}()

    var backgroundView: UIView {
        get {
            return self.backgroundView
        }
        set(theBackgroundView) {
            if theBackgroundView != backgroundView {
                backgroundView.removeFromSuperview()
                self.backgroundView = theBackgroundView
                self.addSubview(backgroundView)
                self.backgroundColor = UIColor.clearColor()
            }
        }
    }

    var selectedBackgroundView: UIView {
        get {
            return self.selectedBackgroundView
        }
        set(theSelectedBackgroundView) {
            if theSelectedBackgroundView != selectedBackgroundView {
                selectedBackgroundView.removeFromSuperview()
                self.selectedBackgroundView = theSelectedBackgroundView
                self.selectedBackgroundView.hidden = !selected
                self.addSubview(selectedBackgroundView)
            }
        }
    }

    var selectionStyle: UITableViewCellSelectionStyle
    var indentationLevel: Int
    var accessoryType: UITableViewCellAccessoryType
    var accessoryView: UIView?
    var editingAccessoryType: UITableViewCellAccessoryType
    var selected: Bool {
        get {
            return self.selected
        }
        set(selected) {
            if self.selected != selected && selectionStyle != .None {
                self.selected = selected
                self._updateSelectionState()
            }
        }
    }

    var highlighted: Bool {
        get {
            return self.highlighted
        }
        set(highlighted) {
            if highlighted != highlighted && selectionStyle != .None {
                self.highlighted = highlighted
                self._updateSelectionState()
            }
        }
    }

    var editing: Bool
    // not yet implemented
    private(set) var showingDeleteConfirmation: Bool

    // not yet implemented
    private(set) var reuseIdentifier: String = ""

    var indentationWidth: CGFloat
    var style: UITableViewCellStyle
    var seperatorView: UITableViewCellSeparator

	override init(frame: CGRect) {
		self.indentationWidth = 10
		self.style = .Default
		self.selectionStyle = .Blue
		self.seperatorView = UITableViewCellSeparator()
		self.addSubview(seperatorView)
		self.accessoryType = .None
		self.editingAccessoryType = .None
		super.init(frame: frame)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds: CGRect = self.bounds
        var showingSeperator: Bool = !seperatorView.hidden
        var contentFrame: CGRect = CGRectMake(0, 0, bounds.size.width, bounds.size.height - (showingSeperator ? 1 : 0))
        var accessoryRect: CGRect = CGRectMake(bounds.size.width, 0, 0, 0)
        if let accessoryView = accessoryView {
            accessoryRect.size = accessoryView.sizeThatFits(bounds.size)
            accessoryRect.origin.x = bounds.size.width - accessoryRect.size.width
            accessoryRect.origin.y = round(0.5 * (bounds.size.height - accessoryRect.size.height))
            accessoryView.frame = accessoryRect
            self.addSubview(accessoryView)
            contentFrame.size.width = accessoryRect.origin.x - 1
        }
        self.backgroundView.frame = contentFrame
        self.selectedBackgroundView.frame = contentFrame
        self.contentView.frame = contentFrame
        self.sendSubviewToBack(selectedBackgroundView)
        self.sendSubviewToBack(backgroundView)
        self.bringSubviewToFront(contentView)
        self.bringSubviewToFront(accessoryView!)
        if showingSeperator {
            self.seperatorView.frame = CGRectMake(0, bounds.size.height - 1, bounds.size.width, 1)
            self.bringSubviewToFront(seperatorView)
        }
        if style == .Default {
            let padding: CGFloat = 5
            let showImage: Bool = (imageView.image != nil)
            let imageWidth: CGFloat = (showImage ? 30 : 0)
            self.imageView.frame = CGRectMake(padding, 0, imageWidth, contentFrame.size.height)
            var textRect: CGRect
            textRect.origin = CGPointMake(padding + imageWidth + padding, 0)
            textRect.size = CGSizeMake(max(0, contentFrame.size.width - textRect.origin.x - padding), contentFrame.size.height)
            self.textLabel.frame = textRect
        }
    }

    func _setSeparatorStyle(theStyle: UITableViewCellSeparatorStyle, color theColor: UIColor) {
        seperatorView.setSeparatorStyle(theStyle, color: theColor)
    }

    func _setHighlighted(highlighted: Bool, forViews subviews: AnyObject) {
        for view: AnyObject in subviews {
            if view.respondsToSelector("setHighlighted:") {
                view.highlighted = highlighted
            }
            self._setHighlighted(highlighted, forViews: view.subviews)
        }
    }

    func _updateSelectionState() {
        var shouldHighlight: Bool = (highlighted || selected)
        self.selectedBackgroundView.hidden = !shouldHighlight
        self._setHighlighted(shouldHighlight, forViews: self.subviews)
    }

    override func setSelected(selected: Bool) {
        self.setSelected(selected, animated: false)
    }

    func setHighlighted(highlighted: Bool) {
        self.setHighlighted(highlighted, animated: false)
    }
}


//var _UITableViewDefaultRowHeight: CGFloat
