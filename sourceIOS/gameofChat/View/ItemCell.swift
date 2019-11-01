//
//  ItemCell.swift
//  gameofChat
//
//  Created by thinhmai on 10/21/19.
//  Copyright © 2019 thinhmai. All rights reserved.
//

import UIKit
import Firebase
import FontAwesome_swift

class ItemCell: UITableViewCell {

	var item: Item? {
		didSet {
			guard let item = item else {
				return
			}
			if let seconds = item.timestamp?.doubleValue {
				let timestampDate = NSDate(timeIntervalSince1970: seconds)
				let dateFormatter = DateFormatter()
				dateFormatter.dateFormat = "HH:mm dd-MM-yyyy"
				timeLabel.text = dateFormatter.string(from: timestampDate as Date)

			}
			titleLabel.text = item.title
			categoryLabel.text = "Quantity: \(String(describing: item.quantity!))"
			statusLabel.text = item.status
			renderOfficeLable(label: fromOfficeLabel, text: item.fromOffice!)
			renderOfficeLable(label: toOfficeLabel, text: item.toOffice!)
			senderRecieverLabel.text = "\(String(describing: item.sender? = "")) to \(String(describing: item.reciever? = ""))"
		}
	}
	var user: User? {
		didSet {
			guard let itemData = item, let userData = user else {
				return
			}
			hideNext = (userData.office == itemData.fromOffice && (itemData.status == "In Progress" || itemData.status == "Recieved")) || itemData.status == "Deliveried"
		}
	}
	var hideNext = false

	let timeLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 13)
		label.textAlignment = .right
		label.textColor = UIColor.lightGray
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	let statusLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 15)
		label.numberOfLines = 1
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	let officesView : UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	let fromOfficeLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 18)
		label.numberOfLines = 1
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	let downIconLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 1
		label.font = UIFont.fontAwesome(ofSize: 18, style: .solid)
		label.text = String.fontAwesomeIcon(name: .angleDoubleDown)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	let toOfficeLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 18)
		label.numberOfLines = 1
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	let titleLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 18)
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	let senderRecieverLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 16)
		label.numberOfLines = 1
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	let categoryLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14)
		label.numberOfLines = 1
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	let nextButton: ButtonExtended = {
		let button = ButtonExtended()
//		button.backgroundColor = UIColor(r: 5, g: 10, b: 200)
//		button.setTitle("Next", for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	lazy var widthConstraint = nextButton.widthAnchor.constraint(lessThanOrEqualToConstant: 60)


	override func layoutSubviews() {
		super .layoutSubviews()
		setupNextButton()

	}

	func renderOfficeLable(label: UILabel,text: String){
		if text == user?.office {
			label.font = UIFont.fontAwesome(ofSize: 24, style: .solid)
			label.text = String.fontAwesomeIcon(name: .home)
		} else {
			label.text = text
		}
	}

	func setupOfficesView(){
		self.addSubview(officesView)
		officesView.addSubview(fromOfficeLabel)
		officesView.addSubview(downIconLabel)
		officesView.addSubview(toOfficeLabel)

		// auto layout
		officesView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
		officesView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
		officesView.widthAnchor.constraint(equalToConstant: 50).isActive = true
		officesView.heightAnchor.constraint(equalToConstant: 80).isActive = true

		fromOfficeLabel.topAnchor.constraint(equalTo: officesView.topAnchor, constant: 8).isActive = true

		downIconLabel.topAnchor.constraint(equalTo: fromOfficeLabel.bottomAnchor, constant: 12).isActive = true
		downIconLabel.centerXAnchor.constraint(equalTo: fromOfficeLabel.centerXAnchor).isActive = true

		toOfficeLabel.topAnchor.constraint(equalTo: downIconLabel.bottomAnchor, constant: 12).isActive = true

	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		addSubview(timeLabel)
		addSubview(statusLabel)
		addSubview(titleLabel)
		addSubview(categoryLabel)
		addSubview(senderRecieverLabel)
		addSubview(nextButton)
		self.setupOfficesView()

		//		auto layout

		titleLabel.leftAnchor.constraint(equalTo: officesView.rightAnchor, constant: 8).isActive = true
		titleLabel.rightAnchor.constraint(equalTo: nextButton.leftAnchor,constant: -4).isActive = true
		titleLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 2).isActive = true

		timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -4).isActive = true
		timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 4).isActive = true
		timeLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
		timeLabel.heightAnchor.constraint(equalToConstant: 23).isActive = true


		categoryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4).isActive = true
		categoryLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor).isActive = true
		categoryLabel.rightAnchor.constraint(equalTo: titleLabel.rightAnchor).isActive = true

		senderRecieverLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 8).isActive = true
		senderRecieverLabel.leftAnchor.constraint(equalTo: categoryLabel.leftAnchor).isActive = true
		senderRecieverLabel.rightAnchor.constraint(equalTo: categoryLabel.rightAnchor).isActive = true

		statusLabel.leftAnchor.constraint(equalTo: officesView.leftAnchor).isActive = true
		statusLabel.topAnchor.constraint(equalTo: senderRecieverLabel.bottomAnchor, constant: 2).isActive = true
		statusLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
		statusLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
		statusLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 8).isActive = true


	}


	func setupNextButton(){
		// TODO : add more logic for visibility of the button
		nextButton.rightAnchor.constraint(equalTo: self.rightAnchor,constant: -16).isActive = true
		nextButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
		nextButton.topAnchor.constraint(equalTo: self.timeLabel.bottomAnchor, constant: 8).isActive = true
		widthConstraint.isActive = true
		widthConstraint.constant = hideNext ? 0 : 60
		nextButton.isHidden = hideNext
		nextButton.setImage(self.getStatusIcon(status: item?.status), for: .normal)
		nextButton.imageView?.contentMode = .scaleAspectFit

	}

	func getStatusIcon(status: String?) -> UIImage?{
			guard let currentStatus = status else {
				return UIImage(named: "new")
			}
			switch currentStatus {
			case "New":
				return UIImage(named: "in_progress")
			case "In Progress":
				return UIImage(named: "recieved")
			case "Recieved":
				return UIImage(named: "delivered")
			case "Deliveried":
				return UIImage(named: "delivered")
			default:
				return UIImage(named: "new")
			}
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

