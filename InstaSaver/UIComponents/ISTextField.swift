//
//  ISTextField.swift
//  InstaSaver
//
//  Created by Кирилл on 28.10.2020.
//

import UIKit

class ISTextField: UIView {
	let textfield: UITextField = {
		let tf = UITextField(frame: .zero)
		tf.font = .searchfield
		tf.backgroundColor = .clear
		tf.textColor = Asset.Colors.black.color
		tf.autocapitalizationType = .none
		tf.autocorrectionType = .no
		tf.keyboardAppearance = .default
		tf.keyboardType = .webSearch
		return tf
	}()
	let btn: UIButton = {
		let btn = UIButton(frame: .zero)
		btn.setImage(Asset.Icons.search.image.withRenderingMode(.alwaysTemplate), for: .normal)
		btn.imageView?.tintColor = Asset.Colors.black4.color
		return btn
	}()
	convenience init() {
		self.init(frame: .zero)
		setup()
	}
	private func setup() {
		self.addSubview(textfield)
		self.addSubview(btn)
		
		self.layer.borderWidth = 1
		
		textfield.addTarget(self, action: #selector(self.setupActive), for: .editingDidBegin)
		textfield.addTarget(self, action: #selector(self.setupInactive), for: .editingDidEnd)
		
		btn.snp.makeConstraints { (make) in
			make.left.top.bottom.equalToSuperview()
		}
		btn.imageView?.snp.removeConstraints()
		btn.imageView?.snp.makeConstraints({ (make) in
			make.width.height.equalTo(28)
			make.left.equalToSuperview().offset(29)
			make.right.equalToSuperview().inset(8)
		})
		textfield.snp.makeConstraints { (make) in
			make.left.equalTo(btn.snp.right)
			make.right.equalToSuperview().inset(8)
			make.centerY.equalToSuperview()
		}
		self.layer.cornerRadius = 8
		setupInactive()
	}
	
	@objc private func setupActive() {
		UIView.animate(withDuration: 0.3) {
			self.backgroundColor = Asset.Colors.white.color
			self.layer.borderColor = Asset.Colors.black5.color.withAlphaComponent(0.3).cgColor
			self.layer.shadowColor = UIColor(displayP3Red: 32/256, green: 32/256, blue: 47/256, alpha: 0.08).cgColor
			self.layer.shadowRadius = 16
			self.layer.shadowOpacity = 1
			self.layer.shadowOffset = CGSize(width: 4, height: 8)
		}
	}
	@objc private func setupInactive() {
		self.textfield.placeholder = "profile search"
		UIView.animate(withDuration: 0.3) {
			self.backgroundColor = Asset.Colors.black1.color
			self.layer.borderColor = Asset.Colors.black1.color.cgColor
			
			self.layer.shadowRadius = 1
			self.layer.shadowOffset = CGSize(width: 0, height: 0)
		}
	}
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		if self.isFocused {
			setupActive()
		} else {
			setupInactive()
		}
	}
}
