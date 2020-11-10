//
//  FeedController.swift
//  InstaSaver
//
//  Created by Кирилл on 21.10.2020.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

enum SectionTypes {
	case stories(Observable<[ISHilight]>)
	case user(ISUser)
}
typealias FeedTableSection = SectionModel<String, SectionTypes>

class FeedVC: ViewController<FeedView>, PreviewDisplayDelegate {
	let viewModel = FeedViewModel()
	
	lazy var dataSource = RxTableViewSectionedReloadDataSource<FeedTableSection> {[weak self] (_, tableView, indexPath, sectionItem) -> UITableViewCell in
		guard let self = self else {return UITableViewCell()}
		
		switch sectionItem {
			case .stories(let hilights):
				let cell = tableView.dequeueReusableCell(withIdentifier: "StoriesCell", for: indexPath) as! StoriesCell
				hilights.bind(to: cell.collectionView.stories).disposed(by: self.bag)
				cell.collectionView.previewDelegate = self
				return cell

			case .user(let user):
				let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsCell", for: indexPath) as! FriendsCell
				
				cell.username.text = user.fullName ?? user.username
				cell.timestamp.text = " @\(user.username)"
				
				if let url = user.avatar {
					URLSession.shared.rx
						.data(request: URLRequest(url: url))
						.map(UIImage.init)
						.observeOn(MainScheduler.instance)
						.bind(to: cell.avatar.rx.image)
						.disposed(by: self.bag)
				} else {
					print("avatar is nil")
				}
				
				return cell
		}
		
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.rootView.contentTable.register(StoriesCell.self, forCellReuseIdentifier: "StoriesCell")
		self.rootView.contentTable.register(FriendsCell.self, forCellReuseIdentifier: "FriendsCell")
		self.rootView.contentTable.delegate = self
		
		bind(output: viewModel.transform(input: input))
	}
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
	}
	var input: FeedViewModel.Input {
		FeedViewModel.Input(
			logoutButtonTap: self.rootView.logoutButton.rx.tap,
			searchQuery: self.rootView.searchView.RXtextfield.text,
			editingBeganEvent: self.rootView.searchView.RXtextfield.controlEvent(.editingDidBegin),
			editingEndEvent: self.rootView.searchView.RXtextfield.controlEvent(.editingDidEnd),
			displayUserTrigger: self.rootView.contentTable.rx.itemSelected
							.do(onNext: {[weak self] in self?.rootView.contentTable.deselectRow(at: $0, animated: false) })
		)
	}
	let bag = DisposeBag()
	
	private func bind(output: FeedViewModel.Output) {
		Observable.combineLatest(
			output.users,
			output.shouldShowStories
		)
		.map { (users, showStories) in
			return showStories ? [
				FeedTableSection(model: "stories", items: [ SectionTypes.stories(output.stories) ]),
				FeedTableSection(model: "users", items: users.map {SectionTypes.user($0)})
			] : [FeedTableSection(model: "users", items: users.map {SectionTypes.user($0)})]
		}.bind(to: self.rootView.contentTable.rx.items(dataSource: dataSource))
		.disposed(by: bag)
		
		output.logoutTrigger.subscribe(onNext: { [weak self] in
			self?.present(LoginViewController(), animated: true, completion: nil)
		}).disposed(by: bag)
		
		output.userPresentTrigger.subscribe(onNext: { [weak self] user in
			let vc = ProfileViewController()
			vc.user.accept(user)
			self?.navigationController?.pushViewController(vc, animated: true)
		}).disposed(by: bag)
	}

}
extension FeedVC: UITableViewDelegate {
	func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		return !(tableView.numberOfSections != 1 && indexPath.section == 0)
	}
}
