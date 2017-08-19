//
//  Helper.swift
//  iChat
//
//  Created by Luka on 2017/8/16.
//  Copyright © 2017年 Luka. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FirebaseDatabase

class Helper {
    static let helper = Helper()
    
    func loginAnonymously() {
        FIRAuth.auth()?.signInAnonymously(completion: { (anonymouseUser: FIRUser?, error: Error?) in
            if error == nil {
                print("UserID: \(anonymouseUser!.uid)")
                
                if let anonymouseUser = anonymouseUser {
                    let newUserRef = FIRDatabase.database().reference().child("users").child(anonymouseUser.uid)
                    newUserRef.setValue(
                        [
                            "displayName" : "anonymous",
                            "uid" : anonymouseUser.uid,
                            "profileUrl" : ""
                        ]
                    )
                }

                self.switchToNavigationVC()
            } else {
                print(error!.localizedDescription)
            }
        })
    }
    
    func loginWithGoogle(authentication: GIDAuthentication) {
        // 使用 google 返回的 access token 去 google 资源服务器中获取用户名和注册成为 Firebase 的帐号
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        FIRAuth.auth()?.signIn(with: credential, completion: { (googleUser: FIRUser?, error: Error?) in
            if error == nil {
                print(googleUser?.displayName as Any)
                print(googleUser?.email as Any)
                if let googleUser = googleUser {
                    let newUserRef = FIRDatabase.database().reference().child("users").child(googleUser.uid)
                    newUserRef.setValue(
                        [
                            "displayName" : googleUser.displayName!,
                            "uid" : googleUser.uid,
                            "profileUrl" : googleUser.photoURL!.absoluteString
                        ]
                    )
                }


                self.switchToNavigationVC()
            }
        })
    }
    
    func switchToNavigationVC() {
        let chatVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NaviVC") as! UINavigationController
        let applicationDelegate = UIApplication.shared.delegate as! AppDelegate
        applicationDelegate.window?.rootViewController = chatVC
    }
    
    func logoutToLoginVC() {
        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LogInViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = loginVC
    }
    
}
