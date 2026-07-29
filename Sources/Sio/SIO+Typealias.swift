import Foundation

public typealias UIO<A> = SIO<Void, Never, A>
public typealias IO<E, A> = SIO<Void, E, A>
public typealias TaskR<R, A> = SIO<R, Error, A>
