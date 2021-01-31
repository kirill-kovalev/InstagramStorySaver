//
//  PostCollectionView.swift
//  InstaSaver
//
//  Created by Кирилл on 30.10.2020.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class PostCell: UICollectionViewCell {
	let bag = DisposeBag()
	let image = ImageView(frame: .zero)
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.image.contentMode = .scaleAspectFill
		self.image.layer.masksToBounds = true
		self.contentView.addSubview(image)
		self.backgroundColor = Asset.Colors.black2.color
	}
	
	override func layoutSubviews() {
		image.frame = contentView.frame
	}
	
}

class PostCollectionView: AutoSizedCollectionView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
	let bag = DisposeBag()
	
	var cache: [IndexPath: UIImage] = [:]
	
	convenience init() {
		let layout = UICollectionViewFlowLayout()
		layout.minimumInteritemSpacing = 10
		layout.minimumLineSpacing = 10
		layout.sectionInset = .init(top: 20, left: 20, bottom: 0, right: 20)
		
		self.init(frame: .zero, collectionViewLayout: layout )
		self.register(PostCell.self, forCellWithReuseIdentifier: "cell")
		
		self.dataSource = self
		self.delegate = self
		
		self.backgroundColor = .clear
		
		posts.subscribe(onNext: {[weak self] _ in
			self?.reloadData()
		}).disposed(by: bag)
	}
	var posts = BehaviorRelay<[ISMedia]>(value: [])

	var cellsPerRow: Int = 3
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { self.posts.value.count}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
		if let url = self.posts.value[indexPath.item].content.first?.thumb ,
		   let cell = cell as? PostCell {
            cell.image.url = url
		}
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let layout = collectionViewLayout as? UICollectionViewFlowLayout
		let insets = layout?.sectionInset ?? .zero
		
		let cellsPerRow = CGFloat(self.cellsPerRow)
		
		let width = UIScreen.main.bounds.width
		let spacing = layout?.minimumInteritemSpacing ?? 0
		
		let contentW = width - insets.left - insets.right - spacing*(cellsPerRow-1)
		let size = contentW/cellsPerRow
		
		return CGSize(width: size, height: size)
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath)
		let cellFrame = cell?.bounds ?? .zero
		let frame = cell?.convert(cellFrame, to: window)
		let item = self.posts.value[indexPath.item]
		previewDelegate?.displayPreview(item.content, from: frame, focus: 0)
	}
	weak var previewDelegate: PreviewDisplayDelegate?
	
}
