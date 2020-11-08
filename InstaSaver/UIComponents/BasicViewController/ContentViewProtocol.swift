//
//  View.swift
//  InstaSaver
//
//  Created by Кирилл on 19.10.2020.
//

import UIKit

protocol ContentViewProtocol: UIView {
	init()
	
	func addViews()
	func setupConstraints()
}

//extension ContentViewProtocol {
//	init() {
//		self.init()
//		self.addViews()
//		self.setupConstraints()
//	}
//}
