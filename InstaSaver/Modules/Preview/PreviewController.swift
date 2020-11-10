//
//  PreviewController.swift
//  InstaSaver
//
//  Created by Кирилл on 04.11.2020.
//

import UIKit
import RxSwift
import RxCocoa

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
	
	var content: [ISMedia.Content] = [] {
		didSet {
			self.collectionView.reloadData()
			self.collection.pageIndicator.numberOfPages = content.count
		}
	}

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {1}

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { content.count }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(PreviewCell.self)", for: indexPath)
		let element = self.content[indexPath.item]
		if let cell = cell as? PreviewCell {
			URLSession.shared.rx
				.data(request: URLRequest(url: element.thumb))
				.map(UIImage.init)
				.bind(to: cell.container.rx.image)
				.disposed(by: bag)
		}
        return cell
    }

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		collectionView.frame.size
	}
	
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let page = scrollView.contentOffset.x/scrollView.bounds.width
		self.collection.pageIndicator.currentPage = Int(page)
	}
}

