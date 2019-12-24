//
//  Request.swift
//  SioEffects
//
//  Created by José Manuel Sánchez Peñarroja on 06/12/2019.
//

import Foundation

public struct Request: Equatable {
	public var method: HTTPMethod
	public var url: RemoteURL
	public var cachePolicy: URLRequest.CachePolicy
	public var timeout: TimeInterval
	public var headers: [String: String]?
	public var successCodes: Range<Int>
	public var queryParams: RequestParameters
	public var bodyParams: RequestParameters
	
	public init(
		method: HTTPMethod,
		url: RemoteURL,
		cachePolicy: URLRequest.CachePolicy,
		timeout: TimeInterval,
		headers: [String: String]?,
		successCodes: Range<Int>,
		queryParams: RequestParameters,
		bodyParams: RequestParameters
	) {
		self.method = method
		self.url = url
		self.cachePolicy = cachePolicy
		self.timeout = timeout
		self.headers = headers
		self.successCodes = successCodes
		self.queryParams = queryParams
		self.bodyParams = bodyParams
	}
}
