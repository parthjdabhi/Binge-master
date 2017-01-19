//
//  MovieDescriptionViewController.swift
//  What2Watch
//
//  Created by Dustin Allen on 8/16/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
import Alamofire
import SDWebImage
import UIActivityIndicator_for_SDWebImage

import TransitionTreasury
import TransitionAnimation

class MovieDescriptionViewController: UIViewController, UITextFieldDelegate, NavgationTransitionable {
    
    @IBOutlet var btnBack: UIButton?
    @IBOutlet var poster: UIImageView!
    @IBOutlet var lblMovieTitle: UILabel!
    @IBOutlet var lblGenere: UILabel!
    @IBOutlet var lblYear: UILabel!
    @IBOutlet var lblPlot: UILabel!
    @IBOutlet var btnSearch: UIButton!
    @IBOutlet var lblDirector: UILabel!
    @IBOutlet var lblLikes: UILabel!
    @IBOutlet var lblCast: UILabel!
    
    //static var imdbID: String = ""
    var movieDetail:[String:String]?
    var movieFullDetail:[String:String]?
    
    var tr_pushTransition: TRNavgationTransitionDelegate?
    weak var modalDelegate: ModalViewControllerDelegate?
    
    override func viewDidLoad() {
        
        lblPlot.lineBreakMode = NSLineBreakMode.ByWordWrapping
        lblPlot.numberOfLines = 0
        lblCast.lineBreakMode = NSLineBreakMode.ByWordWrapping
        lblCast.numberOfLines = 0
        
        lblMovieTitle.text = "\( movieDetail?["movieTitle"] ?? "" )"
        //lblGenere.text = "Genere : \( movieDetail?["genre"] ?? "" )"
        
        if let transitionAnimation = tr_pushTransition?.transition as? IBanTangTransitionAnimation {
            print(transitionAnimation.keyView)
            print(transitionAnimation.keyViewCopy)
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(MovieDescriptionViewController.imageTapped(_:)))
        poster.userInteractionEnabled = true
        poster.addGestureRecognizer(tapGestureRecognizer)
        
        let posterURL = "http://img.omdbapi.com/?i=\(movieDetail?["imdbID"] ?? "")&apikey=57288a3b&h=1000"
        let posterNSURL = NSURL(string: "\(posterURL)")
        self.poster.setImageWithURL(posterNSURL, placeholderImage: UIImage(named: "placeholder"), options: SDWebImageOptions.AllowInvalidSSLCertificates, completed: { (imgPoster, error, cacheType, urlPoster) in
                if error != nil {
                    print(error)
                }
            }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        
        
        CommonUtils.sharedUtils.showProgress(self.view, label: "Please wait..")
        let movieFullDetailURL = "http://www.omdbapi.com/"  //http:// www.omdbapi.com/?i=(*imdbID*)&plot=short&r=json
        Alamofire.request(.GET, movieFullDetailURL, parameters: ["i": movieDetail?["imdbID"] ?? "", "apikey":"57288a3b", "plot":"short", "r":"json"])
            .responseJSON { response in
                
                debugPrint(response)
                CommonUtils.sharedUtils.hideProgress()
                
                if let JSON = response.result.value as? [String:String] {
                    self.movieFullDetail = JSON
                    print("Success with JSON: \(JSON)")
                    
                    if let Year = JSON["Year"] {
                        self.lblYear.text = "\(Year)"
                        self.lblYear.addTextSpacing(8)
                    }
                    if let Plot = JSON["Plot"] {
                        self.lblPlot.text = "About:\n\(Plot)"
                    }
                    if let Director = JSON["Director"] {
                        self.lblDirector.text = "Directed by \(Director)"
                    }
                    if let Likes = JSON["imdbVotes"] {
                        self.lblLikes.text = "\(Likes)"
                    }
                    if let Cast = JSON["Actors"] {
                        self.lblCast.text = "Cast:\n\(Cast)"
                    }
                }
        }
        self.view.layoutIfNeeded()
    }
    
    func imageTapped(img: AnyObject)
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func actionBack(sender: AnyObject) {
        //self.navigationController?.popViewControllerAnimated(true)
        self.navigationController?.tr_popViewController({ () -> Void in
            print("Pop finished.")
        })
        modalDelegate?.modalViewControllerDismiss(callbackData: ["title":"test" ?? ""])
    }
    
    @IBAction func actionSearch(sender: AnyObject) {
    }
}


