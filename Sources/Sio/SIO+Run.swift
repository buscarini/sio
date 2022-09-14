//
//  SIO+Never.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

extension SIO {
	@inlinable
	@discardableResult
	public func run(_ env: R, _ resolve: @escaping ResultCallback) -> Work<E, A> {
		self.fork(env, { _ in }, resolve)
	}
	
	@inlinable
	@discardableResult
	public func runMain(_ env: R, _ resolve: @escaping ResultCallback) -> Work<E, A> {
		self
			.forkOn(.main)
			.run(env, resolve)
	}
	
	@inlinable
	@discardableResult
	public func runForget(_ env: R) -> Work<E, A> {
		self.run(env, { _ in })
	}
}

extension SIO where R == Void {
	@inlinable
	@discardableResult
	public func run(_ resolve: @escaping ResultCallback) -> Work<E, A> {
		self.run((), resolve)
	}
	
	@inlinable
	@discardableResult
	public func runMain(_ resolve: @escaping ResultCallback) -> Work<E, A> {
		self.runMain((), resolve)
	}
	
	@inlinable
	@discardableResult
	public func fork(
		_ reject: @escaping ErrorCallback,
		_ resolve: @escaping ResultCallback
	) -> Work<E, A> {
		self.fork((), reject, resolve)
	}
	
	@inlinable
	@discardableResult
	public func forkMain(
		_ reject: @escaping ErrorCallback,
		_ resolve: @escaping ResultCallback
	) -> Work<E, A> {
		self.fork(in: DispatchQueue.main, reject, resolve)
	}
	
	@inlinable
	@discardableResult
	public func fork(
		in queue: DispatchQueue,
		_ reject: @escaping ErrorCallback,
		_ resolve: @escaping ResultCallback
	) -> Work<E, A> {
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
	@discardableResult
	public func run(_ resolve: @escaping ResultCallback) -> Work<Never, A> {
		self.fork((), absurd, resolve)
	}
}

@inlinable
public func runAll<R, E, A>(
	_ tasks: [SIO<R, E, A>],
	_ scheduler: Scheduler
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
