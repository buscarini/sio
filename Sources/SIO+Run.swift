//
//  SIO+Never.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

extension SIO where E == Never {
	public func run(_ env: R, _ resolve: @escaping ResultCallback) {
		self.fork(env, absurd, resolve)
	}
}

extension SIO where R == Void {
	public func fork(_ reject: @escaping ErrorCallback, _ resolve: @escaping ResultCallback) {
		self.fork((), reject, resolve)
	}
}

extension SIO where R == Void, E == Never {
	public func run(_ resolve: @escaping ResultCallback) {
		self.fork((), absurd, resolve)
	}
}
