//
//  GoogleSignInAppApp.swift
//  GoogleSignInApp
//
//  Created by Santhosh Srinivas on 23/12/21.
//

import SwiftUI
import Firebase
import GoogleSignIn

@main
struct GoogleSignInAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            MainMsgView()
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
      FirebaseApp.configure()
    return true
  }
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any])
      -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
}
