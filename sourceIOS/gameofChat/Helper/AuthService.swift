//
//  AuthService.swift
//  gameofChat
//
//  Created by thinhmai on 10/21/19.
//  Copyright © 2019 thinhmai. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
class AuthService {
	let userInfo: User
	private init(user: User) {
		self.userInfo = user
	}
//	private static var getCurrentUser: User = {
//
//		return self.userInfo
//	}
//
//	class func shared() -> User {
//		return getCurrentUser
//	}
}
