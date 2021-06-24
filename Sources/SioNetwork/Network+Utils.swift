//
//  Network+Utils.swift
//  SioNetwork
//
//  Created by José Manuel Sánchez Peñarroja on 08/12/2019.
//

import Foundation
import Sio

public extension Network {
	func getRequest(
		_ string: String,
		_ params: RequestParameters = .empty,
		_ headers: [String: String]? = nil
	) -> Request? {
		RemoteURL.init(string)
			.flatMap { url in
				Request.init(
					method: .get,
					url: url,
					cachePolicy: .useProtocolCachePolicy,
					timeout: 60,
					headers: headers,
					successCodes: 200..<299,
					queryParams: params,
					bodyParams: .empty
				)
		}
	}
	
	func get(
		_ string: String,
		_ params: RequestParameters = .empty,
		_ headers: [String: String]? = nil
	) -> SIO<Void, NetworkError, (Data, HTTPResponse)> {
		SIO<Void, NetworkError, Request>
			.from(self.getRequest(string, params, headers), NetworkError.unknown)
			.flatMap { req in
				self.request.provide(req)
		}
	}
}
