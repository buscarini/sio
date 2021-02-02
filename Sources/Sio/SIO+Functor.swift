import Foundation

public final class BiMap<Upstream, R, E, A>: SIO where Upstream: SIO, Upstream.R == R {
	let upstream: Upstream
	let mapL: (Upstream.E) -> E
	let mapR: (Upstream.A) -> A
	
	var cancelled = false
	
	public init(
		upstream: Upstream,
		_ left: @escaping (Upstream.E) -> E,
		_ right: @escaping (Upstream.A) -> A
	) {
		self.upstream = upstream
		self.mapL = left
		self.mapR = right
	}
	
	public func fork(_ requirement: R, _ reject: @escaping ErrorCallback, _ resolve: @escaping ResultCallback) {
		guard self.cancelled == false else {
			return
		}
		
		self.upstream.fork(requirement, { e in
			reject(self.mapL(e))
		}) { a in
			resolve(self.mapR(a))
		}
	}
	
	public func cancel() {
		self.upstream.cancel()
		self.cancelled = false
	}
}

extension SIO {
	@inlinable
	public func bimap<F, B>(
		_ f: @escaping (E) -> F,
		_ g: @escaping (A) -> B
	) -> BiMap<Self, R, F, B> {
		BiMap(upstream: self, f, g)
	}
	
	@inlinable
	public func map<B>(_ f: @escaping (A) -> (B)) -> BiMap<Self, R, E, B> {
		self.bimap(id, f)
	}

	@inlinable
	public func map2<Element, B>(_ f: @escaping (Element) -> (B)) -> BiMap<Self, R, E, [B]> where A == [Element] {
		self.bimap(id, { $0.map(f) })
	}


	@inlinable
	public func map2<Element, B>(_ f: @escaping (Element) -> (B)) -> BiMap<Self, R, E, B?> where A == Element? {
		self.bimap(id, { $0.map(f) })
	}

	@inlinable
	public func map2<Left, Right, B>(_ f: @escaping (Right) -> (B)) -> BiMap<Self, R, E, Either<Left, B>> where A == Either<Left, Right> {
		self.bimap(id, { $0.map(f) })
	}

	@inlinable
	public var void: BiMap<Self, R, E, Void> {
		self.map { _ in () }
	}

	@inlinable
	public func const<B>(_ value: B) -> BiMap<Self, R, E, B> {
		self.map { _ in
			value
		}
	}
}
