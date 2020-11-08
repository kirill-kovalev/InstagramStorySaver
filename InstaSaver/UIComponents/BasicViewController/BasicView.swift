//
//  BasicView.swift
//  InstaSaver
//
//  Created by Кирилл on 19.10.2020.
//

import UIKit

class BasicView: UIView, ContentViewProtocol {
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		addViews()
		setupConstraints()}
	required init() {
		super.init(frame: .zero)
		addViews()
		setupConstraints()
	}
	
	func addViews() { }
	
	func setupConstraints() { }

}
