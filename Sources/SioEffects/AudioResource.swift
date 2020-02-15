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
		SIO.from { _ in
			bundle.url(forResource: resourceName, withExtension: ext)
		}
		.flatMap { url in
			SIO.from { _ in
				FileURL.init(url: url)
			}
		}
		.map(AudioResource.init)
	}
}

