import Foundation
import Combine

extension SIO {
	@inlinable
	public func run(_ env: R, _ resolve: @escaping ResultCallback) {
		self.fork(env, { _ in }, resolve)
	}
	
	@inlinable
	public func runMain(_ env: R, _ resolve: @escaping ResultCallback) {
		self
			.forkOn(.main)
			.run(env, resolve)
	}
	
	@inlinable
	public func runForget(_ env: R) {
		self.run(env, { _ in })
	}
}

extension SIO where R == Void {
	@inlinable
	public func run(_ resolve: @escaping ResultCallback) {
		self.run((), resolve)
	}
	
	@inlinable
	public func runMain(_ resolve: @escaping ResultCallback) {
		self.runMain((), resolve)
	}
	
	@inlinable
	public func fork(_ reject: @escaping ErrorCallback, _ resolve: @escaping ResultCallback) {
		self.fork((), reject, resolve)
	}
	
	@inlinable
	public func forkMain(_ reject: @escaping ErrorCallback, _ resolve: @escaping ResultCallback) {
		self.fork(in: DispatchQueue.main, reject, resolve)
	}
	
	@inlinable
	public func fork(in queue: DispatchQueue, _ reject: @escaping ErrorCallback, _ resolve: @escaping ResultCallback) {
			self.fork((), { e in
				queue.async {
					reject(e)
				}
			}, { a in
				queue.async {
					resolve(a)
				}
			})
	}
	
	@inlinable
	public func runForget() {
		self.runForget(())
	}
}

extension SIO where R == Void, E == Never {
	@inlinable
	public func run(_ resolve: @escaping ResultCallback) {
		self.fork((), absurd, resolve)
	}
}

@inlinable
public func runAll<R, E, A, S: Scheduler>(
	_ tasks: [SIO<R, E, A>],
	_ scheduler: S
) -> SIO<R, E, [A]> {
	tasks
		.map { (task: SIO<R, E, A>) -> SIO<R, Never, Either<E, A>> in
			task.either()
		}
		.traverse(scheduler, id)
		.mapError(absurd)
		.map { (eithers: [Either<E, A>]) -> [Either<E, A>] in
			eithers.filter {
				$0.isRight
			}
		}
		.flatMap { (eithers: [Either<E, A>]) -> SIO<R, E, [A]> in
			eithers.traverse(scheduler) {
				SIO<R, E, A>.from($0).require(R.self)
			}
		}
}
