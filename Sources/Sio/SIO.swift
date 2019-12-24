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
	
	public typealias Sync = (R) -> Either<E, A>?
	public typealias Async = (R, @escaping ErrorCallback, @escaping ResultCallback) -> ()
    
	public var queue: DispatchQueue?
	public var delay: TimeInterval = 0
	public var onCancel: EmptyCallback?
	
	enum Implementation {
		case success(A)
		case fail(E)
		case sync(Sync)
		case async(Async)
		case biFlatMap(BiFlatMapBase<R, E, A>)
		
		var bfm: BiFlatMapBase<R, E, A>? {
			switch self {
			case let .biFlatMap(bfm):
				return bfm
			default:
				return nil
			}
		}
	}

	var implementation: Implementation
	
	public var running = false
	
//	var _fork: Computation
	let _cancel: EmptyCallback?
	
	private var _cancelled = false
	private let cancelSyncQueue = DispatchQueue(label: "task_cancel", attributes: .concurrent)
	public private(set) var cancelled: Bool {
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
	
	public init(_ sync: @escaping Sync) {
		self.implementation = .sync(sync)
		self._cancel = nil
	}
	
	public init(_ async: @escaping Async) {
		self.implementation = .async(async)
		self._cancel = nil
	}

	public init(_ async: @escaping Async, cancel: EmptyCallback?) {
		self.implementation = .async(async)

		self._cancel = cancel
	}
	
	init(_ implementation: Implementation, cancel: EmptyCallback?) {
		self.implementation = implementation

		self._cancel = cancel
	}
	
	public func fork(_ requirement: R, _ reject: @escaping ErrorCallback, _ resolve: @escaping ResultCallback) {
        let run = {
			guard self.cancelled == false else {
				return
			}
			
			self.running = true

			switch self.implementation {
            case let .success(a):
                resolve(a)
				self.running = false
            case let .fail(e):
                reject(e)
				self.running = false
			case let .sync(sync):
				defer { self.running = false }
				
				let res = sync(requirement)
				guard self.cancelled == false else {
					return
				}
				
				switch res {
				case let .left(e)?:
					reject(e)
				case let .right(a)?:
					resolve(a)
				case nil:
					return
				}
            case let .async(async):
                async(
                    requirement,
                    { error in
						self.running = false
                        guard !self.cancelled else { return }
                        reject(error)
                	},
                    { result in
						self.running = false
                        guard !self.cancelled else { return }
                        resolve(result)
                	}
                )
            case let .biFlatMap(impl):
				impl.fork(requirement, { e in
//					guard self.cancelled == false else {
//						return
//					}
					
					reject(e)
					self.running = false
				}, { a in
//					guard self.cancelled == false else {
//						return
//					}
					
					resolve(a)
					self.running = false
				})
            }
        }
		
		let queue = self.queue ?? .global()
        queue.asyncAfter(deadline: .now() + self.delay, execute: run)
	}
	
	public func cancel() {
		self.cancelled = true
		self._cancel?()
		self.onCancel?()
	}
}

protocol SIOImpl {
	associatedtype R
	associatedtype E
	associatedtype A
	
//	func forkSync(_ r: R) -> SIO<R, E, A>.Trampoline?
    func fork(_ r: R, _ reject: @escaping (E) -> Void, _ resolve: @escaping (A) -> Void)
	func cancel()
}

class BiFlatMapBase<R, E, A> {
    func fork(_ r: R, _ reject: @escaping (E) -> Void, _ resolve: @escaping (A) -> Void) {
        fatalError()
    }
    
//	func forkSync(_ r: R) -> SIO<R, E, A>.Trampoline? {
//		fatalError()
//	}
	
	func biFlatMap<F, B>(_ f: @escaping (E) -> SIO<R, F, B>, _ g: @escaping (A) -> SIO<R, F, B>) -> SIO<R, F, B> {
		fatalError()
	}
	
	func cancel() {
	}
}

class BiFlatMap<R, E0, E, A0, A>: BiFlatMapBase<R, E, A> {
	var sio: SIO<R, E0, A0>
	var err: (E0) -> SIO<R, E, A>
	var succ: (A0) -> SIO<R, E, A>
	
	public var cancelled = false
	private var nextErr: SIO<R, E, A>?
	private var nextSucc: SIO<R, E, A>?
	
	init(
		sio: SIO<R, E0, A0>,
		err: @escaping (E0) -> SIO<R, E, A>,
		succ: @escaping (A0) -> SIO<R, E, A>
	) {
		self.sio = sio
		self.err = err
		self.succ = succ
	}
	
//	override func biFlatMap<F, B>(_ f: @escaping (E) -> SIO<R, F, B>, _ g: @escaping (A) -> SIO<R, F, B>) -> SIO<R, F, B> {
//
//		let specific = BiFlatMap<R, E0, F, A0, B>(
//			sio: self.sio,
//			err: { e0 in
//				return self.err(e0).biFlatMap(f, g)
//			},
//			succ: { a0 in
//				return self.succ(a0).biFlatMap(f, g)
//
//			}
//		)
//
//		switch self.sio.implementation {
//		case let .success(a):
//			return self.succ(a).biFlatMap(f, g)
//		case let .fail(e):
//			return self.err(e).biFlatMap(f, g)
//		case let .sync(sync):
//			return SIO<R, F, B>.init(
//				.biFlatMap(specific),
//				cancel: specific.cancel
//			)
//		case let .async(async):
//			return SIO<R, F, B>.init(
//				.biFlatMap(specific),
//				cancel: specific.cancel
//			)
//		case let .biFlatMap(bfm):
//			return SIO<R, F, B>.init(
//				.biFlatMap(specific),
//				cancel: specific.cancel
//			)
//		}
//	}
	
	override func biFlatMap<F, B>(_ f: @escaping (E) -> SIO<R, F, B>, _ g: @escaping (A) -> SIO<R, F, B>) -> SIO<R, F, B> {
		let specific = BiFlatMap<R, E0, F, A0, B>(
			sio: self.sio,
			err: { e0 in
				return self.err(e0).biFlatMap(f, g)
			},
			succ: { a0 in
				return self.succ(a0).biFlatMap(f, g)
				
			}
		)
		
		return SIO<R, F, B>.init(
			.biFlatMap(specific),
			cancel: specific.cancel
		)
		
	}
	
	override func cancel() {
		self.cancelled = true
		self.sio.cancel()
		self.nextErr?.cancel()
		self.nextSucc?.cancel()
	}
	
	@inlinable
    override func fork(_ r: R, _ reject: @escaping (E) -> Void, _ resolve: @escaping (A) -> Void) {
		guard self.cancelled == false else {
			return
		}
		
        self.sio.fork(r, { e in
			guard self.cancelled == false else {
				return
			}
			
			let nextE = self.err(e)
			self.nextErr = nextE
			
			guard self.cancelled == false else {
				return
			}
			
            nextE.fork(r, reject, resolve)
			
        }) { a in
			guard self.cancelled == false else {
				return
			}
			
			let nextA = self.succ(a)
			self.nextSucc = nextA
			
			guard self.cancelled == false else {
				return
			}
			
            nextA.fork(r, reject, resolve)
        }
	}
}
