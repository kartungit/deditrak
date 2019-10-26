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
    }

	override func viewDidAppear(_ animated: Bool) {
		super .viewDidAppear(animated)
		checkIfUserLoggedIn()
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
		let searchVC = SearchController()
		searchVC.tabBarItem = itemSearch

		let itemHistory = UITabBarItem()
		itemHistory.title = "History"
		itemHistory.image = UIImage(named: "home_icon")
		let historyVC = HistoryController()
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
	fileprivate func fetchUserAndSetupNavbarTitle() {
		let uid = Auth.auth().currentUser?.uid
		Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value) { (snapshot) in
			if let dictionary = snapshot.value as? [String : Any] {
				self.setupNavigationTitleView(dictionary)
			}
		}
		setupTabBarItems()
	}
	func checkIfUserLoggedIn(){
		//user is not logged in
		if Auth.auth().currentUser?.uid == nil {
			perform(#selector(handleLogout), with: nil, afterDelay: 0)
		} else {
			fetchUserAndSetupNavbarTitle()
		}
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
