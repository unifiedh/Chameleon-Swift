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

let UIApplicationWillChangeStatusBarOrientationNotification: String = "UIApplicationWillChangeStatusBarOrientationNotification"

let UIApplicationDidChangeStatusBarOrientationNotification: String = "UIApplicationDidChangeStatusBarOrientationNotification"

let UIApplicationWillEnterForegroundNotification: String = "UIApplicationWillEnterForegroundNotification"

let UIApplicationWillTerminateNotification: String = "UIApplicationWillTerminateNotification"

let UIApplicationWillResignActiveNotification: String = "UIApplicationWillResignActiveNotification"

let UIApplicationDidEnterBackgroundNotification: String = "UIApplicationDidEnterBackgroundNotification"

let UIApplicationDidBecomeActiveNotification: String = "UIApplicationDidBecomeActiveNotification"

let UIApplicationDidFinishLaunchingNotification: String = "UIApplicationDidFinishLaunchingNotification"

let UIApplicationNetworkActivityIndicatorChangedNotification: String = "UIApplicationNetworkActivityIndicatorChangedNotification"

let UIApplicationLaunchOptionsURLKey: String = "UIApplicationLaunchOptionsURLKey"

let UIApplicationLaunchOptionsSourceApplicationKey: String = "UIApplicationLaunchOptionsSourceApplicationKey"

let UIApplicationLaunchOptionsRemoteNotificationKey: String = "UIApplicationLaunchOptionsRemoteNotificationKey"

let UIApplicationLaunchOptionsAnnotationKey: String = "UIApplicationLaunchOptionsAnnotationKey"

let UIApplicationLaunchOptionsLocalNotificationKey: String = "UIApplicationLaunchOptionsLocalNotificationKey"

let UIApplicationLaunchOptionsLocationKey: String = "UIApplicationLaunchOptionsLocationKey"

let UIApplicationDidReceiveMemoryWarningNotification: String = "UIApplicationDidReceiveMemoryWarningNotification"

let UITrackingRunLoopMode: String = "UITrackingRunLoopMode"

enum UIStatusBarStyle : Int {
    case Default
    case BlackTranslucent
    case BlackOpaque
}

enum UIStatusBarAnimation : Int {
    case None
    case Fade
    case Slide
}

enum UIInterfaceOrientation : Int {
    case Portrait = .Portrait
    case PortraitUpsideDown = .PortraitUpsideDown
    case LandscapeLeft = .LandscapeRight
    case LandscapeRight = .LandscapeLeft
}

enum .Mask : Int {
    case UIInterfaceOrientationMaskPortrait = (1 << .Portrait)
    case UIInterfaceOrientationMaskLandscapeLeft = (1 << .LandscapeLeft)
    case UIInterfaceOrientationMaskLandscapeRight = (1 << .LandscapeRight)
    case UIInterfaceOrientationMaskPortraitUpsideDown = (1 << .PortraitUpsideDown)
    case UIInterfaceOrientationMaskLandscape = ([.LandscapeLeft, .LandscapeRight])
    case UIInterfaceOrientationMaskAll = ([.Portrait, .LandscapeLeft, .LandscapeRight, .PortraitUpsideDown])
    case UIInterfaceOrientationMaskAllButUpsideDown = ([.Portrait, .LandscapeLeft, .LandscapeRight])
}

//#define UIInterfaceOrientationIsPortrait(orientation) \
        .Portrait || 
        (orientation) == .PortraitUpsideDown)

//#define UIInterfaceOrientationIsLandscape(orientation) \
        .LandscapeLeft || 
        (orientation) == .LandscapeRight)
        // push is not gonna work in mac os, unless you are apple (facetime)
