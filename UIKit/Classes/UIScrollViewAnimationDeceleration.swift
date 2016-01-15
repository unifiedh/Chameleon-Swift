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

struct UIScrollViewAnimationDecelerationComponent {
	var decelerateTime: NSTimeInterval = 0
	var position: CGFloat = 0
	var velocity: CGFloat = 0
	var returnTime: NSTimeInterval = 0
	var returnFrom: CGFloat
	var bounced: Bool = false
};

class UIScrollViewAnimationDeceleration: UIScrollViewAnimation {
    convenience override init(scrollView sv: UIScrollView, velocity v: CGPoint) {
        if (self.init(scrollView: sv)) {
            self.lastMomentumTime = self.beginTime
            self.x.decelerateTime = self.beginTime
            self.x.velocity = ClampedVelocty(v.x)
            self.x.position = self.scrollView.contentOffset.x
            self.x.returnFrom = 0
            self.x.returnTime = 0
            self.x.bounced = false
            self.y.decelerateTime = self.beginTime
            self.y.velocity = ClampedVelocty(v.y)
            self.y.position = self.scrollView.contentOffset.y
            self.y.returnFrom = 0
            self.y.returnTime = 0
            self.y.bounced = false
            // if the velocity is 0, we're going to assume we just need to return it back to position immediately
            // this works around the case where the content was already at an edge and the user just flicked in
            // such a way that it should bounce a bit and return to the proper offset. not doing something like this
            // (along with the associated code in UIScrollView) results in crazy forces being applied in those cases.
            if x.velocity == 0 {
                self.x.bounced = true
                self.x.returnTime = self.beginTime
                self.x.returnFrom = x.position
            }
            if y.velocity == 0 {
                self.y.bounced = true
                self.y.returnTime = self.beginTime
                self.y.returnFrom = y.position
            }
        }
    }

    func momentumScrollBy(delta: CGPoint) {
        self.lastMomentumTime = NSDate.timeIntervalSinceReferenceDate()
        if !x.bounced {
            self.x.position += delta.x
            self.x.velocity = ClampedVelocty(delta.x / (lastMomentumTime - x.decelerateTime))
            self.x.decelerateTime = lastMomentumTime
        }
        if !y.bounced {
            self.y.position += delta.y
            self.y.velocity = ClampedVelocty(delta.y / (lastMomentumTime - y.decelerateTime))
            self.y.decelerateTime = lastMomentumTime
        }
    }
    var self.x: UIScrollViewAnimationDecelerationComponent
    var self.y: UIScrollViewAnimationDecelerationComponent
    var self.lastMomentumTime: NSTimeInterval


    func animate() -> Bool {
        let currentTime: NSTimeInterval = NSDate.timeIntervalSinceReferenceDate()
        let isFinishedWaitingForMomentumScroll: Bool = ((currentTime - lastMomentumTime) > 0.15)
        var finished: Bool = false
        while !finished && currentTime >= self.beginTime {
            var confinedOffset: CGPoint = self.scrollView._confinedContentOffset(CGPointMake(x.position, y.position))
            let verticalIsFinished: Bool = BounceComponent(self.beginTime, y, confinedOffset.y)
            let horizontalIsFinished: Bool = BounceComponent(self.beginTime, x, confinedOffset.x)
            finished = (verticalIsFinished && horizontalIsFinished && isFinishedWaitingForMomentumScroll)
            self.beginTime += physicsTimeStep
        }
        self.scrollView._setRestrainedContentOffset(CGPointMake(x.position, y.position))
        return finished
    }
}

