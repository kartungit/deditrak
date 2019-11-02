//
//  SettingController.swift
//  gameofChat
//
//  Created by thinhmai on 10/21/19.
//  Copyright © 2019 thinhmai. All rights reserved.
//

import UIKit
import Firebase

class SettingController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	let tableView = UITableView()
	let cellId = "phoneCell"
	let phoneData = [
		["phone": "0985423512", "office" : "Cong Hoa"],
		["phone": "0985423524", "office" : "Truong Son"],
		["phone": "0985423546", "office" : "Tan Vien"],
		["phone": "0985423566", "office" : "Up Star"]
	]

    override func viewDidLoad() {
        super.viewDidLoad()
		view.backgroundColor = UIColor.white

		tableView.delegate = self
		tableView.dataSource = self
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.separatorStyle = .none
		tableView.estimatedRowHeight = 80

		tableView.register(PhoneCell.self, forCellReuseIdentifier: cellId)

		setupView()
        // Do any additional setup after loading the view.
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

	func setupView(){
		let logoutButton = UIButton()
		logoutButton.setTitle("Log Out", for: .normal)
		logoutButton.backgroundColor = UIColor.black
		logoutButton.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
		logoutButton.translatesAutoresizingMaskIntoConstraints = false

		view.addSubview(logoutButton)
		view.addSubview(tableView)

		// auto layout

		tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 8).isActive = true
		tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70).isActive = true

		logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor ).isActive = true
		logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
		logoutButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
		logoutButton.widthAnchor.constraint(equalToConstant: 120).isActive = true

		let versionLabel = UILabel()
		versionLabel.font = UIFont.systemFont(ofSize: 12)
		versionLabel.textColor = UIColor(r: 26, g: 86, b: 131)
		versionLabel.textAlignment = .right
		versionLabel.numberOfLines = 1
		versionLabel.translatesAutoresizingMaskIntoConstraints = false

		view.addSubview(versionLabel)
		let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
		versionLabel.text = "Ver: \(String(describing: appVersion!))"

		versionLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -4).isActive = true
		versionLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
		versionLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
		versionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 4).isActive = true
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return phoneData.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PhoneCell
		let item = self.phoneData[indexPath.row]
		cell.office = item["office"]
		cell.phoneNumber = item["phone"]
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cell = tableView.cellForRow(at: indexPath) as! PhoneCell

		dialNumber(number: cell.phoneNumber!)
	}
	
	func dialNumber(number : String) {

		if let url = URL(string: "tel://\(number)"),
			UIApplication.shared.canOpenURL(url) {
			if #available(iOS 10, *) {
				UIApplication.shared.open(url, options: [:], completionHandler:nil)
			} else {
				UIApplication.shared.openURL(url)
			}
		} else {
			// add error message here
		}
	}

	@objc func handleLogout(){
		do {
			try Auth.auth().signOut()
		} catch let logoutError {
			print("LOGOUT ERROR :: \(logoutError)")
		}
		self.tabBarController?.selectedIndex = 0
		UserDefaults.standard.removeObject(forKey: "userData")
		let loginController = LoginController()

		loginController.delegate = self.tabBarController as! MainController
		present(loginController, animated: true, completion: nil)
	}

}
