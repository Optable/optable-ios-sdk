//
//  AppDelegate.swift
//  demo-ios-swift
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

import UIKit
import OptableSDK

// The OPTABLE global points to an instance of OptableSDK which is initialized in the AppDelegate application() method at app launch.
// While we could have initialized the global directly here, due to Swift lazy-loading this would delay initialization to the first
// use of the SDK. While not strictly required, we want to force early initialization so that the SDK can detect the correct useragent
// to use in calls to the Optable Sandbox. Since useragent detection is an async process executed at OptableSDK init time, we want to
// ideally have init happen well before the first usage/API call if possible.
var OPTABLE: OptableSDK?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // See comment further above on why we are initializing OptableSDK() from here:
        OPTABLE = OptableSDK(host: "sandbox.optable.co", app: "ios-sdk-demo")

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}

