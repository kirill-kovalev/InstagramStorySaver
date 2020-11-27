//
//  ProfileViewController.swift
//  InstaSaver
//
//  Created by Кирилл on 29.10.2020.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ProfileViewController: ViewController<ProfileView>, PreviewDisplayDelegate {
	let bag = DisposeBag()
	let viewModel = ProfileViewModel()
	
	var user = BehaviorRelay<ISUser?>(value: nil)
	
	var tableView: UITableView {self.rootView.tableView}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		tableView.estimatedRowHeight = 300
		tableView.rowHeight = UITableView.automaticDimension
		tableView.delegate = self
		tableView.dataSource = self
		
		self.bind(output: viewModel.transform(input: input))
		
		user.compactMap {$0}
			.subscribe(onNext: {  [weak self] in
				self?.rootView.headerView.usernameLabel.text = $0.username
				self?.rootView.headerView.infoLabel.text = $0.fullName
				if let url = $0.avatar {
					URLSession.shared.rx
						.data(request: URLRequest(url: url))
						.map(UIImage.init)
						.observeOn(MainScheduler.instance)
						.subscribe(onNext: {  [weak self] in
							self?.rootView.headerView.avatar.image = $0
						}).disposed(by: self?.bag ?? DisposeBag())
				}
				
			})
			.disposed(by: bag)
		
	}
	
	var input: ProfileViewModel.Input {
		ProfileViewModel.Input(
			user: self.user.compactMap {$0}.asObservable(),
			backButtonTap: self.rootView.headerView.backButton.rx.tap,
			userAvatarTap: self.rootView.headerView.avatarButton.rx.tap
		)
	}
	
	func bind(output: ProfileViewModel.Output) {
		output.posts
			.do(afterNext: reloadTable)
			.bind(to: self.rootView.postCollection.posts)
			.disposed(by: bag)
		output.hilights
			.do(afterNext: reloadTable)
			.bind(to: self.rootView.hilightsCollection.hilights)
			.disposed(by: bag)
		output.stories
			.do(afterNext: reloadTable)
			.bind(to: self.rootView.storiesCollection.stories)
			.disposed(by: bag)
		
		output.dismissTrigger.subscribe {[weak self] (_) in
			self?.navigationController?.popViewController(animated: true)
		}.disposed(by: bag)
		output.avatarPreviewTrigger.subscribe( onNext: {[weak self]  in
			let view = self?.rootView.headerView.avatar
			let viewFrame = view?.frame ?? .zero
			let frame = view?.convert(viewFrame, to: self?.view.window)
			self?.displayPreview($0, from: viewFrame)
		}).disposed(by: bag)
	}
	
	func reloadTable(_ : Any) {
		self.rootView.postCollection.layoutIfNeeded()
		self.rootView.tableView.reloadData()
	}

}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
	// resizing collection header
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if scrollView.contentSize.height > UIScreen.main.bounds.height-60 {
			let diff = 260 - pow(scrollView.contentOffset.y, 9/8)
			self.rootView.headerHeightConstraint.constant = diff > 60 ? diff : 60
		}
	}
	
	//tableView
	func numberOfSections(in tableView: UITableView) -> Int {3}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
			case 0: return self.rootView.hilightsCollection.hilights.value.isEmpty ? 0 : 1
			case 1: return self.rootView.storiesCollection.stories.value.content.isEmpty ? 0 : 1
			case 2: return self.rootView.postCollection.posts.value.isEmpty ? 0 : 1
			default: return 1
		}
	}

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		switch section {
			case 0: return self.rootView.hilightsCollection.hilights.value.isEmpty ? UIView(frame: .zero) : ISSectionHeaderView(title: "Hilights")
			case 1: return self.rootView.storiesCollection.stories.value.content.isEmpty ? UIView(frame: .zero) : ISSectionHeaderView(title: "Stories")
			case 2: return self.rootView.postCollection.posts.value.isEmpty ? UIView(frame: .zero) : ISSectionHeaderView(title: "Posts")
			default: return nil
		}
	}
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {nil}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell()
		cell.backgroundColor = .clear
		cell.contentView.backgroundColor = .clear
		if indexPath.section == 0 {
			let collection = self.rootView.hilightsCollection
			cell.contentView.addSubview(collection)
			collection.snp.remakeConstraints { $0.edges.equalToSuperview()
				$0.height.greaterThanOrEqualTo(tableView.frame.width/3.5) }
			collection.previewDelegate = self
		}
		if indexPath.section == 1 {
			let collection = self.rootView.storiesCollection
			cell.contentView.addSubview(collection)
			collection.snp.remakeConstraints {
				$0.edges.equalToSuperview()
				$0.height.greaterThanOrEqualTo(tableView.frame.width).dividedBy(4)
			}
			
			collection.previewDelegate = self
		}
		if indexPath.section == 2 {
			let collection = self.rootView.postCollection
			cell.contentView.addSubview(collection)
			collection.snp.remakeConstraints {
				$0.edges.equalToSuperview()
				$0.width.equalToSuperview()
				$0.height.greaterThanOrEqualTo(collection.snp.width).dividedBy(3).priority(.high)
			}
			collection.previewDelegate = self
			collection.reloadData()
		}
		
		return cell
	}
	
}
