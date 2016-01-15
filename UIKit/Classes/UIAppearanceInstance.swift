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

extension NSObject {
    class func appearance() -> AnyObject {
        return self.appearanceWhenContainedIn(nil)
    }

    convenience init(containerClass: UIAppearanceContainer) {
        var appearanceRules: [NSObject : AnyObject] = objc_getAssociatedObject(self, UIAppearanceClassAssociatedObjectKey)
        if !appearanceRules {
            appearanceRules = [NSObject : AnyObject](minimumCapacity: 1)
            objc_setAssociatedObject(self, UIAppearanceClassAssociatedObjectKey, appearanceRules, .OBJC_ASSOCIATION_RETAIN)
        }
        var containmentPath: [AnyObject] = [AnyObject]()
        var args: va_list
        va_start(args, containerClass)
        for ; containerClass != nil; containerClass = {

        }
        args, AnyClass < UIAppearanceContainer > 
                    containmentPath.append(containerClass)

        va_end(args)
        var record: UIAppearanceProxy = (appearanceRules[containmentPath] as! UIAppearanceProxy)
        if !record {
            record = UIAppearanceProxy(class: self)
            appearanceRules[containmentPath] = record
        }
        return record
    }

    func _UIAppearanceContainer() -> AnyObject? {
        return nil
    }

    func _UIAppearancePropertyDidChange(property: AnyObject) {
        // note an overridden property value so we don't override it with a default value in -_UIAppearanceUpdateIfNeeded
        // this occurs when a value is set directly using a setter on an instance (such as "label.textColor = myColor;")
        var changedProperties: Set<AnyObject> = Set<AnyObject>.setWithSet(objc_getAssociatedObject(self, UIAppearanceChangedPropertiesKey))
        objc_setAssociatedObject(self, UIAppearanceChangedPropertiesKey, changedProperties.byAddingObject = property, OBJC_ASSOCIATION_RETAIN)
    }

    func _UIAppearanceUpdateIfNeeded() {
        // check if we are already up to date, if so, return early
        if objc_getAssociatedObject(self, UIAppearancePropertiesAreUpToDateKey) {
            return
        }
        // first go down our own class heirarchy until we find the root of the UIAppearance protocol
        // then we'll start at the bottom and work up while checking each class for all relevant rules
        // that apply to this instance at this time.
        var classes: [AnyObject] = UIAppearanceHierarchyForClass(self)
        var propertiesToSet: [NSObject : AnyObject] = [NSObject : AnyObject](minimumCapacity: 0)
        for klass: AnyClass in classes {
            var rules: [NSObject : AnyObject] = objc_getAssociatedObject(klass, UIAppearanceClassAssociatedObjectKey)
            // sorts the rule keys (which are arrays of classes) by length
            // if the lengths match, it sorts based on the last class being a superclass of the other or vice-versa
            // if the last classes aren't related at all, it marks them equal (I suspect these cases will always be filtered out in the next step)
            var sortedRulePaths: [AnyObject] = rules.allKeys().sortedArrayUsingComparator({(path1: [AnyObject], path2: [AnyObject]) -> NSComparisonResult in
                if path1.count == path2.count {
                    if (path2.lastObject() is path1.lastObject()) {
                        return NSOrderedAscending as! NSComparisonResult
                    }
                    else if (path1.lastObject() is path2.lastObject()) {
                        return NSOrderedDescending as! NSComparisonResult
                    }
                    else {
                        return NSOrderedSame as! NSComparisonResult
                    }
                }
                else if path1.count < path2.count {
                    return NSOrderedAscending as! NSComparisonResult
                }
                else {
                    return NSOrderedDescending as! NSComparisonResult
                }

            })
            // we should now have a list of classes to check for rule settings for this instance, so now we spin
            // through those and fetch the properties and values and add them to the dictionary of things to do.
            // before applying a rule's properties, we must make sure this instance is qualified, so we must check
            // this instance's container hierarchy against ever class that makes up the rule.
            for rule: [AnyObject] in sortedRulePaths {
                var shouldApplyRule: Bool = true
                for klass: AnyClass in rule.reverseObjectEnumerator() {
                    var container: AnyObject = self._UIAppearanceContainer()
                    while container && !(container is klass) {
                        container = container._UIAppearanceContainer()
                    }
                    if !container {
                        shouldApplyRule = false
                    }
                }
                if shouldApplyRule {
                    var proxy: UIAppearanceProxy = (rules[rule] as! UIAppearanceProxy)
                    propertiesToSet.addEntriesFromDictionary(proxy._appearancePropertiesAndValues())
                }
            }
        }
        // before setting the actual properties on the instance, save off a copy of the existing modified properties
        // because the act of setting the UIAppearance properties will end up messing with that set.
        // after we're done actually applying everything, reset the modified properties set to what it was before.
        var originalProperties = (objc_getAssociatedObject(self, UIAppearanceChangedPropertiesKey) as! NSSet) as Set<NSObject>
        // subtract any properties that have been overriden from the list to apply
        propertiesToSet.removeObjectsForKeys(originalProperties.allObjects())
        // now apply everything that's left
        for property: UIAppearanceProperty in propertiesToSet.allValues() {
            property.invokeUsingTarget(self)
        }
        // now reset our set of changes properties to the original set so we don't count the UIAppearance defaults as overrides
        objc_setAssociatedObject(self, UIAppearanceChangedPropertiesKey, originalProperties, .OBJC_ASSOCIATION_RETAIN)
        // done!
        objc_setAssociatedObject(self, UIAppearancePropertiesAreUpToDateKey, 1, .OBJC_ASSOCIATION_RETAIN)
    }

    func _UIAppearanceSetNeedsUpdate() {
        // this removes UIAppearancePropertiesAreUpToDateKey which will trigger _UIAppearanceUpdateIfNeeded to run (if it is called later)
        objc_setAssociatedObject(self, UIAppearancePropertiesAreUpToDateKey, nil, .OBJC_ASSOCIATION_RETAIN)
    }
}

    let UIAppearanceClassAssociatedObjectKey: String = "UIAppearanceClassAssociatedObjectKey"

    let UIAppearanceChangedPropertiesKey: String = "UIAppearanceChangedPropertiesKey"

    let UIAppearancePropertiesAreUpToDateKey: String = "UIAppearancePropertiesAreUpToDateKey"

        var classes: [AnyObject] = [AnyObject]()
        while klass as! AnyObject.conformsToProtocol() {
            classes.insertObject(klass, atIndex: 0)
            klass = klass.superclass()
        }
        return classes