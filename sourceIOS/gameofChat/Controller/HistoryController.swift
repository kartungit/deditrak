//
//  HistoryController.swift
//  gameofChat
//
//  Created by thinhmai on 10/21/19.
//  Copyright © 2019 thinhmai. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class HistoryController: UIViewController {

	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

	override func viewDidAppear(_ animated: Bool) {
		super .viewDidAppear(animated)
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

	@IBAction func yesterdayAction(_ sender: Any) {
		let historyVC:HistoryDaysController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:"HistoryDaysController") as! HistoryDaysController
		historyVC.historyDays = 1
		self.tabBarController?.navigationController?.pushViewController(historyVC, animated: true)
	}

	@IBAction func last7DaysAction(_ sender: Any) {
		let historyVC:HistoryDaysController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:"HistoryDaysController") as! HistoryDaysController
		historyVC.historyDays = 7
		self.tabBarController?.navigationController?.pushViewController(historyVC, animated: true)
	}

	@IBAction func last14DaysAction(_ sender: Any) {
		let historyVC:HistoryDaysController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:"HistoryDaysController") as! HistoryDaysController
		historyVC.historyDays = 14
		self.tabBarController?.navigationController?.pushViewController(historyVC, animated: true)
	}

	@IBAction func last30DaysAction(_ sender: Any) {
		let historyVC:HistoryDaysController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:"HistoryDaysController") as! HistoryDaysController
		historyVC.historyDays = 30
		self.tabBarController?.navigationController?.pushViewController(historyVC, animated: true)
	}
}
