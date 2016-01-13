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

import AppKit

    let UITextFieldTextDidBeginEditingNotification: String

    let UITextFieldTextDidChangeNotification: String

    let UITextFieldTextDidEndEditingNotification: String

enum UITextBorderStyle : Int {
    case None
    case Line
    case Bezel
    case RoundedRect
}

enum UITextFieldViewMode : Int {
    case Never
    case WhileEditing
    case UnlessEditing
    case Always
}

protocol UITextFieldDelegate: NSObject {
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool

    func textFieldDidBeginEditing(textField: UITextField)

    func textFieldShouldEndEditing(textField: UITextField) -> Bool

    func textFieldDidEndEditing(textField: UITextField)

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool

    func textFieldShouldClear(textField: UITextField) -> Bool

    func textFieldShouldReturn(textField: UITextField) -> Bool
}
class UITextField: UIControl, UITextInput {
    func borderRectForBounds(bounds: CGRect) -> CGRect {
        return bounds
    }

    func clearButtonRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectZero
    }

    func editingRectForBounds(bounds: CGRect) -> CGRect {
        return self.textRectForBounds(bounds)
    }

    func leftViewRectForBounds(bounds: CGRect) -> CGRect {
        if leftView != nil {
            let frame: CGRect = leftView.frame
            bounds.origin.x = 0
            bounds.origin.y = (bounds.size.height / 2.0) - (frame.size.height / 2.0)
            bounds.size = frame.size
            return CGRectIntegral(bounds)
        }
        else {
            return CGRectZero
        }
    }

    func placeholderRectForBounds(bounds: CGRect) -> CGRect {
        return self.textRectForBounds(bounds)
    }

    func rightViewRectForBounds(bounds: CGRect) -> CGRect {
        if rightView != nil {
            let frame: CGRect = rightView.frame
            bounds.origin.x = bounds.size.width - frame.size.width
            bounds.origin.y = (bounds.size.height / 2.0) - (frame.size.height / 2.0)
            bounds.size = frame.size
            return CGRectIntegral(bounds)
        }
        else {
            return CGRectZero
        }
    }

    func textRectForBounds(bounds: CGRect) -> CGRect {
        // Docs say:
        // The default implementation of this method returns a rectangle that is derived from the control’s original bounds,
        // but which does not include the area occupied by the receiver’s border or overlay views.
        // It appears what happens is something like this:
        // check border type:
        //   if no border, skip to next major step
        //   if has border, set textRect = borderBounds, then inset textRect according to border style
        // check if textRect overlaps with leftViewRect, if it does, make it smaller
        // check if textRect overlaps with rightViewRect, if it does, make it smaller
        // check if textRect overlaps with clearButtonRect (if currently needed?), if it does, make it smaller
        var textRect: CGRect = bounds
        if borderStyle != .None {
            textRect = self.borderRectForBounds(bounds)
            // TODO: inset the bounds based on border types...
        }
        // Going to go ahead and assume that the left view is on the left, the right view is on the right, and there's space between..
        // I imagine this is a dangerous assumption...
        if self._isLeftViewVisible() {
            var overlap: CGRect = CGRectIntersection(textRect, self.leftViewRectForBounds(bounds))
            if !CGRectIsNull(overlap) {
                textRect = CGRectOffset(textRect, overlap.size.width, 0)
                textRect.size.width -= overlap.size.width
            }
        }
        if self._isRightViewVisible() {
            var overlap: CGRect = CGRectIntersection(textRect, self.rightViewRectForBounds(bounds))
            if !CGRectIsNull(overlap) {
                textRect = CGRectOffset(textRect, -overlap.size.width, 0)
                textRect.size.width -= overlap.size.width
            }
        }
        return CGRectIntegral(bounds)
    }

    func drawPlaceholderInRect(rect: CGRect) {
    }

    func drawTextInRect(rect: CGRect) {
    }
    weak var delegate: UITextFieldDelegate {
        get {
            return self.delegate
        }
        set {
            if theDelegate != delegate {
                self.delegate = theDelegate
                self.delegateHas.shouldBeginEditing = delegate.respondsToSelector("textFieldShouldBeginEditing:")
                self.delegateHas.didBeginEditing = delegate.respondsToSelector("textFieldDidBeginEditing:")
                self.delegateHas.shouldEndEditing = delegate.respondsToSelector("textFieldShouldEndEditing:")
                self.delegateHas.didEndEditing = delegate.respondsToSelector("textFieldDidEndEditing:")
                self.delegateHas.shouldChangeCharacters = delegate.respondsToSelector("textField:shouldChangeCharactersInRange:replacementString:")
                self.delegateHas.shouldClear = delegate.respondsToSelector("textFieldShouldClear:")
                self.delegateHas.shouldReturn = delegate.respondsToSelector("textFieldShouldReturn:")
            }
        }
    }

    var textAlignment: UITextAlignment {
        get {
            return textLayer.textAlignment
        }
        set {
            self.textLayer.textAlignment = textAlignment
        }
    }

    var placeholder: String {
        get {
            return self.placeholder
        }
        set {
            if !(thePlaceholder == placeholder) {
                self.placeholder = thePlaceholder.copy()
                self.setNeedsDisplay()
            }
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

    var font: UIFont {
        get {
            return textLayer.font
        }
        set {
            self.textLayer.font = newFont
        }
    }

    var borderStyle: UITextBorderStyle {
        get {
            return self.borderStyle
        }
        set {
            if style != borderStyle {
                self.borderStyle = style
                self.setNeedsDisplay()
            }
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

    var editing: Bool {
        get {
            return self.editing
        }
    }

    var clearsOnBeginEditing: Bool
    var adjustsFontSizeToFitWidth: Bool
    var minimumFontSize: CGFloat
    var background: UIImage {
        get {
            return self.background
        }
        set {
            if aBackground != background {
                self.background = aBackground
                self.setNeedsDisplay()
            }
        }
    }

    var disabledBackground: UIImage {
        get {
            return self.disabledBackground
        }
        set {
            if aBackground != disabledBackground {
                self.disabledBackground = aBackground
                self.setNeedsDisplay()
            }
        }
    }

    var clearButtonMode: UITextFieldViewMode
    var leftView: UIView {
        get {
            return self.leftView
        }
        set {
            if leftView != leftView {
                leftView.removeFromSuperview()
                self.leftView = leftView
                self.addSubview(leftView)
            }
        }
    }

    var leftViewMode: UITextFieldViewMode
    var rightView: UIView {
        get {
            return self.rightView
        }
        set {
            if rightView != rightView {
                rightView.removeFromSuperview()
                self.rightView = rightView
                self.addSubview(rightView)
            }
        }
    }

    var rightViewMode: UITextFieldViewMode
    var inputAccessoryView: UIView
    var inputView: UIView
    var self.textLayer: UITextLayer
    var self.delegateHas: struct{unsignedshouldBeginEditing:1;unsigneddidBeginEditing:1;unsignedshouldEndEditing:1;unsigneddidEndEditing:1;unsignedshouldChangeCharacters:1;unsignedshouldClear:1;unsignedshouldReturn:1;}


    convenience override init(frame: CGRect) {
        if (self.init(frame: frame)) {
            self.textLayer = UITextLayer(container: self, isField: true)
            self.layer.insertSublayer(textLayer, atIndex: 0)
            self.textAlignment = .Left
            self.font = UIFont.systemFontOfSize(17)
            self.borderStyle = .None
            self.textColor = UIColor.blackColor()
            self.clearButtonMode = .Never
            self.leftViewMode = .Never
            self.rightViewMode = .Never
            self.opaque = false
        }
    }

    func dealloc() {
        textLayer.removeFromSuperlayer()
    }

    func _isLeftViewVisible() -> Bool {
        return leftView && (leftViewMode == .Always || (editing && leftViewMode == .WhileEditing) || (!editing && leftViewMode == .UnlessEditing))
    }

    func _isRightViewVisible() -> Bool {
        return rightView && (rightViewMode == .Always || (editing && rightViewMode == .WhileEditing) || (!editing && rightViewMode == .UnlessEditing))
    }

    func layoutSubviews() {
        super.layoutSubviews()
        let bounds: CGRect = self.bounds
        self.textLayer.frame = self.textRectForBounds(bounds)
        if self._isLeftViewVisible() {
            self.leftView.hidden = false
            self.leftView.frame = self.leftViewRectForBounds(bounds)
        }
        else {
            self.leftView.hidden = true
        }
        if self._isRightViewVisible() {
            self.rightView.hidden = false
            self.rightView.frame = self.rightViewRectForBounds(bounds)
        }
        else {
            self.rightView.hidden = true
        }
    }

    func setFrame(frame: CGRect) {
        if !CGRectEqualToRect(frame, self.frame) {
            super.frame = frame
            self.setNeedsDisplay()
        }
    }

    func drawRect(rect: CGRect) {
        var background: UIImage = self.enabled ? background : disabledBackground
        background.drawInRect(self.bounds)
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
        var result: Bool = super.becomeFirstResponder()
        if result && (result = textLayer.becomeFirstResponder()) {
            self._textDidBeginEditing()
        }
        return result
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
        return delegateHas.shouldBeginEditing ? delegate.textFieldShouldBeginEditing(self) : true
    }

    func _textDidBeginEditing() {
        var shouldClear: Bool = clearsOnBeginEditing
        if shouldClear && delegateHas.shouldClear {
            shouldClear = delegate.textFieldShouldClear(self)
        }
        if shouldClear {
            // this doesn't work - it can cause an exception to trigger. hrm...
            // so... rather than worry too much about it right now, just gonna delay it :P
            //self.text = @"";
            self.performSelector("setText:", withObject: "", afterDelay: 0)
        }
        self.editing = true
        self.setNeedsDisplay()
        self.setNeedsLayout()
        if delegateHas.didBeginEditing {
            delegate.textFieldDidBeginEditing(self)
        }
        NSNotificationCenter.defaultCenter().postNotificationName(UITextFieldTextDidBeginEditingNotification, object: self)
    }

    func _textShouldEndEditing() -> Bool {
        return delegateHas.shouldEndEditing ? delegate.textFieldShouldEndEditing(self) : true
    }

    func _textDidEndEditing() {
        self.editing = false
        self.setNeedsDisplay()
        self.setNeedsLayout()
        if delegateHas.didEndEditing {
            delegate.textFieldDidEndEditing(self)
        }
        NSNotificationCenter.defaultCenter().postNotificationName(UITextFieldTextDidEndEditingNotification, object: self)
    }

    func _textShouldChangeTextInRange(range: NSRange, replacementText text: String) -> Bool {
        return delegateHas.shouldChangeCharacters ? delegate.textField(self, shouldChangeCharactersInRange: range, replacementString: text) : true
    }

    func _textDidChange() {
        NSNotificationCenter.defaultCenter().postNotificationName(UITextFieldTextDidChangeNotification, object: self)
    }

    func _textDidReceiveReturnKey() {
        if delegateHas.shouldReturn {
            delegate.textFieldShouldReturn(self)
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

        return "<\(self.className()): \(self); textAlignment = \(textAlignment); editing = \(self.editing ? "YES" : "NO"); textColor = \(self.textColor); font = \(self.font); delegate = \(self.delegate)>"
    }

    convenience override init(event: UIEvent) {
        return NSCursor.IBeamCursor()
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
// for unknown reasons, Apple's UIKit actually declares this here (and not in UIView)
// the documentation makes it sound as if this only resigns text fields, but the comment
// in UIKit's actual UITextField header file indicates it may only care about first
// responder status, so that is how I will implement it
extension UIView {
    func endEditing(force: Bool) -> Bool {
        if self.isFirstResponder() {
            if force || self.canResignFirstResponder() {
                return self.resignFirstResponder()
            }
        }
        else {
            for view: UIView in self.subviews {
                if view.endEditing(force) {
                    return true
                }
            }
        }
        return false
    }
}

    let UITextFieldTextDidBeginEditingNotification: String = "UITextFieldTextDidBeginEditingNotification"

    let UITextFieldTextDidChangeNotification: String = "UITextFieldTextDidChangeNotification"

    let UITextFieldTextDidEndEditingNotification: String = "UITextFieldTextDidEndEditingNotification"