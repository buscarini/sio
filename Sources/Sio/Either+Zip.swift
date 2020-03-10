//
//  Either+Zip.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 25/06/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

@inlinable
public func <&><E, A, B>(lhs: Either<E, A>, rhs: Either<E, B>) -> Either<E, (A, B)> {
	zip(lhs, rhs)
}

@inlinable
public func zip<T, U, V>(_ left: Either<T, U>, _ right: Either<T, V>) -> Either<T, (U, V)> {
	switch (left, right) {
	case let (.left(l), _):
		return .left(l)
	case let (_, .left(l)):
		return .left(l)
	case let (.right(l), .right(r)):
		return .right((l, r))
	}
}

@inlinable
public func zip<T, U, V, A>(with f: @escaping (U, V) -> A)
	-> (Either<T, U>, Either<T, V>
) -> Either<T, A> {
	{ left, right in
		zip(left, right).map(f)
	}
}

@inlinable
public func zip2<T, U, V>(_ left: Either<T, U>, _ right: Either<T, V>) -> Either<T, (U, V)> {
	return zip(left, right)
}

@inlinable
public func zip2<T, U, V, A>(with f: @escaping (U, V) -> A)
	-> (Either<T, U>, Either<T, V>
) -> Either<T, A> {
	zip(with: f)
}

@inlinable
public func zip3<E, A, B, C>(    
	_ xs: Either<E, A>, _ ys: Either<E, B>, _ zs: Either<E, C>
) -> Either<E, (A, B, C)> {
	zip2(xs, zip2(ys, zs)) // Either<E, (A, (B, C))>
		.map { a, bc in (a, bc.0, bc.1) }
}

@inlinable
public func zip3<E, A, B, C, D>(
	with f: @escaping (A, B, C) -> D
) -> (Either<E, A>, Either<E, B>, Either<E, C>) -> Either<E, D> {
	{ xs, ys, zs in zip3(xs, ys, zs).map(f) }
}

@inlinable
public func zip4<E, A, B, C, D>(
	_ xs: Either<E, A>, _ ys: Either<E, B>, _ zs: Either<E, C>, _ ws: Either<E, D>
) -> Either<E, (A, B, C, D)> {
	zip2(xs, zip3(ys, zs, ws)) // Either<E, (A, (B, C))>
		.map { a, bcd in (a, bcd.0, bcd.1, bcd.2) }
}

@inlinable
public func zip4<E, A, B, C, D, F>(
	with f: @escaping (A, B, C, D) -> F
) -> (Either<E, A>, Either<E, B>, Either<E, C>, Either<E, D>) -> Either<E, F> {
	{ xs, ys, zs, ws in zip4(xs, ys, zs, ws).map(f) }
}
