import Foundation
import sio

let long = UIO<Int>.init { (_, _, resolve) in
	(1...10).forEach { Swift.print("\($0)") }
	
	print("-------------")
	
	resolve(1000)
}

let long2 = UIO<Int>.init { (_, _, resolve) in
	(0...80).forEach { Swift.print("\($0)") }
	
	print("-------------")
	
	resolve(1)
}

let task = race(
	long,
	long2.flatMap(const(long2))
)
.scheduleOn(DispatchQueue.global())

task.fork(absurd, { a in
	print("Success \(a)")
})
