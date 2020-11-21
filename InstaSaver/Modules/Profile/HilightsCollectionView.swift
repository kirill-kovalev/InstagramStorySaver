//
//  HilightsCollectionView.swift
//  InstaSaver
//
//  Created by Кирилл on 02.11.2020.
//

import UIKit
import RxSwift
import RxCocoa

class HilightsCollectionView: AutoSizedCollectionView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
	class Cell: UICollectionViewCell {
		let storyView = ISAvatarView(style: .highlights)
		
		required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
		override init(frame: CGRect) {
			super.init(frame: frame)
			self.backgroundColor = .clear
			self.contentView.addSubview(storyView)
			storyView.snp.makeConstraints {$0.edges.equalToSuperview()}
		}
	}
	
	let bag = DisposeBag()
	var hilights = BehaviorRelay<[ISHilight]>(value: [])
	
	convenience init() {
		let layout = UICollectionViewFlowLayout()
		layout.minimumInteritemSpacing = 12
		layout.minimumLineSpacing = 12
		layout.sectionInset = .init(top: 20, left: 20, bottom: 20, right: 20)
		
		self.init(frame: .zero, collectionViewLayout: layout )
		self.register(Cell.self, forCellWithReuseIdentifier: "cell")
		self.dataSource = self
		self.delegate = self
		self.backgroundColor = .clear
		self.showsHorizontalScrollIndicator = false
		layout.scrollDirection = .horizontal
		
		self.backgroundColor = .clear
		
		hilights.subscribe(onNext: {[weak self] _ in
			self?.reloadData()
		}).disposed(by: bag)
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { self.hilights.value.count}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
		if let cell = cell as? Cell {
			if let url = hilights.value[indexPath.item].thumb {
				ISNetwork
					.data(url)
					.compactMap(UIImage.init)
					.observeOn(MainScheduler.instance)
					.subscribe(onNext: {
						cell.storyView.image = $0
					})
					.disposed(by: bag)
			}
		}
		
		return cell
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let insets = (collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset ?? .zero
		
		let contentWidth = collectionView.bounds.width - insets.left - insets.right
		let w = contentWidth/4
		let h = w
		return CGSize(width: w, height: h)
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath)
		let cellFrame = cell?.bounds ?? .zero
		let frame = cell?.convert(cellFrame, to: window)
		
		let item = self.hilights.value[indexPath.item]
		previewDelegate?.displayPreview(item.content, from: frame, focus: 0)
	}
	
	override var intrinsicContentSize: CGSize {
		let w = self.frame.width
		let h = self.subviews.first?.frame.height ?? w/4
		let insets = (collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset ?? .zero
		
		let size = CGSize(width: w, height: h + insets.top + insets.bottom)
		return size
	}
	
	weak var previewDelegate: PreviewDisplayDelegate?
}
