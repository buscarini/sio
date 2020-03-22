//
//  AudioResource.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 22/12/2019.
//

import Foundation
import Sio

public struct AudioResource: Equatable, Hashable, Codable {
	public var url: FileURL
	
	public init(
		_ url: FileURL
	) {
		self.url = url
	}
}

public extension AudioResource {
	static func resource(
		_ resourceName: String,
		extension ext: String,
		bundle: Bundle = .main
	) -> IO<Void, AudioResource> {
		FS().url(bundle, name: resourceName, extension: ext)
			.map(AudioResource.init)
	}
}

