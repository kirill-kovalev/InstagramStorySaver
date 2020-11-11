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
	var logoutTrigger = ReplaySubject<Void>.create(bufferSize: 1)
	
	var hilights = ReplaySubject<[ISHilight]>.create(bufferSize: 2)
	
	var userlist: [ISUser] = []
	func transform(input: Input) -> Output {
		let users = input.searchQuery.flatMap { (query) -> Observable<[ISUser]> in
			if let query = query,
			   !query.isEmpty {
				return ISAPI.searchUser(query: query)
							.compactMap {$0}
							.do(onNext: {[weak self] in self?.userlist = $0})
			} else {
				return ISAPI.getFriends()
							.compactMap {$0}
							.do(onNext: {[weak self] in self?.userlist = $0})
				
			}
		}

		input.editingBeganEvent.map { _ in false}.bind(to: shouldShowStories).disposed(by: bag)
		input.editingEndEvent.map { _ in true}.bind(to: shouldShowStories).disposed(by: bag)
		
		input.logoutButtonTap
			.do(onNext: {_ in ISAPI.logout()})
			.bind(to: self.logoutTrigger).disposed(by: bag)
		
		ISAPI.needsAuth.compactMap {$0 ? Void() : nil}
			.bind(to: logoutTrigger)
			.disposed(by: bag)
		
		let userPresent = input.displayUserTrigger.compactMap {[weak self] (indexPath) -> ISUser? in
			if let self = self,
			   indexPath.row >= 0,
			   indexPath.row < self.userlist.count {
				return self.userlist[indexPath.row]
			} else {
				return nil
			}
		}
		
		shouldShowStories
			.flatMap { (_) in ISAPI.getTray() }
			.bind(to: self.hilights)
			.disposed(by: bag)
		
		let loadedHilights = hilights
			.distinctUntilChanged()
			.map { (hilights) -> [ISHilight] in
			hilights.filter {!$0.content.isEmpty}
		}
		let extraLoadedHilights = hilights
			.distinctUntilChanged()
			.compactMap { (hilights) in
			hilights.filter {$0.content.isEmpty}.compactMap(\.owner)
		}
		.filter {!$0.isEmpty}
		.flatMap {ISAPI.getStories(for: $0)}
		
		let displayHilights = Observable.combineLatest(
			loadedHilights,
			extraLoadedHilights
		).map {$0+$1}
		.filter {!$0.isEmpty}
		
		return Output(
			shouldShowStories: self.shouldShowStories.asObservable(),
			stories: displayHilights,
			users: users,
			logoutTrigger: self.logoutTrigger.do(onNext: {}),
			userPresentTrigger: userPresent
		)
	}
	
	struct Input {
		var logoutButtonTap: ControlEvent<Void>
		var searchQuery: ControlProperty<String?>
		var editingBeganEvent: ControlEvent<Void>
		var editingEndEvent: ControlEvent<Void>
		var displayUserTrigger: Observable<IndexPath>
	}
	struct Output {
		var shouldShowStories: Observable<Bool>
		var stories: Observable<[ISHilight]>
		var users: Observable<[ISUser]>
		var logoutTrigger: Observable<Void>
		var userPresentTrigger: Observable<ISUser>
	}
}
