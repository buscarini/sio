//
//  SIO+Never.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

extension SIO {
	public func run(_ env: R, _ resolve: @escaping ResultCallback) {
		self.fork(env, { _ in }, resolve)
	}
	
	public func runMain(_ env: R, _ resolve: @escaping ResultCallback) {
		self
			.forkOn(.main)
			.run(env, resolve)
	}
	
	public func runForget(_ env: R) {
		self.run(env, { _ in })
	}
}

extension SIO where R == Void {
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
}

extension SIO where R == Void, E == Never {
	public func run(_ resolve: @escaping ResultCallback) {
		self.fork((), absurd, resolve)
	}
}

public func runAll<R, E, A>(_ tasks: [SIO<R, E, A>]) -> SIO<R, E, [A]> {
	tasks
		.map { (task: SIO<R, E, A>) -> SIO<R, Never, Either<E, A>> in
			task.either()
		}
		.traverse(id)
		.mapError(absurd)
		.map { (eithers: [Either<E, A>]) -> [Either<E, A>] in
			eithers.filter {
				$0.isRight
			}
		}
		.flatMap { (eithers: [Either<E, A>]) -> SIO<R, E, [A]> in
			eithers.traverse {
				SIO<R, E, A>.from($0).require(R.self)
			}
		}
}
