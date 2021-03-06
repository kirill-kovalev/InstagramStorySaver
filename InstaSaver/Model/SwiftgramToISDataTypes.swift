//
//  SwiftgramToISDataTypes.swift
//  InstaSaver
//
//  Created by Кирилл on 08.11.2020.
//

import Foundation
import ComposableRequestCrypto
import Swiftagram
import SwiftagramCrypto

extension Media.Content {
	func ISContent() -> [ISMedia.Content] {
		switch self {
			case .picture( let picture):
				let imgLinks = (picture.images ?? []).sorted(by: { $0.resolution > $1.resolution}).compactMap(\.url)
				guard let link = imgLinks.first else {return []}
				return [ISMedia.Content(thumb: link, link: link, type: .photo)]

			case .video(let video):
				let thumbLinks = (video.images ?? []).sorted(by: { $0.resolution > $1.resolution}).compactMap(\.url)
				let videoLinks = (video.clips ?? []).sorted(by: { $0.resolution > $1.resolution}).compactMap(\.url)
				
				guard let thumbLink = thumbLinks.first else {return []}
				if let videoLink = videoLinks.first {
					return [ISMedia.Content(thumb: thumbLink, link: videoLink, type: .video)]
				} else {
					return [ISMedia.Content(thumb: thumbLink, link: thumbLink, type: .photo)]
				}
				
			case .album( let album): return album.flatMap {$0.ISContent()}
			case .error: return []
		}
		
	}
}
extension Media {
	func toISMedia() -> ISMedia {
		let content = self.content.ISContent()
		let user = self.user?.toISUser()
		
		return ISMedia(content: content,
					   owner: user,
					   date: self.takenAt ?? Date(),
					   description: self.caption?.text,
					   identity: self.identifier ?? "")

	}
}
extension User {
	func toISUser() -> ISUser {
		let isEmpty = self.name?.isEmpty ?? true
		let fullName = isEmpty ? self.username : self.name
		return ISUser(username: self.username, fullName: fullName, avatar: self.avatar ?? self.thumbnail, identity: self.identifier)
	}
}

extension TrayItem {
	func toISHilight() -> ISHilight {
		let user = self.user?.toISUser()
		let content = self.items?.flatMap { media ->  [ISMedia.Content] in
			media.content.ISContent().map {
				var content = $0
				content.date = media.takenAt ??  media.expiringAt
				return content
			}
		}

		let croppedImageVersion = self.wrapper().dictionary()?["croppedImageVersion"]?.dictionary()?["url"]?.url()
		let thumb = self.cover?.toISMedia().content.first?.thumb ?? content?.first?.thumb ?? croppedImageVersion ?? user?.avatar
		return ISHilight(content: content ?? [],
						 thumb: thumb,
						 owner: user,
						 identity: self.identifier)
	}
}
