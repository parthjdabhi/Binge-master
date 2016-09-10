//
//  TutorialViewController.swift
//  UIPageViewController Post
//
//  Created by Jeffrey Burt on 2/3/16.
//  Copyright © 2016 Seven Even. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var pageControlOption = UIPageControl.self
    var nextIndex: Int=0;
    
    var tutorialPageViewController: TutorialPageViewController? {
        didSet {
            tutorialPageViewController?.tutorialDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.addTarget(self, action: #selector(TutorialViewController.didChangePageControlValue), forControlEvents: .ValueChanged)
        pageControl.numberOfPages = 6
        self.scrollView.delegate = self
        //self.scrollView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width * 6, UIScreen.mainScreen().bounds.size.height)
        self.scrollView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width * 6, 1.0)
        self.initViews()
    }
    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let tutorialPageViewController = segue.destinationViewController as? TutorialPageViewController {
            self.tutorialPageViewController = tutorialPageViewController
        }
    }
    
    var currentIndex: Int? = 0
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        // The view controllers will be shown in this order
        return [self.newColoredViewController("Picture",prevIndex: 0,nextIndex: 1),
                self.newColoredViewController("Red",prevIndex: 0,nextIndex: 2),
                self.newColoredViewController("Blue",prevIndex: 1,nextIndex: 3),
                self.newColoredViewController("DOB",prevIndex: 2,nextIndex: 4),
                self.newColoredViewController("Nationality",prevIndex: 3,nextIndex: 5),
                self.newColoredViewController("Terms",prevIndex: 4,nextIndex: 5)]
    }()
    
    func initViews() {
        
        for i in 0 ... 5 {
            let viewController = orderedViewControllers[i]
            viewController.view.frame = CGRectMake(UIScreen.mainScreen().bounds.size.width * CGFloat(i), 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)
            (viewController as? BaseViewController)?.background.frame = UIScreen.mainScreen().bounds
            (viewController as? BaseViewController)?.view.layoutSubviews()
            //(viewController as? BaseViewController)?.view.layoutIfNeeded()
            
            (viewController as? BaseViewController)?.goBackSelectorClosure = {
                self.navigationController?.popViewControllerAnimated(true)
            }
            self.scrollView.addSubview(viewController.view)
        }
    }
    
    private func newColoredViewController(color: String, prevIndex:Int, nextIndex:Int) -> UIViewController {
        let VC = UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewControllerWithIdentifier("\(color)ViewController") as! BaseViewController
        VC.delegate = self
        VC.goNextSelectorClosure = {
            print("goNextSelectorClosure called")
            self.scrollView.setContentOffset(CGPointMake(CGFloat(UIScreen.mainScreen().bounds.width * CGFloat(nextIndex)), 0), animated: true)
//            [scrollView scrollRectToVisible:CGRectMake(scrollView. *pageNumber, 0, 320 , 240) animated:NO];
        }
        return VC
    }

    /*
    @IBAction func didTapNextButton(sender: UIButton) {
        tutorialPageViewController?.scrollToNextViewController()
    }*/
    
    /**
     Fired when the user taps on the pageControl to change its current page.
     */
    func didChangePageControlValue() {
//        tutorialPageViewController?.scrollToViewController(index: pageControl.currentPage)
    }
    
    func goPage(page:Int) {
        print("Go to \(page) page")
    }
    
    func GoToMainScreen() {
        print("Go To main screen")
    }
    
}

extension TutorialViewController: TutorialPageViewControllerDelegate {
    
    func tutorialPageViewController(tutorialPageViewController: TutorialPageViewController,
        didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }
    
    func tutorialPageViewController(tutorialPageViewController: TutorialPageViewController,
        didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
    }
    
}

extension TutorialViewController: UIScrollViewDelegate
{
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
//        if scrollView.contentOffset.y > 0 {
//            scrollView.contentOffset.y = 0
//        }
//        self.view.endEditing(false)
        
        let diffFromCenter = (Float(scrollView.contentOffset.x) - (Float)(self.pageControl.currentPage)*Float(self.view.frame.size.width));
        let currentPageAlpha = 1.0 - fabs(diffFromCenter)/Float(self.view.frame.size.width);
        let sidePagesAlpha = fabs(diffFromCenter)/Float(self.view.frame.size.width);
        currentIndex = self.pageControl.currentPage

        if diffFromCenter > 0 {
            nextIndex = currentIndex! + 1
        }else {
            nextIndex = currentIndex! - 1
        }
        
        print("diffFromCenter \(diffFromCenter) sidePagesAlpha \(sidePagesAlpha)  currentPageAlpha \(currentPageAlpha) currrent \(currentIndex ?? 9) next \(nextIndex ?? 9) ")
        
        (orderedViewControllers[currentIndex!] as! BaseViewController).background.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: CGFloat(sidePagesAlpha))
        if nextIndex > 0 && nextIndex < 6{
            (orderedViewControllers[nextIndex] as! BaseViewController).background.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: CGFloat(currentPageAlpha))
        }
       
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let page = (Int)((scrollView.contentOffset.x) / (self.view.frame.size.width))
        //print("page \(page)")
        pageControl.currentPage = page
        (orderedViewControllers[page] as! BaseViewController).background.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: CGFloat(0))
    }
}

extension TutorialViewController: BaseViewControllerDelegate {
    func hiddenPageController() {
        self.pageControl.hidden = true
    }
}
