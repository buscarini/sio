//
//  Eihter+Error.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 25/06/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

extension Either where A == Error {
	@inlinable
	public init(catching: @escaping () throws -> B) {
		do {
			self = .right(try catching())
		}
		catch let error {
			self = .left(error)
		}
	}
}
