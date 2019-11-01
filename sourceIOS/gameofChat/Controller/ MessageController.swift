//
//  MessageController.swift
//  gameofChat
//
//  Created by thinhmai on 7/11/19.
//  Copyright © 2019 thinhmai. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

protocol ItemProtocol {
	func createNewItem(user: User?)
}
class MessageController: UITableViewController {


	let cellId = "cellId"
	var message = [Item]()
	var messageDictionary = [String: Message]()
	var userInfo: User!

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.register(ItemCell.self, forCellReuseIdentifier: cellId)
		observeMessages()
	}

	override func viewDidAppear(_ animated: Bool) {
		super .viewDidAppear(animated)
		checkIfUserLoggedIn()
		
	}

	func observeMessages(){
		let messageReference = Database.database().reference().child("messages")

		// Observe the item changed
		messageReference.observe(.childChanged) { (snapshot) in

			let itemId = snapshot.key
			if let item = self.bindingItemFrom(snapshot: snapshot){
				if let index = self.message.firstIndex (where: {$0.itemId == itemId}) {
					self.message[index] = item
				}
			}
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}

		messageReference.observe(.childRemoved) { (snapshot) in
			let itemId = snapshot.key
			self.message.removeAll(where: {$0.itemId == itemId})
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
	}

	func bindingItemFrom(snapshot : DataSnapshot) -> Item? {
		if let dictionary = snapshot.value as? [String: Any] {
			let item = Item()
			item.itemId = dictionary["itemId"] as? String
			item.toId = dictionary["toId"] as? String
			item.fromId = dictionary["fromId"] as? String
			item.title = dictionary["title"] as? String
			item.category = dictionary["category"] as? String
			item.fromOffice = dictionary["fromOffice"] as? String
			item.toOffice = dictionary["toOffice"] as? String
			item.quantity = dictionary["quantity"] as? String
			item.reciever = dictionary["reciever"] as? String
			item.sender = dictionary["sender"] as? String
			item.status = dictionary["status"] as? String
			item.timestamp = dictionary["timestamp"] as? NSNumber
			return item
		}
		return nil
	}

	func bindingUserFrom(snapshot: DataSnapshot) -> User? {
		let user = User()
		if let dictionary = snapshot.value as? [String: Any] {
			user.office = dictionary["office"] as? String
			user.id = dictionary["id"] as? String
			user.email = dictionary["email"] as? String
			user.name = dictionary["name"] as? String
		}
		return user
	}

	func observerUserMessages(){
		if let uOffice = self.userInfo.office {
			let ref = Database.database().reference().child("user-messages").child(uOffice)

			ref.observe(.childAdded) { (snapshot) in
				let messageId = snapshot.key
				let messageReference = Database.database().reference().child("messages").child(messageId)
				messageReference.observeSingleEvent(of: .value, with: { (snapshot) in
					if let item = self.bindingItemFrom(snapshot: snapshot){
						if item.timestamp != nil {
							self.message.append(item)
							self.message.sort(by: { (message1, message2) -> Bool in
								return message1.timestamp!.intValue > message2.timestamp!.intValue
							})

						}
						DispatchQueue.main.async {
							self.tableView.reloadData()
						}
					}
				})
			}
		}

	}



	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return message.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ItemCell

		let item = self.message[indexPath.row]
		cell.item = item
		cell.user = userInfo
		cell.nextButton.item = item
		cell.nextButton.addTarget(self, action: #selector(goToNextStep), for: .touchUpInside)
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cell = tableView.cellForRow(at: indexPath) as! ItemCell

		editItem(item: cell.item, userInfo: self.userInfo)
	}

	@objc func goToNextStep(sender: ButtonExtended){

		if let item = sender.item {
			let ref = Database.database().reference().child("messages").child(item.itemId!)
			ref.updateChildValues(["status": getNextStep(fromStatus: item.status!)])
		}
	}

	func getNextStep(fromStatus: String?) -> String{
		guard let currentStatus = fromStatus else {
			return ""
		}
		switch currentStatus {
		case "New":
			return "In Progress"
		case "In Progress":
			return "Recieved"
		case "Recieved":
			return "Deliveried"
		case "Deliveried":
			return "New"
		default:
			return "New"
		}
	}

	func editItem(item: Item?, userInfo: User?){
		let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
		chatLogController.item = item
		chatLogController.user = userInfo
		self.tabBarController?.navigationController?.pushViewController(chatLogController, animated: true)
	}

	fileprivate func setupNavigationTitleView(user: User) {

		message.removeAll()
		messageDictionary.removeAll()
		tableView.reloadData()

		self.userInfo = user

		observerUserMessages()
		let titleView = UIView()
		let nameLabel = UILabel()
		titleView.frame = CGRect(x: 0, y: 0, width: 160, height: 30)
		titleView.addSubview(nameLabel)
		nameLabel.text = user.name
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
			if let user = self.bindingUserFrom(snapshot: snapshot){
				self.setupNavigationTitleView(user: user)
			}
		}
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


