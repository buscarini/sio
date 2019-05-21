//
//  SIO+Console.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 21/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public enum ConsoleError: Error {
	case noData
}

public extension SIO {
	static var print: SIO<String, Never, Void> {
		return SIO<String, Never, Void>({ env, reject, resolve in
			Swift.print(env)
			resolve(())
		})
	}
	
	static var getLine: IO<ConsoleError, String> {
		return IO<ConsoleError, String>({ _, reject, resolve in
			guard let line = readLine() else {
				reject(.noData)
				return
			}
			
			resolve(line)
		})
	}
}
