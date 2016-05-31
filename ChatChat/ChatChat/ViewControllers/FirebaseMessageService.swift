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
    
    static func addImageUploadFromDevice(id: String, urlString: String, isSameId: Bool, inout messages: [JSQMessage]) {
        let data = NSData(base64EncodedString: urlString, options: .IgnoreUnknownCharacters)
        let image = UIImage(data: data!)
        let jsqPhoto = JSQPhotoMediaItem(image: image!)
        jsqPhoto.appliesMediaViewMaskAsOutgoing = isSameId
        let message = JSQMessage(senderId: id, displayName: NIL_MESSAGE, media: jsqPhoto)
        messages.append(message)
    }

    static func addImageWithUrl(id: String, urlString: String, isSameId:Bool, inout messages: [JSQMessage]) {
        let url = NSURL(string: urlString)
        let data = NSData(contentsOfURL: url!)
        let image = UIImage(data: data!)
        let jsqPhoto = JSQPhotoMediaItem(image: image!)
        jsqPhoto.appliesMediaViewMaskAsOutgoing = isSameId
        let message = JSQMessage(senderId: id, displayName: NIL_MESSAGE, media: jsqPhoto)
        messages.append(message)
    }
    
    static func addMessageToDatabase(isAnonymous: Bool, text: String, id: String, username: String) {
        if isAnonymous == true {
            itemRef = anonymousMessageRef.childByAutoId()
        } else {
            itemRef = messageRef.childByAutoId()
        }
        let messageItem = [
            KEY_TEXT: text,
            KEY_SENDERID: id,
            KEY_USERNAME: username,
            KEY_TYPE: KEY_TEXT
        ]
        itemRef.setValue(messageItem)
    }
    static func addImageUrlToDatabase(isAnonymous: Bool, url: String, id: String, username:String) {
        if isAnonymous == true {
            itemRef = anonymousMessageRef.childByAutoId()
        } else {
            itemRef = messageRef.childByAutoId()
        }
        let messageItem = [
            KEY_IMAGE_URL: url,
            KEY_SENDERID: id,
            KEY_USERNAME: username,
            KEY_TYPE: KEY_IMAGE_URL
        ]
        itemRef.setValue(messageItem)
    }
    static func addImageFromDeviceToDatabase(isAnonymous: Bool, url: String, id: String, username: String) {
        if isAnonymous == true {
            itemRef = anonymousMessageRef.childByAutoId()
        } else {
            itemRef = messageRef.childByAutoId()
        }
        let messageItem = [
            KEY_IMAGE_URL: url,
            KEY_SENDERID: id,
            KEY_USERNAME: username,
            KEY_TYPE: KEY_IMAGE
        ]
        itemRef.setValue(messageItem)
    }
}