enum UIRemoteNotificationType : Int {
        case None = 0
        case Badge = 1 << 0
        case Sound = 1 << 1
        case Alert = 1 << 2
        case NewsstandContentAvailability = 1 << 3
}
        // whenever the NSApplication is no longer "active" from OSX's point of view, your UIApplication instance
        // will switch to UIApplicationStateInactive. This happens when the app is no longer in the foreground, for instance.
        // chameleon will also switch to the inactive state when the screen is put to sleep due to power saving mode.
        // when the screen wakes up or the app is brought to the foreground, it is switched back to UIApplicationStateActive.
        // 
        // UIApplicationStateBackground is now supported and your app will transition to this state in two possible ways.
        // one is when the AppKitIntegration method -terminateApplicationBeforeDate: is called. that method is intended to be
        // used when your NSApplicationDelegate is being asked to terminate. the application is also switched to
        // UIApplicationStateBackground when the machine is put to sleep. when the machine is reawakened, it will transition
        // back to UIApplicationStateInactive (as per the UIKit docs). The OS tends to reactive the app in the usual way if
        // it happened to be the foreground app when the machine was put to sleep, so it should ultimately work out as expected.
        //
        // any registered background tasks are allowed to complete whenever the app switches into UIApplicationStateBackground
        // mode, so that means that when -terminateApplicationBeforeDate: is called directly, we will wait on background tasks
        // and also show an alert to the user letting them know what's happening. it also means we attempt to delay machine
        // sleep whenever sleep is initiated for as long as we can until any pending background tasks are completed. (there is no
        // alert in that case) this should allow your app time to do any of the usual things like sync with network services or
        // save state. just as on iOS, there's no guarentee you'll have time to complete you background task and there's no
        // guarentee that your expiration handler will even be called. additionally, the reliability of your network is certainly
        // going to be suspect when entering sleep as well. so be aware - but basically these same constraints exist on iOS so
        // in many respects it shouldn't affect your code much or at all.
enum UIApplicationState : Int {
        case Active
        case Inactive
        case Background
}
public typealias UIBackgroundTaskIdentifier = UInt
public let UIBackgroundTaskInvalid: UIBackgroundTaskIdentifier = UInt.max
public let UIMinimumKeepAliveTimeout: NSTimeInterval = 0

class UIApplication: UIResponder {
    class func sharedApplication() -> UIApplication {
        if !theApplication {
            self.theApplication = self()
        }
        return theApplication
    }

    func sendAction(action: Selector, to target: AnyObject, from sender: AnyObject, forEvent event: UIEvent) -> Bool {
        if !target {
            // The docs say this method will start with the first responder if target==nil. Initially I thought this meant that there was always a given
            // or set first responder (attached to the window, probably). However it doesn't appear that is the case. Instead it seems UIKit is perfectly
            // happy to function without ever having any UIResponder having had a becomeFirstResponder sent to it. This method seems to work by starting
            // with sender and traveling down the responder chain from there if target==nil. The first object that responds to the given action is sent
            // the message. (or no one is)
            // My confusion comes from the fact that motion events and keyboard events are supposed to start with the first responder - but what is that
            // if none was ever set? Apparently the answer is, if none were set, the message doesn't get delivered. If you expicitly set a UIResponder
            // using becomeFirstResponder, then it will receive keyboard/motion events but it does not receive any other messages from other views that
            // happen to end up calling this method with a nil target. So that's a seperate mechanism and I think it's confused a bit in the docs.
            // It seems that the reality of message delivery to "first responder" is that it depends a bit on the source. If the source is an external
            // event like motion or keyboard, then there has to have been an explicitly set first responder (by way of becomeFirstResponder) in order for
            // those events to even get delivered at all. If there is no responder defined, the action is simply never sent and thus never received.
            // This is entirely independent of what "first responder" means in the context of a UIControl. Instead, for a UIControl, the first responder
            // is the first UIResponder (including the UIControl itself) that responds to the action. It starts with the UIControl (sender) and not with
            // whatever UIResponder may have been set with becomeFirstResponder.
            var responder: AnyObject = sender
            while responder {
                if responder.respondsToSelector(action) {
                    target = responder
                }
                else if responder.respondsToSelector("nextResponder") {
                    responder = responder.nextResponder()
                }
                else {
                    responder = nil
                }
            }
        }
        if target != nil {
            Void(EventActionMethod)
            var method: EventActionMethod = target.methodForSelector(action) as! EventActionMethod
            method(target, action, sender, event)
            return true
        }
        return false
    }

