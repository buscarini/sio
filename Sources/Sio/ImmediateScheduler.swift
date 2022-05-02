import Foundation

public final class ImmediateScheduler: Scheduler {
	public init() {}
	
	@inlinable
	public func sync(
		_ work: Scheduler.Work
	) {
		work()
	}
	
	@inlinable
	public func run(
		_ work: Scheduler.Work
	) {
		work()
	}
	
	@inlinable
	public func runAfter(
		after delay: Seconds<Double>,
		_ work: Scheduler.Work
	) {
		work()
	}
}
