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
	public var createDir = Default.createDir
	public var lsDir = Default.lsDir
	
	public var copy = Default.copyItem
	public var move = Default.moveItem
	public var link = Default.linkItem
	public var remove = Default.removeItem
	
	// Content
	public var writeFile = Default.writeFile
	public var readFile = Default.readFile
	
	// Attributes
	public var markSkipBackup = Default.markSkipBackup

	public init(
		createDir: @escaping (URL, Bool) -> Task<Void>,
		lsDir: @escaping (URL) -> Task<[URL]>,

		copy: @escaping (URL, URL) -> Task<Void>,
		move: @escaping (URL, URL) -> Task<Void>,
		link: @escaping (URL, URL) -> Task<Void>,
		remove: @escaping (URL) -> Task<Void>,
		
		readFile: @escaping (FileURL) -> Task<Data>,
		writeFile: @escaping (Data, FileURL) -> Task<FileURL>,
		
		markSkipBackup: @escaping (URL) -> Task<Void>
	) {
		self.createDir = createDir
		self.lsDir = lsDir
		
		self.remove = remove
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
		static func createDir(at url: URL, createIntermediate: Bool) -> Task<Void> {
			return Task<Void>.init(catching: { _ in
				try FileManager.default.createDirectory(at: url, withIntermediateDirectories: createIntermediate, attributes: nil)
			})
		}
		
		static func lsDir(_ url: URL) -> Task<[URL]> {
			return Task<[URL]>.init(catching: { _ in
				try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
			})
		}
		
		static func copyItem(at url: URL, to target: URL) -> Task<Void> {
			return Task<Void>.init(catching: { _ in
				try FileManager.default.copyItem(at: url, to: target)
			})
		}
		
		static func moveItem(at url: URL, to target: URL) -> Task<Void> {
			return Task<Void>.init(catching: { _ in
				try FileManager.default.moveItem(at: url, to: target)
			})
		}
		
		static func linkItem(at url: URL, to target: URL) -> Task<Void> {
			return Task<Void>.init(catching: { _ in
				try FileManager.default.linkItem(at: url, to: target)
			})
		}
		
		static func removeItem(at url: URL) -> Task<Void> {
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
		static func markSkipBackup(at url: URL) -> Task<Void> {
			return Task<Void>.init(catching: { _ in
				var changeUrl = url
				var resourceValues = URLResourceValues()
				resourceValues.isExcludedFromBackup = true
				try changeUrl.setResourceValues(resourceValues)
			})
		}
	}
}
