//
//  SIO+Ref.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 11/08/2019.
//

import Foundation

public func get<S, E, A>(_ sio: SIO<Ref<S>, E, A>) -> SIO<Ref<S>, E, (S, A)> {
	return sio.read().map { r, a in
		return (r.state, a)
	}
}

public func set<S, E, A>(_ sio: SIO<Ref<S>, E, A>) -> (S) -> SIO<Ref<S>, E, A> {
	return { value in
		modify(sio)(const(value))
	}
}

public func modify<S, E, A>(_ sio: SIO<Ref<S>, E, A>) -> (@escaping (S) -> S) -> SIO<Ref<S>, E, A> {
	return { f in
		environment(Ref<S>.self)
			.flatMap { r in
				r.state = f(r.state)
				return sio
		}
	}
}

public extension SIO where R: AnyRef {
	func get() -> SIO<R, E, (R.S, A)> {
		return self.read().map { r, a in
			return (r.state, a)
		}
	}
	
	func set(_ value: R.S) -> SIO<R, E, A> {
		return modify(Sio.const(value))
	}

	func modify(_ f: @escaping (R.S) -> R.S) -> SIO<R, E, A> {
		return Sio.environment(R.self)
			.flatMap { r in
				r.state = f(r.state)
				return self
		}
	}
}
