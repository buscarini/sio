//
//  ParametersEncoding.swift
//  SioEffects
//
//  Created by José Manuel Sánchez Peñarroja on 06/12/2019.
//

import Foundation

public enum ParametersEncoding {
	case url
	case json
	case other((URLRequest, [String: Any]) throws -> URLRequest)
}

extension ParametersEncoding: Equatable {
	public static func == (left: ParametersEncoding, right: ParametersEncoding) -> Bool {
		switch (left, right) {
		case (.url, .url):
			return true
		case (.json, .json):
			return true
		case (.other, .other):
			return true
		default:
			return false
		}
	}
}

extension ParametersEncoding: Hashable {
	
	public func hash(into hasher: inout Hasher) {
		switch self {
		case .url:
			hasher.combine("url")
		case .json:
			hasher.combine("json")
		case .other:
			hasher.combine("other")
		}
	}
}

