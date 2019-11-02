//
//  NewMessageViewController.swift
//  gameofChat
//
//  Created by thinhmai on 7/16/19.
//  Copyright © 2019 thinhmai. All rights reserved.
//

import UIKit
import Firebase

class NewMessageViewController: UITableViewController {

	let cellID = "cellId"

	var users = [User]()
	var itemDelegate : ItemProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
		self.tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
		fetchUsers()
    }

	func fetchUsers(){
		Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in

			if let dictionary = snapshot.value as? [String: AnyObject]{
				if let user = User.bindingUserFrom(snapshot: snapshot) {
					self.users.append(user)
					DispatchQueue.main.async {
						self.tableView.reloadData()
					}
				}

			}
		})
	}

	@objc func handleCancel(){
		dismiss(animated: true, completion: nil)
	}

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! UserCell
		let user = users[indexPath.row]
		cell.textLabel?.text = user.name
		cell.detailTextLabel?.text = user.email

		if let profileImageUrl = user.profileImageUrl {
			cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
		}

        return cell
    }

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 56
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		dismiss(animated: true) {
			let user = self.users[indexPath.row]
			self.itemDelegate?.createNewItem(user: user)
		}

	}


}
