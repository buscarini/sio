//import Sio
import Foundation
//import ComposableArchitecture
import Combine

public enum EffectError: Error {
	case deallocated
}

extension SIO where R == Void, E: Error {
	public func task(id: String) async throws -> A {
		try await withTaskCancellationHandler {
			try await withCheckedThrowingContinuation { [weak self] continuation in
				var resumed = false
				guard let self else {
					if resumed == false {
						#if DEBUG
						print("Deallocated \(id) #task")
						#endif
						resumed = true
						continuation.resume(throwing: EffectError.deallocated)
					}
					return
				}
				
				guard _Concurrency.Task.isCancelled == false else {
					if resumed == false {
						resumed = true
						continuation.resume(throwing: CancellationError())
					}
					return
				}
				
				let onCancel = self.onCancel
				self.onCancel = {
					onCancel?()
					if resumed == false {
						resumed = true
						continuation.resume(throwing: CancellationError())
					}
				}
				
				self.fork { error in
					if resumed == false {
						resumed = true
						continuation.resume(throwing: error)
					}
				} _: { value in
					if resumed == false {
						resumed = true
						continuation.resume(returning: value)
					}
				}
			}
		} onCancel: { [weak self] in
			#if DEBUG
			print("On cancel #task \(id)")
			#endif
			self?.cancel()
		}
	}
	
	public var task: A {
		get async throws {
			try await self.task(id: "unknown")
		}
	}
	
	public var nonCancellableTask: A {
		get async throws {
			try await withCheckedThrowingContinuation { [weak self] continuation in
				guard let self else {
					continuation.resume(throwing: EffectError.deallocated)
					return
				}
				
				self.fork { error in
					continuation.resume(throwing: error)
				} _: { value in
					continuation.resume(returning: value)
				}
			}
		}
	}
}

