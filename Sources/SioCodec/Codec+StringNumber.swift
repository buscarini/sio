import Foundation
import Sio

public extension Codec where E == Void, A == String, B == TimeInterval {
	static var stringTimeInterval: Codec<Void, String, TimeInterval> {
		Codec<Void, String, TimeInterval>(to: { string in
			Either.from(TimeInterval(string), ())
		}, from: { value in
			.right("\(value)")
		})
	}
}

public extension Codec where E == Void, A == String, B == Int {
	static var stringInt: Codec<Void, String, Int> {
		Codec<Void, String, Int>(to: { string in
			Either.from(Int(string), ())
		}, from: { int in
			.right("\(int)")
		})
	}
}
