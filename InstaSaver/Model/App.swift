//
//  App.swift
//  InstaSaver
//
//  Created by Кирилл on 08.11.2020.
//

import Foundation
import RxSwift
import RxCocoa

import ComposableRequestCrypto
import Swiftagram
import SwiftagramCrypto


class ISAPI {
//	var needsAuth = BehaviorRelay<Bool>(value: false)
	private var secret:Secret? = nil
	
	public var needsAuth:Bool {secret == nil}
	
	func getFriends() -> Observable<[ISUser]>{
		let publisher = PublishSubject<[ISUser]>()
		
		guard let secret = secret else { return publisher.asObservable()}
		
		let cache = [ISUser]()
		publisher.on(.next(cache))
		Endpoint.Friendship.following(secret.identifier)
			.unlocking(with: secret)
			.task(maxLength: .max, by: .default, onComplete: { _ in
				publisher.on(.completed)
			}, onChange: {
				switch $0{
					case .success(let data):
						if let users = data.users?.map({ $0.toISUser() }) {
							publisher.on(.next(users))
						}
					case .failure(let error): publisher.on(.error(error))	
				}
			})
			.resume()
		return publisher.asObservable()
	}
	
	func getPosts(of user:ISUser)-> Observable<[ISMedia]>{
		let publisher = PublishSubject<[ISMedia]>()
		
		guard let secret = secret else { return publisher.asObservable()}
		
		let cache = [ISMedia]()
		publisher.on(.next(cache))
		Endpoint.Media.Posts.owned(by: user.identity)
			.unlocking(with: secret)
			.task(maxLength: 10, by: .default, onComplete: { _ in
				publisher.on(.completed)
			}, onChange: {
				switch $0{
					case .success(let data):
						if let posts = data.media?.map({$0.toISMedia()}) {
							publisher.on(.next(posts))
						}
					case .failure(let error): publisher.on(.error(error))
				}
			})
			.resume()
		return publisher.asObservable()
	}
	
	func getStories(of user:ISUser)-> Observable<ISHilight>{
		let publisher = PublishSubject<ISHilight>()
		
		guard let secret = secret else { return publisher.asObservable()}

		Endpoint.Media.Stories.owned(by: user.identity)
			.unlocking(with: secret)
			.task(onComplete: {
				switch $0{
					case .success(let data):
						if let stories = data.item?.toISHilight() {
							publisher.on(.next(stories))
						}
					case .failure(let error): publisher.on(.error(error))
				}
			})
			.resume()
		return publisher.asObservable()
	}
}
