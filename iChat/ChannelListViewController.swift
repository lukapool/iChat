//
//  ChannelListViewController.swift
//  iChat
//
//  Created by Luka on 2017/8/21.
//  Copyright © 2017年 Luka. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ChannelListViewController: UITableViewController {
    private var channels = [Channel]()
    
    var newChannelTextFiled: UITextField?
    private lazy var channelsRef = FIRDatabase.database().reference().child("channels")
    private var channelRefHandle: FIRDatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: self, action: nil)
        
        observerChannels()
    }
    
    deinit {
        print("ChannelListViewController is deallocing")
        if let refHandle = channelRefHandle {
            channelsRef.removeObserver(withHandle: refHandle)
        }
    }
    
    func observerChannels() {
        channelRefHandle = channelsRef.observe(FIRDataEventType.childAdded, with: { (snapshot: FIRDataSnapshot) in
            let id = snapshot.key
            if let dict = snapshot.value as? [String: AnyObject],
                let name = dict["name"] as? String {
                    print("add new channel {\(id), \(name)}")
                    let channel = Channel(id: id, name: name)
                    self.channels.append(channel)
                    self.tableView.reloadData()
            }

        })
    }
    
    @IBAction func logoutDidTapped(_ sender: UIBarButtonItem) {
        
        do {
            try FIRAuth.auth()?.signOut()
            Helper.helper.logoutToLoginVC()
        } catch {
            print(error)
        }
    }

    @IBAction func createNewChannel(_ sender: UIButton) {
        if let channelName = newChannelTextFiled?.text {
            let newLineAndWhiteSpaces = CharacterSet.whitespacesAndNewlines
            if channelName.trimmingCharacters(in: newLineAndWhiteSpaces) != "" {
                print("new channel name is \(channelName)")
                channelsRef.childByAutoId().setValue(["name": channelName])
            }
            newChannelTextFiled?.text = ""
        }
        newChannelTextFiled?.resignFirstResponder()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return channels.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = indexPath.section == 0 ? "CREATECHANNEL" : "SHOWCHANNELNAME"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        if indexPath.section == 0 {
            if let createChannelCell = cell as? CreateChannelCell {
                newChannelTextFiled = createChannelCell.newChannelTextField
            }
        } else {
            cell.textLabel?.text = channels[indexPath.row].name
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 {
            return nil
        }
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        }
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = channels[indexPath.row]
        let chatVC = ChatViewController()
//        let chatVC = ViewController()
        chatVC.channel = channel
        navigationController?.pushViewController(chatVC, animated: true)
//        self.performSegue(withIdentifier: "ShowChat", sender: channel)
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let channel = sender as? Channel,
            let destination = segue.destination as? ChatViewController{
            destination.channel = channel
        }
    }
    

}
