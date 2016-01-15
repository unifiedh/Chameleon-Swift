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

enum UIViewAnimationGroupTransition : Int {
    case None
    case FlipFromLeft
    case FlipFromRight
    case CurlUp
    case CurlDown
    case FlipFromTop
    case FlipFromBottom
    case CrossDissolve
}

    var UIViewAnimationOptionIsSet: Bool = false

internal class UIViewAnimationGroup: NSObject {
    convenience override init(animationOptions options: UIViewAnimationOptions) {
        if (self.init()) {
            self.waitingAnimations = 1
            self.animationBeginTime = CACurrentMediaTime()
            self.animatingViews = NSMutableSet.setWithCapacity(2)
            self.duration = 0.2
            self.repeatCount = .IsSet(options, .Repeat) ? FLT_MAX : 0
            self.allowUserInteraction = .IsSet(options, .AllowUserInteraction)
            self.repeatAutoreverses = .IsSet(options, .Autoreverse)
            self.beginsFromCurrentState = .IsSet(options, .BeginFromCurrentState)
            let animationCurve: UIViewAnimationOptions = .Curve(options)
            if animationCurve == .CurveEaseIn {
                self.curve = .EaseIn
            }
            else if animationCurve == .CurveEaseOut {
                self.curve = .EaseOut
            }
            else if animationCurve == .CurveLinear {
                self.curve = .Linear
            }
            else {
                self.curve = .EaseInOut
            }

            let animationTransition: UIViewAnimationOptions = .Transition(options)
            if animationTransition == .TransitionFlipFromLeft {
                self.transition = .FlipFromLeft
            }
            else if animationTransition == .TransitionFlipFromRight {
                self.transition = .FlipFromRight
            }
            else if animationTransition == .TransitionCurlUp {
                self.transition = .CurlUp
            }
            else if animationTransition == .TransitionCurlDown {
                self.transition = .CurlDown
            }
            else if animationTransition == .TransitionCrossDissolve {
                self.transition = .CrossDissolve
            }
            else if animationTransition == .TransitionFlipFromTop {
                self.transition = .FlipFromTop
            }
            else if animationTransition == .TransitionFlipFromBottom {
                self.transition = .FlipFromBottom
            }
            else {
                self.transition = .None
            }
        }
    }

    convenience override init(view: UIView, forKey keyPath: String) {
                    animatingViews.append(view)

        if transitionView && self.transition != .None {
            return nil
        }
        else {
            var layer: CALayer = view.layer
            var animation: CABasicAnimation = CABasicAnimation(keyPath: keyPath)
            animation.fromValue = self.beginsFromCurrentState ? layer.presentationLayer[keyPath] : layer[keyPath]
            return self.addAnimation(animation)
        }
    }

    func setTransitionView(view: UIView, shouldCache cache: Bool) {
        self.transitionView = view
        self.transitionShouldCache = cache
    }

    func allAnimatingViews() -> [AnyObject] {
                    return animatingViews.allObjects()

    }
    var name: String
    var context: Void
    var completionBlock: Void
    var allowUserInteraction: Bool
    var beginsFromCurrentState: Bool
    var curve: UIViewAnimationCurve
    var delay: NSTimeInterval
    var delegate: AnyObject
    var didStopSelector: Selector
    var willStartSelector: Selector
    var duration: NSTimeInterval
    var repeatAutoreverses: Bool
    var repeatCount: Float
    var transition: UIViewAnimationGroupTransition

