//
//  Optional+Zip.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 28/11/2019.
//

import Foundation

public func <&><A, B>(lhs: A?, rhs: B?) -> (A, B)? {
	return zip(lhs, rhs)
}

public func zip<U, V>(_ left: U?, _ right: V?) -> (U, V)? {
	guard let left = left, let right = right else {
		return nil
	}
	
	return (left, right)
}

public func zip<U, V, A>(with f: @escaping (U, V) -> A)
	-> (U?,  V?)
	->  A? {
		return { left, right in
			return zip(left, right).map(f)
		}
}

public func zip2<U, V>(_ left:  U?, _ right:  V?) ->  (U, V)? {
	return zip(left, right)
}

public func zip2<U, V, A>(with f: @escaping (U, V) -> A)
	-> ( U?,  V?)
	->  A? {
		return zip(with: f)
}

public func zip3<A, B, C>(
	_ xs: A?, _ ys: B?, _ zs: C?
	) -> (A, B, C)? {
	
	return zip2(xs, zip2(ys, zs)) // (A, (B, C))?
		.map { a, bc in (a, bc.0, bc.1) }
}

public func zip3<A, B, C, D>(
	with f: @escaping (A, B, C) -> D
	) -> (A?, B?, C?) -> D? {
	return { xs, ys, zs in zip3(xs, ys, zs).map(f) }
}

public func zip4<A, B, C, D>(
	_ xs: A?, _ ys: B?, _ zs: C?, _ ws: D?
	) -> (A, B, C, D)? {
	return zip2(xs, zip3(ys, zs, ws)) // (A, (B, C))?
		.map { a, bcd in (a, bcd.0, bcd.1, bcd.2) }
}

public func zip4<A, B, C, D, E>(
	with f: @escaping (A, B, C, D) -> E
) -> (A?, B?, C?, D?) -> E? {
	{ xs, ys, zs, ws in zip4(xs, ys, zs, ws).map(f) }
}
