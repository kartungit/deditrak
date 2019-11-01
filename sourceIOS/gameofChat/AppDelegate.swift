//
//  AppDelegate.swift
//  gameofChat
//
//  Created by thinhmai on 7/11/19.
//  Copyright © 2019 thinhmai. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var userInfo: User!

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

		FirebaseApp.configure()

		window = UIWindow(frame: UIScreen.main.bounds)
		window?.makeKeyAndVisible()

		window?.rootViewController = UINavigationController(rootViewController: MainController())

		self.fetchUserAndSetupNavbarTitle()

		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}

	fileprivate func fetchUserAndSetupNavbarTitle() {
		if let uid = Auth.auth().currentUser?.uid {
			Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
				if let user = User.bindingUserFrom(snapshot: snapshot){
					self.userInfo = user
				}
			}
		}
	}

}

