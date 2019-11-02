//
//  ChatLogController.swift
//  gameofChat
//
//  Created by thinhmai on 7/23/19.
//  Copyright © 2019 thinhmai. All rights reserved.
//

import UIKit
import Firebase
import DropDown
import SearchTextField
import Alamofire

class ChatLogController : UICollectionViewController, UITextFieldDelegate {

	var user: User? {
		didSet {
			if let userData = user, let itemData = self.item {
				if itemData.fromOffice != userData.office {
					self.isEditable = false
				}
				self.viewDetailMode = true
			}
		}
	}
	var viewDetailMode = false
	var isEditable = true
	var item: Item!
	var updating = false
	var deleting = false

	lazy var containerView : UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	lazy var inputTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "Enter title..."
		textField.borderStyle = UITextField.BorderStyle.roundedRect
		textField.addTarget(self, action: #selector(validationInput), for: UIControl.Event.editingChanged)
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.delegate = self
		textField.isEnabled = self.isEditable
		return textField
	}()

	lazy var categoryButton : UIButton = {
		let button = UIButton()
		button.backgroundColor = UIColor(r: 136, g: 187, b: 233)
		button.layer.cornerRadius = 10
		button.setTitle("Category", for: .normal)
		button.addTarget(self, action: #selector(adjustCategory), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.isEnabled = self.isEditable
		return button
	}()

	lazy var quantityTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "Enter quantity..."
		textField.borderStyle = UITextField.BorderStyle.roundedRect
		textField.addTarget(self, action: #selector(validationInput), for: UIControl.Event.editingChanged)
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.delegate = self
		textField.keyboardType = .numberPad
		textField.isEnabled = self.isEditable
		return textField
	}()

	lazy var fromOfficeButton : UIButton = {
		let button = UIButton()
		button.backgroundColor = UIColor(r: 136, g: 187, b: 233)
		button.layer.cornerRadius = 10
		button.setTitle("From office", for: .normal)
//		button.addTarget(self, action: #selector(adjustOfficeSend), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	lazy var toOfficeButton : UIButton = {
		let button = UIButton()
		button.backgroundColor = UIColor(r: 136, g: 187, b: 233)
		button.layer.cornerRadius = 10
		button.setTitle("To office", for: .normal)
		button.addTarget(self, action: #selector(adjustOfficeRecieve), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.isEnabled = self.isEditable
		return button
	}()

	lazy var senderTextField: SearchTextField = {
		let textField = SearchTextField()
		textField.placeholder = "Sender"
		textField.borderStyle = UITextField.BorderStyle.roundedRect
		textField.addTarget(self, action: #selector(validationInput), for: UIControl.Event.editingChanged)
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.delegate = self
		textField.isEnabled = self.isEditable
		textField.filterStrings(Common.username)
		return textField
	}()

	lazy var recieverTextField: SearchTextField = {
		let textField = SearchTextField()
		textField.placeholder = "Reciever"
		textField.borderStyle = UITextField.BorderStyle.roundedRect
		textField.addTarget(self, action: #selector(validationInput), for: UIControl.Event.editingChanged)
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.delegate = self
		textField.isEnabled = self.isEditable
		textField.filterStrings(Common.username)
		return textField
	}()

	lazy var sendButton : UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle(self.viewDetailMode ? "Save" : "Create", for: .normal)
		button.setTitleColor(.blue, for: .normal)
		button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
		button.isHidden = self.viewDetailMode && !self.isEditable
		return button
	}()

	lazy var deleteButton : UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("Delete", for: .normal)
		button.setTitleColor(.red, for: .normal)
		button.addTarget(self, action: #selector(handleDeleteItem), for: .touchUpInside)
		button.isHidden = !(self.viewDetailMode && self.isEditable)
		return button
	}()


	override func viewDidLoad() {
		super .viewDidLoad()
		collectionView?.backgroundColor = .white

		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
		view.addGestureRecognizer(tap)

		self.navigationItem.title = "New Item"
		self.updating = false
		self.deleting = false
	}

	@objc func dismissKeyboard() {
		//Causes the view (or one of its embedded text fields) to resign the first responder status.
		view.endEditing(true)
	}
	func bindingUserFrom(snapshot: DataSnapshot) -> User? {
		let user = User(id: "")
		if let dictionary = snapshot.value as? [String: Any] {
			user.office = dictionary["office"] as? String
			user.id = dictionary["id"] as? String
			user.email = dictionary["email"] as? String
			user.name = dictionary["name"] as? String
		}
		return user
	}
	override func viewWillAppear(_ animated: Bool) {
		super .viewWillAppear(animated)
		guard let uid = Auth.auth().currentUser?.uid else {
			return
		}
		let userRef = Database.database().reference().child("users").child(uid)
		userRef.observeSingleEvent(of: .value) { (snapshot) in
			if let user = self.bindingUserFrom(snapshot: snapshot) {
				self.user = user
				if self.item == nil {
					// create item mode
					self.fromOfficeButton.setTitle(user.office, for: .normal)
				}
			}
		}
		setupInputComponent()
		sendButtonIsActive(active: false)
	}

	func setupInputComponent() {
		view.addSubview(containerView)
		view.insetsLayoutMarginsFromSafeArea = true

		//auto layout
		containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
		containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant:  -16).isActive = true
		containerView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true

		containerView.addSubview(sendButton)
		containerView.addSubview(deleteButton)

		//auto layout
		sendButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
		sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
		sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
		sendButton.heightAnchor.constraint(equalToConstant: 80).isActive = true

		deleteButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
		deleteButton.topAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: 12).isActive = true
		deleteButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
		deleteButton.heightAnchor.constraint(equalToConstant: 80).isActive = true


		containerView.addSubview(inputTextField)
		if let title = item?.title {
			inputTextField.text = title
		}

		//auto layout
		inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
		inputTextField.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
		inputTextField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8).isActive = true
		inputTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true

		containerView.addSubview(categoryButton)
		if let category = item?.category {
			categoryButton.setTitle(category, for: .normal)
		}

		//auto layout
		categoryButton.leftAnchor.constraint(equalTo: inputTextField.leftAnchor).isActive = true
		categoryButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
		categoryButton.topAnchor.constraint(equalTo: inputTextField.bottomAnchor, constant: 8).isActive = true
		categoryButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

		setupQuantityTextfield(currentQuantity: item?.quantity)
		setupFromOfficeButton(office: item?.fromOffice)
		setupToOfficeButton(office: item?.toOffice)
		setupSenderTextField(sender: item?.sender)
		setupRecieverTextField(receiver: item?.reciever)
	}

