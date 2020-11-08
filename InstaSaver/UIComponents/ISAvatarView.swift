//
//  ISAvatarView.swift
//  InstaSaver
//
//  Created by Кирилл on 28.10.2020.
//

import UIKit

@IBDesignable
class ISAvatarView: UIImageView {
	enum Style {
		case avatar
		case avatarSmall
		case highlights
	}
	private var _style: Style = .avatar
	public var style: Style {
		get {
			return self._style
		}
		set {
			self._style = newValue
			
			switch style {
				case .avatar:
					self.frame.size = CGSize(width: 117, height: 117)

				case .avatarSmall:
					self.frame.size = CGSize(width: 35, height: 35)

				case .highlights:
					self.frame.size = CGSize(width: 60, height: 60)
			}
			
			self.layer.borderWidth = (self.frame.height/30).rounded()
		}
	}
	
	convenience init(style: Style = .avatar) {
		self.init(frame: .zero)
		self.style = style
		setupBorder()
		self.contentMode = .scaleAspectFill
	}
	private func setupBorder() {
		layer.masksToBounds = true
		layer.borderColor = self.borderColor.cgColor
	}
	
	@IBInspectable
	public var borderColor: UIColor = Asset.Colors.purple.color
	public override var image: UIImage? {
		get {
			return super.image
		}
		set {
			super.image = newValue ?? Asset.Images.imagePlaceholder.image
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		self.layer.cornerRadius = self.frame.height > self.frame.width ? self.frame.width/2 : self.frame.height/2
		self.layer.borderWidth = (self.frame.height/30).rounded()
	}
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		self.layer.borderColor = self.borderColor.cgColor
	}
}
