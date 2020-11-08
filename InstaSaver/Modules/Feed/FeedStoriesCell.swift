//
//  FeedStoriesCell.swift
//  InstaSaver
//
//  Created by Кирилл on 28.10.2020.
//

import UIKit

class StoriesCell: UITableViewCell {
	private let vstack: UIStackView = {
		let stack = UIStackView(frame: .zero)
		stack.alignment = .center
		stack.axis = .vertical
		stack.spacing = 10
		return stack
	}()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}
	
	let stroriesController = StoriesViewController()
	
	private func setup() {
		self.contentView.backgroundColor = .clear
		self.backgroundColor = .clear
		
		contentView.addSubview(vstack)
		vstack.snp.makeConstraints { $0.edges.equalTo(contentView) }
		vstack.addArrangedSubview(ISSectionHeaderView(title: "Stories"))
		vstack.addArrangedSubview(stroriesController.view)
		vstack.addArrangedSubview(ISSectionHeaderView(title: "All friends"))
		
		stroriesController.view.snp.makeConstraints { (make) in
			make.height.equalTo(147)
			make.left.right.equalToSuperview()
		}
	}
}
