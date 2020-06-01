//
//  Scheduler.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 31/05/2020.
//

import Foundation

public protocol Scheduler {
	typealias Work = () -> Void
	func run(_ work: @escaping Work) -> Void
	func runAfter(after: Seconds<Double>, _ work: @escaping Work) -> Void
}

public class AnyScheduler: Scheduler {
	@usableFromInline
	internal var impl: Scheduler
	
	@inlinable
	public init(_ impl: Scheduler) {
		self.impl = impl
	}
	
	@inlinable
	public func run(_ work: @escaping Work) -> Void {
		self.impl.run(work)
	}
	
	@inlinable
	public func runAfter(after delay: Seconds<Double>, _ work: @escaping Work) -> Void {
		self.impl.runAfter(after: delay, work)
	}
}
