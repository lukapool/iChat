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

class ChatViewController: JSQMessagesViewController {
    
    var messages = [JSQMessage]()
    var messagesRef = FIRDatabase.database().reference().child("messages")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // fake data
        senderId = "1"
        senderDisplayName = "luka"
        observeMessages()
//        let rootRef = FIRDatabase.database().reference()
//        let messageRef = rootRef.child("messages")
//        
//        print(rootRef)
//        print(messageRef)
//        
//        messageRef.observe(FIRDataEventType.childAdded) { (snapshoot: FIRDataSnapshot) in
//            print(snapshoot)
//            if let data = snapshoot.value as? String {
//                print(data)
//            }
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func observeMessages() {
        messagesRef.observe(FIRDataEventType.childAdded) { (snapshot: FIRDataSnapshot) in
//            print(snapshot.value)
            if let dataDic = snapshot.value as? [String: AnyObject] {
                if let mediaType = dataDic["MediaType"] as? String,
                    let senderId = dataDic["senderId"] as? String,
                    let senderName = dataDic["senderName"] as? String {
                    
                    switch mediaType {
                    case "TEXT":
                        if let text = dataDic["text"] as? String {
                            self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, text: text))
                            self.collectionView.reloadData()
                        }
                    case "PHOTO":
                        if let sourcePathURL = dataDic["fileURL"] as? String {
                            let url = URL(string: sourcePathURL)!
                            if let imageData = try? Data(contentsOf: url) {
                                let image = UIImage(data: imageData)
                                let media = JSQPhotoMediaItem(image: image)
                                self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: media))
                                self.collectionView.reloadData()
                            }
                        }
                    case "VIDEO":
                        if let sourcePathURL = dataDic["fileURL"] as? String {
                            let videoURL = URL(string: sourcePathURL)
                            let media = JSQVideoMediaItem(fileURL: videoURL, isReadyToPlay: true)
                            self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: media))
                            self.collectionView.reloadData()
                        }
                    default:
                        break
                    }
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
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        return bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.black)
    }
    // get the avatar image data
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
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
        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! LogInViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = loginVC
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
}

extension ChatViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print(info)
        if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let photo = JSQPhotoMediaItem(image: picture)
            messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: photo))
            sendMeida(image: picture, video: nil)
        } else if let video = info[UIImagePickerControllerMediaURL] as? URL {
            let videoItem = JSQVideoMediaItem(fileURL: video, isReadyToPlay: true)
            messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: videoItem))
            sendMeida(image: nil, video: video)
        }
        picker.dismiss(animated: true, completion: nil)
        collectionView.reloadData()
    }
}

extension ChatViewController: UINavigationControllerDelegate {
    
}
