import Foundation

public extension SIO where R == Void, E == Never {
	@inlinable
	func adapt<S, F>() -> SIO<S, F, A> {
		self
			.require(S.self)
			.mapError(absurd)
	}
}

public extension SIO where R == Void {
	@inlinable
	func adaptR<S>() -> SIO<S, E, A> {
		self
			.require(S.self)
	}
}

public extension SIO where E == Never {
	@inlinable
	func adaptE<F>() -> SIO<R, F, A> {
		self
			.mapError(absurd)
	}
}
