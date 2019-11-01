//
//  User.swift
//  gameofChat
//
//  Created by thinhmai on 7/16/19.
//  Copyright © 2019 thinhmai. All rights reserved.
//

import Foundation
import FirebaseDatabase

class User: NSObject {
	var id: String?
	var office: String?
	var name: String?
	var email: String?
	var profileImageUrl: String?

	static func bindingUserFrom(snapshot: DataSnapshot) -> User? {
		let user = User()
		if let dictionary = snapshot.value as? [String: Any] {
			user.office = dictionary["office"] as? String
			user.id = dictionary["id"] as? String
			user.email = dictionary["email"] as? String
			user.name = dictionary["name"] as? String
		}
		return user
	}
}
