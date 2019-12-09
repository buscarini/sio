//
//  Request+Creation.swift
//  SioNetwork
//
//  Created by José Manuel Sánchez Peñarroja on 07/12/2019.
//

import Foundation

public extension Request {
	static func get(_ url: RemoteURL, _ params: [URLQueryItem] = []) -> Request {
		.init(
			method: .get,
			url: url,
			cachePolicy: .useProtocolCachePolicy,
			timeout: 30,
			headers: nil, successCodes: 200..<299,
			queryParams: RequestParameters.init(
				items: params,
				encoding: .url
			),
			bodyParams: .empty
		)
	}
}
