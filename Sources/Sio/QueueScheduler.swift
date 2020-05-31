//
//  QueueScheduler.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 31/05/2020.
//

import Foundation

public final class QueueScheduler: Scheduler {
	var queue: DispatchQueue
	
	public init(queue: DispatchQueue) {
		self.queue = queue
	}
	
	public static var main: QueueScheduler {
		.init(queue: .main)
	}
	
	public func run(
		_ work: @escaping Scheduler.Work
	) -> Void {
		queue.async {
			work()
		}
	}
	
	public func runAfter(
		after delay: Seconds<Double>,
		_ work: @escaping Scheduler.Work
	) -> Void {
		queue.asyncAfter(deadline: .now() + delay.rawValue, execute: {
			work()
		})
	}
}
