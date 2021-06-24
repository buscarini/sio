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

//extension ParametersEncoding {
//	enum CaseKey: String, Equatable, Codable {
//		case url
//		case json
//		case other
//	}
//	
//	var key: CaseKey {
//		switch self {
//		case .url:
//			return .url
//		case .json:
//			return .json
//		case .other:
//			return .other
//		}
//	}
//	
//	enum CodingKeys: String, CodingKey {
//		case key
//	}
//}
//
//extension ParametersEncoding: Encodable {
//	public func encode(to encoder: Encoder) throws {
//		var container = encoder.container(keyedBy: CodingKeys.self)
//		
//		try container.encode(self.key, forKey: .key)
//	}
//}
//
//extension ParametersEncoding: Decodable {
//	public init(from decoder: Decoder) throws {
//		let container = try decoder.container(keyedBy: CodingKeys.self)
//		
//		let key = try container.decode(CaseKey.self, forKey: .key)
//		switch key {
//		case .url:
//			self = .url
//		case .json:
//			self = .json
//		case .other:
//			throw EncodingError.invalidValue(
//				CaseKey.other,
//				EncodingError.Context(
//					codingPath: container.codingPath,
//					debugDescription: "Value .other does not supporting decoding"
//				)
//			)
//		}
//	}
//}

