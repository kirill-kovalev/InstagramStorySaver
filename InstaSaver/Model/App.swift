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
	
	private var authPublish = ReplaySubject<Bool>.create(bufferSize: 1)
	var needsAuth: Observable<Bool> {authPublish.asObservable()}
	
	private let bag = DisposeBag()
	
	private let storage = KeychainStorage<Secret>()
	public var user: String {secret?.identifier ?? ""}
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
		guard let secret = secret else { return Observable<[ISUser]>.just([])}
		
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
		
		guard let secret = secret else { return Observable<[ISUser]>.just([])}
		
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
		
		guard let secret = secret else { return Observable<[ISMedia]>.just([])}
		
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
						publisher.on(.next(allPosts))
					case .failure(let error): publisher.on(.error(error))
				}
			})
			.resume()
		return publisher.asObservable()
	}
	
	func getStories(of user: ISUser) -> Observable<ISHilight> {
		let publisher = PublishSubject<ISHilight>()
		
		guard let secret = secret else { return Observable<ISHilight>.just(ISHilight.empty)}

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
	
	func getTray() -> Observable<[ISHilight]> {
		let publisher = PublishSubject<[ISHilight]>()
		
		guard let secret = secret else { return Observable<[ISHilight]>.just([])}//
		
		Endpoint.Media.Stories.followed
			.unlocking(with: secret)
			.task(by: .default) {
				switch $0 {
					case .success(let data):
						if let tray = data.items?
							.map({$0.toISHilight()})
						{
							publisher.on(.next(tray))
						}
						
					case .failure(let err): publisher.on(.error(err))
				}
				publisher.on(.completed)
			}.resume()
		return publisher.observeOn(MainScheduler.instance).asObservable()
	}
	
	func getStories(for users: [ISUser]) -> Observable<[ISHilight]> {
		let publisher = PublishSubject<[ISHilight]>()
		guard let secret = secret else { return Observable<[ISHilight]>.just([])}
		
		Endpoint.Media.Stories.owned(by: users.map(\.identity))
			.unlocking(with: secret)
			.task {
				print("loaded")
				switch $0 {
					case .success(let data):
						if let tray = data.items?.map({$1.toISHilight()}) {
							publisher.on(.next(tray))
						}
						
					case .failure(let err):
						publisher.on(.error(err))
				}
				publisher.on(.completed)
			}.resume()
		return publisher.observeOn(MainScheduler.instance).asObservable()
	}
	
	func getHilights(of user: ISUser)-> Observable<[ISHilight]> {
		let publisher = PublishSubject<[ISHilight]>()
		guard let secret = secret else { return Observable<[ISHilight]>.just([])}
		getMedia(for: "2396852811477631110_4616269663")
//		Endpoint.Media.Stories.highlights(for: user.identity)
//			.unlocking(with: secret)
//			.task(by: .default, onComplete: {
//				switch $0 {
//					case .success(let data):
//						if let hilights = data.items?.map({ item -> ISHilight in
//							self.getMedia(for: item.identifier)
//							return item.toISHilight()
//						})
//						{
//							publisher.on(.next(hilights))
//						}
//					case .failure(let error): publisher.on(.error(error))
//				}
//				publisher.on(.completed)
//			})
//			.resume()
		
		return publisher.asObservable()
	}

	func getMedia(for id: String) {
		print("GETMEDIA", "start", id)
		let publisher = PublishSubject<[ISHilight]>()
		guard let secret = secret else { return}// Observable<[ISHilight]>.just([])}
		print("GETMEDIA", "secret")
		Endpoint.Media.summary(for: id )
			.unlocking(with: secret)
			.task(by: .default, onComplete: {
				switch $0 {
					case .success(let data):
//						print("GETMEDIA", data)
						if let content = data.media?.map({$0.toISMedia()}) {
							print("GETMEDIA", content.first?.content.first?.link )
						}
						
					case .failure(let error):
						print("GETMEDIA", "error", error)
						publisher.on(.error(error))
				}
				publisher.on(.completed)
			})
			.resume()
			
	}
}