    func commit() {
        if transitionView && self.transition != .None {
            var trans: CATransition = CATransition()
            switch self.transition {
                case .FlipFromLeft:
                    trans.type = kCATransitionPush
                    trans.subtype = kCATransitionFromLeft
                case .FlipFromRight:
                    trans.type = kCATransitionPush
                    trans.subtype = kCATransitionFromRight
                case .FlipFromTop:
                    trans.type = kCATransitionPush
                    trans.subtype = kCATransitionFromTop
                case .FlipFromBottom:
                    trans.type = kCATransitionPush
                    trans.subtype = kCATransitionFromBottom
                case .CurlUp:
                    trans.type = kCATransitionReveal
                    trans.subtype = kCATransitionFromTop
                case .CurlDown:
                    trans.type = kCATransitionReveal
                    trans.subtype = kCATransitionFromBottom
                default:
                    trans.type = kCATransitionFade
            }

            animatingViews.append(transitionView)
            transitionView.layer.addAnimation(self.addAnimation(trans), forKey: kCATransition)
        }
        waitingAnimations--
        self.notifyAnimationsDidStopIfNeededUsingStatus(true)
    }
    var self.waitingAnimations: Int
    var self.didStart: Bool
    var self.animationBeginTime: CFTimeInterval
    var self.transitionView: UIView
    var self.transitionShouldCache: Bool
    var self.animatingViews: NSMutableSet


    class func initialize() {
        if self == UIViewAnimationGroup {
            runningAnimationGroups = NSMutableSet.setWithCapacity(1)
        }
    }

    func notifyAnimationsDidStartIfNeeded() {
        if !didStart {
            self.didStart = true
                            runningAnimationGroups!.append(self)

            if self.delegate.respondsToSelector(self.willStartSelector) {
                Void(WillStartMethod)
                var method: WillStartMethod = self.delegate.methodForSelector(self.willStartSelector) as! WillStartMethod
                method(self.delegate, self.willStartSelector, self.name, self.context)
            }
        }
    }

    func notifyAnimationsDidStopIfNeededUsingStatus(animationsDidFinish: Bool) {
        if waitingAnimations == 0 {
            if self.delegate.respondsToSelector(self.didStopSelector) {
                var finishedArgument: Int = Int(animationsDidFinish)
                Void(DidFinishMethod)
                var method: DidFinishMethod = self.delegate.methodForSelector(self.didStopSelector) as! DidFinishMethod
                method(self.delegate, self.didStopSelector, self.name, finishedArgument, self.context)
            }
            if self.completionBlock {
                self.completionBlock(animationsDidFinish)
            }
                            animatingViews.removeAllObjects()
                runningAnimationGroups!.removeObject(self)
        }
    }

    func animationDidStart(theAnimation: CAAnimation) {
        assert(NSThread.isMainThread(), "expecting this to be on the main thread")
        self.notifyAnimationsDidStartIfNeeded()
    }

    override func animationDidStop(theAnimation: CAAnimation, finished flag: Bool) {
        assert(NSThread.isMainThread(), "expecting this to be on the main thread")
        waitingAnimations--
        self.notifyAnimationsDidStopIfNeededUsingStatus(flag)
    }

    func addAnimation(animation: CAAnimation) -> CAAnimation {
        animation.timingFunction = CAMediaTimingFunctionFromUIViewAnimationCurve(self.curve)
        animation.duration = self.duration
        animation.beginTime = animationBeginTime + self.delay
        animation.repeatCount = self.repeatCount
        animation.autoreverses = self.repeatAutoreverses
        animation.fillMode = kCAFillModeBackwards
        animation.delegate = self
        animation.removedOnCompletion = true
        waitingAnimations++
        return animation
    }
}

import QuartzCore
    var runningAnimationGroups: NSMutableSet? = nil

        switch curve {
            case .EaseInOut:
                return CAMediaTimingFunction.functionWithName(kCAMediaTimingFunctionEaseInEaseOut)
            case .EaseIn:
                return CAMediaTimingFunction.functionWithName(kCAMediaTimingFunctionEaseIn)
            case .EaseOut:
                return CAMediaTimingFunction.functionWithName(kCAMediaTimingFunctionEaseOut)
            case .Linear:
                return CAMediaTimingFunction.functionWithName(kCAMediaTimingFunctionLinear)
        }

        return nil

        return ((options & option) == option)

        return (options & ([.CurveEaseInOut, .CurveEaseIn, .CurveEaseOut, .CurveLinear]))

        return (options & ([.TransitionNone, .TransitionFlipFromLeft, .TransitionFlipFromRight, .TransitionCurlUp, .TransitionCurlDown, .TransitionCrossDissolve, .TransitionFlipFromTop, .TransitionFlipFromBottom]))