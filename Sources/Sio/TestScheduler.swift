//import Foundation
//
//public final class TestScheduler: Scheduler {
//	private let queue = DispatchQueue(label: "Test Scheduler")
//	
//	struct Item {
//		var date: Date
//		var work: Scheduler.Work
//	}
//	
//	var date: Date
//	var items: [Item] = []
//	
//	public init() {
//		date = Date(timeIntervalSince1970: 0)
//	}
//	
//	
//	public func sync(
//		_ work: @escaping Scheduler.Work
//	) {
//		self.queue.sync {
//			work()
//		}
//	}
//	public func run(
//		_ work: @escaping Scheduler.Work
//	) {
//		self.queue.async {
//			self.items.append(.init(date: self.date, work: work))
//		}
//	}
//	
//	public func runAfter(
//		after delay: Seconds<Double>,
//		_ work: @escaping Scheduler.Work		
//	) {
//		self.queue.async {
//			self.items.append(
//				.init(
//					date: self.date.addingTimeInterval(delay.rawValue),
//					work: work)
//			)
//		}
//	}
//	
//	public func advance(
//		_ time: TimeInterval = 0.01
//	) {
//		self.queue.sync {
//			self.date.addTimeInterval(time)
//		}
//		
//		var past: [Item] = []
//		var future: [Item] = []
//			
//		self.queue.sync {
//			(past, future) = self.items.partition { item in
//				self.date.timeIntervalSince1970
//					- item.date.timeIntervalSince1970
//					>= 0
//					? .left(item) : .right(item)
//			}
//		}
//		
////		print("Tasks to run \(past.count) \(future.count)")
//		
//		guard past.count > 0 else {
//			return
//		}
//
//		self.queue.sync {
//			self.items = future
//		}
//		
//		past.forEach { $0.work() }
//		
//		
//		// Reentrant
////		print("reenter")
//		self.advance()
//	}
//	
//	public func advance(
//		numSteps: Int,
//		queue: DispatchQueue
//	) {
//		guard numSteps > 0 else {
//			return
//		}
//		
//		self.advance()
//		queue.async {
//			self.advance(numSteps: numSteps - 1, queue: queue)
//		}
//	}
//}
