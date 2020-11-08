//
//  FeedView.swift
//  InstaSaver
//
//  Created by Кирилл on 21.10.2020.
//

import UIKit
import SnapKit

class FeedView: BasicView {
	let headerTitle: UILabel = {
		let text = UILabel(frame: .zero)
		text.font = .header
		text.text = "Stories Saver"
		text.textColor = Asset.Colors.black.color
		return text
	}()
	let logoutButton: UIButton = {
		let btn = UIButton(frame: .zero)
		btn.setImage(Asset.Icons.logout.image.withRenderingMode(.alwaysTemplate), for: .normal)
		btn.imageView?.tintColor = Asset.Colors.purple.color
		return btn
	}()
	
	let searchView = FeedSearchView()
	
	let contentTable: UITableView = {
		let table = UITableView(frame: .zero)
		table.separatorStyle = .none
		table.backgroundColor = .clear
		return table
	}()
		
	override func addViews() {
		self.backgroundColor = Asset.Colors.white.color
		self.addSubview(headerTitle)
		self.addSubview(logoutButton)
		self.addSubview(searchView)
		self.addSubview(contentTable)
	}
	override func setupConstraints() {
		headerTitle.snp.makeConstraints { (make) in
			make.left.equalToSuperview().offset(20)
			make.right.equalTo(logoutButton.snp.left)
			make.top.equalTo(safeAreaLayoutGuide).offset(20)
		}
		logoutButton.snp.makeConstraints { (make) in
			make.right.equalToSuperview().inset(40)
			make.width.height.equalTo(24)
			make.centerY.equalTo(headerTitle)
		}
		searchView.snp.makeConstraints { (make) in
			make.top.equalTo(headerTitle.snp.bottom).offset(36)
			make.centerX.equalToSuperview()
			make.width.equalToSuperview().inset(30)
			make.height.equalTo(54)
		}
		contentTable.snp.makeConstraints { (make) in
			make.top.equalTo(searchView.snp.bottom).offset(20)
			make.left.right.bottom.equalToSuperview()
		}
	}
}
