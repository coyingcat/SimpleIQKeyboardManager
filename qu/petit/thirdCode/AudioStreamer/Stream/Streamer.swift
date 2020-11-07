//
//  Streamer.swift
//  AudioStreamer
//
//  Created by Syed Haris Ali on 6/5/18.
//  Copyright © 2018 Ausome Apps LLC. All rights reserved.
//

import AVFoundation
import Foundation
import os.log






/// The `Streamer` is a concrete implementation of the `Streaming` protocol and is intended to provide a high-level, extendable class for streaming an audio file living at a URL on the internet. Subclasses can override the `attachNodes` and `connectNodes` methods to insert custom effects.




open class Streamer: Streaming {
    
    var timeNode: [TimeInterval] = [3.218,
        7.029,
        10.618,
        14.35,
        18.13,
        21.844,
        25.587,
        29.433,
        33.157,
        36.78,
        40.569,
        44.442,
        48.119,
        49.626,
        51.185,
        52.708,
        54.21,
        55.759,
        57.27,
        58.797,
        60.332,
        61.908,
        63.358,
        64.873,
        66.385,
        70.295
    ]
    
    
    var firstPause = false
    
    
    
    static let logger = OSLog(subsystem: "com.fastlearner.streamer", category: "Streamer")

    // MARK: - Properties (Streaming)
    
    public var currentTime: TimeInterval{
        guard let nodeTime = playerNode.lastRenderTime,
            let playerTime = playerNode.playerTime(forNodeTime: nodeTime) else {
            return currentTimeOffset
        }
        let currentTime = TimeInterval(playerTime.sampleTime) / playerTime.sampleRate
        return currentTime + currentTimeOffset
    }
    
    
    
    public var delegate: StreamingDelegate?
    public internal(set) var duration: TimeInterval?
 
    public internal(set) var parseEmpty: Parsing?
    
    public internal(set) var parser: Parsing?
    public internal(set) var reader: Reading?
    
    
    public internal(set) var silence: Reading?
    
    public let engine = AVAudioEngine()
    public let playerNode = AVAudioPlayerNode()
    public internal(set) var stateDeng: StreamingState = .stopped {
        didSet {
            delegate?.streamer(dng: self, changedState: stateDeng)
        }
    }
    
    
    var shutUp = AudioRecord()
    
    
    public var url: URL? {
        didSet {
            resetDng()

            if let src = url {
                do {
                    let data = try Data(contentsOf: src)
                    load(didReceiveData: data)
                } catch {
                    print(error)
                }
                
                
            }
        }
    }
    
    
    
    
    
    
    public var volume: Float {
        get {
            engine.mainMixerNode.outputVolume
        }
        set {
            engine.mainMixerNode.outputVolume = newValue
        }
    }
    var volumeRampTimer: Timer?
    var volumeRampTargetValue: Float = 1

    // MARK: - Properties
    
    /// A `TimeInterval` used to calculate the current play time relative to a seek operation.
    var currentTimeOffset: TimeInterval = 0
    
    /// A `Bool` indicating whether the file has been completely scheduled into the player node.
    var isFileSchedulingComplete = false

    // MARK: - Lifecycle
    
    public init() {
        // Setup the audio engine (attach nodes, connect stuff, etc). No playback yet.
        // Create a new parser
        do {
            parseEmpty = try Parser()
        } catch {
            os_log("Failed to create parser: %@", log: Streamer.logger, type: .error, error.localizedDescription)
        }
        loadEmpty()
        setupAudioEngine()
        
    }

    // MARK: - Setup

