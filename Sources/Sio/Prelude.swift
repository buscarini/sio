//
//  Prelude.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

@inlinable
@Sendable
public func id<a>(_ a: a) -> a {
	a
}

@inlinable
@Sendable
public func absurd<A>(_ n: Never) -> A {}

@inlinable
@Sendable
public func discard<A, B>(_ f: @escaping (A) -> B) -> (A) -> Void {
	{ a in
		_ = f(a)
	}
}

@inlinable
@Sendable
public func const<A, B>(_ b: B) -> (_ a: A) -> B {
	{ _ in b }
}
