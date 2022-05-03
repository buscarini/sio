//
//  sio.swift
//  sio
//
//  Created by José Manuel Sánchez on 19/5/19.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

/// Swift IO R: Requirements, E: Error, A: Success Value
public final class SIO<R, E, A> {
	public typealias ErrorCallback = (E) -> ()
	public typealias ResultCallback = (A) -> ()
	public typealias EmptyCallback = () -> ()
	
	public typealias Sync = (R) -> Either<E, A>?
	public typealias Async = (R, @escaping ErrorCallback, @escaping ResultCallback) -> ()
	
	public var scheduler: AnyScheduler?
	public var delay: Seconds<TimeInterval> = 0
	public var onCancel: EmptyCallback?
	
	@usableFromInline
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
	
	@usableFromInline
	var implementation: Implementation
	
	@usableFromInline
	var _running = false

	private let runningSyncQueue = DispatchQueue(label: "sio_running", attributes: .concurrent)
	public var running: Bool {
		get {
			var result = false
			runningSyncQueue.sync {
				result = _running
			}
			return result
		}
		set {
			runningSyncQueue.async(flags: .barrier) {
				self._running = newValue
			}
		}
	}
	
	//	var _fork: Computation
	@usableFromInline
	let _cancel: EmptyCallback?
	
	private var _cancelled = false
	private let cancelSyncQueue = DispatchQueue(label: "sio_cancel", attributes: .concurrent)
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
	
	@inlinable
	public init(sync: @escaping Sync) {
		self.implementation = .sync(sync)
		self._cancel = nil
	}
	
	@inlinable
	public static func sync(_ sync: @escaping Sync) -> SIO<R, E, A> {
		.init(sync: sync)
	}
	
	@inlinable
	public static func syncMain(_ sync: @escaping Sync) -> SIO<R, E, A> {
		SIO.init(sync: sync)
			.scheduleOn(.main)
	}
	
	@inlinable
	public init(_ async: @escaping Async) {
		self.implementation = .async(async)
		self._cancel = nil
	}
	
	@inlinable
	public init(_ async: @escaping Async, cancel: EmptyCallback?) {
		self.implementation = .async(async)
		
		self._cancel = cancel
	}
	
	@usableFromInline
	init(_ implementation: Implementation, cancel: EmptyCallback?) {
		self.implementation = implementation
		
		self._cancel = cancel
	}
	
	@inlinable
	public func fork(
		_ requirement: R,
		_ reject: @escaping ErrorCallback,
		_ resolve: @escaping ResultCallback
	) {
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
					guard self.cancelled == false else {
						return
					}
					
					reject(e)
					self.running = false
				}, { a in
					guard self.cancelled == false else {
						return
					}
					
					resolve(a)
					self.running = false
				})
			}
		}
		
		guard let scheduler = self.scheduler else {
			run()
			return
		}
		
		scheduler.runAfter(after: self.delay, run)
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

@usableFromInline
class BiFlatMapBase<R, E, A> {
	@usableFromInline
	func fork(_ r: R, _ reject: @escaping (E) -> Void, _ resolve: @escaping (A) -> Void) {
		fatalError()
	}
	
	//	func forkSync(_ r: R) -> SIO<R, E, A>.Trampoline? {
	//		fatalError()
	//	}
	
	@usableFromInline
	func bimap<F, B>(
		_ f: @escaping (E) -> F,
		_ g: @escaping (A) -> B
	) -> SIO<R, F, B> {
		fatalError()
	}
	
	@usableFromInline
	func biFlatMap<F, B>(
		_ f: @escaping (E) -> SIO<R, F, B>,
		_ g: @escaping (A) -> SIO<R, F, B>
	) -> SIO<R, F, B> {
		fatalError()
	}
	
	@usableFromInline
	func cancel() {}
}

@usableFromInline
final class BiFlatMap<R, E0, E, A0, A>: BiFlatMapBase<R, E, A> {
	@usableFromInline var sio: SIO<R, E0, A0>
	@usableFromInline var err: (E0) -> SIO<R, E, A>
	@usableFromInline var succ: (A0) -> SIO<R, E, A>
	
	public var cancelled = false
	@usableFromInline var nextErr: SIO<R, E, A>?
	@usableFromInline var nextSucc: SIO<R, E, A>?
	
	@usableFromInline
	init(
		sio: SIO<R, E0, A0>,
		err: @escaping (E0) -> SIO<R, E, A>,
		succ: @escaping (A0) -> SIO<R, E, A>
	) {
		self.sio = sio
		self.err = err
		self.succ = succ
	}
	
	@inlinable
	override func bimap<F, B>(
		_ f: @escaping (E) -> F,
		_ g: @escaping (A) -> B
	) -> SIO<R, F, B> {
		let specific = BiFlatMap<R, E0, F, A0, B>(
			sio: self.sio,
			err: { e0 in
				self.err(e0).bimap(f, g)
		},
			succ: { a0 in
				self.succ(a0).bimap(f, g)
		}
		)
		
		return SIO<R, F, B>.init(
			.biFlatMap(specific),
			cancel: specific.cancel
		)
	}
	
	@inlinable
	override func biFlatMap<F, B>(
		_ f: @escaping (E) -> SIO<R, F, B>,
		_ g: @escaping (A) -> SIO<R, F, B>
	) -> SIO<R, F, B> {
		let specific = BiFlatMap<R, E0, F, A0, B>(
			sio: self.sio,
			err: { e0 in
				self.err(e0).biFlatMap(f, g)
		},
			succ: { a0 in
				self.succ(a0).biFlatMap(f, g)
		}
		)
		
		return SIO<R, F, B>.init(
			.biFlatMap(specific),
			cancel: specific.cancel
		)
	}
	
	@inlinable
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
