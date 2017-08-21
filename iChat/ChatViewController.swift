//
//  ChatViewController.swift
//  iChat
//
//  Created by Luka on 2017/8/16.
//  Copyright © 2017年 Luka. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import SDWebImage

class ChatViewController: JSQMessagesViewController {
    
    var messages = [JSQMessage]()
    var messagesRef = FIRDatabase.database().reference().child("messages")
    var usersRef = FIRDatabase.database().reference().child("users")
    var avatarDict = [String: JSQMessagesAvatarImage]()
    
    let incomingBubbleImage = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.gray)
    let outgoingBubbleImage = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.blue)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let user = FIRAuth.auth()?.currentUser
        
        
        senderId = user?.uid
        if let displayName = user?.displayName {
            senderDisplayName = displayName
        } else {
            senderDisplayName = "Anonymous"
        }

        observeMessages()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func observerUser(uid: String) {
        usersRef.child(uid).observe(FIRDataEventType.value) { (snapshoot: FIRDataSnapshot) in
            print(snapshoot.value)
            if let dataDict = snapshoot.value as? [String: AnyObject],
                let url = dataDict["profileUrl"] as? String {
                    self.setupAvatar(urlString: url, uid: uid)
            }
        }
    }
    
    func setupAvatar(urlString: String, uid: String) {
        if urlString == "" {
            avatarDict[uid] = JSQMessagesAvatarImageFactory.avatarImage(with: #imageLiteral(resourceName: "profileImage.png"), diameter: 30)
            collectionView.reloadData()
        } else {
            SDWebImageManager.shared().loadImage(with: URL(string: urlString), options: [], progress: nil, completed: { (image: UIImage?, data: Data?, error: Error?, cacheType: SDImageCacheType, success: Bool, url: URL?) in
                if image != nil {
//                    print(Thread.current) 
//                    main thread
                    self.avatarDict[uid] = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: 30)
                    self.collectionView.reloadData()
                }
            })
//            do {
//                let urlString = URL(string: urlString)
//                let data = try Data(contentsOf: urlString!)
//                let image = UIImage(data: data)
//                avatarDict[uid] = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: 30)
//            } catch {
//                print(error)
//            }
        }
    }
    
    func observeMessages() {
        messagesRef.observe(FIRDataEventType.childAdded) { (snapshot: FIRDataSnapshot) in
            print(snapshot.value)
            if let dataDic = snapshot.value as? [String: AnyObject] {
                if let mediaType = dataDic["MediaType"] as? String,
                    let senderId = dataDic["senderId"] as? String,
                    let senderName = dataDic["senderName"] as? String {
                    
                    self.observerUser(uid: senderId)
                    
                    switch mediaType {
                    case "TEXT":
                        if let text = dataDic["text"] as? String {
                            self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, text: text))
                            self.collectionView.reloadData()
                        }
                    case "PHOTO":
                        if let sourcePathURL = dataDic["fileURL"] as? String {
                            let url = URL(string: sourcePathURL)!
                            let media = JSQPhotoMediaItem(image: nil)
                            media?.appliesMediaViewMaskAsOutgoing = senderId == self.senderId
                            self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: media))
                            self.collectionView.reloadData()
                            
                            SDWebImageManager.shared().loadImage(with: url, options: [], progress: nil, completed: { (image, _, _, _, _, _) in
                                if image != nil {
                                    media?.image = image
                                    self.collectionView.reloadData()
                                }
                            })
                            
                        }
                    case "VIDEO":
                        if let sourcePathURL = dataDic["fileURL"] as? String {
                            let videoURL = URL(string: sourcePathURL)
                            let media = JSQVideoMediaItem(fileURL: videoURL, isReadyToPlay: true)
                            media?.appliesMediaViewMaskAsOutgoing = senderId == self.senderId
                            self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: media))
                            self.collectionView.reloadData()
                        }
                    default:
                        break
                    }
                    
                    self.finishReceivingMessage(animated: true)
                }
            }

        }
    
    
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
//        print("send something \(text) from user \(senderDisplayName)")
//        messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
//        collectionView.reloadData()
        let message = messagesRef.childByAutoId()
        let messageData = ["text": text, "senderId": senderId, "senderName": senderDisplayName, "MediaType": "TEXT"]
        message.setValue(messageData)
        finishSendingMessage(animated: true)
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        print("didPressAccessoryButton")
        let sheet = UIAlertController(title: "Media Messages", message: "Please select a media", preferredStyle: UIAlertControllerStyle.actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (cancelAction: UIAlertAction) in
            
        }
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.default) { (cancelAction: UIAlertAction) in
            self.getMediaFrom(type: kUTTypeImage)
        }
        let videoLibraryAction = UIAlertAction(title: "Video Library", style: UIAlertActionStyle.default) { (cancelAction: UIAlertAction) in
            self.getMediaFrom(type: kUTTypeMovie)
        }
        sheet.addAction(photoLibraryAction)
        sheet.addAction(videoLibraryAction)
        sheet.addAction(cancelAction)
        present(sheet, animated: true, completion: nil)

    }
    
    // get image or video 
    private func getMediaFrom(type: CFString) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [type as String]
        present(imagePickerController, animated: true, completion: nil)
    }
    // collection item count
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    // cell for index item
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super .collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        return cell
    }
    // get the data display for the index cell
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    // get the bubble image for the index cell
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        return message.senderId == senderId ? outgoingBubbleImage : incomingBubbleImage
    }
    // get the avatar image data
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.item]
        
        return avatarDict[message.senderId]
    }
    // show the user name above bubble
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return nil
        }
        
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1]
            if previousMessage.senderId == message.senderId {
                return nil
            }
        }
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return CGFloat(0.0)
        }
        
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1]
            if previousMessage.senderId == message.senderId {
                return CGFloat(0.0)
            }
        }

        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
