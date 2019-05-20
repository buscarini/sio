//
//  SIO+Zip.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public func zip<R, E, A, B>(_ left: SIO<R, E, A>, _ right: SIO<R, E, B>) -> SIO<R, E, (A, B)> {
	return liftA2(SIO.of({ a in
		{ b in
			(a, b)
		}
	}), left, right)
}

public func zip<R, E, A, B, C>(with f: @escaping (A, B) -> C)
	-> (SIO<R, E, A>, SIO<R, E, B>)
	-> SIO<R, E, C> {
		return { left, right in
			return zip(left, right).map(f)
		}
}

public func zip2<R, E, A, B>(_ left: SIO<R, E, A>, _ right: SIO<R, E, B>) -> SIO<R, E, (A, B)> {
	return zip(left, right)
}

public func zip2<R, E, A, B, C>(with f: @escaping (A, B) -> C)
	-> (SIO<R, E, A>, SIO<R, E, B>)
	-> SIO<R, E, C> {
		return zip(with: f)
}

public func zip3<R, E, A, B, C>(
	_ xs: SIO<R, E, A>, _ ys: SIO<R, E, B>, _ zs: SIO<R, E, C>
	) -> SIO<R, E, (A, B, C)> {
	
	return zip2(xs, zip2(ys, zs)) // SIO<R, E, (A, (B, C))>
		.map { a, bc in (a, bc.0, bc.1) }
}

func zip3<R, E, A, B, C, D>(
	with f: @escaping (A, B, C) -> D
	) -> (SIO<R, E, A>, SIO<R, E, B>, SIO<R, E, C>) -> SIO<R, E, D> {
	return { xs, ys, zs in zip3(xs, ys, zs).map(f) }
}

