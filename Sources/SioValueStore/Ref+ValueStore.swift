import Foundation
import Sio

public extension Ref {
	nonisolated func valueStore<Wrapped>() -> ValueStoreA<Void, Void, Wrapped>
	where S == Wrapped? {
		.init(
			load: IO<Void, Wrapped?>.await {
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
