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

import WebKit

enum UIWebViewNavigationType : Int {
    case LinkClicked
    case FormSubmitted
    case BackForward
    case Reload
    case FormResubmitted
    case Other
}

protocol UIWebViewDelegate: NSObject {
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool

    func webView(aWebView: UIWebView, didFailLoadWithError error: NSError)

    func webViewDidFinishLoad(webView: UIWebView)
}
class UIWebView: UIView {
    func loadHTMLString(string: String, baseURL: NSURL) {
        webView.mainFrame().loadHTMLString(string, baseURL: baseURL)
    }

    func loadRequest(request: NSURLRequest) {
        if request != request {
            self.request = request
        }
        webView.mainFrame().loadRequest(request)
    }

    func stopLoading() {
        webView.stopLoading(self)
    }

    func reload() {
        webView.reload(self)
    }

    func goBack() {
        webView.goBack()
    }

    func goForward() {
        webView.goForward()
    }

    func stringByEvaluatingJavaScriptFromString(script: String) -> String {
        return webView.stringByEvaluatingJavaScriptFromString(script)!
    }
    weak var delegate: UIWebViewDelegate {
        get {
            return self.delegate
        }
        set {
            self.delegate = newDelegate
            self.delegateHas.shouldStartLoadWithRequest = delegate.respondsToSelector("webView:shouldStartLoadWithRequest:navigationType:")
            self.delegateHas.didFailLoadWithError = delegate.respondsToSelector("webView:didFailLoadWithError:")
            self.delegateHas.didFinishLoad = delegate.respondsToSelector("webViewDidFinishLoad:")
        }
    }

    var loading: Bool {
        get {
            return webView.isLoading()
        }
    }

    var canGoBack: Bool {
        get {
            return webView.canGoBack()
        }
    }

    var canGoForward: Bool {
        get {
            return webView.canGoForward()
        }
    }

    var scalesPageToFit: Bool {
        get {
            return false
        }
    }

    // not implemented
    var request: NSURLRequest {
        get {
            return self.request
        }
    }

    var dataDetectorTypes: UIDataDetectorTypes
    var scrollView: UIScrollView {
        get {
            return nil
        }
    }
    var self.webView: WebView
    var self.webViewAdapter: UIViewAdapter
    var self.delegateHas: struct{unsignedshouldStartLoadWithRequest:1;unsigneddidFailLoadWithError:1;unsigneddidFinishLoad:1;}


    convenience override init(frame: CGRect) {
        if (self.init(frame: frame)) {
            self.webView = WebView as! WebView(frame: NSRectFromCGRect(self.bounds))
            webView.autoresizingMask = (NSViewWidthSizable | NSViewHeightSizable)
            webView.policyDelegate = self
            webView.frameLoadDelegate = self
            webView.UIDelegate = self
            webView.drawsBackground = false
            self.webViewAdapter = UIViewAdapter(frame: self.bounds)
            self.webViewAdapter.NSView = webView
            self.webViewAdapter.scrollEnabled = false
            // WebView does its own scrolling :/
            self.addSubview(webViewAdapter)
        }
    }

    func dealloc() {
        webView.policyDelegate = nil
        webView.frameLoadDelegate = nil
        webView.UIDelegate = nil
    }

    func layoutSubviews() {
        super.layoutSubviews()
        self.webViewAdapter.frame = self.bounds
    }
    // The only reason this is here is because Flamingo currently tries a hack to get at the web view's internals UIScrollView to get
    // the desk ad view to stop stealing the scrollsToTop event. Lame, yes...

    convenience override init(key: String) {
        return nil
    }

    func webView(webView: WebView, decidePolicyForNavigationAction actionInformation: [NSObject : AnyObject], request: NSURLRequest, frame: WebFrame, decisionListener listener: WebPolicyDecisionListener) {
        var shouldStartLoad: Bool = false
        if delegateHas.shouldStartLoadWithRequest {
            var navTypeObject: AnyObject = (actionInformation[WebActionNavigationTypeKey] as! AnyObject)
            var navTypeCode: Int = CInt(navTypeObject)!
            var navType: UIWebViewNavigationType = .Other
            switch navTypeCode {
                case WebNavigationTypeLinkClicked:
                    navType = .LinkClicked
                case WebNavigationTypeFormSubmitted:
                    navType = .FormSubmitted
                case WebNavigationTypeBackForward:
                    navType = .BackForward
                case WebNavigationTypeReload:
                    navType = .Reload
                case WebNavigationTypeFormResubmitted:
                    navType = .FormResubmitted
            }

            shouldStartLoad = delegate.webView(self, shouldStartLoadWithRequest: request, navigationType: navType)
        }
        else {
            shouldStartLoad = true
        }
        if shouldStartLoad {
            listener.use()
        }
        else {
            listener.ignore()
        }
    }

    func webView(sender: WebView, didFinishLoadForFrame frame: WebFrame) {
        if delegateHas.didFinishLoad {
            delegate.webViewDidFinishLoad(self)
        }
        //    [_webViewAdapter becomeFirstResponder];
        //    [_webViewAdapter setNeedsDisplay];
    }

    func webView(sender: WebView, didFailLoadWithError error: NSError, forFrame frame: WebFrame) {
        if delegateHas.didFailLoadWithError {
            delegate.webView(self, didFailLoadWithError: error!)
        }
    }

    func webView(sender: WebView, makeFirstResponder responder: NSResponder) {
        webViewAdapter.NSView.window().makeFirstResponder(responder)
    }

    func webView(sender: WebView, contextMenuItemsForElement element: [NSObject : AnyObject], defaultMenuItems: [AnyObject]) -> [AnyObject] {
        return [AnyObject]()
    }

    func webViewIsResizable(sender: WebView) -> Bool {
        return false
    }

    func canBecomeFirstResponder() -> Bool {
        return true
    }

    func webView(sender: WebView, setFrame frame: NSRect) {
        // DO NOTHING to prevent WebView resize window
    }
}
