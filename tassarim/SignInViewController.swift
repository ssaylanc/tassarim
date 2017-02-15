//
//  SignInViewController.swift
//  tassarim
//
//  Created by saylanc on 23/11/16.
//  Copyright © 2016 saylanc. All rights reserved.
//

import UIKit
import SafariServices
import OAuthSwift

@available(iOS 9.0, *)
class SignInViewController: UIViewController {
    
    var safariViewController: SFSafariViewController?

    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var logoWidth: NSLayoutConstraint!
    @IBOutlet weak var logoBottom: NSLayoutConstraint!
    @IBOutlet weak var logoHeight: NSLayoutConstraint!
    @IBAction func signInButtonDidTouch(_ sender: AnyObject) {
        
        self.doOAuthDribbble()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("sedar\(UIDevice().model)")
        switch UIDevice().modelName {
        case .iPhone4:
            self.logoWidth.constant = 100
            self.logoHeight.constant = 100
            self.logoBottom.constant = 20
        case .iPhone4S:
            self.logoView.frame.size.width = 100
            self.logoView.frame.size.height = 100
            self.logoBottom.constant = 20
        /*case .simulator:
            self.logoWidth.constant = 150
            self.logoHeight.constant = 150
            self.logoBottom.constant = 20*/
        default: break
            
        }
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        
        self.navigationController?.navigationBar.isTranslucent = true
        //safariViewController?.delegate = self
    }
    
    func cancelButton () {
        
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
    
    func doOAuthDribbble(){
        let state: String = generateState(withLength: 20)
        let _ = oauthswift.authorize(
            withCallbackURL: URL(string: "tassarim://oauth")!, scope: "public+write", state:state,
            success: { credential, response, parameters in
                KeychainHelper.save ("dribbble_access_token", data: KeychainHelper.stringToNSDATA(credential.oauthToken))
                DispatchQueue.main.async() { [unowned self] in
                    self.performSegue(withIdentifier: "SignedInSegue", sender: self)
                }
        },
            failure: { error in
                print(error.description)
        })
        
        /*oauthswift.authorize(withCallbackURL: URL(string: "tassarim://oauth")!, scope: "public+write", state: state, success: {
            credential, response, parameters in
            
            KeychainHelper.save ("dribbble_access_token", data: KeychainHelper.stringToNSDATA(credential.oauth_token) )
            
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                self.performSegueWithIdentifier("SignedInSegue", sender: self)
            }
            
            }, failure: {(error:NSError!) -> Void in
                print(error.localizedDescription)
        })*/
        
        /*oauthswift.authorizeWithCallbackURL( NSURL(string: "tassarim://oauth")!, scope: "public+write", state: "", success: {
            credential, response, parameters in
            
            KeychainHelper.save ("dribbble_access_token", data: KeychainHelper.stringToNSDATA(credential.oauth_token) )
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                self.performSegueWithIdentifier("SignedInSegue", sender: self)
            }

            /*self.showAlertView("Dribbble", message: "oauth_token:\(credential.oauth_token)")
            // Get User
            let parameters =  Dictionary<String, AnyObject>()
            oauthswift.client.get("https://api.dribbble.com/v1/user?access_token=\(credential.oauth_token)", parameters: parameters,
                success: {
                    data, response in
                    let jsonDict: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
                    
                    print(jsonDict)
                    KeychainHelper.save ("access_token", data: KeychainHelper.stringToNSDATA(credential.oauth_token) )
                    dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                        self.performSegueWithIdentifier("SignedInSegue", sender: self)
                    }
                    
                }, failure: {(error:NSError!) -> Void in
                    print(error)
            })*/
            }, failure: {(error:NSError!) -> Void in
                print(error.localizedDescription)
        })*/
    }
    
    func showAlertView(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SignedInSegue"{
            let toView = segue.destinationViewController as! ShotDetailViewController
        }
    }*/
    
    
}

