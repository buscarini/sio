//
//  SIO+Monad.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

extension SIO {
	@inlinable
	public func flatMap<B>(_ f: @escaping (A) -> (SIO<R, E, B>)) -> SIO<R, E, B> {
		self.biFlatMap({ e in .rejected(e)}, f)
	}
	
	@inlinable
	public func flatMap<B>(_ io: SIO<A, E, B>) -> SIO<R, E, B> {
		self.flatMap { a in
			io
				.provide(a)
				.require(R.self)
		}
	}
	
	@inlinable
	public func `default`(_ a: A) -> SIO<R, E, A> {
		self.flatMapError { _ in
			SIO.of(a)
		}
	}
		
	@inlinable
	public func flatMapR<B>(_ f: @escaping (R, A) -> (SIO<R, E, B>)) -> SIO<R, E, B> {
		
		return zip(
			Sio.environment(R.self).mapError(absurd),
			self
		).flatMap(f)
		
//		return self.biFlatMapR({ _, e in SIO<R, E, B>.rejected(e) }, f)
	}
	
	@inlinable
	public func replicate(_ count: Int) -> SIO<R, E, [A]> {
		Array(1...count)
			.forEach { _ in self }
	}
	
//	@inlinable
//	public func forever() -> SIO<R, E, A> {
//		self.flatMap { _ in
//			self.forever()
//		}
//	}
}
