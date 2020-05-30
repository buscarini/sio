//
//  FileURL.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 21/08/2019.
//

import Foundation

public protocol PathTarget {}
public enum IsFile: PathTarget {}
public enum IsFolder: PathTarget {}

public struct AbsoluteLocalURL<TargetType: PathTarget>: Equatable, Hashable, Codable {
	public internal(set) var rawValue: URL
}

public extension AbsoluteLocalURL where TargetType == IsFile {
	init?(url: URL) {
		guard
			url.isFileURL,
			url.hasDirectoryPath == false,
			url.absoluteURL == url
		else {
			return nil
		}
		
		rawValue = url.resolvingSymlinksInPath()
	}
}

public extension AbsoluteLocalURL where TargetType == IsFolder {
	init?(url: URL) {
		guard
			url.isFileURL,
			url.hasDirectoryPath,
			url.absoluteURL == url
		else {
			return nil
		}
		
		rawValue = url.resolvingSymlinksInPath()
	}
}

public extension AbsoluteLocalURL {
	func relativePath(_ baseUrl: AbsoluteLocalURL<IsFolder>) -> RelativeLocalURL<TargetType>? {
		guard self.rawValue.absoluteString.hasPrefix(baseUrl.rawValue.absoluteString) else {
			return nil
		}
		
		let trimmed = String(
			self.rawValue.absoluteString.dropFirst(baseUrl.rawValue.absoluteString.count)
		)
		
		return RelativeLocalURL<TargetType>.init(rawValue:
			trimmed
		)
	}
}

// MARK: Functor
extension AbsoluteLocalURL {
	internal func map(_ f: @escaping (URL) -> URL) -> AbsoluteLocalURL {
		var copy = self
		copy.rawValue = f(copy.rawValue)
		return copy
	}
}

public extension AbsoluteLocalURL {
	func coerced<T2>(target: T2.Type) -> AbsoluteLocalURL<T2> {
		return unsafeBitCast(self, to: AbsoluteLocalURL<T2>.self)
	}
}

//public func dirname<LSource: PathSource, RTarget: PathTarget>(_ left: AbsoluteLocalURL<LSource, IsFolder>, _ right: AbsoluteLocalURL<IsRelative, RTarget>) -> AbsoluteLocalURL<LSource, RTarget> {
//}
//

public typealias FileURL = AbsoluteLocalURL<IsFile>
public typealias FolderURL = AbsoluteLocalURL<IsFolder>
