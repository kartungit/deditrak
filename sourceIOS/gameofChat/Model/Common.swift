//
//  Common.swift
//  gameofChat
//
//  Created by Nga Thien Nguyen on 11/2/19.
//  Copyright © 2019 thinhmai. All rights reserved.
//

import Foundation

class Common{

	static let API_NEW_ITEM = "http://192.168.100.130:8080/items/create"
	static let API_UPDATE_ITEM = "http://192.168.100.130:8080/items/update"
	static let API_SEARCH = "http://192.168.100.130:8080/items/search"

	static let emptyText : String = "---"
	static let username = ["Ngà", "Thịnh", "Huy", "Đại", "Anh", "Trang", "Tường", "Lâm", "Ngọc", "Đức", "Chung", "Dương", "Khánh", "Tuấn", "Hợi", "Thiện", "Toàn", "Ngân", "Nga", "Ngọc", "Lam", ]
	static let categorys = ["---", "Paper", "Books", "Devices"]
	static let offices = ["---", "CH", "TS", "TV", "US"]

	static let STATUS_NEW = "NEW"
	static let STATUS_INPROGRESS = "INPROGRESS"
	static let STATUS_RECEIVED = "RECEIVED"
	static let STATUS_DELIVERIED = "DELIVERED"

}
