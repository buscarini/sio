//
//  SIO+Utils.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

@inlinable
public func environment<R, E>(_ type: R.Type) -> SIO<R, E, R> {
	SIO<R, E, R>.environment()
}

@inlinable
public func access<R, E, V>(_ keyPath: KeyPath<R, V>) -> SIO<R, E, V> {
	SIO<R, E, V>.access { $0[keyPath: keyPath] }
}

@inlinable
public func accessM<R, E, A>(_ type: R.Type, _ f: @escaping (R) -> SIO<R, E, A>) -> SIO<R, E, A> {
	SIO<R, E, A>.accessM(f)
}

public extension SIO {
	@inlinable
	func provideSome<R0>(_ f: @escaping (R0) -> R) -> SIO<R0, E, A> {
		SIO<R0, E, A>({ r, reject, resolve in
			self.fork(f(r), reject, resolve)
		},cancel: self.cancel)
	}
	
	@inlinable
	func provide(_ req: R) -> SIO<Void, E, A> {
		self.provideSome { _ in
			req
		}
	}
	
	@inlinable
	func read() -> SIO<R, E, (R, A)> {
		zip(
			SIO<R, E, A>.environment(),
			self
		)
	}
	
	@inlinable
	func access() -> SIO<R, E, R> {
		self.flatMapR { r, _ in
			.of(r)
		}
	}
	
	@inlinable
	func toFunc() -> (R) -> SIO<Void, E, A> {
		{ r in
			self.provide(r)
		}
	}
	
	@inlinable
	static func fromFunc(_ f: @escaping (R) -> SIO<Void, E, A>) -> SIO<R, E, A> {
		environment()
			.flatMap { r in
				f(r).require(R.self)
			}
	}
}

public extension SIO {
	@inlinable
	static func environment<R, E>() -> SIO<R, E, R> {
		access(id)
	}
	
	@inlinable
	static func access<S, R, E>(_ f: @escaping (R) -> S) -> SIO<R, E, S> {
		SIO<R, E, S>({ r in
			.right(f(r))
		})
	}
	
	@inlinable
	static func accessM<R, E>(_ f: @escaping (R) -> SIO<R, E, A>) -> SIO<R, E, A> {
		environment().flatMap(f)
	}
}

public extension SIO where R == Void {
	@inlinable
	func require<S>(_ type: S.Type) -> SIO<S, E, A> {
		self.pullback { _ in () }
	}
}
