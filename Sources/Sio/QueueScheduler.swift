//import Foundation
//
//public final class QueueScheduler: Scheduler {
//	@usableFromInline
//	var queue: DispatchQueue
//	
//	public init(queue: DispatchQueue) {
//		self.queue = queue
//	}
//	
//	public static var main: QueueScheduler {
//		.init(queue: .main)
//	}
//	
//	@inlinable
//	public func sync(
//		_ work: Scheduler.Work
//	) -> Void {
//		queue.sync {
//			work()
//		}
//	}
//	
//	@inlinable
//	public func run(
//		_ work: @escaping Scheduler.Work
//	) -> Void {
//		queue.async {
//			work()
//		}
//	}
//	
//	@inlinable
//	public func runAfter(
//		after delay: Seconds<Double>,
//		_ work: @escaping Scheduler.Work
//	) -> Void {
//		queue.asyncAfter(deadline: .now() + delay.rawValue, execute: {
//			work()
//		})
//	}
//}
