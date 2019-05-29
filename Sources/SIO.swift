//
//  SIO.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 26/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public enum SIO<R, E, A> {
	case zero
	case effect(Eff<R, E, A>)
}

public extension SIO {
	typealias ErrorCallback = (E) -> ()
	typealias ResultCallback = (A) -> ()
	typealias EmptyCallback = () -> ()

	typealias Computation = (R, @escaping ErrorCallback, @escaping ResultCallback) -> ()

	init(_ computation: @escaping Computation) {
		self = .effect(Eff.init(computation))
	}
	
	init(_ computation: @escaping Computation, cancel: EmptyCallback?) {
		self = .effect(Eff.init(computation, cancel: cancel))
	}
	
	func fork(_ requirement: R, _ reject: @escaping ErrorCallback, _ resolve:
		@escaping ResultCallback) {
		switch self {
		case .zero:
			return
		case let .effect(io):
			return io.fork(requirement, reject, resolve)
		}
	}
	
	func cancel() {
		switch self {
		case .zero:
			return
		case let .effect(io):
			io.cancel()
		}
	}
}
