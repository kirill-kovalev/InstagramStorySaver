//
//  StoriesViewController.swift
//  InstaSaver
//
//  Created by Кирилл on 28.10.2020.
//

import UIKit
import RxSwift
import RxCocoa

class FeedStoriesCollectionView: AutoSizedCollectionView {
	class Cell: UICollectionViewCell {
		override init(frame: CGRect) {
			super.init(frame: frame)
			setup()
		}
		
		required init?(coder: NSCoder) {
			super.init(coder: coder)
			setup()
		}
		let avatarView = ISAvatarView(style: .avatar)
		func setup() {
			self.contentView.addSubview(avatarView)
			avatarView.snp.makeConstraints { (make) in
				make.top.equalToSuperview().offset(15)
				make.bottom.equalToSuperview().inset(15)
				make.width.equalTo(avatarView.snp.height)
			}
		}
	}

	let stories = BehaviorRelay<[ISHilight]>(value: [])
	
	private let bag = DisposeBag()
	
	convenience init() {
		let layout = UICollectionViewFlowLayout()
		self.init(frame: .zero, collectionViewLayout: layout)

		self.backgroundColor = .clear
		
		layout.itemSize = CGSize(width: 117, height: 147)
		layout.sectionInset = .init(top: 0, left: 20, bottom: 0, right: 20)
		self.showsHorizontalScrollIndicator = false
		layout.scrollDirection = .horizontal
		self.register(Cell.self, forCellWithReuseIdentifier: "cell")
		
		stories.bind(to: self.rx.items(cellIdentifier: "cell", cellType: Cell.self)) { [weak self] _, data, cell in
			if let self = self,
			   let url = data.owner?.avatar ?? data.thumb {
				ISNetwork
					.data(url)
					.compactMap(UIImage.init)
					.bind(to: cell.avatarView.rx.image)
					.disposed(by: self.bag)
			}
		}.disposed(by: bag)
		
		self.rx.itemSelected.subscribe(onNext: {[weak self] path in
			guard let self = self else {return}
			let items = self.stories.value[path.item].content
			
			let cell = self.cellForItem(at: path)
			let cellFrame = cell?.bounds ?? .zero
			let frame = cell?.convert(cellFrame, to: self.window)
			
			self.previewDelegate?.displayPreview(items, from: frame, focus: 0)
		}).disposed(by: bag)
	}
	
	weak var previewDelegate: PreviewDisplayDelegate?
}
