//
//  SIO+Utils.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public func environment<R>(_ type: R.Type) -> SIO<R, Never, R> {
	return SIO<R, Never, R>.environment()
}

public func access<R, V>(_ keyPath: KeyPath<R, V>) -> SIO<R, Never, V> {
	return SIO<R, Never, V>.access { $0[keyPath: keyPath] }
}

public func accessM<R, E, A>(_ type: R.Type, _ f: @escaping (R) -> SIO<Void, E, A>) -> SIO<R, E, A> {
	return SIO<R, E, A>.accessM(f)
}

public extension SIO {
	func provideSome<R0>(_ f: @escaping (R0) -> R) -> SIO<R0, E, A> {
		return SIO<R0, E, A>({ r, reject, resolve in
			self.fork(f(r), reject, resolve)
		},cancel: self.cancel)
	}
	
	func provide(_ req: R) -> SIO<Void, E, A> {
		return self.provideSome { _ in
			return req
		}
	}
	
	static func environment<R, E>() -> SIO<R, E, R> {
		return access(id)
	}
	
	static func access<S, R, E>(_ f: @escaping (R) -> S) -> SIO<R, E, S> {
		return SIO<R, E, S>({ r in
			return .right(f(r))
		})
	}
	
	static func accessM<R, E>(_ f: @escaping (R) -> SIO<Void, E, A>) -> SIO<R, E, A> {
		return environment().flatMap { r in
			f(r).require(R.self)
		}
	}
}

public extension SIO where R == Void {
	func require<S>(_ type: S.Type) -> SIO<S, E, A> {
		return self.pullback(discard)
	}
}