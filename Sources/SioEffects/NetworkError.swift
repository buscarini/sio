//
//  NetworkError.swift
//  SioEffects
//
//  Created by José Manuel Sánchez Peñarroja on 06/12/2019.
//

import Foundation

public struct NetworkError: Error, Equatable {
	public var code: StatusCode
	
	public init(
		code: StatusCode
	) {
		self.code = code
	}
}
