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

let ISAPI = ISapi()
class ISapi {
	private var secret: Secret? { secretObservable.value }
	private var secretObservable = BehaviorRelay<Secret?>(value: nil)
	
	private var authPublish = ReplaySubject<Bool>.create(bufferSize: 3)
	lazy var needsAuth = authPublish.asObservable()
	
	private let bag = DisposeBag()
	
	private let storage = KeychainStorage<Secret>()
	init() {
		secretObservable.asObservable()
			.map { $0 == nil }
			.bind(to: authPublish)
			.disposed(by: bag)
		
		if let secret = storage.all().first {
			print("auth: ok")
			self.auth(secret)
		} else {
			print("auth: err")
			self.logout()
		}
		
	}
	
	func auth(_ s: Secret) {
		KeychainStorage().store(s)
		secretObservable.accept(s)
	}
	func logout() {
		storage.removeAll()
		secretObservable.accept(nil)
	}
	
	func searchUser(query: String)-> Observable<[ISUser]> {
		let publisher = PublishSubject<[ISUser]>()
		publisher.on(.next([]))
		guard let secret = secret else {
			publisher.on(.completed)
			return publisher.asObservable()
		}
		
		Endpoint.User.all(matching: query)
			.unlocking(with: secret)
			.task(maxLength: .max, by: .default, onComplete: { _ in
				publisher.on(.completed)
			}, onChange: {
				switch $0 {
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
	
	func getFriends() -> Observable<[ISUser]> {
		let publisher = PublishSubject<[ISUser]>()
		
		guard let secret = secret else { return publisher.asObservable()}
		
		let cache = [ISUser]()
		publisher.on(.next(cache))
		Endpoint.Friendship.following(secret.identifier)
			.unlocking(with: secret)
			.task(maxLength: .max, by: .default, onComplete: { _ in
				publisher.on(.completed)
			}, onChange: {
				switch $0 {
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
	
	func getPosts(of user: ISUser)-> Observable<[ISMedia]> {
		let publisher = PublishSubject<[ISMedia]>()
		
		guard let secret = secret else { return publisher.asObservable()}
		
		let cache = [ISMedia]()
		publisher.on(.next(cache))
		
		var allPosts = [ISMedia]()
	
		Endpoint.Media.Posts.owned(by: user.identity)
			.unlocking(with: secret)
			.task(maxLength: 3, by: .default, onComplete: { _ in
				publisher.on(.completed)
			}, onChange: {
				switch $0 {
					case .success(let data):
						if let posts = data.media?.map({$0.toISMedia()}) {
							allPosts.append(contentsOf: posts)
							publisher.on(.next(allPosts))
						}
					case .failure(let error): publisher.on(.error(error))
				}
			})
			.resume()
		return publisher.asObservable()
	}
	
	func getStories(of user: ISUser) -> Observable<ISHilight> {
		let publisher = PublishSubject<ISHilight>()
		
		guard let secret = secret else { return publisher.asObservable()}

		Endpoint.Media.Stories.owned(by: user.identity)
			.unlocking(with: secret)
			.task(onComplete: {
				switch $0 {
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
	
	func getTray(of user: ISUser) -> Observable<[ISHilight]> {
		let publisher = PublishSubject<[ISHilight]>()
		print("start")
		guard let secret = secret else { return publisher.asObservable()}//
		print("secret")
		Endpoint.Media.Stories.followed
			.unlocking(with: secret).task(by: .default) {
				print("loaded")
				switch $0 {
					case .success(let data):
						if let tray = data.items?.map({$0.toISHilight()}) {
							publisher.on(.next(tray))
						}
						
					case .failure(let err):
						print("tray", err)
						publisher.on(.error(err))
				}
				publisher.on(.completed)
			}.resume()
		return publisher.asObservable()
	}
	
	func getHilights(of user: ISUser)-> Observable<[ISHilight]> {
		let publisher = PublishSubject<[ISHilight]>()
		
		guard let secret = secret else { return publisher.asObservable()}
		
		Endpoint.Media.Stories.highlights(for: user.identity)
			.unlocking(with: secret)
			.task(by: .default, onComplete: {
				switch $0 {
					case .success(let data):
						if let hilights = data.items?.map({$0.toISHilight()}) {
							publisher.on(.next(hilights))
						}
					case .failure(let error): publisher.on(.error(error))
				}
				publisher.on(.completed)
			})
			.resume()
		
		return publisher.asObservable()
	}
	
}
