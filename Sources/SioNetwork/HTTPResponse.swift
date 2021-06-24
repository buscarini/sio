//
//  HTTPResponse.swift
//  SioEffects
//
//  Created by José Manuel Sánchez Peñarroja on 06/12/2019.
//

import Foundation

public struct HTTPResponse {
	public var responseCode: StatusCode
	public var url: URL
	public var headerFields: [AnyHashable: Any]?
	
	public init(
		responseCode: StatusCode,
		url: URL,
		headerFields: [AnyHashable: Any]?
	) {
		self.responseCode = responseCode
		self.url = url
		self.headerFields = headerFields
	}
}
