import Foundation
import sio
import PlaygroundSupport

let long = Array(1...100).forEach { item in
		return environment(Console.self)
			.flatMap { console -> SIO<Console, Never, Void> in
//				Swift.print("print \(item)")
				return console.printLine("long \(item)").require(Console.self)
			}
	}
	.map(const("long"))
	.provide(Console.default)
	.scheduleOn(DispatchQueue.global())

//let long = UIO<Int>.init { (_, _, resolve) in
//	(1...10).forEach { Swift.print("\($0)") }
//
//	print("-------------")
//
//	resolve(1000)
//}

let short = UIO<String>.init { (_, _, resolve) in
	(0...800).forEach { Swift.print("short \($0)") }
	
	print("-------------")
	
	resolve("short")
}
.scheduleOn(DispatchQueue.global())

let task = race(
	long,
	short
)

//let task = long

task.forkMain(absurd, { a in
	print("Success \(a)")
	PlaygroundPage.current.finishExecution()
})

PlaygroundPage.current.needsIndefiniteExecution = true
