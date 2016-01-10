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

class UIAppearanceProperty: NSObject {
    convenience override init(invocation setterInvocation: NSInvocation) {
        if (self.init()) {
            var methodSignature: NSMethodSignature = setterInvocation.methodSignature()
            self.invocation = NSInvocation.invocationWithMethodSignature(methodSignature)
            // we want to copy every argument except for target (which is argument 0)
            // so start at 1 and copy...
            for var i = 1; i < methodSignature.numberOfArguments(); i++ {
                let valueType: Character = methodSignature.getArgumentTypeAtIndex(i)
                var bufferSize: Int = 0
                NSGetSizeAndAlignment(valueType, bufferSize, nil)
                var valueBuffer: UInt8
                memset(valueBuffer, 0, bufferSize)
                setterInvocation.getArgument(valueBuffer, atIndex: i)
                invocation.setArgument(valueBuffer, atIndex: i)
            }
            // this is very important since we're caching this invocation!
            invocation.retainArguments()
        }
    }

    func invokeUsingTarget(target: AnyObject) {
        invocation.invokeWithTarget(target)
    }

    func setReturnValueForInvocation(getterInvocation: NSInvocation) {
        var methodSignature: NSMethodSignature = invocation.methodSignature()
        // ensure we have a value to return (which is expected to be at argument index 2)
        assert(methodSignature.numberOfArguments() >= 2, "stored invocation has no property value")
        // fetch and return the property value from our stored invocation
        let valueType: Character = methodSignature.getArgumentTypeAtIndex(2)
        var bufferSize: Int = 0
        NSGetSizeAndAlignment(valueType, bufferSize, nil)
        var valueBuffer: UInt8
        memset(valueBuffer, 0, bufferSize)
        invocation.getArgument(valueBuffer, atIndex: 2)
        // ensure the property value type's size matches the expected return value's size
        assert(bufferSize == getterInvocation.methodSignature().methodReturnLength(), "getter return length not equal to property value size")
        getterInvocation.returnValue = valueBuffer
    }
    var self.invocation: NSInvocation

}
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