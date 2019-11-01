//
//  Item.swift
//  gameofChat
//
//  Created by thinhmai on 10/21/19.
//  Copyright © 2019 thinhmai. All rights reserved.
//

import UIKit

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
}
