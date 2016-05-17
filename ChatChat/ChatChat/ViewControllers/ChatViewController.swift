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
class ChatViewController: JSQMessagesViewController {
    
    // MARK: Properties
    var messages = [JSQMessage]()
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
    var userEmail: String!
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBubbles()
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        print(isAnonymous)
        print(userEmail)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if isAnonymous == true {
            observeMessages(anonymousMessageRef)
        } else {
            observeMessages(messageRef)
        }
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
            let text = snapshot.value[KEY_TEXT] as! String
            let email = snapshot.value[KEY_USEREMAIL] as! String
            if self.senderId != id {
                FirebaseMessageService.addMessage(id, text: "\(email):\n\(text)", messages: &self.messages)
            } else {
                FirebaseMessageService.addMessage(id, text: text, messages: &self.messages)
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
        if message.senderId == senderId {
            cell.textView!.textColor = UIColor.whiteColor()
        } else {
            cell.textView!.textColor = UIColor.blackColor()
        }
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        if isAnonymous == true {
            itemRef = anonymousMessageRef.childByAutoId()
        } else {
            itemRef = messageRef.childByAutoId()
        }
        let messageItem = [
            KEY_TEXT: text,
            KEY_SENDERID: senderId,
            KEY_USEREMAIL: self.userEmail
        ]
        itemRef.setValue(messageItem)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
        isTyping = false
    }
}