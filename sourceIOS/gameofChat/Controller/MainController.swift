//
//  MainController.swift
//  gameofChat
//
//  Created by thinhmai on 10/21/19.
//  Copyright © 2019 thinhmai. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase


class MainController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
		checkIfUserLoggedIn()

    }

	override func viewDidAppear(_ animated: Bool) {
		super .viewDidAppear(animated)
	}

	func setupTabBarItems(){
		let item = UITabBarItem()
		item.title = "Home"
		item.image = UIImage(named: "home_icon")
		let itemsVC = TodayViewController()
		itemsVC.tabBarItem = item


		let itemSearch = UITabBarItem()
		itemSearch.title = "Search"
		itemSearch.image = UIImage(named: "home_icon")
		let searchVC:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:"SearchViewController") as UIViewController
		searchVC.tabBarItem = itemSearch

		let itemHistory = UITabBarItem()
		itemHistory.title = "History"
		itemHistory.image = UIImage(named: "home_icon")
		let historyVC:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:"HistoryController") as UIViewController
		historyVC.tabBarItem = itemHistory


		let itemSetting = UITabBarItem()
		itemSetting.title = "Setting"
		itemSetting.image = UIImage(named: "home_icon")
		let settingVC = SettingController()
		settingVC.tabBarItem = itemSetting

		self.viewControllers = [itemsVC, searchVC, historyVC, settingVC]
	}
	fileprivate func setupNavigationTitleView(_ dictionary: [String : Any]) {
		let titleView = UIView()
		let nameLabel = UILabel()
		titleView.frame = CGRect(x: 0, y: 0, width: 160, height: 30)
		titleView.addSubview(nameLabel)
		nameLabel.text = dictionary["name"] as? String
		nameLabel.translatesAutoresizingMaskIntoConstraints = false
		// auto layout
		nameLabel.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
		nameLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
		nameLabel.leftAnchor.constraint(equalTo: titleView.leftAnchor).isActive = true
		nameLabel.heightAnchor.constraint(equalTo: titleView.heightAnchor).isActive = true
		self.navigationItem.titleView = titleView
	}
	fileprivate func fetchUserAndSetupNavbarTitle(uid : String) {
		let ref = Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
			if let dictionary = snapshot.value as? [String : Any] {
				var user : User?
				if let bindingUser = User.bindingUserFrom(snapshot: snapshot) {
					bindingUser.id = snapshot.key
					user = bindingUser
					let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: user)
					UserDefaults.standard.set(encodedData, forKey: "userData")
					UserDefaults.standard.synchronize()

					UserDefaults.standard.set(uid, forKey: "authUID")
					self.setupTabBarItems()
				}

				self.setupNavigationTitleView(dictionary)
			}
		}
	}
	func checkIfUserLoggedIn(){
		//user is not logged in
		guard let uid = Auth.auth().currentUser?.uid else {
			perform(#selector(handleLogout), with: nil, afterDelay: 0)
			return
		}
		fetchUserAndSetupNavbarTitle(uid : uid)

	}
	@objc func handleLogout(){

		do {
			try Auth.auth().signOut()
		} catch let logoutError {
			print("LOGOUT ERROR :: \(logoutError)")
		}

		let loginController = LoginController()
		present(loginController, animated: true, completion: nil)
	}
}
