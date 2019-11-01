//
//  SearchController.swift
//  gameofChat
//
//  Created by thinhmai on 10/21/19.
//  Copyright © 2019 thinhmai. All rights reserved.
//

import UIKit
import DropDown
import SearchTextField
import Alamofire

// https://github.com/apasccon/SearchTextField

class SearchController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var btnCategory: UIButton!
	@IBOutlet weak var btnFromOffice: UIButton!
	@IBOutlet weak var btnToOffice: UIButton!
	@IBOutlet weak var textSender: SearchTextField!
	@IBOutlet weak var textReceiver: SearchTextField!
	@IBOutlet weak var btnSearch: UIButton!
	@IBOutlet weak var lblNotFound: UILabel!
	@IBOutlet weak var tableResult: UITableView!

	let emptyText : String = "---"
	let username = ["Ngà", "Thịnh", "Huy", "Đại", "Anh", "Trang", "Tường", "Lâm", "Ngọc", "Đức", "Chung", "Dương", "Khánh", "Tuấn", "Hợi", "Thiện", "Toàn", "Ngân", "Nga", "Ngọc", "Lam", ]
	let categorys = ["---", "Paper", "Books", "Devices"]
	let offices = ["---", "CH", "TS", "TV", "US"]
	let cellId = "cellId"

	var searching : Bool = false
	var searchItems = [Item]()
	var userInfo: User!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		btnCategory.setTitle(emptyText, for: .normal)
		btnFromOffice.setTitle(emptyText, for: .normal)
		btnToOffice.setTitle(emptyText, for: .normal)

		// Set the array of strings you want to suggest
		textSender.filterStrings(username)
		textReceiver.filterStrings(username)

		tableResult.dataSource = self
		tableResult.delegate = self
		tableResult.register(ItemCell.self, forCellReuseIdentifier: cellId)

		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		self.userInfo = appDelegate.userInfo 
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

	@IBAction func categoryAction(_ sender: Any) {
		adjustCategory()
	}
	
	@IBAction func fromOfficeAction(_ sender: Any) {
		adjustOfficeSend()
	}

	@IBAction func toOfficeAction(_ sender: Any) {
		adjustOfficeRecieve()
	}

	@IBAction func searchAction(_ sender: Any) {
		search()
	}
	
	@objc func adjustCategory(){
		let button = DropDown()
		button.anchorView = self.btnCategory
		button.dataSource = self.categorys
		button.selectionAction = { [unowned self] (index: Int, item: String) in
			DispatchQueue.main.async {
				self.btnCategory.setTitle(item, for: .normal)
				//self.validationInput()
			}
		}
		button.show()
	}

	@objc func adjustOfficeSend(){
		let button = DropDown()
		button.anchorView = self.btnFromOffice
		button.dataSource = self.offices
		button.selectionAction = { [unowned self] (index: Int, item: String) in
			DispatchQueue.main.async {
				self.btnFromOffice.setTitle(item, for: .normal)
			}
		}
		button.show()
	}

	@objc func adjustOfficeRecieve(){
		let button = DropDown()
		button.anchorView = self.btnToOffice
		button.dataSource = self.offices
		button.selectionAction = { [unowned self] (index: Int, item: String) in
			DispatchQueue.main.async {
				self.btnToOffice.setTitle(item, for: .normal)
				//self.validationInput()
			}
		}
		button.show()
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return searchItems.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ItemCell
		let item : Item? = self.searchItems[indexPath.row];

		cell.item = item
		cell.user = userInfo

		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cell = tableView.cellForRow(at: indexPath) as! ItemCell
		editItem(item: cell.item, userInfo: self.userInfo)
	}

	// With Alamofire
	func search() {
		guard let url = URL(string: "http://192.168.100.130:8080/users/all") else {
			// print("Can't connect to URL")
			showAlert(message: "Can't connect to api, please check your server again.")
			return
		}

		if (searching){
			print("Search api is running ...")
			return
		}

		// turnon flat search
		searching = true

		AF.request(url, method: .get, parameters: ["title": "DiDeTrak"])
			.validate()
			.responseJSON { (response: DataResponse) in
				print("API DONE")
				self.searchItems.removeAll()

				if let status = response.response?.statusCode {
					if status != 200 {
						DispatchQueue.main.async {
							self.showAlert(message: "Please check your server again.")
						}
						// reset flat searching
						self.searching = false
						return
					}
				}

				switch response.result {
				case .success(let json):
					print(json)
					break
				case .failure(let error):
					DispatchQueue.main.async {
						self.showAlert(message: "Search failed with error: \(error.localizedDescription)")
					}
					break
				}

				self.searchItems.append(Item.createTestItem())
				self.searchItems.append(Item.createTestItem())
				self.searchItems.append(Item.createTestItem())
				self.searchItems.append(Item.createTestItem())
				self.searchItems.append(Item.createTestItem())
				self.searchItems.append(Item.createTestItem())

				// reset flat searching
				self.searching = false

				DispatchQueue.main.async {
					self.tableResult.reloadData()
				}
		}

	}

	func showAlert(message:String){
		let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)

		alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))

		self.present(alert, animated: true)
	}

	func editItem(item: Item?, userInfo: User?){
		let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
		chatLogController.item = item
		chatLogController.user = userInfo
		self.navigationController?.pushViewController(chatLogController, animated: true)
	}

}
