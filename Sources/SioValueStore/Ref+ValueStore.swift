import Foundation
import Sio

public extension Ref {
	func valueStore<Wrapped>() -> ValueStoreA<Void, Void, Wrapped>
	where S == Wrapped? {
		.init(
			load: SIO.await {
				await self.value()
			}.fromOptional(),
			save: { newValue in
				SIO.await {
					await self.modify(newValue)
					return newValue
				}
			},
			remove: .await {
				await self.modify(nil)
			}
		)
	}
}
