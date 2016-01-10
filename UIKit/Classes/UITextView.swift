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

    let UITextViewTextDidBeginEditingNotification: String

    let UITextViewTextDidChangeNotification: String

    let UITextViewTextDidEndEditingNotification: String

protocol UITextViewDelegate: NSObject, UIScrollViewDelegate {
    func textViewShouldBeginEditing(textView: UITextView) -> Bool

    func textViewDidBeginEditing(textView: UITextView)

    func textViewShouldEndEditing(textView: UITextView) -> Bool

    func textViewDidEndEditing(textView: UITextView)

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool

    func textViewDidChange(textView: UITextView)

    func textViewDidChangeSelection(textView: UITextView)
}
class UITextView: UIScrollView, UITextInput {
    func scrollRangeToVisible(range: NSRange) {
        textLayer.scrollRangeToVisible(range)
    }

    func hasText() -> Bool {
        return textLayer.text!.characters.count > 0
    }
    var textAlignment: UITextAlignment {
        get {
            return textLayer.textAlignment
        }
        set {
            self.textLayer.textAlignment = textAlignment
        }
    }

    // stub, not yet implemented!
    var selectedRange: NSRange {
        get {
            return textLayer.selectedRange
        }
        set {
            self.textLayer.selectedRange = range
        }
    }

    var editable: Bool {
        get {
            return textLayer.editable
        }
        set {
            self.textLayer.editable = editable
        }
    }

    var text: String {
        get {
            return textLayer.text!
        }
        set {
            self.textLayer.text = newText
        }
    }

    var textColor: UIColor {
        get {
            return textLayer.textColor
        }
        set {
            self.textLayer.textColor = newColor
        }
    }

    var font: UIFont {
        get {
            return textLayer.font
        }
        set {
            self.textLayer.font = newFont
        }
    }

    var dataDetectorTypes: UIDataDetectorTypes
    weak var delegate: UITextViewDelegate {
        get {
            return self.delegate
        }
        set {
            if theDelegate != self.delegate {
                super.delegate = theDelegate
                self.delegateHas.shouldBeginEditing = theDelegate.respondsToSelector("textViewShouldBeginEditing:")
                self.delegateHas.didBeginEditing = theDelegate.respondsToSelector("textViewDidBeginEditing:")
                self.delegateHas.shouldEndEditing = theDelegate.respondsToSelector("textViewShouldEndEditing:")
                self.delegateHas.didEndEditing = theDelegate.respondsToSelector("textViewDidEndEditing:")
                self.delegateHas.shouldChangeText = theDelegate.respondsToSelector("textView:shouldChangeTextInRange:replacementText:")
                self.delegateHas.didChange = theDelegate.respondsToSelector("textViewDidChange:")
                self.delegateHas.didChangeSelection = theDelegate.respondsToSelector("textViewDidChangeSelection:")
            }
        }
    }

    var inputAccessoryView: UIView
    var inputView: UIView
    var self.textLayer: UITextLayer
    var self.delegateHas: struct{unsignedshouldBeginEditing:1;unsigneddidBeginEditing:1;unsignedshouldEndEditing:1;unsigneddidEndEditing:1;unsignedshouldChangeText:1;unsigneddidChange:1;unsigneddidChangeSelection:1;}


    convenience override init(frame: CGRect) {
        if (self.init(frame: frame)) {
            self.textLayer = UITextLayer(container: self, isField: false)
            self.layer.insertSublayer(textLayer, atIndex: 0)
            self.textColor = UIColor.blackColor()
            self.font = UIFont.systemFontOfSize(17)
            self.dataDetectorTypes = .All
            self.editable = true
            self.contentMode = .ScaleToFill
            self.clipsToBounds = true
        }
    }

    func dealloc() {
        textLayer.removeFromSuperlayer()
    }

    func layoutSubviews() {
        super.layoutSubviews()
        self.textLayer.frame = self.bounds
    }

    func setContentOffset(theOffset: CGPoint, animated: Bool) {
        super.setContentOffset(theOffset, animated: animated)
        textLayer.contentOffset = theOffset
    }

    func autocapitalizationType() -> UITextAutocapitalizationType {
        return .None
    }

    func setAutocapitalizationType(type: UITextAutocapitalizationType) {
    }

    func autocorrectionType() -> UITextAutocorrectionType {
        return .Default
    }

    func setAutocorrectionType(type: UITextAutocorrectionType) {
    }