    func sendEvent(event: UIEvent) {
        if event.type == .Touches {
            self.windows.makeObjectsPerformSelector("sendEvent:", withObject: event)
        }
        else {
            self.keyWindow.sendEvent(event)
        }
    }

    func openURL(url: NSURL) -> Bool {
        return url ? NSWorkspace.sharedWorkspace().openURL(url) : false
    }

    func canOpenURL(URL: NSURL) -> Bool {
    }

    func setStatusBarStyle(statusBarStyle: UIStatusBarStyle, animated: Bool) {
    }
    // no effect

    func setStatusBarHidden(hidden: Bool, withAnimation animation: UIStatusBarAnimation) {
    }

    func beginIgnoringInteractionEvents() {
        ignoringInteractionEvents++
    }

    func endIgnoringInteractionEvents() {
        ignoringInteractionEvents--
    }

    func isIgnoringInteractionEvents() -> Bool {
        return (ignoringInteractionEvents > 0)
    }

    func presentLocalNotificationNow(notification: UILocalNotification) {
    }

    func cancelLocalNotification(notification: UILocalNotification) {
    }

    func cancelAllLocalNotifications() {
    }

    func registerForRemoteNotificationTypes(types: UIRemoteNotificationType) {
    }

    func unregisterForRemoteNotifications() {
    }

    func enabledRemoteNotificationTypes() -> UIRemoteNotificationType {
        return .None
    }

    func beginBackgroundTaskWithExpirationHandler(handler: () -> Void) -> UIBackgroundTaskIdentifier {
        var task: UIBackgroundTask = UIBackgroundTask(expirationHandler: handler)
        backgroundTasks.append(task)
        return task.taskIdentifier
    }

    func endBackgroundTask(identifier: UIBackgroundTaskIdentifier) {
        for task: UIBackgroundTask in backgroundTasks {
            if task.taskIdentifier == identifier {
                backgroundTasks.removeObject(task)
            }
        }
    }
    weak var keyWindow: UIWindow {
        get {
            for window: UIWindow in self.windows {
                if window.isKeyWindow {
                    return window
                }
            }
            return nil
        }
    }

    var windows: [AnyObject] {
        get {
            var windows: [AnyObject] = [AnyObject]()
            for screen: UIScreen in UIScreen.screens() {
                windows.addObjectsFromArray(screen.windows)
            }
            return windows.sortedArrayUsingDescriptors([NSSortDescriptor(key: "windowLevel", ascending: true)])
        }
    }

    var statusBarHidden: Bool {
        get {
            return true
        }
    }

    var statusBarFrame: CGRect {
        get {
            return CGRectZero
        }
    }

