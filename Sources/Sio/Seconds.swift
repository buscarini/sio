import Foundation

public struct Seconds<T: Numeric & Sendable>: RawRepresentable, Sendable {
	public var rawValue: T
	
	public init(rawValue: T) {
		self.rawValue = rawValue
	}
}

extension Seconds: Equatable {}
extension Seconds: Hashable where T: Hashable {}
extension Seconds: Codable where T: Codable {}

extension Seconds {
	public func map<U: Numeric>(_ f: @escaping (T) -> U) -> Seconds<U> {
		Seconds<U>(rawValue: f(self.rawValue))
	}
}

public func zip<T: Numeric, U: Numeric>(
	_ left: Seconds<T>,
	_ right: Seconds<T>,
	with f: @escaping (T, T) -> U
) -> Seconds<U> {
	Seconds<U>(
		rawValue: f(left.rawValue, right.rawValue)
	)
}

extension Seconds: ExpressibleByFloatLiteral where RawValue: ExpressibleByFloatLiteral {
	public typealias FloatLiteralType = RawValue.FloatLiteralType
	
	public init(floatLiteral: FloatLiteralType) {
		self.init(rawValue: RawValue(floatLiteral: floatLiteral))
	}
}

extension Seconds: ExpressibleByIntegerLiteral where RawValue: ExpressibleByIntegerLiteral {
	public typealias IntegerLiteralType = RawValue.IntegerLiteralType
	
	public init(integerLiteral: IntegerLiteralType) {
		self.init(rawValue: RawValue(integerLiteral: integerLiteral))
	}
}
