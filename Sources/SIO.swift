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
			let queue = DispatchQueue(label: "Sync")
			var result: Either<E, A>?
			queue.sync {
				c(
					requirement,
					{ e in
						guard !self.cancelled else { return }
						result = .left(e)
					},
					{ a in
						guard !self.cancelled else { return }
						result = .right(a)
					}
				)
			}
			return .result(result)
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

protocol SIOImpl {
	associatedtype R
	associatedtype E
	associatedtype A
	
	func forkSync(_ r: R) -> SIO<R, E, A>.Trampoline?
}

//struct AnySIOImpl<R, E, A>: SIOImpl {
//	var impl: BiFlatMap<R, Any, E, Any, A>
//
//	init(_ impl: BiFlatMap<R, Any, E, Any, A>) {
//		self.impl = impl
//	}
//
//	@inlinable
//	func forkSync(_ r: R) -> SIO<R, E, A>.Trampoline? {
//		return self.impl.forkSync(r)
//	}
//}

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
				
				//
				//
				//						let bfmE = BiFlatMap<R, Any, F, Any, B>(
				//							sio: bfm.err(anye) as! SIO<R, Any, Any>,
				//							err: f,
				//							succ: g
				//						)
				//
				//						return SIO<R, F, B>.init(.biFlatMap(bfmE), cancel: self.cancel)
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
//				fatalError()
//				return sio.forkSync(r).
				
				
				let value = self.sio.forkSync(r)?.run(r)
				
				switch value {
				case let .left(e)?:
					return .next(err(e).forkSync)
				case let .right(a)?:
					return .next(succ(a).forkSync)
				case nil:
					return nil
				}
//				return c(r, err, succ)
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
//	}
		
//				let bfm = impl as! BiFlatMap<R, Any, E0, Any, A0>
//				let next = BiFlatMap<R, Any, E, Any, A>(sio: bfm.sio, err: { e in
//					return SIO<R, E, A>(
//						.biFlatMap(BiFlatMap<R, E0, E, A0, A>(sio: bfm.err(e), err: { self.err($0) }, succ: { self.succ($0) })),
//						cancel: {
//							self.sio.cancel()
//							bfm.sio.cancel()
//						}
//					)
//				}, succ: { a in
//					return SIO(
//						.biFlatMap(BiFlatMap<R, Any, E, Any, A>(sio: bfm.succ(a), err: { self.err($0 as! E0) }, succ: { self.succ($0 as! A0) })),
//						cancel: {
//							self.sio.cancel()
//							bfm.sio.cancel()
//						}
//					)
//				})
				
				
				
				
				

//				switch bfm.sio.implementation {
//				case let .success(a):
//					return bfm.succ(a).forkSync(r)
//				case let .fail(e):
//					return bfm.err(e).forkSync(r)
//				case let .eff(c):
//					fatalError()
//				case let .biFlatMap(impl):
//					let bfm2 = impl as! BiFlatMap
//					let value = bfm2.sio.forkSync(r)?.run(r)
//
//					return .next { r in
//						switch value {
//						case let .left(e)?:
//							bfm2.err(e)
//						case let .right(a)?:
//
//						case nil:
//							return nil
//						}
//
//					}
				
//				let value = bfm.sio.forkSync(r)?.run(r)
//
//	//			let value = impl.forkSync(r)?.run(r)
//				switch value {
//				case let .left(e)?:
//					return .next(err(e).forkSync)
//				case let .right(a)?:
//					return .next(succ(a).forkSync)
//				case nil:
//					return nil
//				}
			
		
		
//		let value = sio.forkSync(r)?.run(r)
//		switch value {
//		case let .left(e)?:
//			return .next(err(e).forkSync)
//		case let .right(a)?:
//			return .next(succ(a).forkSync)
//		case nil:
//			return nil
//		}
	}
}
