//
//  PreviewDisplayProtocol.swift
//  InstaSaver
//
//  Created by Кирилл on 04.11.2020.
//

import UIKit

protocol PreviewDisplayDelegate: UIViewController {
	func displayPreview(_ items: [ISMedia.Content], from frame: CGRect?, focus on: Int)
}
extension PreviewDisplayDelegate {
	func displayPreview(_ items: [ISMedia.Content], from frame: CGRect? = nil, focus on: Int = 0) {
		let vc = PreviewController()
		vc.content = items
		vc.modalTransitionStyle = .crossDissolve
		vc.modalPresentationStyle = .overFullScreen
		vc.presentFromFrame = frame
		self.present(vc, animated: false) { vc.collectionView.scrollToItem(at: IndexPath(item: on, section: 0), at: .centeredHorizontally, animated: false)}
	}
}
