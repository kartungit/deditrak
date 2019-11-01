//
//  TodayViewController.swift
//  gameofChat
//
//  Created by thinhmai on 10/25/19.
//  Copyright © 2019 thinhmai. All rights reserved.
//

import UIKit
import Segmentio

class TodayViewController: UIViewController,ItemProtocol {

	lazy var  segmentioView = Segmentio()
	lazy var  containerView = UIView()
	lazy var  scrollView = UIScrollView()

	private lazy var viewControllers: [MessageController] = {
		return [MessageController(with: "New"),MessageController(with: "In Progress"),MessageController(with: "Recieved"),MessageController(with: "Deliveried")]
	}()

	private func segmentioContent() -> [SegmentioItem] {
		return [
			SegmentioItem(title: "New", image: UIImage(named: "new")),
			SegmentioItem(title: "In Progress", image: UIImage(named: "in_progress")),
			SegmentioItem(title: "Recieved", image: UIImage(named: "recieved")),
			SegmentioItem(title: "Deliveried", image: UIImage(named: "deliveried"))
		]
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		let imageButtonView = UIImageView(image: UIImage(named: "add"))
		imageButtonView.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
		let rightButtonView = UIView()
		rightButtonView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
		rightButtonView.addSubview(imageButtonView)
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleNewItem))
		rightButtonView.addGestureRecognizer(tapGesture)
		self.tabBarController?.navigationItem.rightBarButtonItem =  UIBarButtonItem(customView: rightButtonView)

		view.backgroundColor = UIColor.white
		setupSegmentsViewConstraints()

		setupScrollView()
		segmentioView.setup(
			content: self.segmentioContent(),
			style: SegmentioStyle.onlyLabel,
			options: SegmentioOptions(
				backgroundColor: ColorPalette.white,
				segmentPosition: .fixed(maxVisibleItems: 4),
				scrollEnabled: true,
				horizontalSeparatorOptions: TodayViewController.segmentioHorizontalSeparatorOptions(),
				segmentStates: TodayViewController.segmentioStates()
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
		segmentioView.selectedSegmentioIndex = selectedSegmentioIndex()


	}
	override func viewDidAppear(_ animated: Bool) {
		super .viewDidAppear(animated)


	}

	private func goToControllerAtIndex(_ index: Int) {
		segmentioView.selectedSegmentioIndex = index
	}

	private func selectedSegmentioIndex() -> Int {
		return 0
	}
	@objc func handleNewItem(){
		createNewItem(user: nil)
	}

	func createNewItem(user: User?) {
		let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
		chatLogController.user = user
		self.tabBarController?.navigationController?.pushViewController(chatLogController, animated: true)
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

	private func setupScrollView() {
		scrollView.contentSize = CGSize(
			width: UIScreen.main.bounds.width * CGFloat(viewControllers.count),
			height: containerView.frame.height
		)

		for (index, viewController) in viewControllers.enumerated() {
			viewController.view.translatesAutoresizingMaskIntoConstraints = false
			viewController.view.frame = CGRect(
				x: UIScreen.main.bounds.width * CGFloat(index),
				y: 0,
				width: view.frame.width,
				height: self.containerView.frame.height
			)
			viewController.positionView = index

			addChild(viewController)
			scrollView.addSubview(viewController.view, options: .useAutoresize) // module's extension
						viewController.didMove(toParent: self)
		}
		scrollView.delegate = self
		scrollView.isPagingEnabled = true
		scrollView.showsHorizontalScrollIndicator = false
		scrollView.isMultipleTouchEnabled = true
	}

	private static func segmentioStates() -> SegmentioStates {
		let font = UIFont.systemFont(ofSize: 13)
		return SegmentioStates(
			defaultState: segmentioState(
				backgroundColor: .clear,
				titleFont: font,
				titleTextColor: ColorPalette.grayChateau
			),
			selectedState: segmentioState(
				backgroundColor: .cyan,
				titleFont: font,
				titleTextColor: ColorPalette.black
			),
			highlightedState: segmentioState(
				backgroundColor: ColorPalette.whiteSmoke,
				titleFont: font,
				titleTextColor: ColorPalette.grayChateau
			)
		)
	}

	struct ColorPalette {
		static let white = UIColor(r: 255, g: 255, b: 255)
		static let black = UIColor(r: 3, g: 3, b: 3)
		static let coral = UIColor(r: 244, g: 111, b: 96)
		static let whiteSmoke = UIColor(r: 245, g: 245, b: 245)
		static let grayChateau = UIColor(r: 163, g: 164, b: 168)

	}
	private static func segmentioState(backgroundColor: UIColor, titleFont: UIFont, titleTextColor: UIColor) -> SegmentioState {
		return SegmentioState(
			backgroundColor: backgroundColor,
			titleFont: titleFont,
			titleTextColor: titleTextColor
		)
	}

	private static func segmentioHorizontalSeparatorOptions() -> SegmentioHorizontalSeparatorOptions {
		return SegmentioHorizontalSeparatorOptions(
			type: .topAndBottom,
			height: 1,
			color: ColorPalette.whiteSmoke
		)
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
