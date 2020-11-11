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

class PreviewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
	let bag = DisposeBag()
	
	let collection = PreviewCollectionView()
	override func loadView() {
		self.collectionView = collection
	}

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
		self.collectionView.register(PreviewCell.self, forCellWithReuseIdentifier: "\(PreviewCell.self)")
		self.modalPresentationStyle = .overFullScreen
		self.collection.backButton.rx.tap.subscribe(onNext: { [weak self] in
															self?.dismiss(animated: true, completion: nil)
													})
													.disposed(by: bag)

    }
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		(self.collection.cellForItem(at: IndexPath(row: 0, section: 0)) as? PreviewCell)?.player?.play()
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
			ISNetwork
				.data(element.thumb)
				.map(UIImage.init)
				.bind(to: cell.container.rx.image)
				.disposed(by: bag)
			if let url = cache[indexPath] {
				cell.player = AVPlayer(url: url)
			}
			ISNetwork.download(element)
				.subscribe(onNext: { [weak self] url in
					self?.cache[indexPath] = url
					cell.player = AVPlayer(url: url)
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
				cell.player?.seek(to: .zero)
			}
			cell.player?.pause()
		}
		if let cell = collection.cellForItem(at: IndexPath(item: Int(cureentPage), section: 0)) as? PreviewCell {
			cell.player?.play()
		}
	}
	
}
