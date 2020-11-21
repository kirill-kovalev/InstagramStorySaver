//
//  HorizontalScrollableCell.swift
//  InstaSaver
//
//  Created by Кирилл on 02.11.2020.
//

import UIKit

class HorizontalScrollableCell: UICollectionViewCell {
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
	var collectionLayout: UICollectionViewFlowLayout? {return horizontalCollection.collectionViewLayout as? UICollectionViewFlowLayout}
	let horizontalCollection: UICollectionView
	override init(frame: CGRect) {
		var bounds = frame
		bounds.origin = .zero
		self.horizontalCollection = AutoSizedCollectionView(frame: bounds, collectionViewLayout: UICollectionViewFlowLayout())
		super.init(frame: frame)
		
		self.horizontalCollection.backgroundColor = .red
		(self.horizontalCollection.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .horizontal
		self.contentView.addSubview(horizontalCollection)
		horizontalCollection.snp.makeConstraints { $0.height.width.equalToSuperview() }
		contentView.snp.makeConstraints { $0.edges.equalToSuperview() }
	}

}