	func setupQuantityTextfield(currentQuantity: String? = nil) {
		if let quantity = currentQuantity {
			quantityTextField.text = String(quantity)
		}

		self.containerView.addSubview(self.quantityTextField)

		// auto layout
		quantityTextField.leftAnchor.constraint(equalTo: self.categoryButton.rightAnchor, constant: 16).isActive = true
		quantityTextField.rightAnchor.constraint(equalTo: self.containerView.rightAnchor).isActive = true
		quantityTextField.topAnchor.constraint(equalTo: inputTextField.bottomAnchor, constant: 8).isActive = true
		quantityTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
	}

	func setupFromOfficeButton(office: String? = nil) {
		if let title = office {
			fromOfficeButton.setTitle(title, for: .normal)
		}
		containerView.addSubview(fromOfficeButton)

		//autolayout
		fromOfficeButton.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
		fromOfficeButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.45).isActive = true
		fromOfficeButton.topAnchor.constraint(equalTo: quantityTextField.bottomAnchor, constant: 8).isActive = true
		fromOfficeButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
	}

	func setupToOfficeButton(office: String? = nil) {
		if let title = office {
			toOfficeButton.setTitle(title, for: .normal)
		}
		containerView.addSubview(toOfficeButton)

		//autolayout
		toOfficeButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
		toOfficeButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.45).isActive = true
		toOfficeButton.topAnchor.constraint(equalTo: fromOfficeButton.topAnchor).isActive = true
		toOfficeButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
	}
	func setupSenderTextField(sender: String? = nil) {
		if let text = sender {
			senderTextField.text = text
		}
		containerView.addSubview(senderTextField)

		//autolayout
		senderTextField.leftAnchor.constraint(equalTo: fromOfficeButton.leftAnchor).isActive = true
		senderTextField.widthAnchor.constraint(equalTo: fromOfficeButton.widthAnchor).isActive = true
		senderTextField.topAnchor.constraint(equalTo: fromOfficeButton.bottomAnchor, constant: 4).isActive = true
		senderTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
	}
	func setupRecieverTextField(receiver: String? = nil) {
		if let text = receiver {
			recieverTextField.text = text
		}
		containerView.addSubview(recieverTextField)

		//autolayout
		recieverTextField.leftAnchor.constraint(equalTo: toOfficeButton.leftAnchor).isActive = true
		recieverTextField.widthAnchor.constraint(equalTo: toOfficeButton.widthAnchor).isActive = true
		recieverTextField.topAnchor.constraint(equalTo: senderTextField.topAnchor).isActive = true
		recieverTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
	}

	@objc func adjustCategory(){
		let button = DropDown()
		button.anchorView = self.categoryButton
		button.dataSource = ["Paper", "Books", "Devices"]
		button.selectionAction = { [unowned self] (index: Int, item: String) in
			DispatchQueue.main.async {
				self.categoryButton.setTitle(item, for: .normal)
				self.validationInput()
			}
		}
		button.show()
	}

	@objc func adjustOfficeSend(){
		let button = DropDown()
		button.anchorView = self.fromOfficeButton
		button.dataSource = ["CH", "TS", "TV", "US"]
		button.selectionAction = { [unowned self] (index: Int, item: String) in
			DispatchQueue.main.async {
				self.fromOfficeButton.setTitle(item, for: .normal)
			}
		}
		button.show()
	}

	@objc func adjustOfficeRecieve(){
		let button = DropDown()
		var source = ["CH", "TS", "TV", "US"].filter { $0 != self.user?.office }
//		source.removeAll(where: $0 == self.user?.office)
		button.anchorView = self.toOfficeButton
		button.dataSource = source as! [String]
		button.selectionAction = { [unowned self] (index: Int, item: String) in
			DispatchQueue.main.async {
				self.toOfficeButton.setTitle(item, for: .normal)
				self.validationInput()
			}
		}
		button.show()
	}

	@objc func validationInput(){
		if inputTextField.text != "" && quantityTextField.text != "" && senderTextField.text != "" && recieverTextField.text != "" {
			sendButtonIsActive(active: true)
		} else {
			sendButtonIsActive(active: false)
		}
	}

	func sendButtonIsActive(active: Bool){
		if active {
			sendButton.isEnabled = true
			sendButton.setTitleColor(UIColor(r: 9, g: 0, b: 233), for: .normal)
		} else {
			sendButton.isEnabled = false
			sendButton.setTitleColor(UIColor(r: 136, g: 187, b: 233), for: .disabled)
		}
	}

	@objc func handleSend() {
		if (updating){
			print("is updating ...")
			return
		}
		updating = true

		let fromId = Auth.auth().currentUser!.uid
		let timestamp: Int = Int(NSDate().timeIntervalSince1970)
		guard let category = categoryButton.titleLabel?.text, category != "Category" else {
			alertWith(message: "Category is required")
			updating = false
			return
		}
		guard let fromOffice = fromOfficeButton.titleLabel?.text, fromOffice != "From office" else {
			alertWith(message: "from Office is required")
			updating = false
			return
		}
		guard let toOffice = toOfficeButton.titleLabel?.text, toOffice != "To office" else {
			alertWith(message: "to Office is required")
			updating = false
			return
		}

		let appDelegate = UIApplication.shared.delegate as! AppDelegate

		var value = ["title": inputTextField.text!,
					 "fromId": fromId,
					 "timestamp": timestamp,
					 "category": category,
					 "fromOffice" : fromOffice,
					 "toOffice": toOffice,
					 "quantity": quantityTextField.text!,
					 "sender" : senderTextField.text!,
					 "receiver": recieverTextField.text!,
					 "status" : Common.STATUS_NEW,
					 "userId" : appDelegate.userInfo.id ?? ""] as [String : Any]

		let ref = Database.database().reference().child("messages")
		let childRef = (self.viewDetailMode) ? ref.child(item.itemId!) : ref.childByAutoId()
		childRef.updateChildValues(value) {[weak self] (error, ref) in
			if error != nil {
				print(error!)
				self!.updating = false
				return;
			}

			// send UDID to server to same with Firebase
			value["uid"] = childRef.key

			if self!.viewDetailMode == false {
				let userMessagesRef = Database.database().reference().child("user-messages").child(fromOffice)
				let messageId = childRef.key as! String
				userMessagesRef.updateChildValues([messageId: "TODO"]) {
					(error, ref) in
					if error != nil {
						print(error!)
						self!.updating = false
						return
					}
				}

				childRef.updateChildValues(["itemId": messageId])
				let recipientUserMessage = Database.database().reference().child("user-messages").child(toOffice)
				recipientUserMessage.updateChildValues([messageId: "TODO"])

				// call api create new ITEM
				self!.newItem(parameters: value)
			}
			else{
				// update
				// call api create Update ITEM
				self?.updateItem(parameters: value)
			}
			 self!.navigationController?.popViewController(animated: true)

		}
	}

	@objc func handleDeleteItem(){

		if (self.deleting){
			print("is deleting ...")
			return
		}

		self.deleting = true

		let alert = UIAlertController(title: "Alert", message: "Are you sure to remove this item?", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
			let ref = Database.database().reference().child("messages").child(self.item.itemId!)
			let fromOfficeRef = Database.database().reference().child("user-messages").child(self.item.fromOffice!).child(self.item.itemId!)
			let toOfficeRef = Database.database().reference().child("user-messages").child(self.item.toOffice!).child(self.item.itemId!)
			ref.removeValue()
			fromOfficeRef.removeValue()
			toOfficeRef.removeValue()

			self.deleteItem(uid: self.item.itemId!)
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
			self.deleting = false
		}))
		self.present(alert, animated: true, completion: nil)
	}

	func alertWith(message: String){
		let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}

	func newItem(parameters: [String: Any]){
		guard let url = URL(string: Common.API_NEW_ITEM) else {
			showAlert(message: "Can't connect to api, please check your server again.")
			self.updating = false
			return
		}

		var urlRequest = URLRequest(url: url)
		urlRequest.httpMethod = "POST"

		do {
			urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
		} catch {
			// No-op
		}

		urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

		print(parameters)

		AF.request(urlRequest)
		.responseJSON { (response: DataResponse) in
			switch response.result {
			case .success(let json):
				print(json)
				if let jsonArray = json as? [[String: Any]] {
					print(jsonArray)
				}

				DispatchQueue.main.async {
					self.updating = false
					self.navigationController?.popViewController(animated: true)
				}
				break
			case .failure(let error):
				print(error.localizedDescription)
				self.updating = false
				DispatchQueue.main.async {
					self.showAlert(message: "Search failed with error: \(error.localizedDescription)")
				}
				break
			}
		}
	}

	func updateItem(parameters: [String: Any]){
		guard let url = URL(string: Common.API_UPDATE_ITEM) else {
			showAlert(message: "Can't connect to api, please check your server again.")
			self.updating = false
			return
		}

		var urlRequest = URLRequest(url: url)
		urlRequest.httpMethod = "PUT"

		do {
			urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
		} catch {
			// No-op
		}

		urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

		print(parameters)

		AF.request(urlRequest)
			.responseJSON { (response: DataResponse) in
				switch response.result {
				case .success(let json):
					print(json)
					if let jsonArray = json as? [[String: Any]] {
						print(jsonArray)
					}
					self.updating = false
					DispatchQueue.main.async {
						//
						self.navigationController?.popViewController(animated: true)
					}

					break
				case .failure(let error):
					print(error.localizedDescription)
					self.updating = false
					DispatchQueue.main.async {
						self.showAlert(message: "Search failed with error: \(error.localizedDescription)")
					}
					break
				}
		}
	}

	func deleteItem(uid: String){
		guard let url = URL(string: Common.API_DELETE_ITEM) else {
			showAlert(message: "Can't connect to api, please check your server again.")
			self.deleting = false
			return
		}

		print("delete \(uid)")

		AF.request(url, method: .delete, parameters: ["uid": uid])
			.validate()
			.responseJSON { (response: DataResponse) in
				switch response.result {
				case .success(let json):
					print(json)
					if let jsonArray = json as? [[String: Any]] {
						print(jsonArray)
					}
					self.deleting = false
					DispatchQueue.main.async {
						self.navigationController?.popViewController(animated: true)
					}
					break
				case .failure(let error):
					print(error.localizedDescription)
					self.deleting = false
					DispatchQueue.main.async {
						self.showAlert(message: "Search failed with error: \(error.localizedDescription)")
					}
					break
				}
		}
	}

	func showAlert(message:String){
		let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)

		alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))

		self.present(alert, animated: true)
	}

}
