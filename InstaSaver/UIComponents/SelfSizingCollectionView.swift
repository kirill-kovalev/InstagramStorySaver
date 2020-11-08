//
//  SelfSizingCollectionView.swift
//  InstaSaver
//
//  Created by Кирилл on 30.10.2020.
//

import UIKit


class AutoSizedCollectionView: UICollectionView {

	override var intrinsicContentSize: CGSize {
		get {
			return self.contentSize
		}
	}
	override func reloadData() {
		super.reloadData()
		layoutIfNeeded()
		self.invalidateIntrinsicContentSize()
	}
	
	override func sizeThatFits(_ size: CGSize) -> CGSize {
		if (self.superview != nil) {
			self.superview?.layoutIfNeeded()
		}

		return self.contentSize
	}
}
