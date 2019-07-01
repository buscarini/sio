//
//  Either+Codable.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 25/06/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

extension Either: Decodable where A: Decodable, B: Decodable {
	public init(from decoder: Decoder) throws {
		do {
			self = .left(try decoder.singleValueContainer().decode(A.self))
		}
		catch {
			self = .right(try decoder.singleValueContainer().decode(B.self))
		}
	}
}

extension Either: Encodable where A: Encodable, B: Encodable {
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		switch self {
		case let .left(left):
			try container.encode(left)
		case let .right(right):
			try container.encode(right)
		}
	}
}
