//
//  ISDataTypes.swift
//  InstaSaver
//
//  Created by Кирилл on 08.11.2020.
//

import Foundation

struct ISMedia {
	enum ContentType: Equatable {
		case photo
		case video
	}
	
	var content: [Content]
	var owner: ISUser?
	var date: Date
	var description: String?
	
	var identity: String
	
	struct Content: Equatable {
		var date: Date?
		var thumb: URL
		var link: URL
		var type: ContentType
	}
}
struct ISUser: Equatable {
	var username: String
	var fullName: String?
	var avatar: URL?
	var identity: String
}

struct ISHilight: Equatable {
	static let empty = ISHilight(content: [], thumb: nil, owner: nil, identity: "")
	
	var content: [ISMedia.Content]
	var thumb: URL?
	var owner: ISUser?
	var identity: String
	
}
