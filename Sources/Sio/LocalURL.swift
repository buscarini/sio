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

public protocol PathSource {}
public enum IsRelative: PathSource {}
public enum IsAbsolute: PathSource {}

public struct LocalURL<SourceType: PathSource, TargetType: PathTarget>: Equatable, Hashable {
	public var rawValue: URL
	
	init(rawValue: URL) {
		self.rawValue = rawValue
	}
}

public extension LocalURL where TargetType == IsFile {
	init?(url: URL) {
		guard url.isFileURL, url.hasDirectoryPath == false else {
			return nil
		}
		
		rawValue = url
	}
}

public extension LocalURL where TargetType == IsFolder {
	init?(url: URL) {
		guard url.isFileURL, url.hasDirectoryPath else {
			return nil
		}
		
		rawValue = url
	}
}


// MARK: Functor
public extension LocalURL {
	func map(_ f: @escaping (URL) -> URL) -> LocalURL {
		var copy = self
		copy.rawValue = f(copy.rawValue)
		return copy
	}
}

public extension LocalURL {
	func coerced<S2, T2>(source: S2.Type, target: T2.Type) -> LocalURL<S2, T2> {
		return unsafeBitCast(self, to: LocalURL<S2, T2>.self)
	}
}

// MARK: Utils
public func join<LSource: PathSource, RTarget: PathTarget>(_ left: LocalURL<LSource, IsFolder>, _ right: LocalURL<IsRelative, RTarget>) -> LocalURL<LSource, RTarget> {
	return left.map {
		$0.appendingPathComponent(right.rawValue.path)
	}
	.coerced(source: LSource.self, target: RTarget.self)
}

public func <> <LSource: PathSource, RTarget: PathTarget>(_ left: LocalURL<LSource, IsFolder>, _ right: LocalURL<IsRelative, RTarget>) -> LocalURL<LSource, RTarget> {
	return join(left, right)
}



//public func dirname<LSource: PathSource, RTarget: PathTarget>(_ left: LocalURL<LSource, IsFolder>, _ right: LocalURL<IsRelative, RTarget>) -> LocalURL<LSource, RTarget> {
//}
//

public typealias FileURL = LocalURL<IsAbsolute, IsFile>
