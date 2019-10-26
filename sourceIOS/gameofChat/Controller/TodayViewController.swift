//
//  TodayViewController.swift
//  gameofChat
//
//  Created by thinhmai on 10/25/19.
//  Copyright © 2019 thinhmai. All rights reserved.
//

import UIKit
import Segmentio

class TodayViewController: UIViewController {

	lazy var  segmentioView = Segmentio()
	lazy var  containerView = UIView()
	lazy var  scrollView = UIScrollView()

	private lazy var viewControllers: [UIViewController] = {
		return [SettingController(),SettingController()]
	}()

	private func segmentioContent() -> [SegmentioItem] {
		return [
			SegmentioItem(title: "Tornado", image: UIImage(named: "tornado")),
			SegmentioItem(title: "Earthquakes", image: UIImage(named: "earthquakes"))
		]
	}

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
	override func viewDidAppear(_ animated: Bool) {
		super .viewDidAppear(animated)
		setupSegmentsViewConstraints()
		setupScrollView()
		segmentioView.setup(
			content: self.segmentioContent(),
			style: SegmentioStyle.onlyLabel,
			options: SegmentioOptions(
				backgroundColor: UIColor.white,
				segmentPosition: .fixed(maxVisibleItems: 2),
				scrollEnabled: true
			)
		)
		segmentioView.valueDidChange = { [weak self] _, segmentIndex in
			if let scrollViewWidth = self?.scrollView.frame.width {
				let contentOffsetX = scrollViewWidth * CGFloat(segmentIndex)
				self?.scrollView.setContentOffset(
					CGPoint(x: contentOffsetX, y: 0),
					animated: true
				)
			}
		}
	}

	private func setupScrollView() {
		scrollView.contentSize = CGSize(
			width: UIScreen.main.bounds.width * CGFloat(viewControllers.count),
			height: containerView.frame.height
		)

		for (index, viewController) in viewControllers.enumerated() {
			viewController.view.frame = CGRect(
				x: UIScreen.main.bounds.width * CGFloat(index),
				y: 0,
				width: view.frame.width,
				height: view.frame.height
			)
			addChild(viewController)
			scrollView.addSubview(viewController.view, options: .useAutoresize) // module's extension
			viewController.didMove(toParent: self)
		}
	}

	func setupSegmentsViewConstraints(){

		self.view.addSubview(segmentioView)
		self.view.addSubview(containerView)
		self.containerView.addSubview(scrollView)
		segmentioView.translatesAutoresizingMaskIntoConstraints = false
		containerView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.translatesAutoresizingMaskIntoConstraints = false

		segmentioView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
		segmentioView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		segmentioView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		segmentioView.heightAnchor.constraint(equalToConstant: 50).isActive = true

		containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 50).isActive = true
		containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		containerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

		scrollView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
		scrollView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
		scrollView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
		scrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
	}
}
extension TodayViewController: UIScrollViewDelegate {

	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let currentPage = floor(scrollView.contentOffset.x / scrollView.frame.width)
		segmentioView.selectedSegmentioIndex = Int(currentPage)
	}

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: 0)
	}
}
