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
		self.runOnError { e in
			f(e).runForget()
		}
	}
	
	@inlinable
	func onError(do io: IO<Never, Void>) -> SIO<R, E, A> {
		self.onError { _ in io }
	}
	
	@inlinable
	func onSuccess(_ f: @escaping (A) -> SIO<Void, Never, Void>) -> SIO<R, E, A> {
		self.runOnSuccess { a in
			f(a).runForget()
		}
	}
	
	@inlinable
	func onSuccess(do io: SIO<Void, Never, Void>) -> SIO<R, E, A> {
		onSuccess { _ in
			io
		}
	}
	
	@inlinable
	func runOnError(_ f: @escaping (E) -> Void) -> SIO<R, E, A> {
		self.flatMapError { e in
			SIO<Void, Never, Void>.effect {
				f(e)
			}
			.adapt()
			.flatMap { _ in
				.rejected(e)
			}
		}
	}
	
	@inlinable
	func runOnSuccess(_ f: @escaping (A) -> Void) -> SIO<R, E, A> {
		self.flatMap { a in
			SIO<Void, Never, Void>.effect {
				f(a)
			}
			.adapt()
			.const(a)
		}
	}
}
