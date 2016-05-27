//
//  ChatViewController.swift
//  ChatChat
//
//  Created by Appable on 5/5/16.
//  Copyright © 2016 Appable. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import JSQMessagesViewController
import Photos
class ChatViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Properties
    var messages: [JSQMessage] = []
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    var userIsTypingRef: Firebase!
    var itemRef: Firebase!
    private var localTyping = false
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    var userTypingQuery: FQuery!
    var isAnonymous: Bool!
    var username: String!
    let imagePicker = UIImagePickerController()
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBubbles()
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        imagePicker.delegate = self
        
        if isAnonymous == true {
            observeMessages(anonymousMessageRef)
        } else {
            observeMessages(messageRef)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        observeTyping()
    }
    
    // MARK: Private Methods
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleRedColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
    }
    
    private func observeMessages(ref: Firebase!) {
        let messagesQuery = ref.queryLimitedToLast(30)
        messagesQuery.observeEventType(.ChildAdded) { (snapshot: FDataSnapshot!) in
            let id = snapshot.value[KEY_SENDERID] as! String
            let username = snapshot.value[KEY_USERNAME] as! String
            let type = snapshot.value[KEY_TYPE] as! String
            if type == KEY_TEXT {
                let text = snapshot.value[KEY_TEXT] as! String
                if self.senderId != id {
                    FirebaseMessageService.addMessage(id, text: "\(username):\n\(text)", messages: &self.messages)
                } else {
                    FirebaseMessageService.addMessage(id, text: text, messages: &self.messages)
                }
            } else if type == KEY_IMAGE_URL {
                let urlString = snapshot.value[KEY_IMAGE_URL] as! String
                FirebaseMessageService.addImageWithUrl(id, urlString: urlString, messages: &self.messages)
            } else if type == KEY_IMAGE {
                let urlString = snapshot.value[KEY_IMAGE_URL] as! String
                FirebaseMessageService.addImageUploadFromDevice(id, urlString: urlString, messages: &self.messages)
            }
            self.finishReceivingMessage()
        }
    }
    
    private func observeTyping() {
        userIsTypingRef = typingIndicatorRef.childByAppendingPath(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        userTypingQuery = typingIndicatorRef.queryOrderedByValue().queryEqualToValue(true)
        userTypingQuery.observeEventType(.Value){ (data: FDataSnapshot!) in
            if data.childrenCount == 1 && self.isTyping {
                return
            }
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottomAnimated(true)
        }
    }
    
    override func textViewDidChange(textView: UITextView) {
        super.textViewDidChange(textView)
        isTyping = textView.text != NIL_MESSAGE
    }
}
//MARK: CollectionView Methods
extension ChatViewController {
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        if (message.text != nil) {
            if message.senderId == senderId {
                cell.textView!.textColor = UIColor.whiteColor()
            } else {
                cell.textView!.textColor = UIColor.blackColor()
            }
        }
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        let alert = UIAlertController(title: ADD_IMAGE_MESSAGE, message: NIL_MESSAGE, preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (textUrl) -> Void in
            textUrl.placeholder = ENTER_URL_MESSAGE
        }
        let addImageWithUrlAction = UIAlertAction(title: WITH_URL_MESSAGE, style: .Default) { (UIAlertAction) -> Void in
            let urlString = alert.textFields![0]
            if (urlString != "") {
                FirebaseMessageService.addImageUrlToDatabase(self.isAnonymous, url: urlString.text!, id: self.senderId, username: self.username)
            }
        }
        let pickImageFromDeviceAction = UIAlertAction(title: FROM_DEVICE_MESSAGE, style: .Default) { (UIAlertAction) -> Void in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: CANCEL_MESSAGE, style: .Default) { (UIAlertAction) -> Void in
        }
        alert.addAction(addImageWithUrlAction)
        alert.addAction(pickImageFromDeviceAction)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        FirebaseMessageService.addMessageToDatabase(self.isAnonymous, text: text, id: senderId, username: self.username)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
        isTyping = false
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let data = UIImageJPEGRepresentation(pickedImage,0.1)!
            let base64String = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
            FirebaseMessageService.addImageFromDeviceToDatabase(self.isAnonymous, url: base64String, id: self.senderId, username: self.username)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
}