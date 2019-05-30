//
//  SIO+Console.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 21/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public func printLine(_ string: String) -> UIO<Void> {
	return UIO<Void>({ env, reject, resolve in
		Swift.print(string)
		resolve(())
	})
}

public var getLine: IO<SIOError, String> {
	return IO<SIOError, String>({ _, reject, resolve in
		guard let line = readLine() else {
			reject(.empty)
			return
		}
		
		resolve(line)
	})
}

