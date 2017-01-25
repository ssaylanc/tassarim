//
//  ViewController.swift
//  OAuthSwift
//
//  Created by Dongri Jin on 6/21/14.
//  Copyright (c) 2014 Dongri Jin. All rights reserved.
//

import OAuthSwift

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

class ViewController: OAuthViewController {
    // oauth swift object (retain)
    var oauthswift: OAuthSwift?
    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var logoWidth: NSLayoutConstraint!
    @IBOutlet weak var logoBottom: NSLayoutConstraint!
    @IBOutlet weak var logoHeight: NSLayoutConstraint!
    @IBAction func signInButtonDidTouch(sender: AnyObject) {
        doOAuthDribbble()
    }
    
    
    var currentParameters = [String: String]()
    lazy var internalWebViewController: WebViewController = {
        let controller = WebViewController()
        #if os(OSX)
            controller.view = NSView(frame: NSRect(x:0, y:0, width: 450, height: 500)) // needed if no nib or not loaded from storyboard
        #elseif os(iOS)
            controller.view = UIView(frame: UIScreen.mainScreen().bounds) // needed if no nib or not loaded from storyboard
        #endif
        controller.delegate = self
        controller.viewDidLoad()
        return controller
    }()
    
}

extension ViewController: OAuthWebViewControllerDelegate {
    #if os(iOS) || os(tvOS)
    
    func oauthWebViewControllerDidPresent() {
        
    }
    func oauthWebViewControllerDidDismiss() {
        
    }
    #endif
    
    func oauthWebViewControllerWillAppear() {
        
    }
    func oauthWebViewControllerDidAppear() {
        
    }
    func oauthWebViewControllerWillDisappear() {
        
    }
    func oauthWebViewControllerDidDisappear() {
        // Ensure all listeners are removed if presented web view close
        oauthswift?.cancel()
    }
}

extension ViewController {
    
    // MARK: Dribbble
    func doOAuthDribbble(){
        let state: String = generateStateWithLength(20) as String
        let oauthswift = OAuth2Swift(
            consumerKey:    "your Consumer Key",
            consumerSecret: "your Consumer Secret",
            authorizeUrl:   "https://dribbble.com/oauth/authorize",
            accessTokenUrl: "https://dribbble.com/oauth/token",
            responseType:   "code"
        )
        self.oauthswift = oauthswift
        oauthswift.authorize_url_handler = get_url_handler()
        oauthswift.authorizeWithCallbackURL( NSURL(string: "your URL")!, scope: "public+write", state: state, success: {
            credential, response, parameters in
            KeychainHelper.save ("dribbble_access_token", data: KeychainHelper.stringToNSDATA(credential.oauth_token) )
            self.internalWebViewController.dismissViewControllerAnimated(false, completion: nil)
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                self.performSegueWithIdentifier("SignedInSegue", sender: self)
            }
            
            }, failure: {(error:NSError!) -> Void in
                print(error.localizedDescription)

        })
    }
}

let DocumentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
let FileManager: NSFileManager = NSFileManager.defaultManager()

