import Foundation
import Combine

@inlinable
public func <&><R, E, A, B>(_ left: SIO<R, E, A>, _ right: SIO<R, E, B>) -> SIO<R, E, (A, B)> {
	zip(left, right, DispatchQueue.main)
}


@inlinable
public func zip<R, E, A, B, S: Scheduler>(
	_ left: SIO<R, E, A>,
	_ right: SIO<R, E, B>,
	_ scheduler: S
) -> SIO<R, E, (A, B)> {
	liftA2(SIO.of({ a in
		{ b in
			(a, b)
		}
	}), left, right, scheduler)
}

@inlinable
public func zip<R, E, A, B, C, S: Scheduler>(
	with f: @escaping (A, B) -> C
)
-> (SIO<R, E, A>, SIO<R, E, B>, S)
-> SIO<R, E, C> {
	{ left, right, scheduler in
		zip(left, right, scheduler).map(f)
	}
}

@inlinable
public func zip2<R, E, A, B, S: Scheduler>(
	_ left: SIO<R, E, A>,
	_ right: SIO<R, E, B>,
	_ scheduler: S
) -> SIO<R, E, (A, B)> {
	zip(left, right, scheduler)
}

@inlinable
public func zip2<R, E, A, B, C, S: Scheduler>(
	with f: @escaping (A, B) -> C
)
-> (SIO<R, E, A>, SIO<R, E, B>, S)
-> SIO<R, E, C> {
	zip(with: f)
}

@inlinable
public func zip3<R, E, A, B, C, S: Scheduler>(
	_ xs: SIO<R, E, A>,
	_ ys: SIO<R, E, B>,
	_ zs: SIO<R, E, C>,
	_ scheduler: S
) -> SIO<R, E, (A, B, C)> {
	zip2(xs, zip2(ys, zs, scheduler), scheduler) // SIO<R, E, (A, (B, C))>
		.map { a, bc in (a, bc.0, bc.1) }
}

@inlinable
public func zip3<R, E, A, B, C, D, S: Scheduler>(
	with f: @escaping (A, B, C) -> D
)
-> (SIO<R, E, A>, SIO<R, E, B>, SIO<R, E, C>, S)
-> SIO<R, E, D> {
	{ xs, ys, zs, scheduler in zip3(xs, ys, zs, scheduler).map(f) }
}

@inlinable
public func zip4<R, E, A, B, C, D, S: Scheduler>(
	_ xs: SIO<R, E, A>,
	_ ys: SIO<R, E, B>,
	_ zs: SIO<R, E, C>,
	_ ws: SIO<R, E, D>,
	_ scheduler: S
) -> SIO<R, E, (A, B, C, D)> {
	zip2(xs, zip3(ys, zs, ws, scheduler), scheduler) // SIO<R, E, (A, (B, C))>
		.map { a, bcd in (a, bcd.0, bcd.1, bcd.2) }
}

@inlinable
public func zip4<R, E, A, B, C, D, F, S: Scheduler>(
	with f: @escaping (A, B, C, D) -> F
) -> (SIO<R, E, A>, SIO<R, E, B>, SIO<R, E, C>, SIO<R, E, D>, S) -> SIO<R, E, F> {
	{ xs, ys, zs, ws, scheduler in zip4(xs, ys, zs, ws, scheduler).map(f) }
}
