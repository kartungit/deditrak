//
//  Item.swift
//  gameofChat
//
//  Created by thinhmai on 10/21/19.
//  Copyright © 2019 thinhmai. All rights reserved.
//

import UIKit
import FirebaseDatabase

class Item: NSObject {
	var itemId: String?
	var fromId: String?
	var timestamp: NSNumber?
	var toId: String?
	var title: String?
	var category: String?
	var fromOffice: String?
	var toOffice: String?
	var quantity: String?
	var reciever: String?
	var sender: String?
	var status: String?

	static func createTestItem() -> Item{
		let item : Item = Item()
		item.itemId = "1abc"
		item.fromId = "2abc"
		item.timestamp = Date().timeIntervalSinceNow as NSNumber
		item.toId = "3abc"
		item.title = "Hello"
		item.category = "Paper"
		item.fromOffice = "Cong Hoa"
		item.toOffice = "Truong Son"
		item.quantity = "1"
		item.reciever = "Huy"
		item.sender = "Nga"
		item.status = "New"
		return item
	}

	static func bindingItemFrom(snapshot : DataSnapshot) -> Item? {
		if let dictionary = snapshot.value as? [String: Any] {
			return bindingItemFromDictionary(dictionary: dictionary)
		}
		return nil
	}

	static func bindingItemFromDictionary(dictionary : [String: Any]) -> Item? {
			let item = Item()
			item.itemId = dictionary["itemId"] as? String
			item.toId = dictionary["toId"] as? String
			item.fromId = dictionary["fromId"] as? String
			item.title = dictionary["title"] as? String
			item.category = dictionary["category"] as? String
			item.fromOffice = dictionary["fromOffice"] as? String
			item.toOffice = dictionary["toOffice"] as? String
			item.quantity = dictionary["quantity"] as? String
			item.reciever = dictionary["receiver"] as? String
			item.sender = dictionary["sender"] as? String
			item.status = dictionary["status"] as? String
			item.timestamp = dictionary["timestamp"] as? NSNumber
			return item

	}
}
