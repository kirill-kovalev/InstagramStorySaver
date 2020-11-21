//
//  UserPageHeaderView.swift
//  InstaSaver
//
//  Created by Кирилл on 30.10.2020.
//

import UIKit

class UserPageHeaderView: BasicView {
	let backButton: UIButton = {
		let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
		btn.setImage(Asset.Icons.arrowBack.image.withRenderingMode(.alwaysTemplate), for: .normal)
		btn.imageView?.tintColor = Asset.Colors.black4.color
		return btn
	}()
	
	let avatar = ISAvatarView(style: .avatar)
	let avatarButton = UIButton(frame: .zero)
	let usernameLabel: UILabel = {
		let label = UILabel(frame: .infinite)
		label.numberOfLines = 1
		label.font = .title
		label.textColor = Asset.Colors.black.color
		label.text = "sfdsgsdgsgdfgdfgdfgfdfgfdg"
		label.textAlignment = .center
		return label
	}()
	
	let infoLabel: UILabel = {
		let label = UILabel(frame: .infinite)
		label.numberOfLines = 2
		label.font = .subtitle
		label.textColor = Asset.Colors.black5.color
		label.text = "sfdsgsdgsgd\nfgdfgdfgfdfgfdg"
		label.textAlignment = .center
		return label
	}()
	
	override func addViews() {
		self.backgroundColor = Asset.Colors.white.color
		
		self.addSubview(backButton)
		self.addSubview(usernameLabel)
		self.addSubview(infoLabel)
		self.addSubview(avatar)
		self.addSubview(avatarButton)
		
		avatar.image = nil
	}
	override func layoutSubviews() {
		let completeRatio = 1 - (self.frame.height - 60) / 200
		
		backButton.frame.origin.x = 43 * (1 - completeRatio)
		let centerY = self.bounds.height/2
		backButton.center.y = calculatePosition(from: centerY * 2/3, to: centerY, progress: completeRatio)
		
		backButton.frame.size = CGSize(width: 60, height: 60)
		
		let avatarSidePointX = self.bounds.width - avatar.bounds.width/2
		avatar.center.y = backButton.center.y
		avatar.center.x = calculatePosition(from: self.center.x, to: avatarSidePointX, progress: completeRatio * 2)
		
		let avatarSize = 117 -  57 * completeRatio // 60 - small avatar size; 117 - big avatar size; 57 = 117-60
		avatar.bounds.size = CGSize(width: avatarSize, height: avatarSize)
		
		avatarButton.frame = avatar.frame
		
		let uLabelStartY = avatar.frame.origin.y + avatar.bounds.height + usernameLabel.bounds.height/2 + 13 // 13 - offset from avatar
		usernameLabel.center.y = calculatePosition(from: uLabelStartY, to: backButton.center.y, progress: completeRatio)
		usernameLabel.center.x = self.center.x
		
		let unameWide = self.frame.width - (backButton.frame.origin.x )*2
		let unameNarrow =  self.frame.width - (backButton.frame.origin.x)*2 - backButton.bounds.width - avatar.bounds.width - 30
		usernameLabel.frame.size.width = calculatePosition(from: unameWide, to: unameNarrow, progress: completeRatio)
		
		usernameLabel.frame.size.height = 35
		
		infoLabel.center.x = self.center.x
		infoLabel.frame.size.height = 60
		infoLabel.frame.size.width = usernameLabel.frame.width
		infoLabel.frame.origin.y = usernameLabel.frame.origin.y + usernameLabel.bounds.height
		
		infoLabel.layer.opacity = Float(1 - completeRatio*3)
	}
	
	private func calculatePosition(from: CGFloat, to: CGFloat, progress: CGFloat) -> CGFloat {
		let progress = progress > 1 ? 1 : progress
		let path = to - from
		return from + path * progress
	}
}
