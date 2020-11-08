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

class FeedVC: ViewController<FeedView> {
	let bag = DisposeBag()

	typealias TableSectionModel = SectionModel<String, Any>
	lazy var dataSource = RxTableViewSectionedReloadDataSource<TableSectionModel> {[weak self] (_, tableView, indexPath, _) -> UITableViewCell in
		guard let self = self else {return UITableViewCell()}
		if indexPath.section == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "StoriesCell", for: indexPath)
			
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsCell", for: indexPath)
			
			return cell
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.rootView.contentTable.register(StoriesCell.self, forCellReuseIdentifier: "StoriesCell")
		self.rootView.contentTable.register(FriendsCell.self, forCellReuseIdentifier: "FriendsCell")
		self.rootView.contentTable.delegate = self
		
	}

}
extension FeedVC: UITableViewDelegate {
	func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		return !(tableView.numberOfSections != 1 && indexPath.section == 0)
	}
}