    var networkActivityIndicatorVisible: Bool {
        get {
            return self.networkActivityIndicatorVisible
        }
        set {
            if b != self.isNetworkActivityIndicatorVisible() {
                self.networkActivityIndicatorVisible = b
                NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationNetworkActivityIndicatorChangedNotification, object: self)
            }
        }
    }

    // does nothing, always returns NO
    var statusBarOrientation: UIInterfaceOrientation {
        get {
            return .Portrait
        }
    }

    var statusBarOrientationAnimationDuration: NSTimeInterval {
        get {
            return 0.3
        }
    }

    weak var delegate: UIApplicationDelegate
    var idleTimerDisabled: Bool
    // has no actual affect
    var applicationSupportsShakeToEdit: Bool
    // no effect
    var statusBarStyle: UIStatusBarStyle {
        get {
            return .Default
        }
    }

    // always returns UIStatusBarStyleDefault
    var applicationState: UIApplicationState {
        get {
            return self.applicationState
        }
    }

    // see notes near UIApplicationState struct for details!
    var backgroundTimeRemaining: NSTimeInterval {
        get {
            return backgroundTasksExpirationDate.timeIntervalSinceNow()
        }
    }

    // always 0
    var applicationIconBadgeNumber: Int
    // no effect, but does set/get the number correctly
    var scheduledLocalNotifications: [AnyObject] {
        get {
            return nil
        }
    }
    var self.ignoringInteractionEvents: Int
    var self.backgroundTasksExpirationDate: NSDate
    var self.backgroundTasks: [AnyObject]


    convenience override init() {
        if (self.init()) {
            self.backgroundTasks = [AnyObject]()
            self.applicationState = .Active
            self.applicationSupportsShakeToEdit = true
            // yeah... not *really* true, but UIKit defaults to YES :)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "_applicationWillFinishLaunching:", name: NSApplicationWillFinishLaunchingNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "_applicationDidFinishLaunching:", name: NSApplicationDidFinishLaunchingNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "_applicationWillTerminate:", name: NSApplicationWillTerminateNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "_applicationWillResignActive:", name: NSApplicationWillResignActiveNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "_applicationDidBecomeActive:", name: NSApplicationDidBecomeActiveNotification, object: nil)
            NSWorkspace.sharedWorkspace().notificationCenter().addObserver(self, selector: "_applicationWillResignActive:", name: NSWorkspaceScreensDidSleepNotification, object: nil)
            NSWorkspace.sharedWorkspace().notificationCenter().addObserver(self, selector: "_applicationDidBecomeActive:", name: NSWorkspaceScreensDidWakeNotification, object: nil)
            NSWorkspace.sharedWorkspace().notificationCenter().addObserver(self, selector: "_computerWillSleep:", name: NSWorkspaceWillSleepNotification, object: nil)
            NSWorkspace.sharedWorkspace().notificationCenter().addObserver(self, selector: "_computerDidWakeUp:", name: NSWorkspaceDidWakeNotification, object: nil)
        }
    }

    func dealloc() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        NSWorkspace.sharedWorkspace().notificationCenter().removeObserver(self)
    }

    func _enterBackground() -> Bool {
        if self.applicationState != .Background {
            self.applicationState = .Background
            if delegate.respondsToSelector("applicationDidEnterBackground:") {
                delegate.applicationDidEnterBackground(self)
            }
            NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationDidEnterBackgroundNotification, object: self)
            return true
        }
        else {
            return false
        }
    }

    func _enterForeground() {
        if self.applicationState == .Background {
            if delegate.respondsToSelector("applicationWillEnterForeground:") {
                delegate.applicationWillEnterForeground(self)
            }
            NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationWillEnterForegroundNotification, object: self)
            self.applicationState = .Inactive
        }
    }

    func _runRunLoopForBackgroundTasksBeforeDate(date: NSDate) -> Bool {
        // check if all tasks were done, and if so, break
        if backgroundTasks.count == 0 {
            return false
        }
        // run the runloop in the default mode so things like connections and timers still work for processing our
        // background tasks. we'll make sure not to run this any longer than 1 second at a time, otherwise the alert
        // might hang around for a lot longer than is necessary since we might not have anything to run in the default
        // mode for awhile or something which would keep this method from returning.
        NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: date!)
        // otherwise check if we've timed out and if we are, break
        if NSDate().timeIntervalSinceReferenceDate() >= backgroundTasksExpirationDate.timeIntervalSinceReferenceDate() {
            return false
        }
        return true
    }

    func _cancelBackgroundTasks() {
        // if there's any remaining tasks, run their expiration handlers
        for task: UIBackgroundTask in backgroundTasks.copy() {
            if task.expirationHandler {
                task.expirationHandler()
            }
        }
        // remove any lingering tasks so we're back to being empty
        backgroundTasks.removeAllObjects()
    }

    func _runBackgroundTasks(run_tasks: () -> Void) {
        run_tasks()
    }

    func terminateApplicationBeforeDate(timeoutDate: NSDate) -> NSApplicationTerminateReply {
        self._enterBackground()
        self.backgroundTasksExpirationDate = timeoutDate
        // we will briefly block here for a short time and run the runloop in an attempt to let the background tasks finish up before
        // actually prompting the user with an annoying alert. users are much more used to an app hanging for a brief moment while
        // quitting than they are with an alert appearing/disappearing suddenly that they might have had trouble reading and processing
        // before it's gone. that sort of thing creates anxiety.
        var blockingBackgroundExpiration: NSDate = NSDate(timeIntervalSinceNow: 1.33)
        for ; ;  {
            if !self._runRunLoopForBackgroundTasksBeforeDate(blockingBackgroundExpiration) || NSDate.timeIntervalSinceReferenceDate() >= blockingBackgroundExpiration.timeIntervalSinceReferenceDate() {

            }
        }
        // if it turns out we're all done with tasks (or maybe had none to begin with), we'll clean up the structures
        // and tell our app we can terminate immediately now.
        if backgroundTasks.count == 0 {
            self._cancelBackgroundTasks()
            // and reset our timer since we're done
            self.backgroundTasksExpirationDate = nil
            // and return
            return NSTerminateNow
        }
        // otherwise... we have to do a deferred thing so we can show an alert while we wait for background tasks to finish...
        var taskFinisher = {() -> Void in
            var alert: NSAlert = NSAlert()
            alert.alertStyle = NSInformationalAlertStyle
            alert.showsSuppressionButton = false
            alert.messageText = "Quitting"
            alert.informativeText = "Finishing some tasks..."
            alert.addButtonWithTitle("Quit Now")
            alert.layout()
            // to avoid upsetting the user with an alert that flashes too quickly to read, we'll later artifically ensure that
            // the alert has been visible for at least some small amount of time to give them a chance to see and understand it.
            var minimumDisplayTime: NSDate = NSDate(timeIntervalSinceNow: 2.33)
            var session: NSModalSession = NSApp.beginModalSessionForWindow(alert.window)
            // run the runloop and wait for tasks to finish
            while NSApp.runModalSession(session) == NSRunContinuesResponse {
                if !self._runRunLoopForBackgroundTasksBeforeDate(NSDate(timeIntervalSinceNow: 0.1)) {

                }
            }
            // when we exit the runloop loop, then we're done with the tasks. either they are all finished or the time has run out
            // so we need to clean things up here as if we're all finished. if there's any remaining tasks, run their expiration handlers
            self._cancelBackgroundTasks()
            // and reset our timer since we're done
            self.backgroundTasksExpirationDate = nil
            // now just in case all of this happened too quickly and the user might not have had time to read and understand the alert,
            // we will kill some time for a bit as long as the alert is still visible. runModalSession: will not return NSRunContinuesResponse
            // if the user closed the alert, so in that case then this delay won't happen at all. however if the tasks finished too quickly
            // then what this does is kill time until the user clicks the quit button or the timer expires.
            while NSApp.runModalSession(session) == NSRunContinuesResponse {
                if NSDate.timeIntervalSinceReferenceDate() >= minimumDisplayTime.timeIntervalSinceReferenceDate() {

                }
            }
            NSApp.endModalSession(session)
            // tell the real NSApp we're all done here
            NSApp.replyToApplicationShouldTerminate(true)
        }
        // I need to delay this but run it on the main thread and also be able to run it in the panel run loop mode
        // because we're probably in that run loop mode due to how -applicationShouldTerminate: does things. I don't
        // know if I could do this same thing with a couple of simple GCD calls, but whatever, this works too. :)
        self.performSelectorOnMainThread("_runBackgroundTasks:", withObject: taskFinisher.copy(), waitUntilDone: false, modes: [NSModalPanelRunLoopMode, NSRunLoopCommonModes])
        return NSTerminateLater
    }

    func _computerWillSleep(note: NSNotification) {
        if self._enterBackground() {
            // docs say we have 30 seconds to return from our handler for the sleep notification, so we'll let background tasks
            // take up to 29 of them with the idea that hopefully this means that any cancelation handlers that might need to run
            // have a full second or so to finish up before we're forced to sleep.
            // since we can just block here we don't need to put the app into a modal state or popup a window or anything because
            // the machine is about to go to sleep.. so we'll just do things in a blocking way in this case while still handling
            // any pending background tasks.
            self.backgroundTasksExpirationDate = NSDate(timeIntervalSinceNow: 29)
            for ; ;  {
                if !self._runRunLoopForBackgroundTasksBeforeDate(backgroundTasksExpirationDate) {

                }
            }
            self._cancelBackgroundTasks()
            // and reset our timer since we're done
            self.backgroundTasksExpirationDate = nil
        }
    }

    func _computerDidWakeUp(note: NSNotification) {
        self._enterForeground()
    }

    func canOpenURL(url: NSURL) -> Bool {
        return (url ? NSWorkspace.sharedWorkspace()(URLForApplicationToOpenURL: url) : nil) != nil
    }

    func _applicationWillFinishLaunching(note: NSNotification) {
        var options: [NSObject : AnyObject]? = nil
        if delegate.respondsToSelector("application:willFinishLaunchingOnDesktopWithOptions:") {
            delegate.application(self, willFinishLaunchingOnDesktopWithOptions: options!)
        }
        if delegate.respondsToSelector("application:willFinishLaunchingWithOptions:") {
            delegate.application(self, willFinishLaunchingWithOptions: options!)
        }
    }

    func _applicationDidFinishLaunching(note: NSNotification) {
        var options: [NSObject : AnyObject]? = nil
        if delegate.respondsToSelector("application:didFinishLaunchingOnDesktopWithOptions:") {
            delegate.application(self, didFinishLaunchingOnDesktopWithOptions: options!)
        }
        if delegate.respondsToSelector("application:didFinishLaunchingWithOptions:") {
            delegate.application(self, didFinishLaunchingWithOptions: options!)
        }
        else if delegate.respondsToSelector("applicationDidFinishLaunching:") {
            delegate.applicationDidFinishLaunching(self)
        }

        NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationDidFinishLaunchingNotification, object: self)
    }

    func _applicationWillTerminate(note: NSNotification) {
        if delegate.respondsToSelector("applicationWillTerminateOnDesktop:") {
            delegate.applicationWillTerminateOnDesktop(self)
        }
        if delegate.respondsToSelector("applicationWillTerminate:") {
            delegate.applicationWillTerminate(self)
        }
        NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationWillTerminateNotification, object: self)
    }

    func _applicationWillResignActive(note: NSNotification) {
        if self.applicationState == .Active {
            if delegate.respondsToSelector("applicationWillResignActive:") {
                delegate.applicationWillResignActive(self)
            }
            NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationWillResignActiveNotification, object: self)
            self.applicationState = .Inactive
        }
    }

    func _applicationDidBecomeActive(note: NSNotification) {
        if self.applicationState == .Inactive {
            self.applicationState = .Active
            if delegate.respondsToSelector("applicationDidBecomeActive:") {
                delegate.applicationDidBecomeActive(self)
            }
            NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationDidBecomeActiveNotification, object: self)
        }
    }
    // this is only here because there's a real private API in Apple's UIKit that does something similar

    func _performMemoryWarning() {
        NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationDidReceiveMemoryWarningNotification, object: self)
    }
}
extension UIApplication {
    func setStatusBarHidden(hidden: Bool, animated: Bool) {
    }

