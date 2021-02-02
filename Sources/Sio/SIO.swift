import Foundation

public protocol SIO {
	typealias ErrorCallback = (E) -> ()
	typealias ResultCallback = (A) -> ()

	associatedtype R
	associatedtype E
	associatedtype A
	
	func fork(
		_ requirement: R,
		_ reject: @escaping ErrorCallback,
		_ resolve: @escaping ResultCallback
	)
	
	func cancel()
}

public final class Just<R, E, A>: SIO {
	public typealias EmptyCallback = () -> ()
		
	public var value: A
	private var cancelled = false

	public init(_ value: A) {
		self.value = value
	}

	public func fork(_ requirement: R, _ reject: @escaping ErrorCallback, _ resolve: @escaping ResultCallback) {
		guard self.cancelled == false else {
			return
		}
		
		resolve(self.value)
	}
	
	public func cancel() {
		self.cancelled = true
	}
}

public final class Rejected<R, E, A>: SIO {
	public typealias EmptyCallback = () -> ()
		
	public var error: E
	private var cancelled = false

	public init(_ error: E) {
		self.error = error
	}

	public func fork(_ requirement: R, _ reject: @escaping ErrorCallback, _ resolve: @escaping ResultCallback) {
		guard self.cancelled == false else {
			return
		}
		
		reject(self.error)
	}
	
	public func cancel() {
		self.cancelled = true
	}
}

public final class Sync<R, E, A>: SIO {
	public typealias SyncCallback = (R) -> Either<E, A>?
	private var cancelled = false
	
	public var run: SyncCallback
	
	public init(_ run: @escaping SyncCallback) {
		self.run = run
	}

	public func fork(_ requirement: R, _ reject: @escaping ErrorCallback, _ resolve: @escaping ResultCallback) {
		guard self.cancelled == false else {
			return
		}
		
		guard let result = self.run(requirement) else {
			return
		}
		
		switch result {
		case let .left(e):
			reject(e)
		case let .right(a):
			resolve(a)
		}
	}
	
	public func cancel() {
		self.cancelled = true
	}
}

/// Swift IO R: Requirements, E: Error, A: Success Value
public final class Async<R, E, A>: SIO {
	public typealias EmptyCallback = () -> ()
	
	public typealias AsyncCallback = (R, @escaping ErrorCallback, @escaping ResultCallback) -> ()
	
	public var scheduler: AnyScheduler?
	public var delay: Seconds<TimeInterval> = 0
	public var onCancel: EmptyCallback?
	
	public var async: AsyncCallback
	
	public var running = false
	
	//	var _fork: Computation
	@usableFromInline
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
	
	public init(
		_ async: @escaping AsyncCallback,
		cancel: EmptyCallback?
	) {
		self.async = async
	}
	
	@inlinable
	public func fork(
		_ requirement: R,
		_ reject: @escaping Async.ErrorCallback,
		_ resolve: @escaping Async.ResultCallback
	) {
		let run = {
			guard self.cancelled == false else {
				return
			}
			
			self.running = true
			
			self.async(
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

//protocol SIOImpl {
//	associatedtype R
//	associatedtype E
//	associatedtype A
//
//	//	func forkSync(_ r: R) -> SIO<R, E, A>.Trampoline?
//	func fork(_ r: R, _ reject: @escaping (E) -> Void, _ resolve: @escaping (A) -> Void)
//	func cancel()
//}
//
//@usableFromInline
//class BiFlatMapBase<R, E, A> {
//	@usableFromInline
//	func fork(_ r: R, _ reject: @escaping (E) -> Void, _ resolve: @escaping (A) -> Void) {
//		fatalError()
//	}
//
//	//	func forkSync(_ r: R) -> SIO<R, E, A>.Trampoline? {
//	//		fatalError()
//	//	}
//
//	@usableFromInline
//	func bimap<F, B>(
//		_ f: @escaping (E) -> F,
//		_ g: @escaping (A) -> B
//	) -> SIO<R, F, B> {
//		fatalError()
//	}
//
//	@usableFromInline
//	func biFlatMap<F, B>(
//		_ f: @escaping (E) -> SIO<R, F, B>,
//		_ g: @escaping (A) -> SIO<R, F, B>
//	) -> SIO<R, F, B> {
//		fatalError()
//	}
//
//	@usableFromInline
//	func cancel() {
//	}
//}
//
//final class BiFlatMap<R, E0, E, A0, A>: BiFlatMapBase<R, E, A> {
//	var sio: SIO<R, E0, A0>
//	var err: (E0) -> SIO<R, E, A>
//	var succ: (A0) -> SIO<R, E, A>
//
//	public var cancelled = false
//	private var nextErr: SIO<R, E, A>?
//	private var nextSucc: SIO<R, E, A>?
//
//	init(
//		sio: SIO<R, E0, A0>,
//		err: @escaping (E0) -> SIO<R, E, A>,
//		succ: @escaping (A0) -> SIO<R, E, A>
//	) {
//		self.sio = sio
//		self.err = err
//		self.succ = succ
//	}
//
//	@inlinable
//	override func bimap<F, B>(
//		_ f: @escaping (E) -> F,
//		_ g: @escaping (A) -> B
//	) -> SIO<R, F, B> {
//		let specific = BiFlatMap<R, E0, F, A0, B>(
//			sio: self.sio,
//			err: { e0 in
//				self.err(e0).bimap(f, g)
//		},
//			succ: { a0 in
//				self.succ(a0).bimap(f, g)
//		}
//		)
//
//		return SIO<R, F, B>.init(
//			.biFlatMap(specific),
//			cancel: specific.cancel
//		)
//	}
//
//	@inlinable
//	override func biFlatMap<F, B>(
//		_ f: @escaping (E) -> SIO<R, F, B>,
//		_ g: @escaping (A) -> SIO<R, F, B>
//	) -> SIO<R, F, B> {
//		let specific = BiFlatMap<R, E0, F, A0, B>(
//			sio: self.sio,
//			err: { e0 in
//				self.err(e0).biFlatMap(f, g)
//		},
//			succ: { a0 in
//				self.succ(a0).biFlatMap(f, g)
//		}
//		)
//
//		return SIO<R, F, B>.init(
//			.biFlatMap(specific),
//			cancel: specific.cancel
//		)
//	}
//
//	@inlinable
//	override func cancel() {
//		self.cancelled = true
//		self.sio.cancel()
//		self.nextErr?.cancel()
//		self.nextSucc?.cancel()
//	}
//
//	@inlinable
//	override func fork(_ r: R, _ reject: @escaping (E) -> Void, _ resolve: @escaping (A) -> Void) {
//		guard self.cancelled == false else {
//			return
//		}
//
//		self.sio.fork(r, { e in
//			guard self.cancelled == false else {
//				return
//			}
//
//			let nextE = self.err(e)
//			self.nextErr = nextE
//
//			guard self.cancelled == false else {
//				return
//			}
//
//			nextE.fork(r, reject, resolve)
//
//		}) { a in
//			guard self.cancelled == false else {
//				return
//			}
//
//			let nextA = self.succ(a)
//			self.nextSucc = nextA
//
//			guard self.cancelled == false else {
//				return
//			}
//
//			nextA.fork(r, reject, resolve)
//		}
//	}
//}
