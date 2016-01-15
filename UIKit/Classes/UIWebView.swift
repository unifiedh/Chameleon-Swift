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
import Cocoa

@objc public enum UIWebViewNavigationType : Int {
    case LinkClicked
    case FormSubmitted
    case BackForward
    case Reload
    case FormResubmitted
    case Other
}

@objc public protocol UIWebViewDelegate: NSObjectProtocol {
    optional func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool

    optional func webView(aWebView: UIWebView, didFailLoadWithError error: NSError)

    optional func webViewDidFinishLoad(webView: UIWebView)
}

public class UIWebView: UIView, WebPolicyDelegate, WebUIDelegate, WebFrameLoadDelegate {
    func loadHTMLString(string: String, baseURL: NSURL) {
        webView.mainFrame.loadHTMLString(string, baseURL: baseURL)
    }

    func loadRequest(request: NSURLRequest) {
        if self.request != request {
            self.request = request
        }
        webView.mainFrame.loadRequest(request)
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
	
    weak var delegate: UIWebViewDelegate?

    var loading: Bool {
        get {
            return webView.loading
        }
    }

    var canGoBack: Bool {
        get {
            return webView.canGoBack
        }
    }

    var canGoForward: Bool {
        get {
            return webView.canGoForward
        }
    }

	/// not implemented
    var scalesPageToFit: Bool {
        get {
            return false
        }
    }

    private(set) var request: NSURLRequest?

    var dataDetectorTypes: UIDataDetectorTypes
    var scrollView: UIScrollView? {
        get {
            return nil
        }
    }
    var webView: WebView
    var webViewAdapter: UIViewAdapter
    //var self.delegateHas: struct{unsignedshouldStartLoadWithRequest:1;unsigneddidFailLoadWithError:1;unsigneddidFinishLoad:1;}


    override init(frame: CGRect) {
            self.webView = WebView(frame: NSRectFromCGRect(self.bounds))
            webView.autoresizingMask = [.ViewWidthSizable, .ViewHeightSizable]
            webView.policyDelegate = self
            webView.frameLoadDelegate = self
            webView.UIDelegate = self
            webView.drawsBackground = false
            self.webViewAdapter = UIViewAdapter(frame: self.bounds)
            self.webViewAdapter.NSView = webView
            self.webViewAdapter.scrollEnabled = false
            // WebView does its own scrolling :/
            self.addSubview(webViewAdapter)
		super.init(frame: frame)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.webViewAdapter.frame = self.bounds
    }
    // The only reason this is here is because Flamingo currently tries a hack to get at the web view's internals UIScrollView to get
    // the desk ad view to stop stealing the scrollsToTop event. Lame, yes...

    convenience init?(key: String) {
        return nil
    }

    public func webView(webView: WebView, decidePolicyForNavigationAction actionInformation: [NSObject : AnyObject], request: NSURLRequest, frame: WebFrame, decisionListener listener: WebPolicyDecisionListener) {
        var shouldStartLoad: Bool = false
		if delegate?.webView as ((webView: UIWebView, shouldStartLoadWithRequest: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool)? == nil  {
            var navTypeObject = (actionInformation[WebActionNavigationTypeKey] as? Int) ?? 0
            var navTypeCode: WebNavigationType = WebNavigationType(rawValue: navTypeObject) ?? .Other
            var navType: UIWebViewNavigationType = .Other
            switch navTypeCode {
                case .LinkClicked:
                    navType = .LinkClicked
                case .FormSubmitted:
                    navType = .FormSubmitted
                case .BackForward:
                    navType = .BackForward
                case .Reload:
                    navType = .Reload
                case .FormResubmitted:
                    navType = .FormResubmitted
            }

            shouldStartLoad = delegate?.webView!(self, shouldStartLoadWithRequest: request, navigationType: navType) ?? false
        } else {
            shouldStartLoad = true
        }
        if shouldStartLoad {
            listener.use()
        } else {
            listener.ignore()
        }
    }

    public func webView(sender: WebView, didFinishLoadForFrame frame: WebFrame) {
		delegate?.webViewDidFinishLoad?(self)
        //    [_webViewAdapter becomeFirstResponder];
        //    [_webViewAdapter setNeedsDisplay];
    }

    public func webView(sender: WebView!, didFailLoadWithError error: NSError!, forFrame frame: WebFrame!) {
		delegate?.webView?(self, didFailLoadWithError: error)
    }

    public func webView(sender: WebView, makeFirstResponder responder: NSResponder) {
        webViewAdapter.NSView.window().makeFirstResponder(responder)
    }

    public func webView(sender: WebView, contextMenuItemsForElement element: [NSObject : AnyObject], defaultMenuItems: [AnyObject]) -> [AnyObject] {
        return []
    }

    public func webViewIsResizable(sender: WebView) -> Bool {
        return false
    }

    override func canBecomeFirstResponder() -> Bool {
        return true
    }

    public func webView(sender: WebView, setFrame frame: NSRect) {
        // DO NOTHING to prevent WebView resize window
    }
}

