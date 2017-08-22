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
class LogInViewController: UIViewController, GIDSignInUIDelegate, UITextFieldDelegate {
    @IBOutlet weak var anonymousButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    var stateDidChangeListener: FIRAuthStateDidChangeListenerHandle?
    var isFirstCalled: Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // anonymous button customize
        anonymousButton.layer.borderColor = UIColor.white.cgColor
        anonymousButton.layer.borderWidth = 2.0
        GIDSignIn.sharedInstance().clientID = "317794623259-l3v62v6a96082krgi73c9uuom72lgn11.apps.googleusercontent.com";
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        nameTextField.delegate = self
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LogInViewController.hideKeybroad)))
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeybroad()
        return true
    }
    
     func hideKeybroad() {
        nameTextField.resignFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let name = Helper.helper.getUserName() {
            nameTextField.text = name
        }
//        if FIRAuth.auth()?.currentUser != nil {
//            Helper.helper.switchToNavigationVC()
//        }
       stateDidChangeListener =  FIRAuth.auth()?.addStateDidChangeListener({ [unowned self] (auth: FIRAuth, user: FIRUser?) in
        if !self.isFirstCalled {
            if let user = user {
                print(user)
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                   appDelegate.window?.rootViewController as? LogInViewController != nil{
                    Helper.helper.switchToNavigationVC()
                }
                //                    Helper.helper.switchToNavigationVC()
            } else {
                print("unknown")
            }
        } else {
            self.isFirstCalled = false
        }
       })
    }
    
    @IBAction func loginAnonymouslyDidTapped(_ sender: UIButton) {
        print("login anonymously did tapped")
        nameTextField.resignFirstResponder()
        if let name = nameTextField.text {
            let trimmedName = name.trmmingHeadAndFootSpace()
            if trimmedName != "" {
                print("user name is \(trimmedName)")
                Helper.helper.loginAnonymously(displayName: trimmedName)
            }
        }
        
    }

    @IBAction func googleLoginDidTapped(_ sender: Any) {
        print("google login did tapped")
        // 发起 Google 第三方登录
        GIDSignIn.sharedInstance().signIn()
    }
    
    deinit {
        print("Login View Controller dealloc")
        if let stateDidChangeListener = stateDidChangeListener {
            FIRAuth.auth()?.removeStateDidChangeListener(stateDidChangeListener)
        }
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
        
        // 成功得到 Google 第三方登录的 access token
        Helper.helper.loginWithGoogle(authentication: user.authentication)
    }
}
