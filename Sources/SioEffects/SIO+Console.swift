//
//  SIO+Console.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 21/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation
import Sio

public struct Console {
	public var printLine: (String) -> UIO<Void>
	public var getLine: () -> IO<SIOError, String>
	
	public static var `default`: Console {
		return Console(
			printLine: defaultPrintLine,
			getLine: defaultGetLine
		)
	}
	
	public static func mock(_ getLine: String) -> Console {
		return Console(
			printLine: { _ in .empty },
			getLine: { return .of(getLine) }
		)
	}
	
	public init(
		printLine: @escaping (String) -> UIO<Void>,
		getLine: @escaping () -> IO<SIOError, String>
	) {
		self.printLine = printLine
		self.getLine = getLine
	}
	
	public static func defaultPrintLine(_ string: String) -> UIO<Void> {
		return UIO<Void>({ env, reject, resolve in
			Swift.print(string)
			resolve(())
		})
	}

	public static func defaultGetLine() -> IO<SIOError, String> {
		return IO<SIOError, String>({ _, reject, resolve in
			guard let line = readLine() else {
				reject(.empty)
				return
			}
			
			resolve(line)
		})
	}
}
