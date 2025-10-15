import Combine

import CombineSchedulers

extension Scheduler where SchedulerTimeType.Stride: SchedulerTimeIntervalConvertible {
	public func run(_ work: @escaping () -> Void) -> Void {
		self.schedule {
			work()
		}
	}
	
	public func run(after delay: Seconds<Double>, _ work: @escaping () -> Void) -> Void {
		self.schedule(after: self.now.advanced(by: .seconds(delay.rawValue)), work)
	}
}
