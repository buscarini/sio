import Foundation
import sio
import PlaygroundSupport

let long = Array(1...800).forEach { item in
	environment(Console.self)
		.flatMap { console in
			console.printLine("long \(item)").require(Console.self)
		}
		.scheduleOn(.global())
}
//.map(const(1000))
.provide(Console.default)

//let long = UIO<Int>.init { (_, _, resolve) in
//	(1...10).forEach { Swift.print("\($0)") }
//
//	print("-------------")
//
//	resolve(1000)
//}

let long2 = UIO<[Int]>.init { (_, _, resolve) in
	(0...800).forEach { Swift.print("\($0)") }
	
	print("-------------")
	
	resolve(Array(0...80))
}

let task = zip(
	long,
	long2
)
.scheduleOn(DispatchQueue.global())

task.fork(absurd, { a in
	print("Success \(a)")
})

PlaygroundPage.current.needsIndefiniteExecution = true

print("before cancel zip")
//DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
//	long.cancel()
//}

task.cancel()

print("after cancel zip")

DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
	PlaygroundPage.current.finishExecution()
}


