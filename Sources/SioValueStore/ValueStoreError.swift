//
//  ValueStoreError.swift
//  SioValueStore
//
//  Created by José Manuel Sánchez Peñarroja on 02/07/2019.
//

import Foundation

public enum ValueStoreError: Error {
	case noData
	case encoding(Error)
}
