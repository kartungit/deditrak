//
//  Extension.swift
//  gameofChat
//
//  Created by thinhmai on 7/17/19.
//  Copyright © 2019 thinhmai. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
	func loadImageUsingCacheWithUrlString(urlString: String){

		//check cache for image first
		if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
			self.image = cachedImage
			return
		}
		//else start dowload image
		let url = URLRequest(url: URL(string: urlString)!)
		URLSession.shared.dataTask(with: url, completionHandler: {
			(data, response, error) in
			if error != nil {
				print(error)
				return
			}
			DispatchQueue.main.async {

				if let downloadedImage = UIImage(data: data!) {
					imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
				}

				self.image = UIImage(data: data!)
			}
		}).resume()
	}
}
class ButtonExtended : UIButton {
	var item: Item?
}
