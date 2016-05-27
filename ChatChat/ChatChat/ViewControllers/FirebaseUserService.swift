//
//  FirebaseUserService.swift
//  ChatChat
//
//  Created by Appable on 5/13/16.
//  Copyright © 2016 Appable. All rights reserved.
//

import Foundation
import Firebase
import UIKit
class FirebaseUserService: UserService {
    static func authenticateUser(email: String, password: String, callback: ((user: AnyObject?, error: NSError?) -> Void)) {
        ref.authUser(email, password: password, withCompletionBlock: { (error, auth) -> Void in
            if error == nil {
                let userQuery = userRef.queryOrderedByChild(auth.uid)
                userQuery.observeEventType(.Value) { (snapshot: FDataSnapshot!) in
                    let user = snapshot.value[auth.uid]
                    callback(user: user, error: nil)
                }
            } else {
                callback(user: nil, error: error)
            }
        })
    }
    
    static func authenticateAnonymously(callback: ((error:NSError?) -> Void)) {
        ref.authAnonymouslyWithCompletionBlock { (error, authData) in
            if error == nil {
                callback(error: nil)
            } else {
                callback(error: error)
            }
        }
    }
    
    static func createAccount(email: String, password: String, username:String) {
        ref.createUser(email, password: password) { (error, auth) -> Void in
            if error == nil {
                ref.authUser(email, password: password, withCompletionBlock: {(error, auth) -> Void in
                    itemRef = userRef.childByAppendingPath(auth.uid)
                    let userItem = [
                        KEY_USERNAME: username,
                        KEY_SENDERID: auth.uid,
                        KEY_USEREMAIL: email
                    ]
                    itemRef.setValue(userItem)
                })
                Utilities.showAlert(REGISTER_MESSAGE, message: REGISTER_SUCCESS_MESSAGE)
            } else {
                Utilities.showAlert(ERROR_MESSAGE, message: error.description)
            }
        }
    }
}