//
//  Prelude.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

@inlinable
public func id<a>(_ a: a) -> a {
	return a
}

@inlinable
public func absurd<A>(_ n: Never) -> A {
	switch n {}
}

@inlinable
public func discard<A>(_ value: A) -> Void {	
}

@inlinable
public func const<A, B>(_ b: B) -> (_ a: A) -> B {
	return { _ in b }
}
