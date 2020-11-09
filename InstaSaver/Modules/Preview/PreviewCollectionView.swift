//
//  PreviewCollectionView.swift
//  InstaSaver
//
//  Created by Кирилл on 09.11.2020.
//

import UIKit

class PreviewCollectionView: UICollectionView {
	let backButton: UIButton = {
		let btn = UIButton(frame: .zero)
		btn.setImage(Asset.Icons.arrowBack.image.withRenderingMode(.alwaysTemplate), for: .normal)
		btn.imageView?.tintColor = Asset.Colors.purple.color
		return btn
	}()
		
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
	init() {
		let layout = UICollectionViewFlowLayout()
		super.init(frame: .zero, collectionViewLayout: layout)
		layout.scrollDirection = .horizontal
		layout.minimumLineSpacing = 0
		self.isPagingEnabled = true
		addViews()
		setupConstraints()
	}
	
	private func addViews() {
		self.addSubview(backButton)
	}
	private func setupConstraints() {
		backButton.snp.makeConstraints { (make) in
			make.height.width.equalTo(50)
			make.left.equalTo(frameLayoutGuide).offset(30)
			make.top.equalTo(safeAreaLayoutGuide).offset(20)
		}
	}
	
}
