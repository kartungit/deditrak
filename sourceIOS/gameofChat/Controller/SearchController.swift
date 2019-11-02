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
	@IBOutlet weak var textInputSearch: UITextField!
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

		self.searching = false
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
		if (!self.validateSearch()){
			self.lblNotFound.isHidden = false
			self.searching = false
			self.searchItems.removeAll()
			self.tableResult.reloadData()
			print("Invalid input search")
			return
		}

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

	func validateSearch() -> Bool{
		if (textInputSearch.text!.count > 0){
			return true
		}

		if (btnCategory.titleLabel?.text != self.emptyText){
			return true
		}

		if (btnFromOffice.titleLabel?.text != self.emptyText){
			return true
		}

		if (btnToOffice.titleLabel?.text != self.emptyText){
			return true
		}

		if (textSender.text != ""){
			return true
		}

		if (textReceiver.text != ""){
			return true
		}

		return false
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
		// wifi: zongmnt
		let api_ip_api_search = "http://192.168.8.101:8080/items/search"
		guard let url = URL(string: api_ip_api_search) else {
			// print("Can't connect to URL")
			searching = false
			showAlert(message: "Can't connect to api, please check your server again.")
			return
		}

		if (searching){
			print("Search api is running ...")
			return
		}

		// turnon flat search
		searching = true

		var inputText = ""
		var categoryText = ""
		var fromOffice = ""
		var toOffice = ""
		var sendnder = ""
		var receiver = ""

		if (textInputSearch.text!.count > 0){
			inputText = textInputSearch.text!
		}

		if (btnCategory.titleLabel?.text != self.emptyText){
			categoryText = btnCategory.titleLabel!.text!
		}

		if (btnFromOffice.titleLabel?.text != self.emptyText){
			fromOffice = (btnFromOffice.titleLabel?.text!)!
		}

		if (btnToOffice.titleLabel?.text != self.emptyText){
			toOffice = (btnToOffice.titleLabel?.text!)!
		}

		if (textSender.text != ""){
			sendnder = textSender.text!
		}

		if (textReceiver.text != ""){
			receiver = textReceiver.text!
		}

		self.lblNotFound.isHidden = true

		AF.request(url, method: .get, parameters: ["title": inputText.lowercased().trimmingCharacters(in: .whitespaces),
												   "category": categoryText.lowercased().trimmingCharacters(in: .whitespaces),
												   "fromOffice": fromOffice.lowercased().trimmingCharacters(in: .whitespaces),
												   "toOffice": toOffice.lowercased().trimmingCharacters(in: .whitespaces),
												   "sender":sendnder.lowercased().trimmingCharacters(in: .whitespaces),
												   "receiver":receiver.lowercased().trimmingCharacters(in: .whitespaces)])
			.validate()
			.responseJSON { (response: DataResponse) in
				//print("API DONE")
				self.searchItems.removeAll()

				switch response.result {
				case .success(let json):
					if let jsonArray = json as? [[String: Any]] {
						//print(jsonArray)
						for (jsonitem) in jsonArray {
							//print("\(jsonitem)")
							let item = Item.bindingItemFromDictionary(dictionary: jsonitem)
							self.searchItems.append(item!)
						}
					}
					break
				case .failure(let error):
					DispatchQueue.main.async {
						self.showAlert(message: "Search failed with error: \(error.localizedDescription)")
					}
					break
				}

				// test items
//				self.searchItems.append(Item.createTestItem())
//				self.searchItems.append(Item.createTestItem())
//				self.searchItems.append(Item.createTestItem())
//				self.searchItems.append(Item.createTestItem())
//				self.searchItems.append(Item.createTestItem())
//				self.searchItems.append(Item.createTestItem())

				// reset flat searching
				self.searching = false

				DispatchQueue.main.async {
					if (self.searchItems.count == 0){
						self.lblNotFound.isHidden = false
					}
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
