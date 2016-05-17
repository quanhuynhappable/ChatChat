//
//  LoginViewController.swift
//  ChatChat
//
//  Created by Appable on 5/5/16.
//  Copyright © 2016 Appable. All rights reserved.
//

import Foundation
import UIKit
class LoginViewController: UIViewController {
    
    // MARK: Properties
    var isAnonymous: Bool!
    var userEmail: String!
    
    // MARK: UIViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        let navViewController = segue.destinationViewController as! UINavigationController
        let chatViewController = navViewController.viewControllers.first as! ChatViewController
        chatViewController.senderId = ref.authData.uid
        chatViewController.senderDisplayName = NIL_MESSAGE
        chatViewController.isAnonymous = isAnonymous
        if isAnonymous == false {
            chatViewController.userEmail = userEmail
        } else {
            chatViewController.userEmail = USEREMAIL_ANONYMOUSLY
        }
    }
}

//MARK: Actions
extension LoginViewController {
    //MARK: Login Actions
    @IBAction func loginDidTouch(sender: AnyObject) {
        FirebaseUserService.authenticateAnonymously { (error) -> Void in
            if error != nil {
                return
            }
            self.isAnonymous = true
            self.performSegueWithIdentifier(SEGUE_ID, sender: nil)
        }
    }
    
    @IBAction func loginAccountDidTouch(sender: AnyObject) {
        let alert = UIAlertController(title: LOGIN_MESSAGE, message: NIL_MESSAGE, preferredStyle: .Alert)
        let loginAction = UIAlertAction(title: LOGIN_MESSAGE, style: .Default) { (UIAlertAction) -> Void in
            let emailField = alert.textFields![0]
            let passwordField = alert.textFields![1]
            FirebaseUserService.authenticateUser(emailField.text!, password: passwordField.text!, callback: { (user, error) -> Void in
                if error == nil {
                    self.isAnonymous = false
                    self.userEmail = user!.valueForKey(KEY_EMAIL) as! String
                    self.performSegueWithIdentifier(SEGUE_ID, sender: nil)
                }
            })
        }
        Utilities.addActionForAlertController(alert, action: loginAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: Register Actions
    @IBAction func registerDidTouch(sender: AnyObject) {
        let alert = UIAlertController(title: REGISTER_MESSAGE, message: NIL_MESSAGE, preferredStyle: .Alert)
        let saveAction = UIAlertAction(title: SAVE_MESSAGE, style: .Default) { (UIAlertAction) -> Void in
            let emailField = alert.textFields![0]
            let passwordField = alert.textFields![1]
            FirebaseUserService.createAccount(emailField.text!, password: passwordField.text!)
        }
        Utilities.addActionForAlertController(alert, action: saveAction)
        presentViewController(alert, animated: true, completion: nil)
    }
}