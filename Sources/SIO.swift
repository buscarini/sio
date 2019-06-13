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
    
    public var queue: DispatchQueue?
    public var delay: TimeInterval = 0
	
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
	
	/*func forkSync(_ requirement: R) -> Trampoline? {
		switch self.implementation {
		case let .success(a):
			print("fork sync success")
			return .result(.right(a))
		case let .fail(e):
			print("fork sync fail")
			return .result(.left(e))
		case let .eff(c):
			
			let queue = DispatchQueue(label: "Sync")
			
//			let semaphore = DispatchSemaphore(value: 1)
//
			let value = SyncValue<E, A>()
			
//			print("wait")
//			semaphore.wait()
			print("fork sync eff")
//			queue.sync {
				c(
					requirement,
					{ e in
//						defer {
//	//						print("signal")
//							semaphore.signal()
//						}
						
						guard !self.cancelled else {
							value.result = .cancelled
							return
						}
						
						value.result = .loaded(.left(e))
					},
					{ a in
//						defer {
//	//						print("signal")
////							semaphore.signal()
//						}
						
						guard !self.cancelled else {
							value.result = .cancelled
							return
						}
						
						value.result = .loaded(.right(a))
					}
				)
				
//			}

			
			
			
//			print("wait2")
//			semaphore.wait()
//			semaphore.signal()
		
			while value.notLoaded {
				usleep(useconds_t(10))
			}
		
//			print(value.result)
			
			switch value.result {
			case .notLoaded, .cancelled:
				print("eff not loaded or cancelled")
				return nil
			case let .loaded(res):
				print("eff loaded")
				return .result(res)
			}
			
		case let .biFlatMap(impl):
			print("fork sync biflatmap")
			return .next(impl.forkSync)
		}
	}*/
	
	public func fork(_ requirement: R, _ reject: @escaping ErrorCallback, _ resolve: @escaping ResultCallback) {
        
        let run = {
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
                impl.fork(requirement, reject, resolve)
                
                
                //                guard let result = impl.fork() else {
                //                    return
                //                }
                //
                //                switch result {
                //                case let .left(e):
                //                    reject(e)
                //                case let .right(a):
                //                    resolve(a)
                //                }
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
	}
	
	@inlinable
    override func fork(_ r: R, _ reject: @escaping (E) -> Void, _ resolve: @escaping (A) -> Void) {
        self.sio.fork(r, { e in
            self.err(e).fork(r, reject, resolve)
        }) { a in
            self.succ(a).fork(r, reject, resolve)
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
