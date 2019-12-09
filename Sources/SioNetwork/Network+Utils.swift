//
//  Network+Utils.swift
//  SioNetwork
//
//  Created by José Manuel Sánchez Peñarroja on 08/12/2019.
//

import Foundation
import Sio

public extension Network {
	func get(
		_ string: String,
		_ params: RequestParameters = .empty,
		_ headers: [String: String]? = nil
	) -> SIO<Void, NetworkError, (Data, HTTPResponse)> {
			let url = RemoteURL.init(string)
			return SIO<Void, NetworkError, RemoteURL>
				.from(url, NetworkError.unknown)
				.flatMap { url in
					let request = Request.init(
						method: .get,
						url: url,
						cachePolicy: .useProtocolCachePolicy,
						timeout: 60,
						headers: headers,
						successCodes: 200..<299,
						queryParams: params,
						bodyParams: .empty
					)
					
					return self.request.provide(request)
				}
	}
}
