//
//  SIO+Ref.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 11/08/2019.
//

import Foundation

@inlinable
public func get<S, A>(_ sio: SIO<Ref<S>, any Error, A>) -> SIO<Ref<S>, any Error, (S, A)> {
	sio.read().flatMap { r, a in
		SIO.await {
			await r.value()
		}.map { value in
			(value, a)
		}.require(Ref<S>.self)
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
			.flatMap { (r: Ref<S>) -> SIO<Ref<S>, E, A> in
				SIO<Ref<S>, E, Void>.await {
					let updated = await f(r.value())
					await r.modify(updated)
				}.flatMap { _ in sio }
			}
	}
}

public extension SIO where R: AnyRef {
	@inlinable
	func get() -> SIO<R, E, (R.S, A)> {
		self.read().flatMap { r, a in
			SIO<R, E, R.S>.await {
				await r.value()
			}.map { state in
				(state, a)
			}
		}
	}
	
	@inlinable
	func set(_ value: R.S) -> SIO<R, E, A> {
		modify(Sio.const(value))
	}

	@inlinable
	func modify(_ f: @escaping (R.S) -> R.S) -> SIO<R, E, A> {
		Sio.environment(R.self)
			.flatMap { (r: R) -> SIO<R, E, A> in
				SIO<R, E, Void>.await {
					let updated = await f(r.value())
					await r.modify(updated)
				}.flatMap { _ in self }
			}
	}
}
