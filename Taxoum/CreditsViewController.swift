//
//  CreditsViewController.swift
//  Taxoum
//
//  Created by Amir Braham on 4/15/18.
//  Copyright © 2018 JKTronix. All rights reserved.
//

import UIKit

class CreditsViewController: UIViewController {

    @IBAction func openLink(_ sender: UIButton) {
        UIApplication.shared.openURL(NSURL(string: "http://destination-tunis.fr/les-taxis-jaunes-en-tunisie")! as URL)

    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func goBack(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DepartureDestinationVC")
        self.present(vc!,animated: true)
    }
    

}
