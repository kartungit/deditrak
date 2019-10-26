//
//  LoginController.swift
//  gameofChat
//
//  Created by thinhmai on 7/11/19.
//  Copyright © 2019 thinhmai. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginController: UIViewController {

	let inputContainerView: UIView = {
		let view = UIView()
		return view
	}()

	let loginRegisterButton: UIButton = {
		let button = UIButton(type: .system)
		button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
		button.setTitle("Register", for: .normal)
		button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
		button.setTitleColor(.white, for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false

		button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)

		return button
	}()

	@objc func handleLoginRegister(){
		if loginRegisterSegmentControl.selectedSegmentIndex == 0 {
			handleLogin()
		} else {
			handleRegister()
		}

	}
	func handleLogin(){
		guard let email = emailTextField.text, let password = passwordTextField.text else {
			print("Form is not valid")
			return
		}
		Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
			if (error as NSError?) != nil {
				let getError = error?.localizedDescription

				let alert = UIAlertController(title: "Error", message: getError, preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
				self.present(alert, animated: true, completion: nil)

				return
			}
			self.dismiss(animated: true, completion: nil)
		}
	}

	let nameTextField: UITextField = {
		let tf = UITextField()
		tf.placeholder = "Name"
		tf.translatesAutoresizingMaskIntoConstraints = false
		return tf
	}()

	let nameSeparatorView: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()


	let emailTextField: UITextField = {
		let tf = UITextField()
		tf.placeholder = "Email"
		tf.translatesAutoresizingMaskIntoConstraints = false
		return tf
	}()

	let emailSeparatorView: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()


	let passwordTextField: UITextField = {
		let tf = UITextField()
		tf.placeholder = "Password"
		tf.isSecureTextEntry = true
		tf.translatesAutoresizingMaskIntoConstraints = false
		return tf
	}()

	let passwordSeparatorView: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	lazy var profileImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = #imageLiteral(resourceName: "user")
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFill

		imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
		imageView.isUserInteractionEnabled = true
		return imageView
	}()

	let loginRegisterSegmentControl: UISegmentedControl = {
		let sc = UISegmentedControl(items: ["Login", "Register"])
		sc.translatesAutoresizingMaskIntoConstraints = false
		sc.tintColor = .white
		sc.selectedSegmentIndex = 1
		sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
		return sc
	}()


	@objc func handleLoginRegisterChange(){
		let title = loginRegisterSegmentControl.titleForSegment(at: loginRegisterSegmentControl.selectedSegmentIndex)
		loginRegisterButton.setTitle(title, for: .normal)

		//Change input field layout
		inputContainerViewHeightAnchor?.constant = loginRegisterSegmentControl.selectedSegmentIndex == 0 ? 100 : 150
		nameTextFieldHeightAnchor?.isActive = false
		nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: loginRegisterSegmentControl.selectedSegmentIndex == 0 ? 0 : 1/3)
		nameTextFieldHeightAnchor?.isActive = true

		passwordTextFieldHeightAnchor?.isActive = false
		passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: loginRegisterSegmentControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
		passwordTextFieldHeightAnchor?.isActive = true

		emailTextFielHeightAnchor?.isActive = false
		emailTextFielHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: loginRegisterSegmentControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
		emailTextFielHeightAnchor?.isActive = true
	}
	var inputContainerViewHeightAnchor : NSLayoutConstraint?
	var nameTextFieldHeightAnchor : NSLayoutConstraint?
	var passwordTextFieldHeightAnchor : NSLayoutConstraint?
	var emailTextFielHeightAnchor : NSLayoutConstraint?

	override func viewDidLoad() {
        super.viewDidLoad()

		view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
		view.addSubview(inputContainerView)
		view.addSubview(loginRegisterButton)
		view.addSubview(profileImageView)
		view.addSubview(loginRegisterSegmentControl)

		setupInputContainerView()
		setupLoginRegisterButton()
		setupProfileImageView()
		setuploginRegisterSegmentControl()
    }
	fileprivate func setupInputContainerView() {
		inputContainerView.backgroundColor = .white
		inputContainerView.translatesAutoresizingMaskIntoConstraints = false
		inputContainerView.layer.cornerRadius = 5
		inputContainerView.layer.masksToBounds = true

		//auto layout
		inputContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		inputContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		inputContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: -24).isActive = true
		inputContainerViewHeightAnchor = inputContainerView.heightAnchor.constraint(equalToConstant: 150)
		inputContainerViewHeightAnchor?.isActive = true

		inputContainerView.addSubview(nameTextField)
		inputContainerView.addSubview(nameSeparatorView)
		inputContainerView.addSubview(passwordTextField)
		inputContainerView.addSubview(passwordSeparatorView)
		inputContainerView.addSubview(emailTextField)
		inputContainerView.addSubview(emailSeparatorView)

		//auto layout
		nameTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
		nameTextField.topAnchor.constraint(equalTo: inputContainerView.topAnchor).isActive = true
		nameTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
		nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
		nameTextFieldHeightAnchor?.isActive = true

		//auto layout
		nameSeparatorView.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
		nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
		nameSeparatorView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
		nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true

		//auto layout
		emailTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
		emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
		emailTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
		emailTextFielHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
		emailTextFielHeightAnchor?.isActive = true

		//auto layout
		emailSeparatorView.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
		emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
		emailSeparatorView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
		emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true

		//auto layout
		passwordTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
		passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
		passwordTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
		passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
		passwordTextFieldHeightAnchor?.isActive = true

		//auto layout
		passwordSeparatorView.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
		passwordSeparatorView.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor).isActive = true
		passwordSeparatorView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
		passwordSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
	}

	fileprivate func setupLoginRegisterButton() {
		//auto layout
		loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		loginRegisterButton.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: 12).isActive = true
		loginRegisterButton.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
		loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
	}
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	fileprivate func setupProfileImageView() {
		//auto layout
		profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentControl.topAnchor, constant: -12).isActive = true
		profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
		profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
	}
	fileprivate func setuploginRegisterSegmentControl() {
		//auto layout
		loginRegisterSegmentControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		loginRegisterSegmentControl.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: -12).isActive = true
		loginRegisterSegmentControl.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
		loginRegisterSegmentControl.heightAnchor.constraint(equalToConstant: 36).isActive = true
	}

}

extension UIColor {
	convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
		self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
	}
}
