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
	public var createDir: (URL, Bool) -> Task<Void>
	public var lsDir: (URL) -> Task<[URL]>
	
	public var copy: (URL, URL) -> Task<Void>
	public var move: (URL, URL) -> Task<Void>
	public var link: (URL, URL) -> Task<Void>
	public var remove: (URL) -> Task<Void>
	
	// Content
	public var readFile: (FileURL) -> Task<Data>
	public var writeFile: (Data, FileURL) -> Task<FileURL>
	
	// Attributes
	public var markSkipBackup: (URL) -> Task<Void>

	public init(
		createDir: @escaping (URL, Bool) -> Task<Void> = Default.createDir,
		lsDir: @escaping (URL) -> Task<[URL]> = Default.lsDir,

		copy: @escaping (URL, URL) -> Task<Void> = Default.copyItem,
		move: @escaping (URL, URL) -> Task<Void> = Default.moveItem,
		link: @escaping (URL, URL) -> Task<Void> = Default.linkItem,
		remove: @escaping (URL) -> Task<Void> = Default.removeItem,
		
		readFile: @escaping (FileURL) -> Task<Data> = Default.readFile,
		writeFile: @escaping (Data, FileURL) -> Task<FileURL> = Default.writeFile,
		
		markSkipBackup: @escaping (URL) -> Task<Void> = Default.markSkipBackup
	) {
		self.createDir = createDir
		self.lsDir = lsDir
		
		self.remove = remove
		
		self.copy = copy
		self.move = move
		self.link = link
		self.remove = remove
		
		self.readFile = readFile
		self.writeFile = writeFile
		
		self.markSkipBackup = markSkipBackup
	}
	
	public func createFileDir(at url: FileURL, createIntermediate: Bool) -> Task<FileURL> {
		return Task.of(url)
			.map {
				$0.rawValue.deletingLastPathComponent()
			}
			.flatMap { self.createDir($0, createIntermediate) }
			.map { _ in
				return url
			}
	}
	
	// MARK: Defaults
	public enum Default {
		public static func createDir(at url: URL, createIntermediate: Bool) -> Task<Void> {
			return Task<Void>.init(catching: { _ in
				try FileManager.default.createDirectory(at: url, withIntermediateDirectories: createIntermediate, attributes: nil)
			})
		}
		
		public static func lsDir(_ url: URL) -> Task<[URL]> {
			return Task<[URL]>.init(catching: { _ in
				try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
			})
		}
		
		public static func copyItem(at url: URL, to target: URL) -> Task<Void> {
			return Task<Void>.init(catching: { _ in
				try FileManager.default.copyItem(at: url, to: target)
			})
		}
		
		public static func moveItem(at url: URL, to target: URL) -> Task<Void> {
			return Task<Void>.init(catching: { _ in
				try FileManager.default.moveItem(at: url, to: target)
			})
		}
		
		public static func linkItem(at url: URL, to target: URL) -> Task<Void> {
			return Task<Void>.init(catching: { _ in
				try FileManager.default.linkItem(at: url, to: target)
			})
		}
		
		public static func removeItem(at url: URL) -> Task<Void> {
			return Task<Void>.init(catching: { _ in
				try FileManager.default.removeItem(at: url)
			})
		}
		
		// MARK: IO
		public static func readFile(from path: FileURL) -> Task<Data> {
			return Task<Data>.init(catching: { _ in
				try Data(contentsOf: path.rawValue)
			})
		}
		
		
		public static func writeFile(data: Data, toPath url: FileURL) -> Task<FileURL> {
			return Task<Void>.init(catching: { _ in
				try data.write(to: url.rawValue)
			})
				.map(const(url))
		}
		
		
		// MARK: Attributes
		public static func markSkipBackup(at url: URL) -> Task<Void> {
			return Task<Void>.init(catching: { _ in
				var changeUrl = url
				var resourceValues = URLResourceValues()
				resourceValues.isExcludedFromBackup = true
				try changeUrl.setResourceValues(resourceValues)
			})
		}
	}
}

public extension FS {
	func removeFile(_ path: FileURL) -> Task<Void> {
		return self.remove(path.rawValue)
	}
}
