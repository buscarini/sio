//
//  SIO+Creation.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public extension SIO {
	@inlinable
	static func of(_ value: A) -> Just<R, E, A> {
		Just(value)
	}
	
	@inlinable
	static func lazy(_ value: @autoclosure @escaping () -> A) -> Sync<R, E, A> {
		Sync { _ in
			.right(value())
		}
	}

	@inlinable
	static func rejected(_ error: E) -> Rejected<R, E, A> {
		Rejected(error)
	}
	
	@inlinable
	static func rejectedLazy(_ error: @autoclosure @escaping () -> E) -> Sync<R, E, A> {
		Sync { _ in
			.left(error())
		}
	}
	
	@inlinable
	static func fromFunc(_ f: @escaping (R) -> A) -> Sync<R, E, A> {
		Sync { r in
			.right(f(r))
		}
	}
}

public extension SIO where E == Never, A == Void {
	@inlinable
	static var empty: Just<R, E, A> {
		Just(())
	}
	
	@inlinable
	static func effect(_ f: @escaping (R) -> Void) -> Sync<R, Never, Void> {
		Sync { r in
			f(r)
			return .right(())
		}
	}
	
//	@inlinable
//	static func effectMain(_ f: @escaping (R) -> Void) -> Sync<R, Never, Void> {
//		effect(f).scheduleOn(.main)
//	}
}

public extension SIO {
	@inlinable
	static var never: Async<R, Never, Never> {
		Async<R, Never, Never>({ _, _ ,_ in }, cancel: nil)
	}
	
//	@inlinable
//	var never: Async<R, Never, Never> {
//		self.biFlatMap(.never)
//	}
}
