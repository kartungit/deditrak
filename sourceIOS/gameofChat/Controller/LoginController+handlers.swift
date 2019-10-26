//
//  LoginController+handlers.swift
//  gameofChat
//
//  Created by thinhmai on 7/17/19.
//  Copyright © 2019 thinhmai. All rights reserved.
//

import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {


	fileprivate func registerUserToDatabase(_ uid: String, values: [String: AnyObject]) {
		let ref = Database.database().reference()
		let usersReference = ref.child("users").child(uid)
		usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
			if err != nil {
				print(err)
				return
			}
			self.dismiss(animated: true, completion: nil)
		})
	}

	func handleRegister(){
		guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
			print("Form is not valid")
			return
		}
		Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
			guard let user = authResult?.user, error == nil else {
				print(" ERROR: \(String(describing: error))")
				return
			}
			// Successful register
			print("\(user.email!) created!!!!")
			Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
				guard let strongSelf = self else { return }
				// ...
				guard let uid = user?.user.uid else {
					return
				}
				let imageName = NSUUID().uuidString
				let storageRef = Storage.storage().reference().child("\(imageName).png")

				if let profileImage = strongSelf.profileImageView.image, let uploadData = profileImage.jpegData(compressionQuality: 0.1) {
					storageRef.putData(uploadData, metadata: nil, completion: {(metadata, err) in
						if err != nil {
							print(err)
							return
						}
						storageRef.downloadURL { (url, error) in
							guard let downloadURL = url else {
								// Uh-oh, an error occurred!
								return
							}

							let values = ["name": name, "email": email,
										  "profileImageUrl": downloadURL.absoluteString] as [String : AnyObject]
							strongSelf.registerUserToDatabase(uid, values: values)

						}
					})
				}
			}


		})

	}

	@objc func handleSelectProfileImageView() {
		let picker = UIImagePickerController()
		picker.delegate = self
		present(picker, animated: true, completion: nil)
	}

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		if let originalImage = info[UIImagePickerController.InfoKey.originalImage], let selectedImage = originalImage as? UIImage {
			print(selectedImage.size)

			profileImageView.image = selectedImage
		}
		dismiss(animated: true, completion: nil)

	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		print("Cancle picker")
		dismiss(animated: true, completion: nil)
	}
}
