import Foundation
import Sio

// Represents an indexed value store. It can be implemented to use a file, network calls, preferences, etc.
public struct IValueStore<R, K: Hashable, E, A, B> {
	public var load: (K) -> SIO<R, E, B>
	public var save: (K, A) -> SIO<R, E, B>
	public var remove: (K) -> SIO<R, E, Void>
	
	public init(
		load: @escaping (K) -> SIO<R, E, B>,
		save: @escaping (K, A) -> SIO<R, E, B>,
		remove: @escaping (K) -> SIO<R, E, Void>
	) {
		self.load = load
		self.save = save
		self.remove = remove
	}
}
