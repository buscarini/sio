//
//  SIO+Ref.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 11/08/2019.
//

import Foundation

@inlinable
public func get<S, E, A>(_ sio: SIO<Ref<S>, E, A>) -> SIO<Ref<S>, E, (S, A)> {
	sio.read().map { r, a in
		(r.state, a)
	}
}

@inlinable
public func set<S, E, A>(_ sio: SIO<Ref<S>, E, A>) -> (S) -> SIO<Ref<S>, E, A> {
	{ value in
		modify(sio)(const(value))
	}
}

@inlinable
public func modify<S, E, A>(_ sio: SIO<Ref<S>, E, A>) -> (@escaping (S) -> S) -> SIO<Ref<S>, E, A> {
	{ f in
		environment(Ref<S>.self)
			.flatMap { r in
				r.state = f(r.state)
				return sio
		}
	}
}

public extension SIO where R: AnyRef {
	@inlinable
	func get() -> SIO<R, E, (R.S, A)> {
		self.read().map { r, a in
			(r.state, a)
		}
	}
	
	@inlinable
	func set(_ value: R.S) -> SIO<R, E, A> {
		modify(Sio.const(value))
	}

	@inlinable
	func modify(_ f: @escaping (R.S) -> R.S) -> SIO<R, E, A> {
		Sio.environment(R.self)
			.flatMap { r in
				r.state = f(r.state)
				return self
		}
	}
}
