//
//  User.swift
//  gameofChat
//
//  Created by thinhmai on 7/16/19.
//  Copyright © 2019 thinhmai. All rights reserved.
//

import Foundation
import FirebaseDatabase

class User: NSObject, NSCoding  {

	var id: String?
	var office: String?
	var name: String?
	var email: String?
	var profileImageUrl: String?
	var unseenNew: String?
	var unseenInProgress: String?
	var unseenRecieved: String?
	var unseenDeliveried: String?

	func encode(with aCoder: NSCoder) {
		aCoder.encode(id, forKey: "id")
		aCoder.encode(name, forKey: "name")
		aCoder.encode(office, forKey: "office")
		aCoder.encode(email, forKey: "email")
		aCoder.encode(unseenNew, forKey: "unseenNew")
		aCoder.encode(unseenInProgress, forKey: "unseenInProgress")
		aCoder.encode(unseenRecieved, forKey: "unseenRecieved")
		aCoder.encode(unseenDeliveried, forKey: "unseenDeliveried")
		aCoder.encode(profileImageUrl, forKey: "profileImageUrl")
	}

	required convenience init?(coder aDecoder: NSCoder) {
		let id = aDecoder.decodeObject(forKey: "id") as! String
		let name = aDecoder.decodeObject(forKey: "name") as! String
		let office = aDecoder.decodeObject(forKey: "office") as! String
		let email = aDecoder.decodeObject(forKey: "email") as! String
		let unseenNew = aDecoder.decodeObject(forKey: "unseenNew") as? String ?? ""
		let unseenInProgress = aDecoder.decodeObject(forKey: "unseenInProgress") as? String ?? ""
		let unseenRecieved = aDecoder.decodeObject(forKey: "unseenRecieved") as? String ?? ""
		let unseenDeliveried = aDecoder.decodeObject(forKey: "unseenDeliveried") as? String ?? ""
		let profileImageUrl = aDecoder.decodeObject(forKey: "profileImageUrl") as? String ?? ""
		self.init(id: id, name: name, office: office, email: email, unseenNew: unseenNew, unseenRecieved: unseenRecieved, unseenInProgress: unseenInProgress, unseenDeliveried: unseenDeliveried, profileImageUrl: profileImageUrl)
	}


	init(id: String, name: String, office: String, email: String, unseenNew: String, unseenRecieved:String, unseenInProgress: String, unseenDeliveried: String, profileImageUrl: String) {
		self.id = id
		self.name = name
		self.office = office
		self.email = email
		self.unseenNew = unseenNew
		self.unseenRecieved = unseenRecieved
		self.unseenInProgress = unseenInProgress
		self.unseenDeliveried = unseenDeliveried
		self.profileImageUrl = profileImageUrl
	}

	init(id: String){
		self.id = id
	}

	static func bindingUserFrom(snapshot: DataSnapshot) -> User? {
		let user = User(id: "")

		if let dictionary = snapshot.value as? [String: Any] {
			user.office = dictionary["office"] as? String
			user.id = snapshot.key
			user.email = dictionary["email"] as? String
			user.name = dictionary["name"] as? String
			user.unseenNew = dictionary["unseenNew"] as? String
			user.unseenInProgress = dictionary["unseenInProgress"] as? String
			user.unseenRecieved = dictionary["unseenRecieved"] as? String
			user.unseenDeliveried = dictionary["unseenDeliveried"] as? String
		}
		return user
	}
}
