//
//  DestinationViewController.swift
//  Taxoum
//
//  Created by Amir Braham on 9/14/17.
//  Copyright © 2017 JKTronix. All rights reserved.
//

import UIKit
import Lottie
class DestinationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        let locationAnimationView = LOTAnimationView(name: "location")
        self.view.addSubview(locationAnimationView)
        locationAnimationView.contentMode = .scaleAspectFill
        locationAnimationView.frame =  CGRect(x: 87 , y: 364, width: 200,height: 180)
        locationAnimationView.loopAnimation = true
        locationAnimationView.play()
    }

}
