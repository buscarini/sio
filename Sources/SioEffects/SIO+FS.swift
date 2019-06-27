//
//  SIO.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 29/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation
import Sio

public struct FS {
	public var createDir = defaultCreateDir
	
	public var copyItem = defaultCopyItem
	public var moveItem = defaultMoveItem
	public var linkItem = defaultLinkItem
	public var removeItem = defaultRemoveItem
	
	// Attributes
	public var markSkipBackup = defaultMarkSkipBackup

	public init(
		createDir: @escaping (URL, Bool) -> Task<Void>,
		
		copyItem: @escaping (URL, URL) -> Task<Void>,
		moveItem: @escaping (URL, URL) -> Task<Void>,
		linkItem: @escaping (URL, URL) -> Task<Void>,
		removeItem: @escaping (URL) -> Task<Void>,
		
		markSkipBackup: @escaping (URL) -> Task<Void>
	) {
		self.createDir = createDir
		
		self.removeItem = removeItem
		self.moveItem = moveItem
		self.linkItem = linkItem
		self.removeItem = removeItem
		
		self.markSkipBackup = markSkipBackup
	}
	
	static func defaultCreateDir(at url: URL, createIntermediate: Bool) -> Task<Void> {
		return Task<Void>.init(catching: { _ in
			try FileManager.default.createDirectory(at: url, withIntermediateDirectories: createIntermediate, attributes: nil)
		})
	}
	
	static func defaultCopyItem(at url: URL, to target: URL) -> Task<Void> {
		return Task<Void>.init(catching: { _ in
			try FileManager.default.copyItem(at: url, to: target)
		})
	}
	
	static func defaultMoveItem(at url: URL, to target: URL) -> Task<Void> {
		return Task<Void>.init(catching: { _ in
			try FileManager.default.moveItem(at: url, to: target)
		})
	}
	
	static func defaultLinkItem(at url: URL, to target: URL) -> Task<Void> {
		return Task<Void>.init(catching: { _ in
			try FileManager.default.linkItem(at: url, to: target)
		})
	}
	
	static func defaultRemoveItem(at url: URL) -> Task<Void> {
		return Task<Void>.init(catching: { _ in
			try FileManager.default.removeItem(at: url)
		})
	}
	
	static func defaultMarkSkipBackup(at url: URL) -> Task<Void> {
		return Task<Void>.init(catching: { _ in
			var changeUrl = url
			var resourceValues = URLResourceValues()
			resourceValues.isExcludedFromBackup = true
			try changeUrl.setResourceValues(resourceValues)
		})
	}
	
	
}