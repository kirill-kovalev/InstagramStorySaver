//
//  FeedItemCell.swift
//  InstaSaver
//
//  Created by Кирилл on 28.10.2020.
//

import UIKit

class FriendsCell: UITableViewCell {
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}
	
	let avatar = ISAvatarView(style: .avatarSmall)
	
	let username: UILabel = {
		let label = UILabel(frame: .zero)
		label.font = .listItemTitle
		label.textColor = Asset.Colors.black.color
		return label
	}()
	
	let subtitle: UILabel = {
		let label = UILabel(frame: .zero)
		label.font = .listItemSubtitle
		label.textColor = Asset.Colors.black5.color
		label.text = "Tap to watch"
		return label
	}()
	let timestamp: UILabel = {
		let label = UILabel(frame: .zero)
		label.font = .listItemSubtitle
		label.textColor = Asset.Colors.black4.color
		label.text = " - 24 hours ago"
		return label
	}()
	
	let arrow = UIImageView(image: Asset.Icons.arrowForward.image.withRenderingMode(.alwaysTemplate))
	
	private func setup() {
		self.contentView.backgroundColor = .clear
		self.backgroundColor = .clear
		
		self.addSubview(avatar)
		self.addSubview(username)
		self.addSubview(subtitle)
		self.addSubview(timestamp)
		self.addSubview(arrow)
		arrow.tintColor = Asset.Colors.purple.color
		setupConstrints()
	}
	private func setupConstrints() {
		avatar.snp.makeConstraints { (make) in
			make.top.equalToSuperview().offset(8)
			make.bottom.equalToSuperview().inset(8)
			make.left.equalToSuperview().offset(42)
			make.width.equalTo(56)
			make.height.equalTo(avatar.snp.width).priority(.high)
		}
		arrow.snp.makeConstraints { (make) in
			make.height.width.equalTo(20)
			make.centerY.equalToSuperview()
			make.right.equalToSuperview().inset(42)
		}
		username.snp.makeConstraints { (make) in
			make.left.equalTo(avatar.snp.right).offset(11)
			make.bottom.equalTo(avatar.snp.centerY)
			make.right.equalTo(arrow.snp.left).inset(5)
		}
		
		subtitle.snp.makeConstraints { (make) in
			make.left.equalTo(username)
			make.top.equalTo(avatar.snp.centerY).offset(3)
		}
		timestamp.snp.makeConstraints { (make) in
			make.left.equalTo(subtitle.snp.right)
			make.centerY.equalTo(subtitle)
			make.right.lessThanOrEqualTo(arrow.snp.left).inset(-5)
		}
	}
	
}
