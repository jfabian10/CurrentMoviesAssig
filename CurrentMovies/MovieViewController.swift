//
//  MovieViewController.swift
//  CurrentMovies
//
//  Created by Jesus Fabian on 10/28/16.
//  Copyright © 2016 Jesus Fabian. All rights reserved.
//

import UIKit

class MovieViewController: UIViewController {
    
    var movieDataPassed = [String: AnyObject]()
    
    // Instance variables holding the object references of the UI objects instantiated in the Storyboard
    @IBOutlet var moviePosterImageView: UIImageView!
    @IBOutlet var movieTitleLabel: UILabel!
    @IBOutlet var criticsScoreLabel: UILabel!
    @IBOutlet var audienceScoreLabel: UILabel!
    @IBOutlet var mpaaRatingRuntimeLabel: UILabel!
    @IBOutlet var releaseDateLabel: UILabel!
    @IBOutlet var castTextView: UITextView!
    @IBOutlet var movieInfoTextView: UITextView!
    
    /*
     -----------------------
     MARK: - View Life Cycle
     -----------------------
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         --------------------------------------------------------
         How to adjust the title to fit within the navigation bar
         --------------------------------------------------------
         */
        
        let labelRect = CGRect(x: 0, y: 0, width: 300, height: 40)
        
        let titleLabel = UILabel(frame: labelRect)
        
        titleLabel.text = movieDataPassed["title"] as? String
        
        titleLabel.adjustsFontSizeToFitWidth = true
        
        titleLabel.textAlignment = .center
        
        self.navigationItem.titleView = titleLabel
        
        
        
        //-----------------------------------
        // Display Movie Poster Profile Image
        //-----------------------------------
        
        let posterUrlsDict = movieDataPassed["posters"] as! Dictionary<String, AnyObject>
        let profileImageUrlGiven = posterUrlsDict["original"] as! String
        
        // Create an NSURL object from the URL string
        let url = URL(string: profileImageUrlGiven)
        
        var imageData: Data?
        
        do {
            /*
             Try getting the image data from the URL and map it into virtual memory, if possible and safe.
             NSDataReadingMappedIfSafe indicates that the file should be mapped into virtual memory, if possible and safe.
             */
            imageData = try Data(contentsOf: url!, options: NSData.ReadingOptions.mappedIfSafe)
            
        } catch let error as NSError {
            
            showErrorMessage("Error in retrieving movie profile image data: \(error.localizedDescription)")
            return
        }
        
        if let moviePosterImage = imageData {
            
            // Movie poster profile image data is successfully obtained from the API
            moviePosterImageView!.image = UIImage(data: moviePosterImage)
            
        } else {
            
            showErrorMessage("Error in retrieving movie profile image data!")
        }
        
        //--------------------
        // Display Movie Title
        //--------------------
        
        movieTitleLabel.text = movieDataPassed["title"] as? String
        
        //-------------------------------------
        // Display Critics and Audience Ratings
        //-------------------------------------
        
        let ratingsDict = movieDataPassed["ratings"] as! Dictionary<String, AnyObject>
        
        let criticsScore = ratingsDict["critics_score"] as? Int
        let audienceScore = ratingsDict["audience_score"] as? Int
        
        criticsScoreLabel.text = "\(criticsScore!)%"
        audienceScoreLabel.text = "\(audienceScore!)%"
        
        //--------------------------------
        // Display MPAA Rating and Runtime
        //--------------------------------
        
        let mpaaRating = movieDataPassed["mpaa_rating"] as! String
        
        var runtime = ""
        
        let runtimeInMinutes: AnyObject? = movieDataPassed["runtime"]
        
        // Check to see if runtimeInMinutes is of Type Int; if so, assign it to runtimeInMinutesAsInt
        if let runtimeInMinutesAsInt = runtimeInMinutes as? Int {
            
            // Remainder operator % returns the remainder of the division
            let minutes = runtimeInMinutesAsInt % 60
            let hours = Int((runtimeInMinutesAsInt - minutes) / 60)
            
            // Set hour and minute labels
            let hrsLabel = hours > 1 ? "hrs" : "hr"
            let minsLabel = minutes > 1 ? "mins" : "min"
            
            runtime = "\(hours) \(hrsLabel) \(minutes) \(minsLabel)"
            
        } else {
            // Some movies do not have runtime value
            runtime = "No Runtime"
        }
        
