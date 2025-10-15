import Foundation
import Combine

import CombineSchedulers

public extension SIO {
	@inlinable
	func runAt<S: Scheduler>(
		_ date: Date,
		_ scheduler: S = DispatchQueue.main.eraseToAnyScheduler()
	) -> SIO<R, E, A> {
		self |> delayed(
			Seconds(rawValue: date.timeIntervalSinceNow),
			scheduler
		)
	}
}
