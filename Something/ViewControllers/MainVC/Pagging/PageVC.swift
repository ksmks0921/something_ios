//
//  PageVC.swift
//  Something
//
//  Created by Maninder Singh on 17/02/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//


import UIKit
import FAPanels

class PageVC: UIPageViewController {
    
    // MARK: - IBOutlets
    
    
    // MARK: - Variables
    var indexOfLastVC = 0
    var pageControl = UIPageControl.appearance()
    lazy var orderedViewControllers: [UIViewController] = {
        return [self.newVc(viewController: "FirstPageVC"),
                self.newVc(viewController: "SecondPageVC"),
                self.newVc(viewController: "ThirdPageVC")]
    }()
    
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("next"), object: nil)
        self.view.backgroundColor = defaultColor
        self.dataSource = self
        self.delegate = self
        self.configurePageControl()
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],direction: .forward,animated: true,completion: nil)
        }
    }
    
    // MARK: - IBActions
    
    
    // MARK: - Custom Methods
    
    func newVc(viewController: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController)
    }
    
    @objc func methodOfReceivedNotification(notification: Notification){
        indexOfLastVC = indexOfLastVC + 1
        if indexOfLastVC == 3 {
            //            let VC = self.storyboard?.instantiateViewController(withIdentifier: "NAVC")
            //            let app = UIApplication.shared.delegate as! AppDelegate
            //            app.window?.rootViewController = VC
            
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "PannelVC") as! FAPanelController
            let leftMenuVC = self.storyboard?.instantiateViewController(withIdentifier: "SideMenuVC") as! SideMenuVC
            let rightMenuVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            let centerNavVC = UINavigationController(rootViewController: rightMenuVC)
            centerNavVC.isNavigationBarHidden = true
            VC.configs.shadowColor = UIColor.black.cgColor
            VC.configs.shadowOffset = CGSize(width: 10.0, height: 200.0)
            VC.configs.shadowOppacity = 0.5
            VC.configs.leftPanelGapPercentage = 0.75
            _ = VC.center(centerNavVC).left(leftMenuVC)
            
            self.navigationController?.pushViewController(VC, animated: true)
        }else{
            
            let startingViewController = self.orderedViewControllers[indexOfLastVC]
            self.pageControl.currentPage = indexOfLastVC
            let viewControllers: [UIViewController] = [startingViewController]
            self.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
        }
        
    }
    
    func configurePageControl() {
        pageControl = UIPageControl(frame: CGRect(x: 0,y: 40 ,width: UIScreen.main.bounds.width,height: 50))
        self.pageControl.numberOfPages = orderedViewControllers.count
        self.pageControl.currentPage = 0
        self.pageControl.backgroundColor = defaultColor
        self.pageControl.tintColor = UIColor.black
        self.pageControl.pageIndicatorTintColor = UIColor.white
        self.pageControl.currentPageIndicatorTintColor = UIColor.black
        self.view.addSubview(pageControl)
    }
}

// MARK: - UIPageView controller methods
extension PageVC : UIPageViewControllerDelegate , UIPageViewControllerDataSource{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return nil
        }
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        return orderedViewControllers[previousIndex]
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        return orderedViewControllers[nextIndex]
    }
    
    
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed{
            let pageContentViewController = pageViewController.viewControllers![0]
            indexOfLastVC = orderedViewControllers.index(of: pageContentViewController)!
            self.pageControl.currentPage = orderedViewControllers.index(of: pageContentViewController)!
        }else{
            print(indexOfLastVC)
        }
        
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        let indexComming = orderedViewControllers.index(of: pendingViewControllers[0])!
    }
    
}

