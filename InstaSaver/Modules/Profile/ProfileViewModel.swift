//
//  ProvileViewModel.swift
//  InstaSaver
//
//  Created by Кирилл on 08.11.2020.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

class ProfileViewModel {
	let bag = DisposeBag()
	
	var posts = ReplaySubject<[ISMedia]>.create(bufferSize: 2)
	var stories = ReplaySubject<ISHilight>.create(bufferSize: 2)
	var hilights = ReplaySubject<[ISHilight]>.create(bufferSize: 2)
	
	func transform(input: Input) -> Output {
		input.user
			.flatMap(ISAPI.getPosts)
			.bind(to: self.posts)
			.disposed(by: bag)
		input.user
			.flatMap(ISAPI.getStories)
			.bind(to: self.stories)
			.disposed(by: bag)
		
		input.user
			.flatMap(ISAPI.getHilights)
			.bind(to: self.hilights)
			.disposed(by: bag)
		
		let avatarPresentOutput = input.userAvatarTap
			.flatMap{input.user}
			.compactMap(\.avatar)
			.map { [ISMedia.Content(date: nil, thumb: $0, link: $0, type: .photo)]}

		return Output(
			posts: posts.asObservable(),
			stories: stories.asObservable(),
			hilights: hilights.asObservable(),
			dismissTrigger: input.backButtonTap.asObservable(),
			avatarPreviewTrigger: avatarPresentOutput
		)
	}
	
	struct Input {
		var user: Observable<ISUser>
		var backButtonTap: ControlEvent<Void>
		var userAvatarTap: ControlEvent<Void>
	}
	struct Output {
		var posts: Observable<[ISMedia]>
		var stories: Observable<ISHilight>
		var hilights: Observable<[ISHilight]>
		
		var dismissTrigger: Observable<Void>
		var avatarPreviewTrigger: Observable<[ISMedia.Content]>
	}
}
