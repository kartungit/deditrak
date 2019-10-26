//
//  PhoneCell.swift
//  gameofChat
//
//  Created by thinhmai on 10/23/19.
//  Copyright © 2019 thinhmai. All rights reserved.
//

import UIKit

class PhoneCell: UITableViewCell {
	var office:String?{
		didSet{
			if let office = office {
				title.text = "\(office) office:"
			}
		}
	}
	var phoneNumber:String?{
		didSet{
			phoneLabel.text = phoneNumber
		}
	}

	let title : UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 16)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	let imgPhone :UIImageView = {
		let img =  UIImageView(image: UIImage(named: "phone"))
		img.translatesAutoresizingMaskIntoConstraints = false
		return img
	}()
	let phoneLabel : UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	override func layoutSubviews() {
		super .layoutSubviews()
//		generatePhoneView(office: office!, number: phoneNumber!)
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style:style, reuseIdentifier: reuseIdentifier)
		generatePhoneView()

	}

	func generatePhoneView(){

		addSubview(title)
		addSubview(imgPhone)
		addSubview(phoneLabel)

		// auto layout

		title.topAnchor.constraint(equalTo: self.topAnchor,constant: 8).isActive = true
		title.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
		title.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 8).isActive = true
		title.heightAnchor.constraint(equalToConstant: 30).isActive = true

		imgPhone.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4).isActive = true
		imgPhone.leftAnchor.constraint(equalTo: title.leftAnchor).isActive = true
		imgPhone.heightAnchor.constraint(equalToConstant: 36).isActive = true
		imgPhone.widthAnchor.constraint(equalToConstant: 36).isActive = true

		phoneLabel.leftAnchor.constraint(equalTo: imgPhone.rightAnchor,constant: 8).isActive = true
		phoneLabel.topAnchor.constraint(equalTo: imgPhone.topAnchor).isActive = true
		phoneLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
		phoneLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -16).isActive = true


	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
