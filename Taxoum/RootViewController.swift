//
//  UIPageViewController.swift
//  Taxoum
//
//  Created by Amir Braham on 9/13/17.
//  Copyright © 2017 JKTronix. All rights reserved.
//

import UIKit

class RootViewController: UIPageViewController , UIPageViewControllerDataSource {

    var viewControllersList : [UIViewController] =  {
        let sb = UIStoryboard(name : "Main", bundle: nil)
        let welcomeVC = sb.instantiateViewController(withIdentifier: "welcomeVC")
        let DepartureDestinationVC = sb.instantiateViewController(withIdentifier: "DepartureDestinationVC")
        
        return [welcomeVC,DepartureDestinationVC]
    }()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        
        
        if let firstVC = viewControllersList.first {
            self.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
    
    
    }

    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = viewControllersList.index(of: viewController) else {return nil}
        guard vcIndex - 1 >= 0 else {return nil}
        guard viewControllersList.count > vcIndex - 1 else {return nil}
        
        return viewControllersList[vcIndex - 1 ]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = viewControllersList.index(of: viewController) else {return nil}
        guard vcIndex + 1 <= viewControllersList.count else {return nil}
        guard viewControllersList.count != vcIndex + 1 else {return nil}
        guard viewControllersList.count > vcIndex + 1 else {return nil}
        return viewControllersList[vcIndex + 1]
    }

}
