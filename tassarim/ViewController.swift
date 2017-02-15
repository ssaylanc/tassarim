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
    @IBAction func signInButtonDidTouch(_ sender: AnyObject) {
        doOAuthDribbble()
    }
    
    
    var currentParameters = [String: String]()
    lazy var internalWebViewController: WebViewController = {
        let controller = WebViewController()
        #if os(OSX)
            controller.view = NSView(frame: NSRect(x:0, y:0, width: 450, height: 500)) // needed if no nib or not loaded from storyboard
        #elseif os(iOS)
            controller.view = UIView(frame: UIScreen.main.bounds) // needed if no nib or not loaded from storyboard
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
        let state: String = generateState(withLength: 20)
        let oauthswift = OAuth2Swift(
            consumerKey:    "4cf827eca84b70b9edbcbc053f28ee93f517fbd8e26cc52038950a593f69262b",
            consumerSecret: "dd240ac0423d35d8177710fadd9acbb434021734d88bad65e7284ed667bb0282",
            authorizeUrl:   "https://dribbble.com/oauth/authorize",
            accessTokenUrl: "https://dribbble.com/oauth/token",
            responseType:   "code"
        )
        self.oauthswift = oauthswift
        oauthswift.authorizeURLHandler = get_url_handler()
        let _ = oauthswift.authorize(
            withCallbackURL: URL(string: "tassarim://oauth")!, scope: "public+write", state:state,
            success: { credential, response, parameters in
                KeychainHelper.save ("dribbble_access_token", data: KeychainHelper.stringToNSDATA(credential.oauthToken) )
                
                DispatchQueue.main.async() { [unowned self] in
                    self.performSegue(withIdentifier: "SignedInSegue", sender: self)
                }
        },
            failure: { error in
                print(error.description)
        })
    }
}

let DocumentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
let FileManager: Foundation.FileManager = Foundation.FileManager.default

extension ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("sedar\(UIDevice().modelName)")
        switch UIDevice().modelName {
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
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        
        self.navigationController?.navigationBar.isTranslucent = true
        // init now web view handler
        internalWebViewController.webView
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
            self.performSegue(withIdentifier: "SignedInSegue", sender: self)
            /*let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
             let shotsVC = mainStoryBoard.instantiateViewControllerWithIdentifier("ShotsVC")
             self.presentViewController(shotsVC, animated: true, completion: nil)*/
        }
    }

    
    // MARK: utility methods
    
    var confPath: String {
        let appPath = "\(DocumentDirectory)/.oauth/"
        if !FileManager.fileExists(atPath: appPath) {
            do {
                try FileManager.createDirectory(atPath: appPath, withIntermediateDirectories: false, attributes: nil)
            }catch {
                print("Failed to create \(appPath)")
            }
        }
        return "\(appPath)Services.plist"
    }
    
    func snapshot() -> Data {
        #if os(iOS)
            UIGraphicsBeginImageContext(self.view.frame.size)
            self.view.layer.render(in: UIGraphicsGetCurrentContext()!)
            let fullScreenshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            UIImageWriteToSavedPhotosAlbum(fullScreenshot!, nil, nil, nil)
            return  UIImageJPEGRepresentation(fullScreenshot!, 0.5)!
        #elseif os(OSX)
            let rep: NSBitmapImageRep = self.view.bitmapImageRepForCachingDisplayInRect(self.view.bounds)!
            self.view.cacheDisplayInRect(self.view.bounds, toBitmapImageRep:rep)
            return rep.TIFFRepresentation!
        #endif
    }
    
    func showAlertView(_ title: String, message: String) {
        #if os(iOS)
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        #elseif os(OSX)
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = message
            alert.addButtonWithTitle("Close")
            alert.runModal()
        #endif
    }
    
    func showTokenAlert(_ name: String?, credential: OAuthSwiftCredential) {
        var message = "oauth_token:\(credential.oauthToken)"
        if !credential.oauthTokenSecret.isEmpty {
            message += "\n\noauth_toke_secret:\(credential.oauthTokenSecret)"
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
        case main, background
        
        var queue: DispatchQueue {
            switch self {
            case .main:
                return DispatchQueue.main
            case .background:
                return DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
            }
        }
        func async(_ block: @escaping () -> Void) {
            self.queue.async {
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
    let segueSemaphore = DispatchSemaphore(value: 0)
    var data: T?
    
    func waitData(_ timeout: DispatchTime = DispatchTime.distantFuture) -> T? {
        segueSemaphore.wait(timeout: timeout) // wait user
        return data
    }
    
    func publish(_ data: T) {
        self.data = data
        segueSemaphore.signal()
    }
    
    func cancel() {
        segueSemaphore.signal()
    }
}
