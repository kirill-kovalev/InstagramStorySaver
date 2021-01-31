//
//  StoriesCollectionView.swift
//  InstaSaver
//
//  Created by Кирилл on 02.11.2020.
//

import UIKit

import RxSwift
import RxCocoa

class StoriesCollectionView: AutoSizedCollectionView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
	class Cell: UICollectionViewCell {
		let storyView = ISStoryView(a: 0)
		
		required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
		override init(frame: CGRect) {
			super.init(frame: frame)
			self.contentView.addSubview(storyView)
			storyView.snp.makeConstraints {$0.edges.equalToSuperview()}
		}
	}
	
	let bag = DisposeBag()
	var stories = BehaviorRelay<ISHilight>(value: ISHilight(content: [], thumb: nil, owner: nil, identity: ""))
	
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
		layout.scrollDirection = .horizontal
		self.showsHorizontalScrollIndicator = false
		
		self.backgroundColor = .clear
		
		stories.subscribe(onNext: {[weak self] hilights in
			print("size: count", hilights.content.count)
			self?.reloadData()
		}).disposed(by: bag)

	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {stories.value.content.count}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
		if let cell = cell as? Cell {
			let item = stories.value.content[indexPath.item]
			let tisn = item.date?.timeIntervalSinceNow ?? 0 // timw interval since now
            
            let timeInterval = tisn > 0 ? 24*60*60 - tisn : -tisn
            
			if timeInterval < 3600 {
				cell.storyView.timestampText.text = "\(Int(timeInterval)) minutes ago"
			} else {
				cell.storyView.timestampText.text = "\(Int(timeInterval/3600)) hours ago"
			}
//            cell.storyView.timestampText.text = "\(item.date!)"
			let thumb = item.thumb
			ISNetwork
				.data(thumb)
				.observeOn(MainScheduler.instance)
				.compactMap(UIImage.init)
				.bind(to: cell.storyView.storyImage.rx.image)
				.disposed(by: bag)
			
		}
		return cell
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let insets = (collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset ?? .zero
		
		let contentWidth = collectionView.bounds.width - insets.left - insets.right
		let w = contentWidth/2
		let h = 16/9*w + 20
		return CGSize(width: w, height: h)
	}
	
	override var intrinsicContentSize: CGSize {
		let w = self.frame.width
		let h = self.subviews.first?.frame.height ?? 16/9*w + 20
		let insets = (collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset ?? .zero
		return CGSize(width: w, height: h + insets.top + insets.bottom)
	}
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath)
		let cellFrame = cell?.bounds ?? .zero
		let frame = cell?.convert(cellFrame, to: window)
		
		let item = self.stories.value
		previewDelegate?.displayPreview(item.content, from: frame, focus: indexPath.item)
	}
	weak var previewDelegate: PreviewDisplayDelegate?
}
