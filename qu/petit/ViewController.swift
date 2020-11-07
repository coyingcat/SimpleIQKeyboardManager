//
//  ViewController.swift
//  petit
//
//  Created by Jz D on 2020/10/16.
//  Copyright © 2020 Jz D. All rights reserved.
//

import UIKit


import AVFoundation


import RxSwift
import RxCocoa

import NSObject_Rx

class ViewController: UIViewController {
    
    
    
    @IBOutlet weak var playB: UIButton!
    
    
    var isSelected = false
    
    @IBOutlet weak var progress: UISlider!
    
    
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var timeTotal: UILabel!
    
    
    @IBOutlet weak var intervalTwoB: UIButton!
    
    
    @IBOutlet weak var intervalThreeB: UIButton!
    
    
    @IBOutlet weak var timeTwoB: UIButton!
    
    
    @IBOutlet weak var timeThreeB: UIButton!
    
    lazy var audioStream: Streamer = {
        let streamer = Streamer()
        streamer.delegate = self
        return streamer
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        audioStream.url = Bundle.main.url(forResource: "test", withExtension: "wav")
        forUI()
        forPanel()
      //  calculateI()
    }
    
    
    
    
    func forUI(){
        view.backgroundColor = UIColor.white
        playB.play()
        
        playB.addTarget(self, action: #selector(doPlay), for: .touchUpInside)
      //  playB.titleLabel?.font = UIFont.regular(ofSize: 24)
        
        
        //
        
        progress.value = 0
        progress.rx.controlEvent([.touchDown]).subscribe(onNext: { [weak self]  () in
            // 感觉有一个订阅刷新
            guard let `self` = self else { return }
            print(11)
            self.toPause()
        }).disposed(by: rx.disposeBag)
        
        
        
        progress.rx.controlEvent([.touchUpInside, .touchUpOutside, .touchCancel]).subscribe(onNext: { [weak self]  () in
            guard let `self` = self else { return }
            print(33)
            self.toPlay()
        }).disposed(by: rx.disposeBag)
        
        
        
        progress.rx.value.subscribe(onNext: { [weak self]  (value) in
            guard let `self` = self else { return }
            let v = Double(value)
            print(22)
            UserSetting.shared.currentTime = v
            self.currentTime.text = v.mmSS
        }).disposed(by: rx.disposeBag)
 
 
    
    }
    
    
    
    func forPanel(){
        intervalTwoB.sideNormal()
        intervalThreeB.sideNormal()
        
        
        timeTwoB.sideNormal()
        timeThreeB.sideNormal()
        
        
        
        intervalTwoB.rx.tap.subscribe(onNext: { () in
            
            self.intervalTwoB.isSelected.toggle()
            self.intervalThreeB.isSelected = false
            
            
            self.intervalTwoB.sideToggle()
            self.intervalThreeB.sideNormal()
            self.audioStream.shutUp.delay(two: self.intervalTwoB.isSelected)
            
        }).disposed(by: rx.disposeBag)
        
        
        intervalThreeB.rx.tap.subscribe(onNext: { () in
            
            self.intervalThreeB.isSelected.toggle()
            self.intervalTwoB.isSelected = false
            
            
            self.intervalThreeB.sideToggle()
            self.intervalTwoB.sideNormal()
            
            self.audioStream.shutUp.delay(three: self.intervalThreeB.isSelected)
            
        }).disposed(by: rx.disposeBag)
        
        
        timeTwoB.rx.tap.subscribe(onNext: { () in
            
            self.timeTwoB.isSelected.toggle()
            self.timeThreeB.isSelected = false
            
            
            self.timeTwoB.sideToggle()
            self.timeThreeB.sideNormal()
            self.audioStream.shutUp.twoTime(hit: self.timeTwoB.isSelected)
        }).disposed(by: rx.disposeBag)
        
        
        timeThreeB.rx.tap.subscribe(onNext: { () in
            
            self.timeThreeB.isSelected.toggle()
            self.timeTwoB.isSelected = false
            
            
            self.timeThreeB.sideToggle()
            self.timeTwoB.sideNormal()
           
            self.audioStream.shutUp.threeTime(hit: self.timeThreeB.isSelected)
        }).disposed(by: rx.disposeBag)
        
        
        
    }
    
    
    
    @objc
    func doPlay(){
        isSelected.toggle()
        if isSelected{
            
            playB.pause()
            toPlay()
        }
        else{
            playB.play()
            toPause()
        }
        
        
    }
    
    
    
    func toPlay(){
        audioStream.climb(to: UserSetting.shared.currentTime)
    }
    
    func toPause(){
       audioStream.firstPause = true
       audioStream.pauseS()
    }
   
    
    
    func config(duration t: Double){
        progress.minimumValue = 0
        progress.maximumValue = Float(t)
        progress.value = Float(UserSetting.shared.currentTime)
        timeTotal.text = t.mmSS
        
        
        timeTotal.isHidden = false
        currentTime.text = UserSetting.shared.currentTime.mmSS
        currentTime.isHidden = false
    }
    
    
    
}






