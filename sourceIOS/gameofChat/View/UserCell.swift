//
//  UserCell.swift
//  gameofChat
//
//  Created by thinhmai on 7/24/19.
//  Copyright © 2019 thinhmai. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {

	var item: Item? {
		didSet {
			guard let item = item else {
				return
			}

			self.detailTextLabel?.text = item.title
			if let toId = item.toId {
				let ref = Database.database().reference().child("users").child(toId)
				ref.observeSingleEvent(of: .value) { (snapshot) in
					print(snapshot)
					if let dictionary = snapshot.value as? [String: Any] {
						self.textLabel?.text = dictionary["name"] as? String
						if let profileImageUrl = dictionary["profileImageUrl"] as? String {
							self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
						}
					}
				}
			}
			detailTextLabel?.text = item.title
			if let seconds = item.timestamp?.doubleValue {
				let timestampDate = NSDate(timeIntervalSince1970: seconds)
				let dateFormatter = DateFormatter()
				dateFormatter.dateFormat = "hh:mm:ss a"
				timeLabel.text = dateFormatter.string(from: timestampDate as Date)

			}
		}
	}

	let profileImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.layer.cornerRadius = 20
		imageView.layer.masksToBounds = true
		return imageView
	}()

	let timeLabel: UILabel = {
		let label = UILabel()
//		label.text = "HH:MM:SS"
		label.font = UIFont.systemFont(ofSize: 13)
		label.textColor = UIColor.lightGray
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()


	override func layoutSubviews() {
		super .layoutSubviews()
		textLabel?.frame = CGRect(x: 56, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
		detailTextLabel?.frame = CGRect(x: 56, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
		timeLabel.heightAnchor.constraint(equalToConstant: 23).isActive = true

	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style:.subtitle, reuseIdentifier: reuseIdentifier)

		addSubview(profileImageView)
		addSubview(timeLabel)

		//auto layout

		profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
		profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
		profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
		profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true

		timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 8).isActive = true
		timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
		timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true

	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

