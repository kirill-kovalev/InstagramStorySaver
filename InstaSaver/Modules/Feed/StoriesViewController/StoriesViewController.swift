//
//  StoriesViewController.swift
//  InstaSaver
//
//  Created by Кирилл on 28.10.2020.
//

import UIKit
import RxSwift
import RxCocoa

class StoriesViewController: UIViewController {
	let rootView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
	override func loadView() { self.view = rootView }
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.rootView.backgroundColor = .clear
		let layout = (self.rootView.collectionViewLayout as? UICollectionViewFlowLayout)
		layout?.itemSize = CGSize(width: 117, height: 147)
		layout?.sectionInset = .init(top: 0, left: 20, bottom: 0, right: 20)
		rootView.showsHorizontalScrollIndicator = false
		layout?.scrollDirection = .horizontal
		self.rootView.register(StoriesCollectionCell.self, forCellWithReuseIdentifier: "StoriesCollectionCell")
		
    }
    
}

class StoriesCollectionCell: UICollectionViewCell {
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