        mpaaRatingRuntimeLabel!.text = "\(mpaaRating), \(runtime)"
        
        //---------------------
        // Display Release Date
        //---------------------
        
        var releaseDateInTheaters = ""
        
        var releaseDatesDict = movieDataPassed["release_dates"] as! Dictionary<String, String>
        
        // If releaseDatesDict is not empty
        if !releaseDatesDict.isEmpty {
            
            // If a value is available for the "theater" key in the dictionary
            if let releaseDate = releaseDatesDict["theater"] {
                
                releaseDateInTheaters = releaseDate
                
                var date: Date?
                
                // NSDateFormatter is used to convert NSDate objects into String representations of
                // dates and times or convert String representations of dates and times into NSDate objects.
                let dateFormatter = DateFormatter()
                /*
                 We use unicode’s date format patterns here to specify the date styles.
                 
                 yyyy    --> Year as 4-digit number,     e.g., 2014
                 MM      --> Month as 2-digit number,    e.g., 09
                 MMM     --> Abbreviated month name,     e.g., Sept
                 MMMM    --> Full month name,            e.g., September
                 dd      --> Day as 2-digit number,      e.g., 14
                 */
                
                // The Date retrieved from the API as String is formatted as "yyyy-MM-dd", e.g., "2015-10-17"
                // Set the date format for the dateFormatter to use
                dateFormatter.dateFormat = "yyyy-MM-dd"
                
                // Ask the dateFormatter to create an NSDate object from the releaseDateInTheaters
                // string date given in the format set above.
                date = dateFormatter.date(from: releaseDateInTheaters)
                
                // Specify the new date style desired, e.g., October 17, 2015
                dateFormatter.dateFormat = "MMMM dd, yyyy"
                
                // Ask the dateFormatter to create a String representation of the NSDate object
                // according to the format specified above
                releaseDateInTheaters = dateFormatter.string(from: date!)
            }
        }
        
        releaseDateLabel!.text = releaseDateInTheaters
        
        //------------------------
        // Display Top Movie Stars
        //------------------------
        
        var topArtists = movieDataPassed["abridged_cast"] as! Array<AnyObject>
        
        var topStarsOfTheMovie = ""
        let numberOfCastMembers = topArtists.count
        
        for j in 0..<numberOfCastMembers {
            
            let movieStar = topArtists[j] as! Dictionary<String, AnyObject>
            let movieStarName = movieStar["name"] as! String
            
            topStarsOfTheMovie += movieStarName
            
            // Place a comma after each last name except the last one
            if j != (numberOfCastMembers - 1) {
                topStarsOfTheMovie += ", "
            }
        }
        
        castTextView.text = topStarsOfTheMovie
        
        //-------------------
        // Display Movie Info
        //-------------------
        
        movieInfoTextView.text = movieDataPassed["synopsis"] as? String
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        /*
         Ask the movieInfoTextView to scroll to the top of the text view.
         You can use the following to scroll to the bottom of the text view if desired in another app:
         movieInfoTextView.scrollRangeToVisible(NSMakeRange(0, (movieInfoTextView.text as NSString).length))
         */
        movieInfoTextView.scrollRangeToVisible(NSMakeRange(0, 0))
    }
    
    
    /*
     -------------------------------
     MARK: - Memory Warning Received
     -------------------------------
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        showErrorMessage("Received memory warning!")
    }
    
    /*
     ------------------------------------------------
     MARK: - Show Alert View Displaying Error Message
     ------------------------------------------------
     */
    func showErrorMessage(_ errorMessage: String) {
        
        /*
         Create a UIAlertController object; dress it up with title, message, and preferred style;
         and store its object reference into local constant alertController
         */
        let alertController = UIAlertController(title: "Unable to Obtain Data!", message: errorMessage,
                                                preferredStyle: UIAlertControllerStyle.alert)
        
        // Create a UIAlertAction object and add it to the alert controller
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // Present the alert controller by calling the presentViewController method
        present(alertController, animated: true, completion: nil)
    }
    
}
