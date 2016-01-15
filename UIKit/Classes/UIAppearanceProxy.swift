/*
 * Copyright (c) 2012, The Iconfactory. All rights reserved.
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

class UIAppearanceProxy: NSObject {
    init(`class` k: UIAppearance) {
        self.targetClass = k
        self.settings = [NSObject : AnyObject]()
        super.init()
    }

    func _appearancePropertiesAndValues() -> [NSObject : AnyObject] {
        return settings
    }
    var targetClass: UIAppearance
    var settings: [NSObject : AnyObject]


    func forwardInvocation(anInvocation: NSInvocation) {
        // allowed selector formats:
        //  -set<Name>:forAxis:axis:axis:...
        //  -<name>ForAxis:axis:axis...
        //
        // the axis parts are optional.
        // property values must be one of these types: id, NSInteger, NSUInteger, CGFloat, CGPoint, CGSize, CGRect, UIEdgeInsets or UIOffset.
        // each axis must be either NSInteger or NSUInteger.
        // throw an exception if other types are used in an axis.
        var methodSignature: NSMethodSignature = anInvocation.methodSignature()
        var propertyKey: [AnyObject] = [AnyObject]()
        // see if this selector is a setter or a getter
        let isSetter: Bool = NSStringFromSelector(anInvocation.selector()).hasPrefix("set") && methodSignature.numberOfArguments() > 2 && strcmp(methodSignature.methodReturnType()) == 0
        let isGetter: Bool = !isSetter && strcmp(methodSignature.methodReturnType()) != 0
        // ensure that the property type is legit
        let propertyType: Character = isSetter ? methodSignature.getArgumentTypeAtIndex(2) : (isGetter ? methodSignature.methodReturnType() : nil)
        if !TypeIsPropertyType(propertyType) {
            NSException.exceptionWithName(NSInvalidArgumentException, reason: "property type must be id, NSInteger, NSUInteger, CGFloat, CGPoint, CGSize, CGRect, UIEdgeInsets or UIOffset", userInfo: nil)
        }
        // use axis arguments when building the unique key for this property
        let axisStartIndex: Int = isSetter ? 3 : 2
        for var i = axisStartIndex; i < methodSignature.numberOfArguments(); i++ {
            let type: Character = methodSignature.getArgumentTypeAtIndex(i)
            // ensure that the axis arguments are integers
            if !TypeIsIntegerType(type) {
                NSException.exceptionWithName(NSInvalidArgumentException, reason: "axis type must be NSInteger or NSUInteger", userInfo: nil)
            }
            var axisValue: Int = 0
            anInvocation.getArgument(axisValue, atIndex: i)
            propertyKey.append(axisValue)
        }
        if isGetter {
            // convert the getter's selector into a setter's selector since that's what we actually key the property value with
            var selectorKeyString: NSMutableString = NSStringFromSelector(anInvocation.selector()).mutableCopy()
            selectorKeyString.replaceCharactersInRange(NSMakeRange(0, 1), withString: selectorKeyString.substringToIndex(1).uppercaseString)
            selectorKeyString.insertString("set", atIndex: 0)
            // if the property has 1 or more axis parts, we need to take those into account, too
            if methodSignature.numberOfArguments() > 2 {
                let colonRange: NSRange = selectorKeyString.rangeOfString(":")
                let forRange: NSRange = selectorKeyString.rangeOfString("For")
                if colonRange.location != NSNotFound && forRange.location != NSNotFound && colonRange.location > NSMaxRange(forRange) {
                    let axisNameRange: NSRange = NSMakeRange(forRange.location + 3, colonRange.location - forRange.location - 3)
                    var axisName: String = selectorKeyString.substringWithRange(axisNameRange)
                    axisName = axisName.stringByReplacingCharactersInRange(NSMakeRange(0, 1), withString: axisName.substringToIndex(1).uppercaseString)
                    var axisSelectorPartName: String = "for\(axisName):"
                    selectorKeyString.insertString(axisSelectorPartName, atIndex: NSMaxRange(colonRange))
                    selectorKeyString.replaceCharactersInRange(NSMakeRange(forRange.location, colonRange.location - forRange.location), withString: "")
                }
            }
            else {
                selectorKeyString.appendString(":")
            }
            // finish building the property key now that we have the expected selector name
            propertyKey.append(selectorKeyString.copy())
            // fetch the current property value using the key and put it in the current invocation
            // so it can be returned to the caller
            var propertyValue: UIAppearanceProperty = (settings[propertyKey] as! UIAppearanceProperty)
            propertyValue.returnValueForInvocation = anInvocation
        }
        else if isSetter {
            var selectorString: String = NSStringFromSelector(anInvocation.selector())
            // finish building the property key using the selector we have
            propertyKey.append(selectorString)
            // save the actual property value using the key
            settings[propertyKey] = UIAppearanceProperty(invocation: anInvocation)
            // WARNING! Swizzling ahead!
            // what we're doing here is sneakily overriding the existing implemention with our own so we can track when the setter is called
            // and not have the appearance defaults override if a more local setting has been made.
            // the plan is to replace the class's original implementation of the setter with a custom one and save off the original IMP
            // so that we can call it later after doing what we need to do in the custom setter.
            // this checks to see if we've overriden the current setter for this class or not, and if not, we do so and store it off
            // in an associated dictionary that's attached to the class itself so we can get at it later from our setter.
            // I could not come up with a better way to do this and I have no idea how safe this really is at this point.
            // I wanted to insert a custom class a bit like how KVO apparently works, but it turns out most of the functions I need
            // for that are either deprecated or marked as "don't use" in the docs. :/ this is the best I could come up with given my
            // current knowledge of how everything works at this abstraction level. abandon all hope, ye who enter here...
            var methodOverrides: [NSObject : AnyObject] = objc_getAssociatedObject(targetClass, UIAppearanceSetterOverridesAssociatedObjectKey)
            if !methodOverrides {
                methodOverrides = [NSObject : AnyObject](minimumCapacity: 1)
                objc_setAssociatedObject(targetClass, UIAppearanceSetterOverridesAssociatedObjectKey, methodOverrides, OBJC_ASSOCIATION_RETAIN)
            }
            if !(methodOverrides[selectorString] as! String) {
                var method: Method = class_getInstanceMethod(targetClass, anInvocation.selector())
                if method != nil {
                    var implementation: IMP = method_getImplementation(method)
                    var overrideImplementation: IMP = ImplementationForPropertyType(methodSignature.getArgumentTypeAtIndex(2))
                    if implementation != overrideImplementation {
                        methodOverrides[selectorString] = NSValue(bytes: implementation, objCType: )
                        class_replaceMethod(targetClass, anInvocation.selector(), overrideImplementation, method_getTypeEncoding(method))
                    }
                }
            }
        }
        else {
            // derp
            self.doesNotRecognizeSelector(anInvocation.selector())
        }

    }

    func methodSignatureForSelector(aSelector: Selector) -> NSMethodSignature {
        return super.methodSignatureForSelector(aSelector) ?? targetClass as! AnyObject.instanceMethodSignatureForSelector(aSelector)
    }
}

let UIAppearanceSetterOverridesAssociatedObjectKey = "UIAppearanceSetterOverridesAssociatedObjectKey"
/*
        return (t != nil) && (strcmp(t) == 0 || strcmp(t) == 0 || strcmp(t) == 0 || strcmp(t) == 0 || strcmp(t) == 0)

        return (t != nil) && (strcmp(t) == 0 || strcmp(t) == 0 || strcmp(t) == 0 || strcmp(t) == 0 || strcmp(t) == 0)

        return (t != nil) && strcmp(t) == 0

        return (t != nil) && strcmp(t) == 0

        return (t != nil) && strcmp(t) == 0

        return (t != nil) && strcmp(t) == 0

        return (t != nil) && strcmp(t) == 0

        return (t != nil) && strcmp(t) == 0

        return (t != nil) && strcmp(t) == 0

        return TypeIsSignedInteger(t) || TypeIsUnsignedInteger(t)

        return TypeIsIntegerType(t) || TypeIsObject(t) || TypeIsCGFloat(t) || TypeIsCGPoint(t) || TypeIsCGSize(t) || TypeIsCGRect(t) || TypeIsUIEdgeInsets(t) || TypeIsUIOffset(t)

// fetches the original IMP for the method that we tucked away earlier (see down below) when we first registered
// an appearance setting for this class/property combo.

        var boxedMethodImp: NSValue? = nil
        var klass: AnyClass = self
        while klass && !boxedMethodImp {
            var overrides: [NSObject : AnyObject] = objc_getAssociatedObject(klass, UIAppearanceSetterOverridesAssociatedObjectKey)
            boxedMethodImp = (overrides[NSStringFromSelector(cmd)] as! String)
            klass = klass.superclass()
        }
        if boxedMethodImp && strcmp(boxedMethodImp!.objCType) == 0 {
            var imp: IMP
            boxedMethodImp!.getValue(imp)
            return imp
        }
        else {
            return nil
        }

// this function is used by the setter override to record which property with which axis values was set
// it then attaches that record to the *instance* (not the class!) so this information can be used later
// (currently in UIView) to intelligently apply the default UIAppearance rules without having them override
// settings that were set on the instance directly somewhere. this is how Apple's stuff works and that feature
// is the reason we have to go through all this trouble overriding stuff in the first place!

        var propertyKey: [AnyObject] = [AnyObject]()
        // IMPORTANT! Must build the property key the same way we do down in -forwardInvocation:
        for var i = 0; i < numberOfAxisValues; i++ {
            propertyKey.append(axisValues[i])
        }
        propertyKey.append(NSStringFromSelector(cmd))
        self._UIAppearancePropertyDidChange(propertyKey)

// this evil macro is used to generate type-specific setter overrides
// it currently only supports up to 4 axis values. if more are needed, just add more cases here following the pattern. easy!
//#define UIAppearanceSetterOverride(TYPE) \
        Void(SetterMethod)
        var imp: SetterMethod = GetOriginalMethodIMP(self, cmd) as! SetterMethod
        let numberOfAxisValues: Int = self.methodSignatureForSelector(cmd).numberOfArguments() - 3
        if imp && numberOfAxisValues >= 0 {
            var args: va_list
            va_start(args, property)
        }

        imp(self, cmd, property)

        axisValues[0] = va_arg(args, Int)
        imp(self, cmd, property, axisValues[0])

        axisValues[0] = va_arg(args, Int)
        axisValues[1] = va_arg(args, Int)
        imp(self, cmd, property, axisValues[0], axisValues[1])

        axisValues[0] = va_arg(args, Int)
        axisValues[1] = va_arg(args, Int)
        axisValues[2] = va_arg(args, Int)
        imp(self, cmd, property, axisValues[0], axisValues[1], axisValues[2])

        axisValues[0] = va_arg(args, Int)
        axisValues[1] = va_arg(args, Int)
        axisValues[2] = va_arg(args, Int)
        axisValues[3] = va_arg(args, Int)
        imp(self, cmd, property, axisValues[0], axisValues[1], axisValues[2], axisValues[3])

        (self, cmd, numberOfAxisValues, axisValues)
        va_end(args)

// curse you, static language!

        Character(Character())
        if TypeIsSignedInteger(t) {
            return UIAppearanceSetterOverride_NSInteger as! IMP
        }
        else if TypeIsUnsignedInteger(t) {
            return UIAppearanceSetterOverride_NSUInteger as! IMP
        }
        else if TypeIsObject(t) {
            return UIAppearanceSetterOverride_id as! IMP
        }
        else if TypeIsCGFloat(t) {
            return UIAppearanceSetterOverride_CGFloat as! IMP
        }
        else if TypeIsCGPoint(t) {
            return UIAppearanceSetterOverride_CGPoint as! IMP
        }
        else if TypeIsCGSize(t) {
            return UIAppearanceSetterOverride_CGSize as! IMP
        }
        else if TypeIsCGRect(t) {
            return UIAppearanceSetterOverride_CGRect as! IMP
        }
        else if TypeIsUIEdgeInsets(t) {
            return UIAppearanceSetterOverride_UIEdgeInsets as! IMP
        }
        else if TypeIsUIOffset(t) {
            return UIAppearanceSetterOverride_UIOffset as! IMP
        }
        else {
            NSException.exceptionWithName(NSInternalInconsistencyException, reason: "no setter implementation for property type", userInfo: nil)
        }
*/

