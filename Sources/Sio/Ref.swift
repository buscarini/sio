//
//  Ref.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 11/08/2019.
//

import Foundation

public protocol AnyRef: AnyObject {
	associatedtype S
	func value() async -> S
	func modify(_ newState: S) async
}

public actor Ref<S>: @preconcurrency AnyRef {
	public var _state: S
	
	public init(_ state: S) {
		self._state = state
	}
	
	public func modify(_ newState: S) async {
		self._state = newState
	}
	
	public func value() async -> S {
		_state
	}
}

extension AnyRef {
	@discardableResult
	public func update(_ f: (inout S) -> Void) async -> S {
		var s = await self.value()
		f(&s)
		await self.modify(s)
		return s
	}
	
	public func update<A>(_ f: (inout S) -> A) async -> A {
		var s = await self.value()
		let a = f(&s)
		await self.modify(s)
		return a
	}
}
