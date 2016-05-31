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
    static func addImageWithUrl(id: String, urlString: String, isSameId: Bool, inout messages: [JSQMessage])
    static func addImageUploadFromDevice(id: String, urlString: String, isSameId: Bool, inout messages: [JSQMessage])
//    static func addImageWithUrl(id: String, urlString: String, inout messages: [JSQMessage])
//    static func addImageUploadFromDevice(id: String, urlString: String, inout messages: [JSQMessage])
    static func addImageUrlToDatabase(isAnonymous: Bool, url: String, id: String, username:String)
    static func addMessageToDatabase(isAnonymous: Bool, text: String, id: String, username: String)
    static func addImageFromDeviceToDatabase(isAnonymous: Bool, url:String, id: String, username: String)
}