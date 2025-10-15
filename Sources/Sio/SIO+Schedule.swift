import Foundation
import Combine
import CombineSchedulers

public extension SIO {
	@inlinable
	func scheduleOn(_ queue: DispatchQueue) -> SIO<R, E, A> {
		scheduleOn(queue.eraseToAnyScheduler())
	}
	
	@inlinable
	func scheduleOn(_ scheduler: AnySchedulerOf<DispatchQueue>) -> SIO<R, E, A> {
		let copy = self
		copy.scheduler = scheduler.eraseToAnyScheduler()
		return copy
	}
	
	@inlinable
	func forkOn(_ queue: DispatchQueue) -> SIO<R, E, A> {
		forkOn(queue.eraseToAnyScheduler())
	}
	
	@inlinable
	func forkOn<S: Scheduler>(_ scheduler: S) -> SIO<R, E, A> {
		SIO({ (env, reject, resolve) in
			self.fork(
				env,
				{ error in
					scheduler.run {
						reject(error)
					}
				},
				{ result in
					scheduler.run {
						resolve(result)
					}
				}
			)
		})
	}
}
