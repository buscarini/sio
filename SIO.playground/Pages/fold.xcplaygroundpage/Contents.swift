import Foundation
import sio
import PlaygroundSupport


let task = SIO<Int, Never, Void>.environment()
	.flatMap { initial in
		Array(1...1000).foldM(initial, {
			SIO<Int, Never, Int>.of($0 + $1)
		})
	}
	.map { "\($0)" }
	.flatMap(
		Console.default.printLine
	)

task
	.provide(10)
	.run {
		
	}
