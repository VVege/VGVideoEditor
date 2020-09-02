//
//  ViewController.swift
//  VGVideoEditor
//
//  Created by 周智伟 on 2020/9/1.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var player:LHVideoEditPlayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let path = Bundle.main.path(forResource: "test2", ofType: "mp4")
        let source = LHVideoRootSource.init(videoPath: path!)
        
        let path1 = Bundle.main.path(forResource: "test3", ofType: "mp4")
        let subSource = LHVideoSubSource.init(videoPath: path1!)
        
        source.append(subSource: subSource)
        
        player = LHVideoEditPlayer.init(source: source)
        player.layer.frame = CGRect(x: 100, y: 100, width: 200, height: 200)
        view.layer.addSublayer(player.layer)
        player.play()
    }
}

