//
//  FirebaseMessageService.swift
//  ChatChat
//
//  Created by Appable on 5/16/16.
//  Copyright © 2016 Appable. All rights reserved.
//

import Foundation
import JSQMessagesViewController
class FirebaseMessageService: MessageService {
    static func addMessage(id: String, text: String, inout messages: [JSQMessage]) {
        let message = JSQMessage(senderId: id, displayName: NIL_MESSAGE, text: text)
        messages.append(message)
    }
}
