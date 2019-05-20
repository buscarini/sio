//
//  Prelude.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public func id<a>(_ a: a) -> a {
	return a
}

public func absurd<A>(_ n: Never) -> A {
	switch n {}
}
