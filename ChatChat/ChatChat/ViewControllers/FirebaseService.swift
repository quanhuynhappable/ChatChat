//
//  FirebaseService.swift
//  ChatChat
//
//  Created by Appable on 5/12/16.
//  Copyright © 2016 Appable. All rights reserved.
//

import Foundation
import Firebase
let ref = Firebase(url: "https://demochatchat.firebaseio.com/")
let messageRef = ref.childByAppendingPath("messages")
let anonymousMessageRef = ref.childByAppendingPath("anonymousMessages")
let typingIndicatorRef = ref.childByAppendingPath("typingIndicator")
let userRef = ref.childByAppendingPath("user")
var itemRef: Firebase!
