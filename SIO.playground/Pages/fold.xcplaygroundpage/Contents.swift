import Foundation
import Sio
import SioEffects
import PlaygroundSupport


let task = SIO<Int, Never, Void>.environment()
	.flatMap { initial in
		Array(1...1000).foldM(initial, {
			SIO<Int, Never, Int>.of($0 + $1)
		})
	}
	.map { "\($0)" }
	.flatMap {
		Console.default.printLine($0).require(Int.self)
	}

task
	.provide(10)
	.run {
		
	}
