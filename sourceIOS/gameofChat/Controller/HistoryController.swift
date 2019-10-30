//
//  HistoryController.swift
//  gameofChat
//
//  Created by thinhmai on 10/21/19.
//  Copyright © 2019 thinhmai. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class HistoryController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	@IBOutlet weak var tableView: UITableView!

	let sections = ["Yesterday", "Last 7 days", "Last 14 days", "Last 30 days"]

	let cellId = "cellId"
	var userInfo: User!

	var yesterdayItems = [Item]()
	var lastweekItems = [Item]()
	var last2weeksItems = [Item]()
	var lastMonthItems = [Item]()

	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.tableView.dataSource = self
		self.tableView.delegate =  
		self.tableView.register(ItemCell.self, forCellReuseIdentifier: cellId)
		self.observeMessages()
    }

	override func viewDidAppear(_ animated: Bool) {
		super .viewDidAppear(animated)
		checkIfUserLoggedIn()

	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

	func numberOfSections(in tableView: UITableView) -> Int {
		return 4;
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return sections[section]
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if (section == 0){
			return yesterdayItems.count
		}
		else if (section == 1){
			return lastweekItems.count
		}
		else if (section == 2){
			return last2weeksItems.count
		}
		return lastMonthItems.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ItemCell
		var item : Item? = nil;
		switch (indexPath.section) {
		case 0:
			item = self.yesterdayItems[indexPath.row]
			break
		case 1:
			item = self.lastweekItems[indexPath.row]
			break
		case 2:
			item = self.last2weeksItems[indexPath.row]
			break
		case 3:
			item = self.lastMonthItems[indexPath.row]
			break
		default:
			break

		}

		cell.item = item
		cell.user = userInfo

		//cell.nextButton.item = item
		//cell.nextButton.addTarget(self, action: #selector(goToNextStep), for: .touchUpInside)
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cell = tableView.cellForRow(at: indexPath) as! ItemCell
		editItem(item: cell.item, userInfo: self.userInfo)
	}

	func observeMessages(){
		let messageReference = Database.database().reference().child("messages")

		// Observe the item changed
		messageReference.observe(.childChanged) { (snapshot) in
			self.setupNavigationTitleView()
		}

		messageReference.observe(.childRemoved) { (snapshot) in
			self.setupNavigationTitleView()
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

							let calendar = Calendar.current

							// Replace the hour (time) of both dates with 00:00
							let date1 = Date.init(timeIntervalSince1970: TimeInterval(truncating: item.timestamp ?? 0)) //calendar.startOfDay(for: )
							let date2 = Date() //calendar.startOfDay(for: Date())

							print("day1: \(date1), day2: \(date2)")

							let components = calendar.dateComponents([.day], from: date1, to: date2)

							let distance = components.day! + 1

							print("distance \(distance)")

//							let weekday = Calendar.current.component(.weekday, from: date2)
//							let f = DateFormatter()
//							print(weekday)
//							print(f.weekdaySymbols[Calendar.current.component(.weekday, from: Date())])
//
//							let components1 = Calendar.current.dateComponents([.day, .month], from: date1)
//							let day = components1.day!
//							let month = components1.month!
//							print(day, month)

							if (distance == 1){
								self.yesterdayItems.append(item)
								self.yesterdayItems.sort(by: { (message1, message2) -> Bool in
									return message1.timestamp!.intValue > message2.timestamp!.intValue
								})
							}
							else if (distance <= 7){
								self.lastweekItems.append(item)
								self.lastweekItems.sort(by: { (message1, message2) -> Bool in
									return message1.timestamp!.intValue > message2.timestamp!.intValue
								})
							}
							else if (distance > 7 && distance <= 14)
							{
								self.last2weeksItems.append(item)
								self.last2weeksItems.sort(by: { (message1, message2) -> Bool in
									return message1.timestamp!.intValue > message2.timestamp!.intValue
								})
							}
							else{
								self.lastMonthItems.append(item)
								self.lastMonthItems.sort(by: { (message1, message2) -> Bool in
									return message1.timestamp!.intValue > message2.timestamp!.intValue
								})
							}

						}

						DispatchQueue.main.async {
							self.tableView.reloadData()
						}
					}
				})
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

	fileprivate func fetchUserAndSetupNavbarTitle() {
		let uid = Auth.auth().currentUser?.uid
		Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value) { (snapshot) in
			if let user = self.bindingUserFrom(snapshot: snapshot){
				self.userInfo = user
				self.navigationItem.title = user.name
				self.setupNavigationTitleView()
			}
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

	fileprivate func setupNavigationTitleView() {
		yesterdayItems.removeAll()
		lastweekItems.removeAll()
		last2weeksItems.removeAll()
		lastMonthItems.removeAll()

		// Update UI
		tableView.reloadData()

		// Fetch data by account.
		observerUserMessages()
	}

	func editItem(item: Item?, userInfo: User?){
		let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
		chatLogController.item = item
		chatLogController.user = userInfo
		self.tabBarController?.navigationController?.pushViewController(chatLogController, animated: true)
	}

}
