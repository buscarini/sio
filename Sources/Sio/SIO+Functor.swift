import Foundation

extension SIO {
	@inlinable
	public func map<B>(_ f: @escaping (A) -> (B)) -> SIO<R, E, B> {
		self.bimap(id, f)
	}
	
	@inlinable
	public func map2<Element, B>(_ f: @escaping (Element) -> (B)) -> SIO<R, E, [B]> where A == [Element] {
		self.bimap(id, { $0.map(f) })
	}
	
	
	@inlinable
	public func map2<Element, B>(_ f: @escaping (Element) -> (B)) -> SIO<R, E, B?> where A == Element? {
		self.bimap(id, { $0.map(f) })
	}
	
	@inlinable
	public func map2<Left, Right, B>(_ f: @escaping (Right) -> (B)) -> SIO<R, E, Either<Left, B>> where A == Either<Left, Right> {
		self.bimap(id, { $0.map(f) })
	}
	
	@inlinable
	public var void: SIO<R, E, Void> {
		self.map { _ in () }
	}
	
	@inlinable
	public func const<B>(_ value: B) -> SIO<R, E, B> {
		self.map { _ in
			value
		}
	}
}
