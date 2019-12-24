//
//  IsOptional.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 23/12/2019.
//

import Foundation

public protocol IsOptional {
	associatedtype Wrapped
	var some: Wrapped? { get set }
}

extension Optional: IsOptional {
	public var some: Wrapped? {
		set {
			self = newValue
		}
		get {
			self
		}
	}
}
