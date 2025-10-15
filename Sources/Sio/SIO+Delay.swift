import Foundation
import Combine

import CombineSchedulers

@inlinable
public func delayed<R, E, A, S: Scheduler>(
	_ delay: Seconds<TimeInterval>,
	_ scheduler: S = DispatchQueue.global().eraseToAnyScheduler()
) -> (SIO<R, E, A>) -> SIO<R, E, A> {
	{ io in
		let res = SIO({ env, reject, resolve in
			scheduler.run(after: delay) {
				io.fork(env, reject, resolve)
			}
		}, cancel: io.cancel)
		
		return res
	}
}

public extension SIO {
	@inlinable
	func delay(
		_ time: Seconds<TimeInterval>,
		_ queue: DispatchQueue
	) -> SIO<R, E, A> {
		delayed(time, queue.eraseToAnyScheduler())(self)
	}
	
	@inlinable
	func delay<S: Scheduler>(
		_ time: Seconds<TimeInterval>,
		_ scheduler: S = DispatchQueue.main.eraseToAnyScheduler()
	) -> SIO<R, E, A> {
		delayed(time, scheduler)(self)
	}
	
	@inlinable
	func sleep<S: Scheduler>(
		_ time: Seconds<TimeInterval>,
		_ scheduler: S = DispatchQueue.main.eraseToAnyScheduler()
	) -> SIO<R, E, A> {
		self.flatMap { value in
			SIO<R, E, A>.of(value).delay(time, scheduler)
		}
	}
}
