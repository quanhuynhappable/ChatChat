//
//  Utilities.swift
//  ChatChat
//
//  Created by Appable on 5/16/16.
//  Copyright © 2016 Appable. All rights reserved.
//

import Foundation
import UIKit
class Utilities {
    //MARK: Define AlertController
    static func addActionForAlertController(alert: UIAlertController, action: UIAlertAction) {
        alert.addTextFieldWithConfigurationHandler { (textEmail) -> Void in
            textEmail.placeholder = ENTER_EMAIL_MESSAGE
        }
        alert.addTextFieldWithConfigurationHandler { (textPassword) -> Void in
            textPassword.secureTextEntry = true
            textPassword.placeholder = ENTER_PASSWORD_MESSAGE
        }
        let cancelAction = UIAlertAction(title: CANCEL_MESSAGE, style: .Default) { (UIAlertAction) -> Void in
        }
        alert.addAction(action)
        alert.addAction(cancelAction)
    }
    
    static func showAlert(title:String, message:String) {
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: OK_MESSAGE)
        alert.show()
    }
}