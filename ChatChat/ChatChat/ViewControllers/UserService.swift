//
//  UserService.swift
//  ChatChat
//
//  Created by Appable on 5/13/16.
//  Copyright © 2016 Appable. All rights reserved.
//

import Foundation
protocol UserService {
    static func authenticateUser(email: String, password: String, callback: ((user: AnyObject?, error: NSError?) -> Void))
    static func authenticateAnonymously(callback: ((error:NSError?) -> Void))
    static func createAccount(email: String, password: String)
}