//
//  Scheduler.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 31/05/2020.
//

import Foundation

public protocol Scheduler {
	typealias Work = () -> Void
	func run (_ work: @escaping Work) -> Void
	func runAfter(after: Seconds<Double>, _ work: @escaping Work) -> Void
}
