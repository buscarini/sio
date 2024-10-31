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