/*
 I attempted to emulate 10.7's behavior here as best I could, however my physics-fu is weak.
 It doesn't feel quite right so it's possible this approach is vastly wrong, but it's decent
 for now, I suppose.
 
 I've noticed that while OSX appears to have a springy feel when you bounce into an edge, it
 will only spring out to the maximum and then snaps back to the resting position. In other words
 it appears that no matter how hard you throw the content at the edge, it will always spring out
 to some maximum (which appears to be based on how hard you've thrown it) and then quickly snaps
 back to the home position for that axis - it does not contniue bouncing like a proper spring
 might. So what I've tried to do here is emulate a kind of springy behavior right up until applying
 the spring's tension results in a sufficiently slow velocity. At that point I switch to a static
 animation which returns the content to its final resting place within a fixed time.
 
 Additionally, rather than attempt to emulate the correct momentum scrolling animation and perfectly
 match the friction and deceleration curves, I found a way to pass the OS' momentum scroll events
 into this animation as they occur by way of -momentumScrollBy:. What happens here is if the
 animation has started to bounce the content, it will then ignore changes coming from that method
 for the rest of its run. The idea is that once an edge has hit the wall, the animation will be
 in my hands from that point on so as to avoid feeding additional accelerations into the process and
 causing the bouncing to get out of hand. I had originally attempted to animate the momentum scrolling
 myself as well but I could never seem to match the feel of the system's momentum in terms of
 friction/deceleration-rate, etc. Again it is possible this isn't actually as hard as it seems to me,
 but my sadly terrible math abilities are failing me here. I guess I just don't know how to correctly
 frame this problem in my mind to acheive the results I wish I could achieve at the moment. Hopefully
 someone else who's better at this can come along and make it better somehow.
 
 There's another important reason that emulating my own momentum animation ran into trouble. On OSX
 if you flick to scroll and momentum is happening, the moment you place your fingers on the trackpad
 the momentum will stop. Without utterly changing how events are read in from OSX, I had no easy way
 note when the user simply placed their fingers on the trackpad and therefore had no easy way to
 cancel a momentum scrolling animation at that moment. The normal scrolling gesture isn't recognized
 until the user moves their fingers a bit. This resulted in a pretty terrible feeling where you could
 flick a bit and start a momentum scroll and then place your fingers on the trackpad to stop the scroll
 would not work. It was highly jarring. By passing the system's momentum events through instead, it
 solves the problem because the system intelligently will stop sending momentum scrolls the moment the
 user touches their fingers down again on the trackpad and thus we automatically stop receiving them.
 A timer on the animation keeps an eye out for future scroll events and if they don't appear within
 a short time, the animation is considered finished (assuming all bouncing is completed) and thus
 will end the deceleration sequence entirely and UIScrollView ends up sending the proper delegate
 messages, etc. New scrolls such as a new pan gesture will cancel the animation directly so things
 will proceed as expected in those situations.
 */

 // Emulates OS X's Springy Animation

    let minimumBounceVelocityBeforeReturning: CGFloat = 100

    let returnAnimationDuration: NSTimeInterval = 0.33

    let physicsTimeStep: NSTimeInterval = 1 / 120.0

    let springTightness: CGFloat = 7

    let springDampening: CGFloat = 15

        return (v < min) ? min : (v > max) ? max : v

        let V: CGFloat = 200
        return Clamp(v, -V, V)

        let d: CGFloat = position - restPosition
        return (-tightness * d) - (dampening * velocity)

        if c->bounced && c->returnTime != 0 {
            let returnBounceTime: NSTimeInterval = min(1, ((t - c->returnTime) / returnAnimationDuration))
            c->position = UIQuadraticEaseOut(returnBounceTime, c->returnFrom, to)
            return (returnBounceTime == 1)
        }
        else if fabs(to - c->position) > 0 {
            let F: CGFloat = Spring(c->velocity, c->position, to, springTightness, springDampening)
            c->velocity += F * physicsTimeStep
            c->position += c->velocity * physicsTimeStep
            c->bounced = true
            if fabsf(c->velocity) < minimumBounceVelocityBeforeReturning {
                c->returnFrom = c->position
                c->returnTime = t
            }
            return false
        }
        else {
            return true
        }