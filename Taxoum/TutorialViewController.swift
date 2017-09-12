//
//  TutorialViewController.swift
//  Taxoum
//
//  Created by Amir Braham on 9/12/17.
//  Copyright © 2017 JKTronix. All rights reserved.
//

import UIKit
import Lottie

class TutorialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let taxiAnimationView = LOTAnimationView(name: "TaxiAnimation")
        self.view.addSubview(taxiAnimationView)
        taxiAnimationView.contentMode = .scaleAspectFill
        taxiAnimationView.frame =  CGRect(x: 0 , y: 140, width: self.view.frame.size.width,height: 215)
        taxiAnimationView.loopAnimation = true
        taxiAnimationView.play()
        
        let swipeAnimationView = LOTAnimationView(name: "swipe_up")
        self.view.addSubview(swipeAnimationView)
        swipeAnimationView.contentMode = .scaleAspectFill
        swipeAnimationView.frame =  CGRect(x: 145 , y: 450, width: 90,height: 45)
        swipeAnimationView.transform = CGAffineTransform(rotationAngle: 1.5708);
        swipeAnimationView.loopAnimation = true
        swipeAnimationView.play()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
