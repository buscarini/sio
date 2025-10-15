import Foundation

extension SIO where R == Void, E: Error {
	public var await: A {
		get async throws {
			try await withCheckedThrowingContinuation { continuation in
				self.fork { error in
					continuation.resume(throwing: error)
				} _: { value in
					continuation.resume(returning: value)
				}
			}
		}
	}
}

extension SIO {
	public static func await(
		_ f: @escaping () async -> A
	) -> SIO<R, E, A> {
//		var task: _Concurrency.Task<Void, Never>?
		return SIO { _, _, resolve in
//			task =
			_Concurrency.Task {
				let a = await f()
				resolve(a)
			}
		} cancel: {
//			task?.cancel()
		}
	}
}

extension SIO where R == Void, E == any Error {
	public static func tryAwait(
		_ f: @escaping () async throws -> A
	) -> IO<any Error, A> {
		var task: _Concurrency.Task<Void, Never>?
		return SIO { _, reject, resolve in
			task = _Concurrency.Task {
				do {
					let a = try await f()
					resolve(a)
				} catch {
					reject(error)
				}
			}
		} cancel: {
			task?.cancel()
		}
	}
}
