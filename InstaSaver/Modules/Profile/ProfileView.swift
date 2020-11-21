//
//  ProfileView.swift
//  InstaSaver
//
//  Created by Кирилл on 29.10.2020.
//

import UIKit

class ProfileView: BasicView {
	lazy var tableView: UITableView = {
		let tableView = UITableView(frame: .zero)
		tableView.allowsMultipleSelection = false
		tableView.allowsSelection = false
		tableView.separatorStyle = .none
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 100
		tableView.backgroundColor = .clear
		return tableView
	}()
	
	let postCollection = PostCollectionView()
	let storiesCollection = StoriesCollectionView()
	let hilightsCollection = HilightsCollectionView()
	
	let headerView = UserPageHeaderView()
	
	var headerHeightConstraint: NSLayoutConstraint!
	override func addViews() {
		self.backgroundColor = Asset.Colors.white.color
		self.addSubview(tableView)
		self.addSubview(headerView)
	}
	override func setupConstraints() {
		headerView.snp.makeConstraints { (make) in
			make.top.equalTo(safeAreaLayoutGuide)
			make.left.right.equalToSuperview()
			self.headerHeightConstraint =
				make.height.equalTo(260).constraint.layoutConstraints.first
		}
		tableView.snp.makeConstraints { (make) in
			make.left.right.bottom.equalToSuperview()
			make.top.equalTo(headerView.snp.bottom)
		}
	}
}
