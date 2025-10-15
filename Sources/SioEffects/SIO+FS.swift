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
	public var createDir: (URL, Bool) -> IO<Error, Void>
	public var lsDir: (URL) -> IO<Error, [URL]>
	
	public var copy: (URL, URL) -> IO<Error, Void>
	public var move: (URL, URL) -> IO<Error, Void>
	public var link: (URL, URL) -> IO<Error, Void>
	public var remove: (URL) -> IO<Error, Void>
	
	// Content
	public var readFile: (FileURL) -> IO<Error, Data>
	public var writeFile: (Data, FileURL) -> IO<Error, FileURL>
	
	// Attributes
	public var markSkipBackup: (URL) -> IO<Error, Void>

	public init(
		createDir: @escaping (URL, Bool) -> IO<Error, Void> = Default.createDir,
		lsDir: @escaping (URL) -> IO<Error, [URL]> = Default.lsDir,

		copy: @escaping (URL, URL) -> IO<Error, Void> = Default.copyItem,
		move: @escaping (URL, URL) -> IO<Error, Void> = Default.moveItem,
		link: @escaping (URL, URL) -> IO<Error, Void> = Default.linkItem,
		remove: @escaping (URL) -> IO<Error, Void> = Default.removeItem,
		
		readFile: @escaping (FileURL) -> IO<Error, Data> = Default.readFile,
		writeFile: @escaping (Data, FileURL) -> IO<Error, FileURL> = Default.writeFile,
		
		markSkipBackup: @escaping (URL) -> IO<Error, Void> = Default.markSkipBackup
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
	
	public func createFileDir(at url: FileURL, createIntermediate: Bool) -> IO<Error, FileURL> {
		.of(url)
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
		public static func createDir(at url: URL, createIntermediate: Bool) -> IO<Error, Void> {
			IO<Error, Void>.init(catching: { _ in
				try FileManager.default.createDirectory(at: url, withIntermediateDirectories: createIntermediate, attributes: nil)
			})
		}
		
		public static func lsDir(_ url: URL) -> IO<Error, [URL]> {
			IO<Error, [URL]>.init(catching: { _ in
				try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
			})
		}
		
		public static func copyItem(at url: URL, to target: URL) -> IO<Error, Void> {
			return IO<Error, Void>.init(catching: { _ in
				try FileManager.default.copyItem(at: url, to: target)
			})
		}
		
		public static func moveItem(at url: URL, to target: URL) -> IO<Error, Void> {
			return IO<Error, Void>.init(catching: { _ in
				try FileManager.default.moveItem(at: url, to: target)
			})
		}
		
		public static func linkItem(at url: URL, to target: URL) -> IO<Error, Void> {
			return IO<Error, Void>.init(catching: { _ in
				try FileManager.default.linkItem(at: url, to: target)
			})
		}
		
		public static func removeItem(at url: URL) -> IO<Error, Void> {
			return IO<Error, Void>.init(catching: { _ in
				try FileManager.default.removeItem(at: url)
			})
		}
		
		// MARK: IO
		public static func readFile(from path: FileURL) -> IO<Error, Data> {
			return IO<Error, Data>.init(catching: { _ in
				try Data(contentsOf: path.rawValue)
			})
		}
		
		
		public static func writeFile(data: Data, toPath url: FileURL) -> IO<Error, FileURL> {
			return IO<Error, Void>.init(catching: { _ in
				try data.write(to: url.rawValue)
			})
				.map(const(url))
		}
		
		
		// MARK: Attributes
		public static func markSkipBackup(at url: URL) -> IO<Error, Void> {
			return IO<Error, Void>.init(catching: { _ in
				var changeUrl = url
				var resourceValues = URLResourceValues()
				resourceValues.isExcludedFromBackup = true
				try changeUrl.setResourceValues(resourceValues)
			})
		}
	}
}

public extension FS {
	func removeFile(_ path: FileURL) -> IO<Error, Void> {
		return self.remove(path.rawValue)
	}
}
