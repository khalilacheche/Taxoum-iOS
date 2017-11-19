import UIKit

class testViewController: UIViewController {
    @IBOutlet weak var subView: UIView!
    
    
    @IBAction func up(_ sender: UISwipeGestureRecognizer) {
        switched(s: false)
    }
    @IBAction func down(_ sender: UISwipeGestureRecognizer) {
        switched(s: true)
    }
    func switched(s: Bool){
        //print(self.subView.frame.origin.y)
        let origin: CGFloat = s ? view.frame.height-200 : 250
        UIView.animate(withDuration: 0.35) {
            self.subView.frame.origin.y = origin
        }
        //print(self.subView.frame.origin.y)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        

    }

}
