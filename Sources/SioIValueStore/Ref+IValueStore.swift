import Foundation
import Sio

public extension Ref {
	func iValueStore<K: Hashable, A>() -> IValueStoreA<Void, K, Void, A> where S == Dictionary<K, A> {
		.init(
			load: { k in
				SIO.await {
					await self.value()[k]
				}.fromOptional()
			},
			save: { k, newValue in
				SIO.await {
					await self.update { dic in
						dic[k] = newValue
						return newValue
					}
				}
			},
			remove: { k in
				SIO.await {
					await self.update { dic in
						dic[k] = nil
					}
				}
			}
		)
	}
}
