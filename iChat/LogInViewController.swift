//
//  LogInViewController.swift
//  iChat
//
//  Created by Luka on 2017/8/16.
//  Copyright © 2017年 Luka. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {
    @IBOutlet weak var anonymousButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // anonymous button customize
        anonymousButton.layer.borderColor = UIColor.white.cgColor
        anonymousButton.layer.borderWidth = 2.0
    }

    @IBAction func loginAnonymouslyDidTapped(_ sender: UIButton) {
        print("login anonymously did tapped")
        let chatVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! UINavigationController
        let applicationDelegate = UIApplication.shared.delegate as! AppDelegate
        applicationDelegate.window?.rootViewController = chatVC
    }

    @IBAction func googleLoginDidTapped(_ sender: Any) {
        print("google login did tapped")
    }
}
