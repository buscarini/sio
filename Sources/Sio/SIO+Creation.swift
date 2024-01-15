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
	static func of(_ value: A) -> SIO {
		SIO(.success(value), cancel: nil)
	}
	
	@inlinable
	static func lazy(_ value: @autoclosure @escaping () -> A) -> SIO {
		SIO({ (_, _, resolve) in
			resolve(value())
		})
	}

	@inlinable
	static func rejected(_ error: E) -> SIO {
		SIO(.fail(error), cancel: nil)
	}
	
	@inlinable
	static func rejectedLazy(_ error: @autoclosure @escaping () -> E) -> SIO {
		SIO({ (_, reject, _) in
			reject(error())
		})
	}
	
	@inlinable
	static func fromFunc(_ f: @escaping (R) -> A) -> SIO<R, Never, A> {
		SIO<R, Never, A>.environment().map(f)
	}
}

public extension SIO where R == Void {
	convenience init(
		_ callback: @escaping (@escaping ErrorCallback, @escaping ResultCallback) -> ()
	) {
		self.init({ _, reject, resolve in
			callback(reject, resolve)
		})
	}
}

public extension SIO where E == Never, A == Void {
	@inlinable
	static var empty: SIO<R, Never, Void> {
		.effect { _ in }
	}
	
	@inlinable
	static func effect(_ f: @escaping (R) -> Void) -> SIO<R, Never, Void> {
		SIO<R, Never, Void>.sync({ r in
			f(r)
			return .right(())
		})
	}
	
	@inlinable
	static func effectMain(_ f: @escaping (R) -> Void) -> SIO<R, Never, Void> {
		effect(f).scheduleOn(.main)
	}
}

public extension SIO {
	@inlinable
	static var never: SIO<R, Never, Never> {
		.init { (_, _, _) in }
	}
	
	@inlinable
	var never: SIO<R, Never, Never> {
		self.biFlatMap(.never)
	}
}
