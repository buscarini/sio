import Foundation
import Combine

public extension SIO {
	@inlinable
	func retry(_ times: Int) -> SIO<R, E, A> {
		retry(times: times, modify: id)
	}
	
	@inlinable
	func retry(
		times: Int,
		modify: @escaping (SIO<R, E, A>) -> SIO<R, E, A>
	) -> SIO<R, E, A> {
		guard times > 0 else {
			return self
		}
		
		return self <|> modify(self.retry(times: times - 1, modify: modify))
	}
	
	@inlinable
	func retry<S: Scheduler>(
		times: Int,
		delay: Seconds<TimeInterval>,
		scheduler: S
	) -> SIO<R, E, A> {
		self.retry(times: times, modify: { io in
			io.delay(delay, scheduler)
		})
	}
}
