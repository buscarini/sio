//
//  SIO+Timeout.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 23/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public extension SIO {
	@inlinable
	func timeout(
		_ timeout: Seconds<TimeInterval>,
		_ scheduler: Scheduler = QueueScheduler(queue: .global())
	) -> SIO<R, E, A?> {
		race(
			self.either().mapError(absurd).map(Either<E, A>?.some),
			SIO<R, E, Either<E, A>?>.of(nil).delay(timeout, scheduler)
		)
		.flatMap { optionalEither -> SIO<R, E, A?> in
			guard let either = optionalEither else {
				return SIO<R, E, A?>.of(nil)
			}
			
			return SIO<R, E, A>.from(either)
				.require(R.self).map(A?.some)
		}
	}
	
	@inlinable
	func timeoutTo(
		_ value: A,
		_ timeout: Seconds<TimeInterval>,
		_ scheduler: Scheduler = QueueScheduler(queue: .global())
	) -> SIO<R, E, A> {
		race(
			self.either().mapError(absurd),
			SIO<R, E, Either<E, A>>.of(.right(value)).delay(timeout, scheduler)
		)
		.flatMap { either in
			return SIO<R, E, A>.from(either)
				.require(R.self)
		}
	}
}
