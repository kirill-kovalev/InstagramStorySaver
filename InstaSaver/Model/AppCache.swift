//
//  AppCache.swift
//  InstaSaver
//
//  Created by Кирилл on 21.11.2020.
//

import Foundation
import RxSwift
import RxCocoa

import RealmSwift
import RxRealm

class AppCache {
	let realm = (try? Realm())!
	
	lazy var friends = friendsList.replayAll()
	private var friendsList = BehaviorRelay<[ISUser]>(value: [])
	
	init(){
		let a = realm.objects(FriendNode.self)
		let b = Array(a).compactMap {$0.enity}
		friendsList.accept(b)
	}
}

class FriendNode: RealmSwift.Object {
	dynamic var enity: ISUser?
}
