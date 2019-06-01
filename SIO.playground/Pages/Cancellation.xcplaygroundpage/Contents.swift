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

let task = long
	.flatMap { _ in long2 }
	.flatMap { _ in long2 }

task
.scheduleOn(DispatchQueue.global())
.fork(absurd, { a in
		print("Success \(a)")
	})

print("before cancel")
task.cancel()
print("after cancel")

