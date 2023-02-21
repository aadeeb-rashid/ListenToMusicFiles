//
//  AudioPlayerViewController.swift
//  ListenToMusicFiles
//
//  Created by aadeeb rashid on 1/23/23.
//

import UIKit
import AVFAudio
class AudioPlayerViewController: UIViewController, NeedsMusicInfoDelegate
{
    

    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var trackSlider: UISlider!
    
    private var trackTimer : Timer = Timer()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        AppDelegate.sharedManagers()?.audioManager.setDelegate(viewController: self)
        titleLabel.text = " ";
        self.initRepeatandShuffleButtons()
    }
    
    private func initRepeatandShuffleButtons()
    {
        self.initRepeatButton()
        self.initShuffleButton()
    }

    private func initRepeatButton()
    {
        if(!AppDelegate.sharedManagers()!.audioManager.getRepeatMode())
        {
            self.repeatButton.setBackgroundImage(UIImage(named: "MusicPlayerRepeatOff"), for: .normal)
            return;
        }
        self.repeatButton.setBackgroundImage(UIImage(named: "MusicPlayerRepeatOn"), for: .normal)
    }
    
    private func initShuffleButton()
    {
        if(!(AppDelegate.sharedManagers()?.audioManager.getShuffleMode() ?? false))
        {
            self.shuffleButton.setBackgroundImage(UIImage(named: "MusicPlayerShuffleOff"), for: .normal)
            return;
        }
        self.shuffleButton.setBackgroundImage(UIImage(named: "MusicPlayerShuffleOn"), for: .normal)
    }
    
    @IBAction func didPressRewindButton(_ sender: UIButton)
    {
        AppDelegate.sharedManagers()?.audioManager.handleRewindButtonPressed()
    }
    
    @IBAction func didPressPauseButton(_ sender: UIButton)
    {
        AppDelegate.sharedManagers()?.audioManager.handlePlayPauseButtonPressed()
    }

    @IBAction func didPressForwardButton(_ sender: UIButton)
    {
        AppDelegate.sharedManagers()?.audioManager.handleForwardButtonPressed()
    }
    
    @IBAction func didPressRepeatButton(_ sender: UIButton)
    {
        AppDelegate.sharedManagers()?.audioManager.handleRepeatButtonPressed()
    }
    
    @IBAction func didPressShuffleButton(_ sender: UIButton)
    {
        AppDelegate.sharedManagers()?.audioManager.handleShuffleButtonPressed()
    }
    
    
    @IBAction func didSeek(_ sender: UISlider)
    {
        AppDelegate.sharedManagers()?.audioManager.handleSeekToTime(time: TimeInterval(sender.value + 1))
    }
    
    @objc func updateTimerLabels(_ timer: Timer)
    {
        AppDelegate.sharedManagers()?.audioManager.updateMetaData()
        let progress : Float = Float(AppDelegate.sharedManagers()?.audioManager.getAudioPlayerTime() ?? 0) + 0.7;
        self.trackSlider.setValue(progress, animated: false)
        self.currentTimeLabel.text = String(format: "%d:%.2d", Int(progress) / 60, (Int(progress) % 60))
    }
    
    func initializeAudioPlayerScreenFromSongDuration(duration: TimeInterval)
    {
        trackTimer.invalidate()
        self.trackSlider.minimumValue = 0;
        self.trackSlider.maximumValue = Float(duration);
        self.trackSlider.setValue(0, animated: false)
        self.currentTimeLabel.text = "0:00"
        self.totalTimeLabel.text = String(format: "%d:%.2d", Int(duration) / 60, (Int(duration) % 60))
        trackTimer =  Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.updateTimerLabels), userInfo: nil, repeats: true)
    }
    
    func setTitle(title: String)
    {
        self.titleLabel.text = title
    }
    
    func changePlayPauseButton(image: UIImage)
    {
        self.pauseButton.setBackgroundImage(image, for: .normal)
    }
    
    func changeRepeatButton(image: UIImage)
    {
        self.repeatButton.setBackgroundImage(image, for: .normal)
    }
    
    func changeShuffleButton(image: UIImage)
    {
        self.shuffleButton.setBackgroundImage(image, for: .normal)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        AppDelegate.sharedManagers()?.audioManager.stopPlaying()
    }
    

}
