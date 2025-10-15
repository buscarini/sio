import Foundation

public typealias UIO<A> = SIO<Void, Never, A>
public typealias IO<E, A> = SIO<Void, E, A>
public typealias TaskR<R, A> = SIO<R, Error, A>

@available(*, deprecated, message: "Use an explicit name instead. Deprecated due to naming collision with Swift concurrency.")
public typealias Task<A> = SIO<Void, Error, A>
