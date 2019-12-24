//
//  AudioPlayer.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 22/12/2019.
//

import Foundation
import AVFoundation

public class AudioPlayer: AVAudioPlayer {
	public var playFinished: ((Bool) -> Void)?

	public override init(contentsOf url: URL) throws {
		try super.init(contentsOf: url)
		
		commonInit()
	}
	
	public override init(data: Data) throws {
		try super.init(data: data)
		
		commonInit()
	}
	
	public override init(contentsOf url: URL, fileTypeHint utiString: String?) throws {
		try super.init(contentsOf: url, fileTypeHint: utiString)
		
		commonInit()
	}
	
	func commonInit() {
		self.delegate = self
	}
}

extension AudioPlayer: AVAudioPlayerDelegate {
	public func audioPlayerDidFinishPlaying(
		_ player: AVAudioPlayer,
		successfully flag: Bool
	) {
		playFinished?(flag)
	}
}
