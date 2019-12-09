//
//  RequestParameters.swift
//  SioEffects
//
//  Created by José Manuel Sánchez Peñarroja on 06/12/2019.
//

import Foundation

public struct RequestParameters: Equatable, Hashable {
	public var items: [URLQueryItem]
	public var encoding: ParametersEncoding
	
	public init(
		items: [URLQueryItem],
		encoding: ParametersEncoding
	) {
		self.items = items
		self.encoding = encoding
	}
}

public extension RequestParameters {
	static var empty: RequestParameters {
		.init(items: [], encoding: .url)
	}
}
