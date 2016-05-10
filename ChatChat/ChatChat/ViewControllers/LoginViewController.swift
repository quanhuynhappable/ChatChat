//
//  LoginViewController.swift
//  ChatChat
//
//  Created by Appable on 5/5/16.
//  Copyright © 2016 Appable. All rights reserved.
//

import Foundation
import UIKit
import Firebase
class LoginViewController: UIViewController {
    
    // MARK: Properties
    let ref = Firebase(url: "https://demochatchat.firebaseio.com")
    var isAnonymously: Bool!
    var userEmail: String!
    
    // MARK: UIViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: Actions
    @IBAction func loginDidTouch(sender: AnyObject) {
        ref.authAnonymouslyWithCompletionBlock { (error, authData) in
            if error != nil {
                print(error.description)
                return
            }
            self.isAnonymously = true
            self.performSegueWithIdentifier("LoginToChat", sender: nil)
        }
    }
    
    @IBAction func loginAccountDidTouch(sender: AnyObject) {
        let alert = UIAlertController(title: "Login", message: "Login", preferredStyle: .Alert)
        
        let loginAction = UIAlertAction(title: "Login", style: .Default) { (UIAlertAction) -> Void in
            let emailField = alert.textFields![0]
            let passwordField = alert.textFields![1]
            self.ref.authUser(emailField.text, password: passwordField.text, withCompletionBlock: { (error, auth) -> Void in
                if error == nil {
                    self.isAnonymously = false
                    self.userEmail = emailField.text
                    self.performSegueWithIdentifier("LoginToChat", sender: nil)
                }
            })
        }
        
        addActionForAlertController(alert, action: loginAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }

    @IBAction func registerDidTouch(sender: AnyObject) {
        let alert = UIAlertController(title: "Register", message: "Register", preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .Default) { (UIAlertAction) -> Void in
            let emailField = alert.textFields![0]
            let passwordField = alert.textFields![1]
            self.ref.createUser(emailField.text, password: passwordField.text) { (error, auth) -> Void in
                if error == nil {
                    self.ref.authUser(emailField.text, password: passwordField.text, withCompletionBlock: {(error, auth) -> Void in
                    })
                    let successAlert = UIAlertView(title: "", message: "Register Successfully!", delegate: nil, cancelButtonTitle: "OK")
                    successAlert.show()
                } else {
                    let errorAlert = UIAlertView(title: "Error", message: error.description, delegate: nil, cancelButtonTitle: "OK")
                    errorAlert.show()
                }
            }
        }
        
        addActionForAlertController(alert, action: saveAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        let navViewController = segue.destinationViewController as! UINavigationController
        let chatViewController = navViewController.viewControllers.first as! ChatViewController
        chatViewController.senderId = ref.authData.uid
        chatViewController.senderDisplayName = ""
        chatViewController.isAnonymously = isAnonymously
        if isAnonymously == false {
            chatViewController.userEmail = userEmail
        } else {
            chatViewController.userEmail = "ThanhNiênẨnDanh@chatchat.com"
        }
    }
    
    func addActionForAlertController(alert: UIAlertController, action: UIAlertAction) {
        alert.addTextFieldWithConfigurationHandler { (textEmail) -> Void in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextFieldWithConfigurationHandler { (textPassword) -> Void in
            textPassword.secureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (UIAlertAction) -> Void in
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
    }
}