    func enablesReturnKeyAutomatically() -> Bool {
        return true
    }

    func setEnablesReturnKeyAutomatically(enabled: Bool) {
    }

    func keyboardAppearance() -> UIKeyboardAppearance {
        return .Default
    }

    func setKeyboardAppearance(type: UIKeyboardAppearance) {
    }

    func keyboardType() -> UIKeyboardType {
        return .Default
    }

    func setKeyboardType(type: UIKeyboardType) {
    }

    func returnKeyType() -> UIReturnKeyType {
        return UIReturnKeyDefault
    }

    func setReturnKeyType(type: UIReturnKeyType) {
    }

    func isSecureTextEntry() -> Bool {
        return textLayer.isSecureTextEntry()
    }

    func setSecureTextEntry(secure: Bool) {
        textLayer.secureTextEntry = secure
    }

    func canBecomeFirstResponder() -> Bool {
        return (self.window != nil)
    }

    func becomeFirstResponder() -> Bool {
        if super.becomeFirstResponder() {
            return textLayer.becomeFirstResponder()
        }
        else {
            return false
        }
    }

    func resignFirstResponder() -> Bool {
        if super.resignFirstResponder() {
            return textLayer.resignFirstResponder()
        }
        else {
            return false
        }
    }

    func _textShouldBeginEditing() -> Bool {
        return delegateHas.shouldBeginEditing ? self.delegate.textViewShouldBeginEditing(self) : true
    }

    func _textDidBeginEditing() {
        if delegateHas.didBeginEditing {
            self.delegate.textViewDidBeginEditing(self)
        }
        NSNotificationCenter.defaultCenter().postNotificationName(UITextViewTextDidBeginEditingNotification, object: self)
    }

    func _textShouldEndEditing() -> Bool {
        return delegateHas.shouldEndEditing ? self.delegate.textViewShouldEndEditing(self) : true
    }

    func _textDidEndEditing() {
        if delegateHas.didEndEditing {
            self.delegate.textViewDidEndEditing(self)
        }
        NSNotificationCenter.defaultCenter().postNotificationName(UITextViewTextDidEndEditingNotification, object: self)
    }

    func _textShouldChangeTextInRange(range: NSRange, replacementText text: String) -> Bool {
        return delegateHas.shouldChangeText ? self.delegate.textView(self, shouldChangeTextInRange: range, replacementText: text) : true
    }

    func _textDidChange() {
        if delegateHas.didChange {
            self.delegate.textViewDidChange(self)
        }
        NSNotificationCenter.defaultCenter().postNotificationName(UITextViewTextDidChangeNotification, object: self)
    }

    func _textDidChangeSelection() {
        if delegateHas.didChangeSelection {
            self.delegate.textViewDidChangeSelection(self)
        }
    }

    func description() -> String {
        var textAlignment: String = ""
        switch self.textAlignment {
            case .Left:
                textAlignment = "Left"
            case .Center:
                textAlignment = "Center"
            case .Right:
                textAlignment = "Right"
        }

        return "<\(self.className()): \(self); textAlignment = \(textAlignment); selectedRange = \(NSStringFromRange(self.selectedRange)); editable = \(self.editable ? "YES" : "NO"); textColor = \(self.textColor); font = \(self.font); delegate = \(self.delegate)>"
    }

    convenience override init(event: UIEvent) {
        return self.editable ? NSCursor.IBeamCursor() : nil
    }

    func sizeThatFits(size: CGSize) -> CGSize {
        return textLayer.sizeThatFits(size)
    }

    override func setSelectedTextRange(range: UITextRange) {
    }

    func selectedTextRange() -> UITextRange {
        return nil
    }

    func beginningOfDocument() -> UITextRange {
        return nil
    }

    func endOfDocument() -> UITextPosition {
        return nil
    }

    func offsetFromPosition(fromPosition: UITextPosition, toPosition: UITextPosition) -> Int {
        return 0
    }

    func positionFromPosition(position: UITextPosition, offset: Int) -> UITextPosition {
        return nil
    }

    func textRangeFromPosition(fromPosition: UITextPosition, toPosition: UITextPosition) -> UITextRange {
        return nil
    }
}

import AppKit
    let UITextViewTextDidBeginEditingNotification: String = "UITextViewTextDidBeginEditingNotification"

    let UITextViewTextDidChangeNotification: String = "UITextViewTextDidChangeNotification"

    let UITextViewTextDidEndEditingNotification: String = "UITextViewTextDidEndEditingNotification"