    func setStatusBarHidden(hidden: Bool, animated: Bool) {
    }
}
// This can replace your call to NSApplicationMain. It does not implement NSApplicationMain exactly (and it never calls NSApplicationMain)
// so you should use this with some caution. It does *not* subclass NSApplication but does allow you to subclass UIApplication if you want,
// although that's not really tested so it probably wouldn't work very well. It sets NSApplication's delegate to a very simple dummy object
// which traps -applicationShouldTerminate: to handle background tasks so you don't have to bother with it. Like NSApplicationMain, this
// looks for a NIB file in the Info.plist identified by the NSMainNibFile key and will load it using AppKit's NIB loading stuff. In an
// attempt to make this as confusing as possible, when the main NIB is loaded, it uses the UIApplication (NOT THE NSApplication!) as the
// file's owner! Yep. Insane, I know. I generally do not use NIBs myself, but it's nice for the menu bar. So... yeah...
// NOTE: This does not use NSPrincipalClass from Info.plist since iOS doesn't either, so if that exists in your Info.plist, it is ignored.
    var UIApplicationMain: Int

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

import Cocoa



// correct?
    let UIMinimumKeepAliveTimeout: NSTimeInterval = 0

    var self.theApplication: UIApplication? = nil

                    var app: UIApplication = principalClassName ? NSClassFromString(principalClassName).sharedApplication() : UIApplication.sharedApplication()
            var delegate: UIApplicationDelegate = delegateClassName ? NSClassFromString(delegateClassName)() : nil
            app.delegate = delegate
            var infoDictionary: [NSObject : AnyObject] = NSBundle.mainBundle().infoDictionary!
            var mainNibName: String = (infoDictionary["NSMainNibFile"] as! String)
            var topLevelObjects: [AnyObject]? = nil
            var mainNib: NSNib = NSNib(nibNamed: mainNibName, bundle: NSBundle.mainBundle())
            mainNib.instantiateWithOwner(app, topLevelObjects: topLevelObjects!)
            var backgroundTaskCatchingDelegate: NSApplicationDelegate = UINSApplicationDelegate()
            NSApplication.sharedApplication().delegate = backgroundTaskCatchingDelegate
            NSApplication.sharedApplication().run()
            // the only purpose of this is to confuse ARC. I'm not sure how else to do it.
            // without this here, ARC thinks it can dealloc some stuff before we're really done
            // with it, and since we're never really going to be done with this stuff, it has to
            // be kept around as long as the app runs, but since the app never actually gets here
            // it will never be executed but this prevents ARC from preemptively releasing things.
            // meh.
            [app, delegate, topLevelObjects, backgroundTaskCatchingDelegate].count

        // this never happens
        return 0

        for screen: UIScreen in UIScreen.screens() {
            screen.UIKitView.sendStationaryTouches()
        }

        // the intent here was that there needed to be a way to force-cancel touches to somewhat replicate situations that
        // might arise on OSX that you could kinda/sorta pretend were phonecall-like events where you'd want a touch or
        // gesture or something to cancel. these situations come up when things like popovers and modal menus are presented,
        //
        // If the need arises, my intent here is to send a notification or something on the *next* runloop to all UIKitViews
        // attached to screens to tell them to kill off their current touch sequence (if any). It seems important that this
        // happen on the *next* runloop cycle and not immediately because there were cases where the touch cancelling would
        // happen in response to something like a touch ended event, so we can't just blindly cancel a touch while it's in
        // the process of being evalulated since that could lead to very inconsistent behavior and really weird edge cases.
        // by deferring the cancel, it would then be able to take the right action if the touch phase was something *other*
        // than ended or cancelled by the time it attemped cancellation.
        if !view {
            for screen: UIScreen in UIScreen.screens() {
                screen.UIKitView.performSelector("cancelTouchesInView:", withObject: nil, afterDelay: 0)
            }
        }
        else {
            view.window.screen.UIKitView.performSelector("cancelTouchesInView:", withObject: view, afterDelay: 0)
        }