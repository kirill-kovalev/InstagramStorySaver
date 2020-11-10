//
//  NetworkManager.swift
//  InstaSaver
//
//  Created by Кирилл on 04.11.2020.
//

import Foundation
import RxSwift

class ISNetwork {
	private class DataContainer {
		init(_ data: Data) {
			self.data = data
		}
		let data: Data
	}
//	static let shared = ISNetwork()
	
	private static var cache = NSCache<NSString, DataContainer>()
	
	static func data(_ url: URL) -> Observable<Data> {
		if let data = cache.object(forKey: url.absoluteString as NSString)?.data {
			return Observable.just(data)
		} else {
			return URLSession.shared.rx.data(request: URLRequest(url: url)).do(onNext: { data in
				self.cache.setObject(DataContainer(data), forKey: url.absoluteString as NSString)
			}).asObservable()
		}
	}
}
