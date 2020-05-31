//
//  TestScheduler.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 31/05/2020.
//

import Foundation

public final class TestScheduler: Scheduler {
	struct Item {
		var date: Date
		var work: Scheduler.Work
	}
	
	var date: Date
	var items: [Item] = []
	
	public init() {
		date = Date()
	}
	
	public func run(
		_ work: @escaping Scheduler.Work
	) -> Void {
		items.append(.init(date: Date(), work: work))
	}
	
	public func runAfter(
		after delay: Seconds<Double>,
		_ work: @escaping Scheduler.Work		
	) -> Void {
		items.append(.init(
			date: Date().addingTimeInterval(delay.rawValue),
			work: work)
		)
	}
	
	public func advance(
		_ time: TimeInterval = 0.01
	) {
		date.addTimeInterval(time)
		
		let (past, future) = items.partition { item in
			item.date < self.date ? .left(item) : .right(item)
		}
		
		past.forEach { $0.work() }
		
		items = future
	}
}
