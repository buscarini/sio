//
//  Player.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 22/12/2019.
//

import Foundation
import AVFoundation
import Sio

public struct Player {
	public var player: AudioPlayer

	private init(_ player: AudioPlayer) {
		self.player = player
	}

	public static var create: SIO<AudioResource, Error, Player> {
		SIO<AudioResource, Error, AudioPlayer>.init(catching: { resource in
			try AudioPlayer(contentsOf: resource.url.rawValue)
		})
		.map(Player.init)
	}

	public var play: UIO<Void> {
		.init(
			{ (_, _, resolve) in
				self.player.playFinished = { _ in
					resolve(())
				}
				
				self.player.play()
			},
			cancel: {
				self.player.stop()
			}
		)
	}
}
