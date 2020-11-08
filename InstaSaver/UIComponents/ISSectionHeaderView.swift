//
//  ISSectionHeaderView.swift
//  InstaSaver
//
//  Created by Кирилл on 30.10.2020.
//

import UIKit

private func labelGenerator(_ text: String) -> UILabel {
	let label = UILabel(frame: .zero)
	label.font = .subtitle
	label.textColor = Asset.Colors.black.color
	label.text = text
	return label
}
private func spacerGenerator() -> UIView {
	let view = UIView(frame: CGRect(x: 0, y: 0, width: 240, height: 1))
	view.backgroundColor = Asset.Colors.black1.color
	view.snp.makeConstraints {
		$0.width.equalTo(240)
		$0.height.equalTo(1)
	}
	return view
}

class ISSectionHeaderView: UIStackView {
	var title: String {
		get {
			return (self.arrangedSubviews.first as? UILabel)?.text ?? ""
		}
		set {
			(self.arrangedSubviews.first as? UILabel)?.text = newValue
		}
	}
	convenience init(title: String) {
		self.init(arrangedSubviews: [
			labelGenerator(title),
			spacerGenerator()
		])
		self.alignment = .center
		self.axis = .vertical
		self.spacing = 5
		
		self.backgroundColor = Asset.Colors.white.color
	}
}
