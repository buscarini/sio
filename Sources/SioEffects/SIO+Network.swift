//
//  SIO+Network.swift
//  SioEffects
//
//  Created by José Manuel Sánchez Peñarroja on 06/12/2019.
//

import Foundation
import Sio

public struct Network {
	public var request = Default.request
	
	
	public init(
		request: SIO<Request, NetworkError, Data>
	) {
		self.request = request
	}
	
	// MARK: Defaults
	public enum Default {
		public static var request: SIO<Request, NetworkError, Data> {
			.init { (request, reject, resolve) in
				
				let urlRequest = URLRequest(
					url: request.url.rawValue,
					cachePolicy: request.cachePolicy,
					timeoutInterval: request.timeout
				)
				
				let task = URLSession().dataTask(with: urlRequest)
				task.resume()
				
			}
		}
	}
}
