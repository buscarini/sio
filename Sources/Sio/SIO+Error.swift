//
//  SIO+Error.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public extension SIO {
	@inlinable
	func mapError<F>(_ f: @escaping (E) -> (F)) -> SIO<R, F, A> {
		self.bimap(f, id)
	}
	
	@inlinable
	func constError<F>(_ value: F) -> SIO<R, F, A> {
		self.mapError { _ in
			value
		}
	}
	
	@inlinable
	func flatMapError<F>(_ f: @escaping (E) -> (SIO<R, F, A>)) -> SIO<R, F, A> {
		self.biFlatMap(f, { SIO<R, F, A>.of($0) })
	}
	
	@inlinable
	func flatMapError<F>(_ io: SIO<R, F, A>) -> SIO<R, F, A> {
		self.flatMapError({ _ in io })
	}
	
	@inlinable
	func ignore() -> SIO<R, Void, A> {
		mapError { _ in
			()
		}
	}
	
	func ignoreErrors() -> SIO<R, Never, A> {
		.init { (r, reject, resolve) in
			self.fork(r, { _ in }, resolve)
		}
	}
	
	@inlinable
	func `catch`(_ value: A) -> SIO<R, Never, A> {
		self.flatMapError { _ in
			.of(value)
		}
	}
}

public extension SIO where E == Error {
	init(catching: @escaping (R) throws -> A) {
		self.init({ (env, reject, resolve) in
			do {
				resolve(try catching(env))
			}
			catch let error {
				reject(error)
			}
		})
	}
}

public extension SIO where A == Void {
	func recoverErrors() -> SIO<R, Never, Void> {
		self.catch(())
	}
}
