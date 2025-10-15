import Foundation
import Combine

import CombineSchedulers

public extension SIO {
	@inlinable
	func timeout<S: Scheduler>(
		_ timeout: Seconds<TimeInterval>,
		_ scheduler: S = DispatchQueue.global().eraseToAnyScheduler()
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
	func timeoutTo<S: Scheduler>(
		_ value: A,
		_ timeout: Seconds<TimeInterval>,
		_ scheduler: S = DispatchQueue.global().eraseToAnyScheduler()
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
