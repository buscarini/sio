//
//  sio.swift
//  sio
//
//  Created by José Manuel Sánchez on 19/5/19.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

/// Swift IO R: Requirements, E: Error, A: Success Value
public class SIO<R, E, A> {
	public typealias ErrorCallback = (E) -> ()
	public typealias ResultCallback = (A) -> ()
	public typealias EmptyCallback = () -> ()
	
	public typealias Computation = (R, @escaping ErrorCallback, @escaping ResultCallback) -> ()
	
	enum Trampoline {
		case success(A)
		case fail(E)
		case eff(Computation)
//		case biFlatMap(SIO<R, Any, Any>, (R, Any) -> SIO<R, E, A>, (R, Any) -> SIO<R, E, A>)
	}

	var trampoline: Trampoline?
	
//	var _fork: Computation
	let _cancel: EmptyCallback?
	
	private var _cancelled = false
	private let cancelSyncQueue = DispatchQueue(label: "task_cancel", attributes: .concurrent)
	public var cancelled: Bool {
		get {
			var result = false
			cancelSyncQueue.sync {
				result = self._cancelled
			}
			return result
		}
		
		set {
			cancelSyncQueue.async(flags: .barrier) {
				self._cancelled = newValue
			}
		}
	}
	
	public init(_ computation: @escaping Computation) {
//		self.trampoline = .next({
//
//		})
		
		self.trampoline = .eff(computation)
		
//		self._fork = computation
		self._cancel = nil
	}

	public init(_ computation: @escaping Computation, cancel: EmptyCallback?) {
		self.trampoline = .eff(computation)

//		self._fork = computation
		self._cancel = cancel
	}
	
	init(_ trampoline: Trampoline, cancel: EmptyCallback?) {
		self.trampoline = trampoline

		self._cancel = cancel
	}
	
	public func fork(_ requirement: R, _ reject: @escaping ErrorCallback, _ resolve: @escaping ResultCallback) {
		guard let t = self.trampoline else {
			return
		}
		
		switch t {
		case let .success(a):
			resolve(a)
		case let .fail(e):
			reject(e)
		case let .eff(c):
			c(
				requirement,
				{ error in
					guard !self.cancelled else { return }
					reject(error)
				},
				{ result in
					guard !self.cancelled else { return }
					resolve(result)
				}
			)
//		case let .biFlatMap(io, err, succ):
//			io.fork(requirement, { e in
//				err(requirement, e).fork(requirement, reject, resolve)
//			}, { value in
//				succ(requirement, value).fork(requirement, reject, resolve)
//			})
		}
		
//		self._fork(
//			requirement,
//			{ error in
//				guard !self.cancelled else { return }
//				reject(error)
//			},
//			{ result in
//				guard !self.cancelled else { return }
//				resolve(result)
//			}
//		)
	}
	
	public func cancel() {
		self.cancelled = true
		self._cancel?()
	}
}
