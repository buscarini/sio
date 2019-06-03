import Foundation
import sio


let long = Array(1...10).forEach { item in
	environment(Console.self)
		.flatMap { console in
			console.printLine("\(item)").require(Console.self)
	}
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
	(0...80).forEach { Swift.print("\($0)") }
	
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

print("before cancel zip")
task.cancel()
print("after cancel zip")
