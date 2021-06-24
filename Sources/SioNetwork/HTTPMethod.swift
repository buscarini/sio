//
//  HTTPMethod.swift
//  SioEffects
//
//  Created by José Manuel Sánchez Peñarroja on 06/12/2019.
//

import Foundation

public enum HTTPMethod: String, Equatable, Hashable, CaseIterable, Codable {
	case get
	case post
	case put
	case delete
	case patch
}

