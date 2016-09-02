//
//  TutorialPageViewController.swift
//  UIPageViewController Post
//
//  Created by Jeffrey Burt on 12/11/15.
//  Copyright © 2015 Atomic Object. All rights reserved.
//

import UIKit

class TutorialPageViewController: UIViewController {
    
    
    
    weak var tutorialDelegate: TutorialPageViewControllerDelegate?
    var currentIndex: Int?
    
    @IBOutlet weak var scrollView: UIScrollView!
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        // The view controllers will be shown in this order
        return [self.newColoredViewController("Picture"),
            self.newColoredViewController("Red"),
            self.newColoredViewController("Blue"),
            self.newColoredViewController("DOB"),
            self.newColoredViewController("Nationality"),
            self.newColoredViewController("Terms")]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        dataSource = self
//        delegate = self
        
//        if let initialViewController = orderedViewControllers.first {
//            scrollToViewController(initialViewController)
//            
//        }
        
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * 6, self.scrollView.frame.size.height)
        self.initViews()
        
        tutorialDelegate?.tutorialPageViewController(self,
            didUpdatePageCount: orderedViewControllers.count)
    }
    
    func initViews() {
        
        for i in 0 ... 5 {
            let viewController = orderedViewControllers[i]
            viewController.view.frame = CGRectMake(self.scrollView.frame.size.width * CGFloat(i), 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)
            self.scrollView.addSubview(viewController.view)
        }
    }
    
    /**
     Scrolls to the next view controller.
     */
//    func scrollToNextViewController() {
//        if let visibleViewController = orderedViewControllers.first,
//            let nextViewController = pageViewController(self,
//                viewControllerAfterViewController: visibleViewController) {
//                    scrollToViewController(nextViewController)
//        }
//    }
//    
//    /**
//     Scrolls to the view controller at the given index. Automatically calculates
//     the direction.
//     
//     - parameter newIndex: the new index to scroll to
//     */
//    func scrollToViewController(index newIndex: Int) {
//        if let firstViewController = viewControllers?.first,
//            let currentIndex = orderedViewControllers.indexOf(firstViewController) {
//                let direction: UIPageViewControllerNavigationDirection = newIndex >= currentIndex ? .Forward : .Reverse
//                let nextViewController = orderedViewControllers[newIndex]
//                scrollToViewController(nextViewController, direction: direction)
//        }
//    }
//    
//    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
//        return UIStatusBarStyle.LightContent
//    }
//    
    private func newColoredViewController(color: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewControllerWithIdentifier("\(color)ViewController")
    }
//
//    /**
//     Scrolls to the given 'viewController' page.
//     
//     - parameter viewController: the view controller to show.
//     */
//    private func scrollToViewController(viewController: UIViewController,
//        direction: UIPageViewControllerNavigationDirection = .Forward) {
//        setViewControllers([viewController],
//            direction: direction,
//            animated: true,
//            completion: { (finished) -> Void in
//                // Setting the view controller programmatically does not fire
//                // any delegate methods, so we have to manually notify the
//                // 'tutorialDelegate' of the new index.
//                self.notifyTutorialDelegateOfNewIndex()
//        })
//    }
//
//    /**
//     Notifies '_tutorialDelegate' that the current page index was updated.
//     */
//    private func notifyTutorialDelegateOfNewIndex() {
//        if let firstViewController = viewControllers?.first,
//            let index = orderedViewControllers.indexOf(firstViewController) {
//                tutorialDelegate?.tutorialPageViewController(self,
//                    didUpdatePageIndex: index)
//        }
//    }
//    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        print(touches)
//    }
//    
//    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        let firstTouch = touches[touches.endIndex] as UITouch
//        let firstlocation = firstTouch.locationInView(self.view)
//        let touch = touches.first
//        let location = touch?.locationInView(self.view)
//        let currentPageAlpha = 1.0 - (location?.x)! / self.view.frame.size.width;
//        let sidePagesAlpha = (location?.x)! / self.view.frame.size.width;
//        var nextIndex = 0;
//        if location!.x > firstlocation.x {
//            nextIndex = currentIndex! + 1
//        }else {
//            nextIndex = currentIndex! - 1;
//        }
//        
//        if currentIndex == 0 {
//            (orderedViewControllers[currentIndex!] as! ProfilePictureViewController).background.alpha = currentPageAlpha
//            (orderedViewControllers[1] as! EmailViewController).background.alpha = sidePagesAlpha
//        }
//    }
    
}

//// MARK: UIPageViewControllerDataSource
//
//extension TutorialPageViewController: UIPageViewControllerDataSource {
//    
//    func pageViewController(pageViewController: UIPageViewController,
//        viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
//            guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
//                return nil
//            }
//            
//            let previousIndex = viewControllerIndex - 1
//            currentIndex = viewControllerIndex;
//        
//            // User is on the first view controller and swiped left to loop to
//            // the last view controller.
//            guard previousIndex >= 0 else {
//                return orderedViewControllers.last
//            }
//            
//            guard orderedViewControllers.count > previousIndex else {
//                return nil
//            }
//            
//            return orderedViewControllers[previousIndex]
//    }
//
//    func pageViewController(pageViewController: UIPageViewController,
//        viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
//            guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
//                return nil
//            }
//            
//            let nextIndex = viewControllerIndex + 1
//            let orderedViewControllersCount = orderedViewControllers.count
//            
//            // User is on the last view controller and swiped right to loop to
//            // the first view controller.
//            guard orderedViewControllersCount != nextIndex else {
//                return orderedViewControllers.first
//            }
//            
//            guard orderedViewControllersCount > nextIndex else {
//                return nil
//            }
//            
//            return orderedViewControllers[nextIndex]
//    }
//    
//}
//
//extension TutorialPageViewController: UIPageViewControllerDelegate {
//    
//    func pageViewController(pageViewController: UIPageViewController,
//        didFinishAnimating finished: Bool,
//        previousViewControllers: [UIViewController],
//        transitionCompleted completed: Bool) {
//        notifyTutorialDelegateOfNewIndex()
//    }
//    
//    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
//        
//        print("asdfasdf")
//    }
//    
//}

protocol TutorialPageViewControllerDelegate: class {
    
    /**
     Called when the number of pages is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter count: the total number of pages.
     */
    func tutorialPageViewController(tutorialPageViewController: TutorialPageViewController,
        didUpdatePageCount count: Int)
    
    /**
     Called when the current index is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter index: the index of the currently visible page.
     */
    func tutorialPageViewController(tutorialPageViewController: TutorialPageViewController,
        didUpdatePageIndex index: Int)
    
}
