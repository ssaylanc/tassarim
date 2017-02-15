//
//  WebViewController.swift
//  tassarim
//
//  Created by saylanc on 23/11/16.
//  Copyright © 2016 saylanc. All rights reserved.
//

import OAuthSwift

#if os(iOS)
    import UIKit
    typealias WebView = UIWebView // WKWebView
#elseif os(OSX)
    import AppKit
    import WebKit
    typealias WebView = WKWebView
#endif

class WebViewController: OAuthWebViewController {
    
    var targetURL : NSURL = NSURL()
    let webView : WebView = WebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if os(iOS)
            self.webView.frame = UIScreen.main.bounds
            self.webView.scalesPageToFit = true
            self.webView.delegate = self
            self.view.addSubview(self.webView)
            loadAddressURL()
        #elseif os(OSX)
            
            self.webView.frame = self.view.bounds
            self.webView.navigationDelegate = self
            self.webView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(self.webView)
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view":self.webView]))
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view":self.webView]))
        #endif
    }
    
    override func handle(_ url: URL) {
        targetURL = url as NSURL
        super.handle(url)
        
        loadAddressURL()
    }
    
    func loadAddressURL() {
        let req = URLRequest(url: targetURL as URL)
        self.webView.loadRequest(req)
    }
}

// MARK: delegate
#if os(iOS)
    extension WebViewController: UIWebViewDelegate {
        func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
            if let url = request.url, (url.scheme == "tassarim://oauth"){
                // Call here AppDelegate.sharedInstance.applicationHandleOpenURL(url) if necessary ie. if AppDelegate not configured to handle URL scheme
                // compare the url with your own custom provided one in `authorizeWithCallbackURL`
                self.dismissWebViewController()
            }
            return true
        }
    }
    
#elseif os(OSX)
    extension WebViewController: WKNavigationDelegate {
        
        func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
            
            // here we handle internally the callback url and call method that call handleOpenURL (not app scheme used)
            if let url = navigationAction.request.URL, url.scheme == "oauth-swift" {
                AppDelegate.sharedInstance.applicationHandleOpenURL(url)
                decisionHandler(.Cancel)
                
                self.dismissWebViewController()
                return
            }
            
            decisionHandler(.Allow)
        }
        
        /* override func  webView(webView: WebView!, decidePolicyForNavigationAction actionInformation: [NSObject : AnyObject]!, request: NSURLRequest!, frame: WebFrame!, decisionListener listener: WebPolicyDecisionListener!) {
         
         if request.URL?.scheme == "oauth-swift" {
         self.dismissWebViewController()
         }
         
         } */
    }
#endif


/*import UIKit

class WebViewController: UIViewController {

    var url: String!
    @IBOutlet weak var webView: UIWebView!
    
    @IBAction func closeButtonDidTouch(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let targetURL = NSURL(string: url)
        let request = NSURLRequest(URL: targetURL!)
        webView.loadRequest(request)
    }
   
    /*override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().statusBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        //It will show the status bar again after dismiss
        UIApplication.sharedApplication().statusBarHidden = false
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }*/
}*/
