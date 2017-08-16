//
//  ChatViewController.swift
//  iChat
//
//  Created by Luka on 2017/8/16.
//  Copyright © 2017年 Luka. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func logoutDidTapped(_ sender: UIBarButtonItem) {
        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! LogInViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = loginVC
    }

}
