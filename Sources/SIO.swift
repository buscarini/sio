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
	
	indirect enum Trampoline {
		case result(Either<E, A>?)
		case next((R) -> Trampoline?)
		
		var isFinal: Bool {
			switch self {
			case .result:
				return true
			case .next:
				return false
			}
		}
		
		func run(_ r: R) -> Either<E, A>? {
			
			var t: Trampoline? = self
			
			while t != nil {
				switch t {
				case let .result(res)?:
					return res
				case let .next(f)?:
					t = f(r)
				case nil:
					return nil
				}
			}
			
			return nil
		}
	}
	
	enum Implementation {
		case success(A)
		case fail(E)
		case eff(Computation)
		case biFlatMap(BiFlatMapBase<R, E, A>)
//		case biFlatMap(SIO<R, Any, Any>, (R, Any) -> SIO<R, E, A>, (R, Any) -> SIO<R, E, A>)
	}

	var implementation: Implementation
	
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
//		self.implementation = .next({
//
//		})
		
		self.implementation = .eff(computation)
		
//		self._fork = computation
		self._cancel = nil
	}

	public init(_ computation: @escaping Computation, cancel: EmptyCallback?) {
		self.implementation = .eff(computation)

//		self._fork = computation
		self._cancel = cancel
	}
	
	init(_ implementation: Implementation, cancel: EmptyCallback?) {
		self.implementation = implementation

		self._cancel = cancel
	}
	
	func forkSync(_ requirement: R) -> Trampoline? {
		switch self.implementation {
		case let .success(a):
			return .result(.right(a))
		case let .fail(e):
			return .result(.left(e))
		case let .eff(c):
			
			let semaphore = DispatchSemaphore(value: 1)
			
			let value = NoSyncValue<E, A>()
			
//			print("wait")
			semaphore.wait()
			c(
				requirement,
				{ e in
					defer {
//						print("signal")
						semaphore.signal()
					}
					
					guard !self.cancelled else {
						value.result = .cancelled
						return
					}
					
					value.result = .loaded(.left(e))
				},
				{ a in
					defer {
//						print("signal")
						semaphore.signal()
					}
					
					guard !self.cancelled else {
						value.result = .cancelled
						return
					}
					
					value.result = .loaded(.right(a))
				}
			)

//			print("wait2")
			semaphore.wait()
			semaphore.signal()
			
//			while value.notLoaded {
//				usleep(useconds_t(2000))
//			}
			
			print(value.result)
			
			switch value.result {
			case .notLoaded, .cancelled:
				return nil
			case let .loaded(res):
				return .result(res)
			}
			
		case let .biFlatMap(impl):
			return .next(impl.forkSync)
		}
	}
	
	public func fork(_ requirement: R, _ reject: @escaping ErrorCallback, _ resolve: @escaping ResultCallback) {		
		switch self.implementation {
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
		case let .biFlatMap(impl):
			guard let result = impl.forkSync(requirement)?.run(requirement) else {
				return
			}
			
			switch result {
			case let .left(e):
				reject(e)
			case let .right(a):
				resolve(a)
			}
		}
	}
	
	public func cancel() {
		self.cancelled = true
		self._cancel?()
	}
}

protocol SIOImpl {
	associatedtype R
	associatedtype E
	associatedtype A
	
	func forkSync(_ r: R) -> SIO<R, E, A>.Trampoline?
}

class BiFlatMapBase<R, E, A> {
	func forkSync(_ r: R) -> SIO<R, E, A>.Trampoline? {
		fatalError()
	}
	
	func biFlatMap<F, B>(_ f: @escaping (E) -> SIO<R, F, B>, _ g: @escaping (A) -> SIO<R, F, B>) -> SIO<R, F, B> {
		fatalError()
	}
}

class BiFlatMap<R, E0, E, A0, A>: BiFlatMapBase<R, E, A> {
	var sio: SIO<R, E0, A0>
	var err: (E0) -> SIO<R, E, A>
	var succ: (A0) -> SIO<R, E, A>
	
	init(
		sio: SIO<R, E0, A0>,
		err: @escaping (E0) -> SIO<R, E, A>,
		succ: @escaping (A0) -> SIO<R, E, A>
	) {
		self.sio = sio
		self.err = err
		self.succ = succ
	}
	
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
			cancel: self.sio.cancel
		)
		
	}
	
	@inlinable
	override func forkSync(_ r: R) -> SIO<R, E, A>.Trampoline? {
			switch sio.implementation {
			case let .success(a):
				return self.succ(a).forkSync(r)
			case let .fail(e):
				return self.err(e).forkSync(r)
			case .eff:
				let value = self.sio.forkSync(r)?.run(r)
				
				switch value {
				case let .left(e)?:
					return .next(err(e).forkSync)
				case let .right(a)?:
					return .next(succ(a).forkSync)
				case nil:
					return nil
				}

			case let .biFlatMap(impl):
				
				let value = self.sio.forkSync(r)?.run(r)
				
				switch value {
				case let .left(e)?:
					return .next(err(e).forkSync)
				case let .right(a)?:
					return .next(succ(a).forkSync)
				case nil:
					return nil
				}
		}
	}
}
