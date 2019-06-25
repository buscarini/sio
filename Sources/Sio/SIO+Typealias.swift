//
//  SIO+Typealias.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 21/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public typealias UIO<A> = SIO<Void, Never, A>
public typealias IO<E, A> = SIO<Void, E, A>
public typealias TaskR<R, A> = SIO<R, Error, A>
public typealias Task<A> = SIO<Void, Error, A>
