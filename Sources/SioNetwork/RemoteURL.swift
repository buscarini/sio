//
//  RemoteURL.swift
//  SioEffects
//
//  Created by José Manuel Sánchez Peñarroja on 06/12/2019.
//

import Foundation

public struct RemoteURL: Equatable, Hashable, Codable {
	public private(set) var rawValue: URL
	
	init?(url: URL) {
		guard url.isFileURL == false else {
			return nil
		}
		
		self.rawValue = url
	}
}

public extension RemoteURL {
	init?(_ string: String) {
		guard let remote = URL.init(string: string)
			.flatMap(RemoteURL.init(url:))
		else {
				return nil
		}
		
		self = remote
	}
}
