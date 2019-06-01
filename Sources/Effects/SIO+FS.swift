//
//  SIO.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 29/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public struct FS {
	
	public var removeItem = defaultRemoveItem

	public init(
		removeItem: @escaping (URL) -> Task<Void>
	) {
		self.removeItem = removeItem
	}
	
	static func defaultRemoveItem(at url: URL) -> Task<Void> {
		return Task<Void>.init(catching: { _ in
			try FileManager.default.removeItem(at: url)
		})
	}
}
