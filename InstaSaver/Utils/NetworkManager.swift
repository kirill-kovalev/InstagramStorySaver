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
	static func download(_ media: ISMedia.Content) -> Observable<URL> {
		let publisher = ReplaySubject<URL>.createUnbounded()
		do {
			let documentsUrl = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
			let remoteLink = media.link
			
			if let cachedData = cache.object(forKey: remoteLink.lastPathComponent as NSString)?.data,
			   let stringUrl = String(data: cachedData, encoding: .utf8),
			   let localUrl = documentsUrl.appendingPathComponent(stringUrl) as? URL,
			   print("caching",localUrl) == Void()
			{
				print("caching found ",localUrl)
				publisher.on(.next(localUrl))
				publisher.on(.completed)
			} else {
				URLSession.shared.downloadTask(with: remoteLink) { (tempURL, _, error) in
					if let error = error {
						publisher.on(.error(error))
						return
					}
					print("caching temp",tempURL)
					
					if let tempURL = tempURL {
						let destURL = documentsUrl.appendingPathComponent(remoteLink.lastPathComponent)
						do {
							print("caching dest",destURL)
							
							_ = try? FileManager.default.removeItem(at: destURL)
							try FileManager.default.copyItem(at: tempURL, to: destURL)
							
							if let data = destURL.lastPathComponent.data(using: .utf8) {
								cache.setObject(DataContainer(data), forKey: remoteLink.lastPathComponent as NSString)
							}
//							sleep(1)
							publisher.on(.next(destURL))
						} catch { publisher.on(.error(error)) }
					}
					publisher.on(.completed)
				}.resume()
			}

		} catch { publisher.on(.error(error)) }
		
		return publisher.asObservable()

	}
	
}
