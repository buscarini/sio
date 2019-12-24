//
//  NetworkError.swift
//  SioEffects
//
//  Created by José Manuel Sánchez Peñarroja on 06/12/2019.
//

import Foundation

public enum NetworkError: Error {
	case unknown
	case response(HTTPResponse, Error?, Data?)
}
