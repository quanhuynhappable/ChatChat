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
            self.performSegueWithIdentifier("LoginToChat", sender: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        let navViewController = segue.destinationViewController as! UINavigationController
        let chatViewController = navViewController.viewControllers.first as! ChatViewController
        chatViewController.senderId = ref.authData.uid
        chatViewController.senderDisplayName = ""
    }
}