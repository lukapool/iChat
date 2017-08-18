//
//  LogInViewController.swift
//  iChat
//
//  Created by Luka on 2017/8/16.
//  Copyright © 2017年 Luka. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
class LogInViewController: UIViewController, GIDSignInUIDelegate {
    @IBOutlet weak var anonymousButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // anonymous button customize
        anonymousButton.layer.borderColor = UIColor.white.cgColor
        anonymousButton.layer.borderWidth = 2.0
        GIDSignIn.sharedInstance().clientID = "317794623259-l3v62v6a96082krgi73c9uuom72lgn11.apps.googleusercontent.com";
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        FIRAuth.auth()?.addStateDidChangeListener({ (auth: FIRAuth, user: FIRUser?) in
            if let user = user {
                print(user)
                Helper.helper.switchToNavigationVC()
            } else {
                print("unknown")
            }
        })
    }
    
    @IBAction func loginAnonymouslyDidTapped(_ sender: UIButton) {
        print("login anonymously did tapped")
        Helper.helper.loginAnonymously()
    }

    @IBAction func googleLoginDidTapped(_ sender: Any) {
        print("google login did tapped")
        // 发起 Google 第三方登录
        GIDSignIn.sharedInstance().signIn()
    }
}

//第三方登录的结果处理回调
extension LogInViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            print(error.localizedDescription)
            return
        }
        print(user.authentication)
        // 成功的到 Google 第三方登录的 access token
        Helper.helper.loginWithGoogle(authentication: user.authentication)
    }
}
