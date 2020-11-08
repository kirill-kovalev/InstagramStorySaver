//
//  FeedViewModel.swift
//  InstaSaver
//
//  Created by Кирилл on 08.11.2020.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

import ComposableRequestCrypto
import Swiftagram
import SwiftagramCrypto

class FeedViewModel {
	
	let bag = DisposeBag()

	
	
	var shouldShowStories = BehaviorRelay<Bool>(value: true)
	var logoutTrigger = PublishRelay<Void>()
	
	var userlist:[ISUser] = []
	func transform(input:Input) -> Output{
		
		let users = input.searchQuery.flatMap { (query) -> Observable<[ISUser]> in
			if let query = query,
			   !query.isEmpty {
				return ISAPI.searchUser(query: query)
							.do(onNext: {[weak self] in self?.userlist = $0})
			}else {
				return ISAPI.getFriends()
							.do(onNext: {[weak self] in self?.userlist = $0})
				
			}
		}

		input.editingBeganEvent.map { _ in false}.bind(to: shouldShowStories).disposed(by: bag)
		input.editingEndEvent.map { _ in true}.bind(to: shouldShowStories).disposed(by: bag)
		
		input.logoutButtonTap.bind(to: self.logoutTrigger).disposed(by: bag)
		ISAPI.needsAuth.compactMap {$0 ? Void() : nil}.bind(to: self.logoutTrigger).disposed(by: bag)
		
		let userPresent = input.displayUserTrigger.compactMap {[weak self] (indexPath) -> ISUser? in
//			if indexPath.section
			if let self = self,
			   indexPath.row >= 0,
			   indexPath.row < self.userlist.count{
				return self.userlist[indexPath.row]
			}else{
				return nil
			}
		}
		
		return Output(
			shouldShowStories: self.shouldShowStories.asObservable(),
			stories: Observable<[ISHilight]>.just([]),
			users: users,
			logoutTrigger: self.logoutTrigger.do(onNext: {}),
			userPresentTrigger: userPresent
		)
	}
	
	
	struct Input {
		var logoutButtonTap:ControlEvent<Void>
		var searchQuery:ControlProperty<String?>
		var editingBeganEvent:ControlEvent<Void>
		var editingEndEvent:ControlEvent<Void>
		var displayUserTrigger:Observable<IndexPath>
	}
	struct Output {
		var shouldShowStories:Observable<Bool>
		var stories:Observable<[ISHilight]>
		var users:Observable<[ISUser]>
		var logoutTrigger:Observable<Void>
		var userPresentTrigger:Observable<ISUser>
	}
}
