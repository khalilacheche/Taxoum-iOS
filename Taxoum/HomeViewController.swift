
import UIKit
import Lottie

class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let taxiAnimationView = LOTAnimationView(name: "TaxiAnimation")
        self.view.addSubview(taxiAnimationView)
        taxiAnimationView.contentMode = .scaleAspectFill
        taxiAnimationView.frame =  CGRect(x: 0 , y: 337, width: self.view.frame.size.width,height: 215)
        taxiAnimationView.loopAnimation = true
        taxiAnimationView.play()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