    func setupAudioEngine() {
        os_log("%@ - %d", log: Streamer.logger, type: .debug, #function, #line)

        // Attach nodes
        attachNodes()

        // Node nodes
        connectNodes()

        // Prepare the engine
        engine.prepare()
        
        /// Use timer to schedule the buffers (this is not ideal, wish AVAudioEngine provided a pull-model for scheduling buffers)
        print("intervalD", intervalD)
        let timer = Timer(timeInterval: intervalD, repeats: true) {
            [weak self] _ in
            guard self?.stateDeng != .stopped else {
                return
            }
            
            self?.scheduleNextBuffer()
            self?.handleTimeUpdate()
            self?.notifyTimeUpdated()
        }
        RunLoop.current.add(timer, forMode: .common)
    }

    /// Subclass can override this to attach additional nodes to the engine before it is prepared. Default implementation attaches the `playerNode`. Subclass should call super or be sure to attach the playerNode.
    open func attachNodes() {
        engine.attach(playerNode)
    }

    /// Subclass can override this to make custom node connections in the engine before it is prepared. Default implementation connects the playerNode to the mainMixerNode on the `AVAudioEngine` using the default `readFormat`. Subclass should use the `readFormat` property when connecting nodes.
    open func connectNodes() {
        engine.connect(playerNode, to: engine.mainMixerNode, format: readFormat)
    }
    
    // MARK: - Reset
    
    func resetDng() {
        os_log("%@ - %d", log: Streamer.logger, type: .debug, #function, #line)
        
        // Reset the playback state
        stopDng()
        duration = nil
        reader = nil
        isFileSchedulingComplete = false
        
        // Create a new parser
        do {
            parser = try Parser()
        } catch {
            os_log("Failed to create parser: %@", log: Streamer.logger, type: .error, error.localizedDescription)
        }
    }
    
    // MARK: - Methods
    
    public func playS() {
        os_log("%@ - %d", log: Streamer.logger, type: .debug, #function, #line)
        
        // Check we're not already playing
        guard !playerNode.isPlaying else {
            return
        }
        
        if !engine.isRunning {
            do {
                try engine.start()
            } catch {
                os_log("Failed to start engine: %@", log: Streamer.logger, type: .error, error.localizedDescription)
            }
        }
        
        // To make the volume change less harsh we mute the output volume
        volume = 0
        
        // Start playback on the player node
        playerNode.play()
        
        // After 250ms we restore the volume to where it was
        swellVolume()
        
        // Update the state
        stateDeng = .playing
    }
    
    public func pauseS() {
        os_log("%@ - %d", log: Streamer.logger, type: .debug, #function, #line)
        
        // Check if the player node is playing
        guard playerNode.isPlaying else {
            return
        }
        volume = 0
        // Pause the player node and the engine
        playerNode.pause()
        
        // Update the state
        stateDeng = .paused
    }
    
    public func stopDng() {
        os_log("%@ - %d", log: Streamer.logger, type: .debug, #function, #line)
        
        // Stop the downloader, the player node, and the engine
   
        playerNode.stop()
        engine.stop()
        
        // Update the state
        stateDeng = .stopped
    }
    
    
    
    
    
    
    
    
    public
    func seek(to time: TimeInterval) throws {
        os_log("%@ - %d [%.1f]", log: Streamer.logger, type: .debug, #function, #line, time)
        
        // Make sure we have a valid parser and reader
        guard let parser = parser, let reader = reader else {
            return
        }
        
        // Get the proper time and packet offset for the seek operation
        guard let frameOffset = parser.frameOffset(forTime: time),
            let packetOffset = parser.packetOffset(forFrame: frameOffset) else {
                return
        }
        currentTimeOffset = time
        isFileSchedulingComplete = false
        
        // We need to store whether or not the player node is currently playing to properly resume playback after
        let isPlaying = playerNode.isPlaying
        
        // Stop the player node to reset the time offset to 0
        
        
        // 栈，排空
        playerNode.stop()
        volume = 0
        
        // Perform the seek to the proper packet offset
        do {
            try reader.seek(packetOffset)
        } catch {
            os_log("Failed to seek: %@", log: Streamer.logger, type: .error, error.localizedDescription)
            return
        }
        
        // If the player node was previous playing then resume playback
        if isPlaying {
            playerNode.play()
        }
        
        // Update the current time
        delegate?.streamer(fire: self, updatedCurrentTime: time)
        
        swellVolume()
    }
    
    
    
    
    func swellVolume(){
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(420)) { [unowned self] in
            self.volumeRampTimer?.invalidate()
            let timer = Timer(timeInterval: Double( 0.25 / (self.volumeRampTargetValue * 10)), repeats: true) { timer in
                if self.volume != self.volumeRampTargetValue {
                    self.volume = self.volumeRampTargetValue
                } else {
                    self.volumeRampTimer = nil
                    timer.invalidate()
                }
            }
            RunLoop.current.add(timer, forMode: .common)
            self.volumeRampTimer = timer
        }
    }

    
    
    
    
    // MARK: - Scheduling Buffers

    func scheduleNextBuffer() {
        guard let reader = reader else {
            os_log("No reader yet...", log: Streamer.logger, type: .debug)
            return
        }

        
        guard shutUp.pauseWork == false else {
            if firstPause == false, Date().timeIntervalSince(shutUp.currentMoment) >= shutUp.stdPauseT{
                
                playS()
                shutUp.pauseWork = false
            }
            
            return
        }
        
        print("currentTime: ", currentTime)
        var shouldReturn = false
        
        let i = shutUp.current
        let count = timeNode.count
        
        
        if shutUp.toClimb{

            if shutUp.howMany < shutUp.countStdRepeat{
                print("i:   ", i)
                if i < count, currentTime > timeNode[i]{
                    shutUp.howMany += 1
                    if i == 0{
                        try? seek(to: 0)
                    }
                    else{
                        try? seek(to: timeNode[i - 1])
                    }
                    shouldReturn = true
                }
            }
            else{
                shutUp.toClimb = false
            }

        }
        else {
            
            print("i:   ", i)
            if i < count, currentTime > timeNode[i]{
                shutUp.doPause(at: i)
                pauseS()
                
                shouldReturn = true
            }
            
            
        }
        
        guard shouldReturn == false else {
            return
        }
        // 文件，读完了，就不要再继续调度了
        guard !isFileSchedulingComplete else {
            return
        }
        
        
        do {
            
            let nextScheduledBuffer = try reader.read(readBufferSize)
    
            // 这个方法，很有意思，timer 给他塞的 buffer, 比他自己消费的速度， 快多了
            playerNode.scheduleBuffer(nextScheduledBuffer)
        } catch ReaderError.reachedEndOfFile {
            os_log("Scheduler reached end of file", log: Streamer.logger, type: .debug)
            isFileSchedulingComplete = true
        } catch {
            os_log("Cannot schedule buffer: %@", log: Streamer.logger, type: .debug, error.localizedDescription)
        }
    }

    // MARK: - Handling Time Updates
    
    /// Handles the duration value, explicitly checking if the duration is greater than the current value. For indeterminate streams we can accurately estimate the duration using the number of packets parsed and multiplying that by the number of frames per packet.
    func handleDurationUpdate() {
        if let newDuration = parser?.duration {
            // Check if the duration is either nil or if it is greater than the previous duration
            var shouldUpdate = false
            if duration == nil {
                shouldUpdate = true
            } else if let oldDuration = duration, oldDuration < newDuration {
                shouldUpdate = true
            }
            
            // Update the duration value
            if shouldUpdate {
                self.duration = newDuration
                notifyDurationUpdate(newDuration)
            }
        }
    }
    
    /// Handles the current time relative to the duration to make sure current time does not exceed the duration
    func handleTimeUpdate() {
        guard let duration = duration else {
            return
        }

        if currentTime >= duration {
            try? seek(to: 0)
            stateDeng = .over
            // 弹奏完成
            pauseS()
            
        }
    }

 

    func notifyDurationUpdate(_ duration: TimeInterval) {
        guard let _ = url else {
            return
        }

        delegate?.streamer(self, updatedDuration: duration)
    }

    func notifyTimeUpdated() {
        guard engine.isRunning, playerNode.isPlaying else {
            return
        }

        delegate?.streamer(fire: self, updatedCurrentTime: currentTime)
    }
}






extension Streamer {
    
  

    
    public func load(didReceiveData data: Data) {
        os_log("%@ - %d", log: Streamer.logger, type: .debug, #function, #line)

        guard let parser = parser else {
            os_log("Expected parser, bail...", log: Streamer.logger, type: .error)
            return
        }
        
        /// Parse the incoming audio into packets
        do {
            try parser.parse(data: data)
        } catch {
            os_log("Failed to parse: %@", log: Streamer.logger, type: .error, error.localizedDescription)
        }
        
        /// Once there's enough data to start producing packets we can use the data format
        if reader == nil, let _ = parser.dataFormat {
            do {
                reader = try Reader(parser: parser, readFormat: readFormat)
            } catch {
                os_log("Failed to create reader: %@", log: Streamer.logger, type: .error, error.localizedDescription)
            }
        }
        
        /// Update the progress UI
        DispatchQueue.main.async {
            [weak self] in
            
            
            // Check if we have the duration
            self?.handleDurationUpdate()
        }
    }
    
    
    
    
    
    func climb(to time: TimeInterval){
        
        firstPause = false
        
        
        
        calculateI()
        
        try? seek(to: time)
        
        playS()
        
    }
}







extension Streamer {
    
    func calculateI(){
          var i = 0
          let count = timeNode.count
          let current = UserSetting.shared.currentTime
          while i < count{
              if current > timeNode[i]{
                  i += 1
              }
              else{
                  break
              }
          }
          shutUp.current = max(0, i - 1)
      }

    
    public func loadEmpty(){
        
        guard let parser = parseEmpty, let src = Bundle.main.url(forResource: "out", withExtension: "wav") else {
            os_log("Expected parser, bail...", log: Streamer.logger, type: .error)
            return
        }
        
        /// Parse the incoming audio into packets
        do {
            let data = try Data(contentsOf: src)
            try parser.parse(data: data)
        } catch {
            os_log("Failed to parse: %@", log: Streamer.logger, type: .error, error.localizedDescription)
        }
        
        /// Once there's enough data to start producing packets we can use the data format
        if silence == nil, let _ = parser.dataFormat {
            do {
                silence = try Reader(parser: parser, readFormat: readFormat)
            } catch {
                os_log("Failed to create reader: %@", log: Streamer.logger, type: .error, error.localizedDescription)
            }
        }
    
    }
    
}




// 计算 音频分配 buffer, 累计时间长度

