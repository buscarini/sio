import Foundation
import Sio

extension Codec {
	public func bidimap<A0, B0>(
		_ preLeft: @escaping (A0) -> A,
		_ postLeft: @escaping (A) -> A0,
		_ preRight: @escaping (B0) -> B,
		_ postRight: @escaping (B) -> B0
	) -> Codec<E, A0, B0> {
		.init { a0 in
			self.to(preLeft(a0)).mapRight(postRight)
		} from: { b0 in
			self.from(preRight(b0)).mapRight(postLeft)
		}
	}
	
	public func dimap<B0>(
		_ pre: @escaping (B0) -> B,
		_ post: @escaping (B) -> B0
	) -> Codec<E, A, B0> {
		bidimap(id, id, pre, post)
	}
	
	public func dimapLeft<A0>(
		_ pre: @escaping (A0) -> A,
		_ post: @escaping (A) -> A0
	) -> Codec<E, A0, B> {
		bidimap(pre, post, id, id)
	}
	
	public func dimapRight<B0>(
		_ pre: @escaping (B0) -> B,
		_ post: @escaping (B) -> B0
	) -> Codec<E, A, B0> {
		dimap(pre, post)
	}
}
