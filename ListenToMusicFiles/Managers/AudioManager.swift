//
//  AudioManager.swift
//  ListenToMusicFiles
//
//  Created by aadeeb rashid on 1/18/23.
//

import Foundation
import AVFAudio
import MediaPlayer

@objc protocol NeedsMusicInfoDelegate
{
    func setTitle(title: String)
    func initializeAudioPlayerScreenFromSongDuration(duration: TimeInterval)
    func changePlayPauseButton(image: UIImage)
    func changeRepeatButton(image: UIImage)
    func changeShuffleButton(image: UIImage)
    @objc func updateTimerLabels(_ timer : Timer)
}


class AudioManager : Manager, AVAudioPlayerDelegate
{
    private var audioPlayer: AVAudioPlayer!
    private var position: Int = 0
    private var shuffleModeEnabled : Bool = false
    private var shuffleQueue : [Int]?
    private var repeatModeEnabled : Bool = false
    private var currentSong: String = "";
    private var delegate: NeedsMusicInfoDelegate?
    
    func getRepeatMode() -> Bool
    {
        return repeatModeEnabled
    }
    
    func getShuffleMode() -> Bool
    {
        return shuffleModeEnabled
    }
    
    func getAudioPlayerTime() -> TimeInterval
    {
        return audioPlayer.currentTime
    }
    
    func setDelegate(viewController: NeedsMusicInfoDelegate)
    {
        delegate = viewController
    }
    
    func setVolume(value: Float)
    {
        audioPlayer.setVolume(value, fadeDuration: 0.5);
    }
    
    func stopPlaying()
    {
        if(audioPlayer.isPlaying)
        {
            audioPlayer.stop()
        }
    }
    
    
    func playAudioFromPosition(position: Int)
    {
        self.position = position;
        if(position >= AppDelegate.sharedManagers()?.userManager.getLibrary().count ?? 0)
        {
            self.position = 0;
        }
        self.currentSong = AppDelegate.sharedManagers()?.userManager.getLibrary()[position].fileName ?? " ";
        
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let audioUrl = documentsDirectoryURL.appendingPathComponent(self.currentSong)
        DispatchQueue.main.async
        {
            do
            {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                try AVAudioSession.sharedInstance().setActive(true)
                self.audioPlayer = try AVAudioPlayer(contentsOf: audioUrl)
                self.prepareMusicInfoDelegate()
                self.audioPlayer.play()
                self.updateMetaData()
                self.audioPlayer.delegate = self
                if(self.repeatModeEnabled)
                {
                    self.audioPlayer.numberOfLoops = -1;
                }
                else
                {
                    self.audioPlayer.numberOfLoops = 0;
                }
            }
            catch _
            {
                AppDelegate.sharedManagers()?.errorManager.handleError(error: MusicPlayerError.playerMalfunctioned)
            }
        }
    }
    
    private func prepareMusicInfoDelegate()
    {
        self.audioPlayer.prepareToPlay()
        self.delegate?.setTitle(title: self.currentSong)
        self.delegate?.initializeAudioPlayerScreenFromSongDuration(duration: self.audioPlayer.duration)
    }
    
    func setupForAudioPlayOutsideOfApp()
    {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        self.addPlayButtonToCommandCenter(commandCenter: commandCenter)
        self.addPauseButtonToCommandCenter(commandCenter: commandCenter)
        self.addRewindButtonToCommandCenter(commandCenter: commandCenter)
        self.addForwardButtonToCommandCenter(commandCenter: commandCenter)
        self.addSeekingToCommandCenter(commandCenter: commandCenter)
    }
    
    private func addPlayButtonToCommandCenter(commandCenter: MPRemoteCommandCenter)
    {
        commandCenter.playCommand.addTarget
        {
            [unowned self] event in
            self.handlePlayPauseButtonPressed()
            return .success
        }
    }
    
    private func addPauseButtonToCommandCenter(commandCenter: MPRemoteCommandCenter)
    {
        commandCenter.pauseCommand.addTarget
        {
            [unowned self] event in
            self.handlePlayPauseButtonPressed()
            return.success
        }
    }
    
    func handlePlayPauseButtonPressed()
    {
        if(audioPlayer.isPlaying)
        {
            self.handlePauseButtonPressed()
            delegate?.changePlayPauseButton(image: UIImage(named: "MusicPlayerPlay") ?? UIImage())
            return;
        }
        
        self.handlePlayButtonPressed()
        delegate?.changePlayPauseButton(image: UIImage(named: "MusicPlayerPause") ?? UIImage())
    }
    