//
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        print("index path : \(indexPath.item)")
        let message = messages[indexPath.item]
        if message.isMediaMessage {
            if let mediaItem = message.media as? JSQVideoMediaItem {
                let player = AVPlayer(url: mediaItem.fileURL)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                present(playerViewController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func logoutDidTapped(_ sender: UIBarButtonItem) {
        
        do {
            try FIRAuth.auth()?.signOut()
            Helper.helper.logoutToLoginVC()
        } catch {
            print(error)
        }
    }
    
    func sendMeida(image: UIImage?, video: URL?) {
        print(FIRStorage.storage().reference())
        let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\(NSDate.timeIntervalSinceReferenceDate)"
        print(filePath)
        if let image = image {
            let imageData = UIImageJPEGRepresentation(image, 0.1)!
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpg"
            FIRStorage.storage().reference().child(filePath).put(imageData, metadata: metadata, completion: { (metaData, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                } else if let metaData = metaData {
                    let downloadStringPath = metaData.downloadURLs![0].absoluteString
                    print(downloadStringPath)
                    let newMessageRef = self.messagesRef.childByAutoId()
                    let newMessageData = ["fileURL": downloadStringPath, "senderId": self.senderId, "senderName": self.senderDisplayName, "MediaType": "PHOTO"]
                    newMessageRef.setValue(newMessageData)
                }
            })
        } else if let video = video {
            do {
                let videoData = try Data(contentsOf: video)
                let metadata = FIRStorageMetadata()
                metadata.contentType = "video/mp4"
                FIRStorage.storage().reference().child(filePath).put(videoData, metadata: metadata, completion: { (metaData, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    } else if let metaData = metaData {
                        let downloadStringPath = metaData.downloadURLs![0].absoluteString
                        print(downloadStringPath)
                        let newMessageRef = self.messagesRef.childByAutoId()
                        let newMessageData = ["fileURL": downloadStringPath, "senderId": self.senderId, "senderName": self.senderDisplayName, "MediaType": "VIDEO"]
                        newMessageRef.setValue(newMessageData)
                    }
                })
            } catch {
                print(error)
            }
        }
    }
    
    deinit {
        print("Chat View Controller dealloc")
        usersRef.removeAllObservers()
        messagesRef.removeAllObservers()
    }
    
}

extension ChatViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print(info)
        if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            let photo = JSQPhotoMediaItem(image: picture)
//            messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: photo))
            sendMeida(image: picture, video: nil)
        } else if let video = info[UIImagePickerControllerMediaURL] as? URL {
//            let videoItem = JSQVideoMediaItem(fileURL: video, isReadyToPlay: true)
//            messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: videoItem))
            sendMeida(image: nil, video: video)
        }
        picker.dismiss(animated: true, completion: nil)
        collectionView.reloadData()
    }
}

extension ChatViewController: UINavigationControllerDelegate {
    
}
