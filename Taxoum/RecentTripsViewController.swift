//
//  RecentTripsViewController.swift
//  Taxoum
//
//  Created by Amir Braham on 4/2/18.
//  Copyright © 2018 JKTronix. All rights reserved.
//

import UIKit

class RecentTripsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("hello")
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        label.center = CGPoint(x: 160, y: 285)
        label.textAlignment = .center
        label.text = "I'am a test label"
        self.view.addSubview(label)
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
