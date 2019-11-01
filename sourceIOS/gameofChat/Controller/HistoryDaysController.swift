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

class HistoryDaysController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	@IBOutlet weak var tableView: UITableView!

	//let sections = ["Yesterday", "Last 7 days", "Last 14 days", "Last 30 days"]
	let cellId = "cellId"
	var historyDays : Int = 0

	var userInfo: User!

	var historyItems = [Item]()

	override func viewDidLoad() {
        super.viewDidLoad()

		switch historyDays {
		case 1:
			self.navigationItem.title = "Yesterday"
			break
		case 7:
			self.navigationItem.title = "Last 7 days"
			break
		case 14:
			self.navigationItem.title = "Last 14 days"
			break
		default:
			self.navigationItem.title = "Last 30 days"
			break
		}

        // Do any additional setup after loading the view.
		self.tableView.dataSource = self
		self.tableView.delegate = self
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

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return historyItems.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ItemCell
		let item : Item? = self.historyItems[indexPath.row];

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

							if (distance <= self.historyDays){
								self.historyItems.append(item)
								self.historyItems.sort(by: { (message1, message2) -> Bool in
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
			if let user = User.bindingUserFrom(snapshot: snapshot){
				self.userInfo = user
				let appDelegate = UIApplication.shared.delegate as! AppDelegate
				appDelegate.userInfo = user
				
				// self.navigationItem.title = user.name
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
		historyItems.removeAll()
		
		// Update UI
		tableView.reloadData()

		// Fetch data by account.
		observerUserMessages()
	}

	func editItem(item: Item?, userInfo: User?){
		let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
		chatLogController.item = item
		chatLogController.user = userInfo
		self.navigationController?.pushViewController(chatLogController, animated: true)
	}

}
