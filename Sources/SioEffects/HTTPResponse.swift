//
//  HTTPResponse.swift
//  SioEffects
//
//  Created by José Manuel Sánchez Peñarroja on 06/12/2019.
//

import Foundation

public struct HTTPResponse: Equatable, Hashable {
	public var responseCode: Int
	public var data: Data?
	public var url: URL
	public var headerFields: [AnyHashable: AnyHashable]?
	
	public init(responseCode: Int, data: Data?, url: URL,headerFields: [AnyHashable: AnyHashable]?) {
		self.responseCode = responseCode
		self.data = data
		self.url = url
		self.headerFields = headerFields
	}
}