    private func handlePauseButtonPressed()
    {
        self.audioPlayer.pause()
        self.updateMetaData()
    }
    
    private func handlePlayButtonPressed()
    {
        self.audioPlayer.play()
        self.updateMetaData()
    }
    
    private func addRewindButtonToCommandCenter(commandCenter: MPRemoteCommandCenter)
    {
        commandCenter.previousTrackCommand.addTarget
        {
            [unowned self] event in
            self.handleRewindButtonPressed()
            return .success
        }
    }
    
    func handleRewindButtonPressed()
    {
        self.rewindOrPlayPrevSong()
    }
    
    private func rewindOrPlayPrevSong()
    {
        if(audioPlayer.currentTime > 2.0)
        {
            self.playAudioFromPosition(position: self.position)
            return;
        }
        self.playPrevSong()
    }
    
    private func playPrevSong()
    {
        if(self.position == 0)
        {
            self.playAudioFromPosition(position: (AppDelegate.sharedManagers()?.userManager.getLibrary().count ?? 1) - 1)
            return;
        }
        self.playAudioFromPosition(position: (self.position - 1) % (AppDelegate.sharedManagers()?.userManager.getLibrary().count ?? 1))
    }
    
    private func addForwardButtonToCommandCenter(commandCenter: MPRemoteCommandCenter)
    {
        commandCenter.nextTrackCommand.addTarget
        {
            [unowned self] event in
            self.handleForwardButtonPressed()
            return .success
        }
    }
    
    func handleForwardButtonPressed()
    {
        self.playNextSong();
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        if(!repeatModeEnabled)
        {
            if(shuffleModeEnabled)
            {
                self.playNextSongFromShuffleQueue()
            }
            else
            {
                self.playNextSong()
            }
        }
    }
    
    private func playNextSong()
    {
        self.playAudioFromPosition(position: (self.position + 1) % (AppDelegate.sharedManagers()?.userManager.getLibrary().count ?? 1))
    }
    
    private func playNextSongFromShuffleQueue()
    {
        self.buildShuffleQueueIfEmpty()
        let shuffleQueueIndex : Int = shuffleQueue!.firstIndex(of: self.position) ?? 0
        let newPosition = shuffleQueue![(shuffleQueueIndex+1) % (self.shuffleQueue?.count ?? 1)]
        self.playAudioFromPosition(position: newPosition)
    }
    
    func handleShuffleButtonPressed()
    {
        shuffleModeEnabled = !shuffleModeEnabled
        self.buildShuffleQueueIfEmpty()
        delegate?.changeShuffleButton(image: UIImage(named: shuffleModeEnabled ? "MusicPlayerShuffleOn" : "MusicPlayerShuffleOff") ?? UIImage())
    }
    
    func buildShuffleQueueIfEmpty()
    {
        if(shuffleQueue == nil)
        {
            self.buildShuffleQueue()
        }
    }
    
    func buildShuffleQueue()
    {
        shuffleQueue = []
        for i in 0...((AppDelegate.sharedManagers()?.userManager.getLibrary().count ?? 1) - 1)
        {
            shuffleQueue?.append(i)
        }
        shuffleQueue?.shuffle()
    }
    
    func clearShuffleQueue()
    {
        self.shuffleQueue = nil
    }

    
    private func addSeekingToCommandCenter(commandCenter: MPRemoteCommandCenter)
    {
        commandCenter.changePlaybackPositionCommand.addTarget
        {
            [unowned self] event in
            let time = (event as? MPChangePlaybackPositionCommandEvent)?.positionTime ?? 0
            self.handleSeekToTime(time: time)
            return .success
        }
    }
    
    func handleSeekToTime(time : TimeInterval)
    {
        self.audioPlayer.currentTime = time
        self.updateMetaData()
    }
    
    func handleRepeatButtonPressed()
    {
        repeatModeEnabled = !repeatModeEnabled
        self.audioPlayer.numberOfLoops = repeatModeEnabled ? -1 : 1
        delegate?.changeRepeatButton(image: UIImage(named: repeatModeEnabled ? "MusicPlayerRepeatOn" : "MusicPlayerRepeatOff") ?? UIImage())
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?)
    {
        if let error = error
        {
            AppDelegate.sharedManagers()?.errorManager.handleError(error: error)
        }
    }
    
    func updateMetaData()
    {
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = self.currentSong;
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer.currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = audioPlayer.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = audioPlayer.rate
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
