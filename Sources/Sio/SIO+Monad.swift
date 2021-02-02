import Foundation

public final class BiFlatMap<Upstream, R, E, A>: SIO
where Upstream: SIO, Upstream.R == R {
	let upstream: Upstream
	let fmapL: (Upstream.E) -> Async<R, E, A>
	let fmapR: (Upstream.A) -> Async<R, E, A>
	
	var cancelled = false
	
	public init(
		upstream: Upstream,
		_ left: @escaping (Upstream.E) -> Async<R, E, A>,
		_ right: @escaping (Upstream.A) -> Async<R, E, A>
	) {
		self.fmapL = left
		self.fmapR = right
	}
	
	public func fork(_ requirement: R, _ reject: @escaping ErrorCallback, _ resolve: @escaping ResultCallback) {
		guard self.cancelled == false else {
			return
		}
		
		upstream.fork(
			requirement,
			{ e in
				let tmp: Async<R, E, A> = self.fmapL(e)
				
				tmp.fork(requirement, { e in
					reject(e)
				}, { a in
					resolve(a)
				})
			},
			{ a in
				let tmp = self.fmapR(a)
				tmp.fork(requirement, reject, resolve)
			}
		)
	}
	
	public func cancel() {
		self.upstream.cancel()
		self.cancelled = true
	}
}


extension SIO {
	@inlinable
	public func flatMap<Next, B>(_ f: @escaping (A) -> Next<R, E, B>)) -> BiFlatMap<Self, R, E, B> where Next: SIO {
		self.biFlatMap({ e in .rejected(e) }, f)
	}
	
	@inlinable
	public func flatMap<B>(_ io: SIO<A, E, B>) -> SIO<R, E, B> {
		self.flatMap { a in
			io
				.provide(a)
				.require(R.self)
		}
	}
	
	@inlinable
	public func `default`(_ a: A) -> SIO<R, E, A> {
		self.flatMapError { _ in
			SIO.of(a)
		}
	}
		
	@inlinable
	public func flatMapR<B>(_ f: @escaping (R, A) -> (SIO<R, E, B>)) -> SIO<R, E, B> {
		Sio.environment(R.self).mapError(absurd).flatMap { r in
			self.flatMap { a in
				f(r, a)
			}
		}
	}
	
	@inlinable
	public func replicate(_ count: Int) -> SIO<R, E, [A]> {
		Array(1...count)
			.forEach { _ in self }
	}
	
	@inlinable
	public func forever() -> SIO<R, E, A> {
		self.flatMap { _ in
			self.forever()
		}
	}
}

extension SIO {
	@inlinable
	public func flatMapNever<F, B>(_ f: @escaping (A) -> (SIO<R, F, B>)) -> SIO<R, F, B> where E == Never {
		self
			.biFlatMap(absurd, f)

	}

	@inlinable
	public func flatMapNever<F, B>(_ io: SIO<A, F, B>) -> SIO<R, F, B>  where E == Never {
		self
			.mapError(absurd)
			.flatMap { a in
				io
					.provide(a)
					.require(R.self)
			}
	}
}
