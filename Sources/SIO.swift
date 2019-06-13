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
	
	indirect enum Trampoline {
		case result(Either<E, A>?)
		case sync((R) -> Trampoline)
		case async((R, @escaping (Trampoline) -> Void) -> Void)
		
		var isSync: Bool {
			switch self {
			case .result, .sync:
				return true
			case .async:
				return false
			}
		}
		
		var isFinal: Bool {
			switch self {
			case .result:
				return true
			case .sync, .async:
				return false
			}
		}
		
		func run(_ r: R, _ completion: @escaping (Either<E, A>?) -> Void) {
			var t: Trampoline? = self
			
			while t != nil {
				switch t {
				case let .result(res)?:
					return completion(res)
				case let .sync(sync)?:
					t = sync(r)
				case let .async(async)?:
					async(r, { t in
						t.run(r, completion)
					})
					return
				case nil:
					return
				}
			}
		}
	}
	
	enum Implementation {
		case success(A)
		case fail(E)
		case sync(Sync)
		case async(Async)
		case biFlatMap(BiFlatMapBase<R, E, A>)
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
            switch self.implementation {
            case let .success(a):
                resolve(a)
            case let .fail(e):
                reject(e)
			case let .sync(sync):
				switch sync(requirement) {
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
                        guard !self.cancelled else { return }
                        reject(error)
                },
                    { result in
                        guard !self.cancelled else { return }
                        resolve(result)
                }
                )
            case let .biFlatMap(impl):
                impl.fork(requirement, reject, resolve)
            }
        }
        
        if let queue = self.queue {
            queue.asyncAfter(deadline: .now() + self.delay, execute: run)
        }
        else {
            run()
        }
	}
	
	public func cancel() {
		self.cancelled = true
		self._cancel?()
		
		switch self.implementation {
		case let .biFlatMap(bfm):
			bfm.cancel()
		default:
			break
		}
		
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
	
	private var cancelled = false
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
	
	override func cancel() {
		self.cancelled = true
		self.sio.cancel()
		self.nextErr?.cancel()
		self.nextSucc?.cancel()
	}
	
	@inlinable
    override func fork(_ r: R, _ reject: @escaping (E) -> Void, _ resolve: @escaping (A) -> Void) {
        self.sio.fork(r, { e in
			guard self.cancelled == false else {
				return
			}
			
			let nextE = self.err(e)
			self.nextErr = nextE
            nextE.fork(r, reject, resolve)
			
        }) { a in
			guard self.cancelled == false else {
				return
			}
			
			let nextA = self.succ(a)
			self.nextSucc = nextA
            nextA.fork(r, reject, resolve)
        }
        
//
//    			switch sio.implementation {
//			case let .success(a):
//                succ(a).fork(r, reject, resolve)
//			case let .fail(e):
//                err(e).fork(r, reject, resolve)
//
//			case let .eff(c):
//                c(r, { e in
//                    self.err(e).fork(r, reject, resolve)
//                }, { a in
//                    self.succ(a).fork(r, reject, resolve)
//                })
//
//			case let .biFlatMap(impl):
//                impl.fork(r, { e in
//                    self.err(e).fork(r, reject, resolve)
//                }) { a in
//                    self.succ(a).fork(r, reject, resolve)
//                }
//		}
	}
}
