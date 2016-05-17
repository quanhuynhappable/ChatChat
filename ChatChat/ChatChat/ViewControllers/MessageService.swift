//
//  MessageService.swift
//  ChatChat
//
//  Created by Appable on 5/16/16.
//  Copyright © 2016 Appable. All rights reserved.
//

import Foundation
import JSQMessagesViewController
protocol MessageService {
    static func addMessage(id: String, text: String, inout messages: [JSQMessage])
}