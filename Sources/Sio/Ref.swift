//
//  Ref.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 11/08/2019.
//

import Foundation

public protocol AnyRef: AnyObject {
	associatedtype S
	var state: S { get set }
}

public class Ref<S>: AnyRef {
	public var state: S
	
	public init(_ state: S) {
		self.state = state
	}
}

