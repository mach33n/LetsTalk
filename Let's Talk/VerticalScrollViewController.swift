//
//  MiddleScrollViewController.swift
//  SnapchatSwipeView
//
//  Created by Jake Spracher on 12/14/15.
//  Copyright © 2015 Jake Spracher. All rights reserved.
//

import UIKit

class VerticalScrollViewController: UIViewController, SnapContainerViewControllerDelegate {
    var middleVc: UIViewController!
    var scrollView: UIScrollView!
    
    class func verticalScrollVcWith(middleVc: UIViewController) -> VerticalScrollViewController {
        let middleScrollVc = VerticalScrollViewController()
        
        middleScrollVc.middleVc = middleVc
        
        return middleScrollVc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view:
        setupScrollView()
    }
    
    func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        
        let view = (
            x: self.view.bounds.origin.x,
            y: self.view.bounds.origin.y,
            width: self.view.bounds.width,
            height: self.view.bounds.height
        )
        
        scrollView.frame = CGRect(x: view.x, y: view.y, width: view.width, height: view.height)
        self.view.addSubview(scrollView)
        
        let scrollWidth: CGFloat  = view.width
        var scrollHeight: CGFloat
        
        if middleVc != nil {
            scrollHeight  = 2 * view.height
            middleVc.view.frame = CGRect(x: 0, y: view.height, width: view.width, height: view.height)
            
            addChildViewController(middleVc)
            
            scrollView.addSubview(middleVc.view)
            
            middleVc.didMove(toParentViewController: self)
            
            scrollView.contentOffset.y = middleVc.view.frame.origin.y
            
        } else if middleVc == nil {
            scrollHeight  =  view.height
            middleVc.view.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
            
            addChildViewController(middleVc)
            scrollView.addSubview(middleVc.view)
            
            middleVc.didMove(toParentViewController: self)
            
            scrollView.contentOffset.y = 0

        } else {
            scrollHeight  = view.height
            middleVc.view.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
            
            addChildViewController(middleVc)
            scrollView.addSubview(middleVc.view)
            middleVc.didMove(toParentViewController: self)
        }
        
        scrollView.contentSize = CGSize(width: scrollWidth, height: scrollHeight)
    }

    // MARK: - SnapContainerViewControllerDelegate Methods
    
    func outerScrollViewShouldScroll() -> Bool {
        if scrollView.contentOffset.y < middleVc.view.frame.origin.y || scrollView.contentOffset.y > 2*middleVc.view.frame.origin.y {
            return false
        } else {
            return true
        }
    }
    
}
