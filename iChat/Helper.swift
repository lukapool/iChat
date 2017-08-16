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

class Helper {
    static let helper = Helper()
    
    func loginAnonymously() {
        FIRAuth.auth()?.signInAnonymously(completion: { (anonymouseUser: FIRUser?, error: Error?) in
            if error == nil {
                print("UserID: \(anonymouseUser!.uid)")
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
                self.switchToNavigationVC()
            }
        })
    }
    
    private func switchToNavigationVC() {
        let chatVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! UINavigationController
        let applicationDelegate = UIApplication.shared.delegate as! AppDelegate
        applicationDelegate.window?.rootViewController = chatVC
    }
    
}