extension ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("sedar\(UIDevice().type)")
        switch UIDevice().type {
        case .iPhone4:
            self.logoWidth.constant = 100
            self.logoHeight.constant = 100
            self.logoBottom.constant = 20
        case .iPhone4S:
            self.logoView.frame.size.width = 100
            self.logoView.frame.size.height = 100
            self.logoBottom.constant = 20
        case .simulator:
             self.logoWidth.constant = 150
             self.logoHeight.constant = 150
             self.logoBottom.constant = 20
        default: break
            
        }
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        
        self.navigationController?.navigationBar.translucent = true
        // init now web view handler
        internalWebViewController.webView
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let data = KeychainHelper.load("dribbble_access_token")
        var token: String = ""
        print("data: \(data)")
        
        if data != nil {
            token = KeychainHelper.NSDATAtoString(data!)
        }
        
        if token.isEmpty == true {
            //self.doOAuthDribbble()
        }
        else {
            self.performSegueWithIdentifier("SignedInSegue", sender: self)
            /*let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
             let shotsVC = mainStoryBoard.instantiateViewControllerWithIdentifier("ShotsVC")
             self.presentViewController(shotsVC, animated: true, completion: nil)*/
        }
    }

    
    // MARK: utility methods
    
    var confPath: String {
        let appPath = "\(DocumentDirectory)/.oauth/"
        if !FileManager.fileExistsAtPath(appPath) {
            do {
                try FileManager.createDirectoryAtPath(appPath, withIntermediateDirectories: false, attributes: nil)
            }catch {
                print("Failed to create \(appPath)")
            }
        }
        return "\(appPath)Services.plist"
    }
    
    func snapshot() -> NSData {
        #if os(iOS)
            UIGraphicsBeginImageContext(self.view.frame.size)
            self.view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
            let fullScreenshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            UIImageWriteToSavedPhotosAlbum(fullScreenshot, nil, nil, nil)
            return  UIImageJPEGRepresentation(fullScreenshot, 0.5)!
        #elseif os(OSX)
            let rep: NSBitmapImageRep = self.view.bitmapImageRepForCachingDisplayInRect(self.view.bounds)!
            self.view.cacheDisplayInRect(self.view.bounds, toBitmapImageRep:rep)
            return rep.TIFFRepresentation!
        #endif
    }
    
    func showAlertView(title: String, message: String) {
        #if os(iOS)
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        #elseif os(OSX)
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = message
            alert.addButtonWithTitle("Close")
            alert.runModal()
        #endif
    }
    
    func showTokenAlert(name: String?, credential: OAuthSwiftCredential) {
        var message = "oauth_token:\(credential.oauth_token)"
        if !credential.oauth_token_secret.isEmpty {
            message += "\n\noauth_toke_secret:\(credential.oauth_token_secret)"
        }
        self.showAlertView(name ?? "Service", message: message)
    }
    
    // MARK: handler
    
    func get_url_handler() -> OAuthSwiftURLHandlerType {
        let url_handler = internalWebViewController
        self.addChildViewController(url_handler) // allow WebViewController to use this ViewController as parent to be presented
        return url_handler

        /*guard let type = self.formData.data?.handlerType else {
            return OAuthSwiftOpenURLExternally.sharedInstance
        }
        switch type {
        case .External :
            return OAuthSwiftOpenURLExternally.sharedInstance
        case .Internal:
            let url_handler = internalWebViewController
            self.addChildViewController(url_handler) // allow WebViewController to use this ViewController as parent to be presented
            return url_handler
        case .Safari:
            #if os(iOS)
                if #available(iOS 9.0, *) {
                    let handler = SafariURLHandler(viewController: self, oauthSwift: self.oauthswift!)
                    handler.presentCompletion = {
                        print("Safari presented")
                    }
                    handler.dismissCompletion = {
                        print("Safari dismissed")
                    }
                    return handler
                }
            #endif
            return OAuthSwiftOpenURLExternally.sharedInstance
        }
        
        #if os(OSX)
            // a better way is
            // - to make this ViewController implement OAuthSwiftURLHandlerType and assigned in oauthswift object
            /* return self */
            // - have an instance of WebViewController here (I) or a segue name to launch (S)
            // - in handle(url)
            //    (I) : affect url to WebViewController, and  self.presentViewControllerAsModalWindow(self.webViewController)
            //    (S) : affect url to a temp variable (ex: urlForWebView), then perform segue
            /* performSegueWithIdentifier("oauthwebview", sender:nil) */
            //         then override prepareForSegue() to affect url to destination controller WebViewController
            
        #endif*/
    }
    //(I)
    //let webViewController: WebViewController = internalWebViewController
    //(S)
    //var urlForWebView:?NSURL = nil
    
    // Little class to dispatch async (could use framework like Eki or swift 3 DispatchQueue)
    enum Queue {
        case Main, Background
        
        var queue: dispatch_queue_t {
            switch self {
            case .Main:
                return dispatch_get_main_queue()
            case .Background:
                return dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
            }
        }
        func async(block: () -> Void) {
            dispatch_async(self.queue) {
                block()
            }
        }
    }
    
}

// MARK: - Table
/*extension ViewController: FormViewControllerDelegate {
    
    var key: String? { return self.currentParameters["consumerKey"] }
    var secret: String? {return self.currentParameters["consumerSecret"] }
    
    func didValidate(key: String?, secret: String?, handlerType: URLHandlerType) {
        self.dismissForm()
        
        self.formData.publish(FormViewControllerData(key: key ?? "", secret: secret ?? "", handlerType: handlerType))
    }
    
    func didCancel() {
        self.dismissForm()
        
        self.formData.cancel()
    }
    
    func dismissForm() {
        #if os(iOS)
            /*self.dismissViewControllerAnimated(true) { // without animation controller
             print("form dismissed")
             }*/
            self.navigationController?.popViewControllerAnimated(true)
        #endif
    }
}*/

// Little utility class to wait on data
class Semaphore<T> {
    let segueSemaphore = dispatch_semaphore_create(0)
    var data: T?
    
    func waitData(timeout: dispatch_time_t = DISPATCH_TIME_FOREVER) -> T? {
        dispatch_semaphore_wait(segueSemaphore, timeout) // wait user
        return data
    }
    
    func publish(data: T) {
        self.data = data
        dispatch_semaphore_signal(segueSemaphore)
    }
    
    func cancel() {
        dispatch_semaphore_signal(segueSemaphore)
    }
}
