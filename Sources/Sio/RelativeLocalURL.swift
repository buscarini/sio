//
//  RelativeLocalURL.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 24/12/2019.
//

import Foundation

public struct RelativeLocalURL<TargetType: PathTarget>: RawRepresentable, Equatable, Hashable, Codable {
	public internal(set) var rawValue: String
	
	public init(rawValue: String) {
		self.rawValue = RelativeLocalURL.cleanUp(rawValue)
	}
	
	public static func cleanUp(_ path: String) -> String {
		path.trimmingCharacters(in: .init(charactersIn: "/ "))
	}
}

// MARK: Functor
extension RelativeLocalURL {
	internal func map(_ f: @escaping (String) -> String) -> RelativeLocalURL {
		var copy = self
		copy.rawValue = RelativeLocalURL.cleanUp(f(copy.rawValue))
		return copy
	}
}

public extension RelativeLocalURL {
	func coerced<T2>(target: T2.Type) -> RelativeLocalURL<T2> {
		return unsafeBitCast(self, to: RelativeLocalURL<T2>.self)
	}
}
