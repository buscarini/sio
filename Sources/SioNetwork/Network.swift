//
//  SIO+Network.swift
//  SioEffects
//
//  Created by José Manuel Sánchez Peñarroja on 06/12/2019.
//

import Foundation
import Sio

public struct Network {
	public var request: SIO<Request, NetworkError, (Data, HTTPResponse)>
	
	public init(
		request: SIO<Request, NetworkError, (Data, HTTPResponse)> = Default.request
	) {
		self.request = request
	}
	
	// MARK: Defaults
	public enum Default {
		public static var request: SIO<Request, NetworkError, (Data, HTTPResponse)> {
			var task: URLSessionDataTask?
			
			return .init({ (request, reject, resolve) in
				
				let urlRequest = URLRequest(
					url: request.url.rawValue,
					cachePolicy: request.cachePolicy,
					timeoutInterval: request.timeout
				)
				
				task = URLSession(configuration: .default).dataTask(with: urlRequest) { (data, response, error) in
					
					guard let response = response as? HTTPURLResponse else {
						reject(NetworkError.unknown)
						return
					}
					
					let httpResponse = HTTPResponse.init(
						responseCode: .init(rawValue: response.statusCode),
						url: response.url ?? request.url.rawValue,
						headerFields: response.allHeaderFields
					)
					
					if let data = data {
						resolve((data, httpResponse))
					}
					else {
						reject(NetworkError.response(httpResponse, error, data))
					}
				}

				task?.resume()
			}, cancel: {
				task?.cancel()
				task = nil
			})
		}
	}
}
