//
//  SIO+Effects.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public extension SIO {
	@inlinable
	func onError(_ f: @escaping (E) -> IO<Never, Void>) -> SIO<R, E, A> {
		self.flatMapError { e in
			f(e)
				.require(R.self)
				.mapError(absurd)
				.flatMap { _ in
					SIO<R, E, A>.rejected(e)
				}
		}
	}
	
	@inlinable
	func onError(do io: IO<Never, Void>) -> SIO<R, E, A> {
		self.onError { _ in io }
	}
	
	@inlinable
	func onSuccess(_ f: @escaping (A) -> SIO<Void, Never, Void>) -> SIO<R, E, A> {
		self.flatMap { a in
			f(a)
			.adapt()
			.require(R.self)
			.const(a)
		}
	}
	
	@inlinable
	func onSuccess(do io: SIO<Void, Never, Void>) -> SIO<R, E, A> {
		onSuccess { _ in
			io
		}
	}
}
