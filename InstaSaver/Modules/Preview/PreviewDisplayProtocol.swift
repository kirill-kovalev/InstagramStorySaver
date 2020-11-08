//
//  PreviewDisplayProtocol.swift
//  InstaSaver
//
//  Created by Кирилл on 04.11.2020.
//

import UIKit


protocol PreviewDisplayDelegate:UIViewController{
	func displayPreview(_ items:[ISMedia.Content], from frame:CGRect, focus on:Int)
}
extension PreviewDisplayDelegate{
	func displayPreview(_ items:[ISMedia.Content],from frame:CGRect = .zero, focus on:Int = 0){
		let vc = PreviewController()
		vc.content = items
//		if let navigationController = self.navigationController {
//			navigationController.pushViewController(vc, animated: true)
//		}else {
			self.present(vc, animated: true) { vc.collectionView.scrollToItem(at: IndexPath(item: on, section: 0), at: .centeredHorizontally, animated: false)}
//		}
		
	}
}
