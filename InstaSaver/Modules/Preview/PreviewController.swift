//
//  PreviewController.swift
//  InstaSaver
//
//  Created by Кирилл on 04.11.2020.
//

import UIKit
import RxSwift
import RxCocoa
import AVKit

class PreviewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, ExportDelegateProtocol {
	let bag = DisposeBag()
	
	let collection = PreviewCollectionView()
	override func loadView() {
		self.collectionView = collection
	}
	var presentFromFrame: CGRect?
	
	override func viewWillAppear(_ animated: Bool) {
		if let frame = presentFromFrame {
			self.view.frame = frame
			self.collection.backButton.layer.opacity = 0.4
			animate {
				self.view.frame = UIScreen.main.bounds
				self.collection.backButton.layer.opacity = 1
			}
		} else {
			super.viewWillAppear(animated)
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		if let frame = presentFromFrame {
			self.collection.backButton.layer.opacity = 1
			animate{
				self.view.frame = frame
				self.collection.backButton.layer.opacity = 0.4
			}
		} else {
			super.viewWillDisappear(animated)
		}
	}
	@objc func panDidPerformed(_ sender: UIPanGestureRecognizer) {
		let translation = sender.translation(in: self.view)
		let translX = translation.x/2
		let translY = translation.y/2
		
		let distance = sqrt(pow(translX, 2)+pow(translY, 2))
		let maxDistance = view.window!.bounds.height/4
		
		let scaleFactor: CGFloat = 0.6
		let scale = 1 - min(scaleFactor*(distance/(maxDistance*3)), scaleFactor)
		animate {
			self.view.transform = CGAffineTransform(translationX: translX, y: translY)
					.concatenating(CGAffineTransform(scaleX: scale, y: scale))
		}
		
		guard sender.state == .ended  else {return}
		
		if distance > maxDistance || sender.velocity(in: view).x > 50 {
			self.dismiss(animated: true, completion: nil)
		} else {
			animate{
				self.view.transform = .identity
			}
			
		}
	}
	private func animate(animations: @escaping () -> Void ){
		UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5, options: [.curveEaseInOut], animations: animations, completion: nil)
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		self.collectionView.register(PreviewCell.self, forCellWithReuseIdentifier: "\(PreviewCell.self)")
//		self.modalPresentationStyle = .overFullScreen
		self.collection.gesture.addTarget(self, action: #selector(panDidPerformed))
		self.collection.backButton.rx.tap.subscribe(onNext: { [weak self] in
															self?.dismiss(animated: true, completion: nil)
													})
													.disposed(by: bag)

    }
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		(self.collection.cellForItem(at: IndexPath(row: 0, section: 0)) as? PreviewCell)?.player.play()
	}
	
	
	
	var content: [ISMedia.Content] = [] {
		didSet {
			self.collectionView.reloadData()
			self.collection.pageIndicator.numberOfPages = content.count
		}
	}
	var cache: [IndexPath: URL] = [:]
	
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {1}

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { content.count }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(PreviewCell.self)", for: indexPath)
		let element = self.content[indexPath.item]
		if let cell = cell as? PreviewCell {
			cell.exportDelegate = self
			ISNetwork
				.data(element.thumb)
				.map(UIImage.init)
				.bind(to: cell.container.rx.image)
				.disposed(by: bag)
			if let url = cache[indexPath] {
				cell.url = url
			}
			ISNetwork.download(element)
				.subscribe(onNext: { [weak self] url in
					self?.cache[indexPath] = url
					cell.url = url
					
					if
						let currentPage = self?.cureentPage,
						let activeCell = collectionView.cellForItem(at: IndexPath(item: Int(currentPage), section: 0)) as? PreviewCell {
						activeCell.player.play()
					}
					
				})
				.disposed(by: bag)
			
		}
        return cell
    }

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		collectionView.frame.size
	}
	
	var cureentPage: Int {Int(collection.contentOffset.x/collection.bounds.width)}
	
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		self.collection.pageIndicator.currentPage = cureentPage
		self.collection.visibleCells.compactMap {$0 as? PreviewCell}.enumerated().forEach { (index, cell) in
			if abs(index - cureentPage) > 1 {
				cell.player.seek(to: .zero)
			}
			cell.player.pause()
		}
		if let cell = collection.cellForItem(at: IndexPath(item: Int(cureentPage), section: 0)) as? PreviewCell {
			cell.player.play()
		}
	}
	
}
