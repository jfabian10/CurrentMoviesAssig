//
//  MoviesTableViewController.swift
//  CurrentMovies
//
//  Created by Jesus Fabian on 10/28/16.
//  Copyright © 2016 Jesus Fabian. All rights reserved.
//

import UIKit

class MoviesTableViewController: UITableViewController {
    
    let tableViewRowHeight: CGFloat = 90.0
    
    // moviesCurrentlyPlayingInTheaters is an Array of Dictionaries, where each Dictionary contains data about a movie
    var moviesCurrentlyPlayingInTheaters = [AnyObject]()
    
    var numberOfMoviesToDisplay = 0
    var movieDataToPass = [String: AnyObject]()
    
    /*
     -----------------------
     MARK: - View Life Cycle
     -----------------------
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var dictionaryOfMoviesInTheaters = [String: AnyObject]()
        
        /*
         The Rotten Tomatoes Application Programming Interface (API) is a RESTful web service providing
         movie data in the JSON (JavaScript Object Notation) format.
         
         REST (REpresentational State Transfer) is a client-server architectural style and is typically
         used with the HTTP protocol. It enables the access of Web Services as simple resources using URLs.
         A Web Service is a component software application intended to provide services (functions) to another
         software application over the Internet. The Web Services created for use under the REST architectural
         style are known as RESTful Web Services.
         
         The Rotten Tomatoes API documentation is provided at http://developer.rottentomatoes.com/docs
         
         "In Theaters Movies" data can be accessed from the Rotten Tomatoes API using the apiURL given below.
         
         Documentation of the JSON data returned in response to this API request is provided at:
         http://developer.rottentomatoes.com/docs/read/json/v10/In_Theaters_Movies
         */
        
        // This URL returns the JSON data about the movies currently playing in theaters using Dr. Balci's API key.
        let apiURL = "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/in_theaters.json?apikey=g9qcds978gjpn6a3k78zzj7m&page_limit=50"
        
        // Create an NSURL object from the API URL string
        let url = URL(string: apiURL)
        
        /*
         We use the NSData object constructor below to download the JSON data via HTTP in a single thread in this method.
         Downloading large amount of data via HTTP in a single thread would result in poor performance.
         For better performance, NSURLSession can be used.
         
         NSURLSession provides an API for downloading content via HTTP with (a) a rich set of delegate methods for
         supporting authentication, (b) the ability to perform background downloads when your iOS app is suspended,
         and (c) a series of sessions created, each of which coordinates a group of related data transfer tasks. [Apple]
         
         To obtain the best performance:
         (1) Download data in multiple threads including background downloads using multithreading and Grand Central Dispatch.
         (2) Store each image on the device after first download to prevent downloading it repeatedly.
         */
        
        let jsonData: Data?
        
        do {
            /*
             Try getting the JSON data from the URL and map it into virtual memory, if possible and safe.
             DataReadingMappedIfSafe indicates that the file should be mapped into virtual memory, if possible and safe.
             */
            jsonData = try Data(contentsOf: url!, options: NSData.ReadingOptions.mappedIfSafe)
            
        } catch let error as NSError {
            
            showErrorMessage("Error in retrieving JSON data: \(error.localizedDescription)")
            return
        }
        
        if let jsonDataFromApiUrl = jsonData {
            
            // The JSON data is successfully obtained from the API
            
            /*
             NSJSONSerialization class is used to convert JSON and Foundation objects (e.g., NSDictionary) into each other.
             NSJSONSerialization class's method JSONObjectWithData returns an NSDictionary object from the given JSON data.
             */
            
            do {
                let jsonDataDictionary = try JSONSerialization.jsonObject(with: jsonDataFromApiUrl, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                
                // Typecast the returned NSDictionary as Dictionary<String, AnyObject>
                dictionaryOfMoviesInTheaters = jsonDataDictionary as! Dictionary<String, AnyObject>
                
                // moviesCurrentlyPlayingInTheaters is an Array of Dictionaries, where each Dictionary contains data about a movie
                moviesCurrentlyPlayingInTheaters = dictionaryOfMoviesInTheaters["movies"] as! Array<AnyObject>
                
                let numberOfMoviesFromJsonData = moviesCurrentlyPlayingInTheaters.count
                
                // Select no more than 50 movies to display using the Ternary Conditional Operator
                numberOfMoviesToDisplay = numberOfMoviesFromJsonData > 50 ? 50 : numberOfMoviesFromJsonData
                
            } catch let error as NSError {
                
                showErrorMessage("Error in JSON Data Serialization: \(error.localizedDescription)")
                return
            }
            
        } else {
            
            showErrorMessage("Error in retrieving JSON data!")
        }
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
    
    /*
     --------------------------------------
     MARK: - Table View Data Source Methods
     --------------------------------------
     */
    
    // Asks the data source to return the number of sections in the table view
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    // Asks the data source to return the number of rows in a section, the number of which is given
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return numberOfMoviesToDisplay
    }
    
    /*
     ------------------------------------
     Prepare and Return a Table View Cell
     ------------------------------------
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let rowNumber: Int = (indexPath as NSIndexPath).row    // Identify the row number
        
        // Obtain the object reference of a reusable table view cell object instantiated under the identifier
        // MovieCell, which is specified in the storyboard
        let cell: MovieTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as! MovieTableViewCell
        
        // Obtain the Dictionary containing the data about the movie at rowNumber
        let movieDataDict = moviesCurrentlyPlayingInTheaters[rowNumber] as! Dictionary<String, AnyObject>
        
        //-----------------------
        // Set Movie Poster Image
        //-----------------------
        
        let posterUrlsDict = movieDataDict["posters"] as! Dictionary<String, AnyObject>
        let thumbnailURL = posterUrlsDict["thumbnail"] as! String
        
        // Create an NSURL object from the thumbnail poster image URL string
        let url = URL(string: thumbnailURL)
        
        var imageData: Data?
        
        do {
            /*
             Try getting the thumbnail image data from the URL and map it into virtual memory, if possible and safe.
             DataReadingMappedIfSafe indicates that the file should be mapped into virtual memory, if possible and safe.
             */
            imageData = try Data(contentsOf: url!, options: NSData.ReadingOptions.mappedIfSafe)
            
        } catch let error as NSError {
            
            showErrorMessage("Error in retrieving thumbnail image data: \(error.localizedDescription)")
        }
        
        if let moviePosterImage = imageData {
            
            // Movie poster thumbnail image data is successfully retrieved
            cell.moviePosterImageView!.image = UIImage(data: moviePosterImage)
            
        } else {
            showErrorMessage("Error occurred while retrieving movie poster thumbnail image data!")
        }
        
        //----------------
        // Set Movie Title
        //----------------
        
        let movieTitle = movieDataDict["title"] as! String
        
        cell.movieTitleLabel!.text = movieTitle
        
        //--------------------------
        // Set Audience (User) Score
        //--------------------------
        
        let ratingsDict = movieDataDict["ratings"] as! Dictionary<String, AnyObject>
        let audienceScore = ratingsDict["audience_score"] as! Int
        
        cell.audienceScoreLabel!.text = "\(audienceScore)%"
        
        //------------------------
        // Set Top Two Movie Stars
        //------------------------
        
        var topArtists = movieDataDict["abridged_cast"] as! Array<AnyObject>
        
        var topStarsOfTheMovie = ""
        let numberOfCastMembers = topArtists.count
        
        for j in 0..<numberOfCastMembers {
            
            let movieStarDict = topArtists[j] as! Dictionary<String, AnyObject>
            let movieStarName = movieStarDict["name"] as! String
            
            topStarsOfTheMovie += movieStarName
            
            // Place a comma after first last name
            if j == 0 {
                topStarsOfTheMovie += ", "
            }
            // Display only the top two movie stars
            if j == 1 {break}
        }
        
        cell.movieStarsLabel!.text = topStarsOfTheMovie
        
        //-------------------------------------------
        // Set MPAA Rating, Runtime, and Release Date
        //-------------------------------------------
        
        let mpaaRating = movieDataDict["mpaa_rating"] as! String
        
        var runtime = ""
        
        let runtimeInMinutes: AnyObject? = movieDataDict["runtime"]
        
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
        
        var releaseDateInTheaters = ""
        
        var releaseDatesDict = movieDataDict["release_dates"] as! Dictionary<String, String>
        
        // If releaseDatesDict is not empty
        if !releaseDatesDict.isEmpty {
            
            // If a value is available for the "theater" key in the dictionary
            if let releaseDate = releaseDatesDict["theater"] {
                
                releaseDateInTheaters = releaseDate
            }
        }
        
        cell.mpaaRatingRuntimeDateLabel!.text = "\(mpaaRating), \(runtime), \(releaseDateInTheaters)"
        
        return cell
    }
    
    /*
     -----------------------------------
     MARK: - Table View Delegate Methods
     -----------------------------------
     */
    
    // Asks the table view delegate to return the height of a given row.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return tableViewRowHeight
    }
    
    // Informs the table view delegate that the specified row is selected.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let rowNumber: Int = (indexPath as NSIndexPath).row    // Identify the row number
        
        // Obtain the Dictionary containing the data about the selected movie to pass to the downstream view controller
        movieDataToPass = moviesCurrentlyPlayingInTheaters[rowNumber] as! Dictionary<String, AnyObject>
        
        performSegue(withIdentifier: "MovieInfo", sender: self)
    }
    
    /*
     -------------------------
     MARK: - Prepare For Segue
     -------------------------
     */
    
    // This method is called by the system whenever you invoke the method performSegueWithIdentifier:sender:
    // You never call this method. It is invoked by the system.
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        if segue.identifier == "MovieInfo" {
            
            // Obtain the object reference of the destination view controller
            let movieViewController: MovieViewController = segue.destination as! MovieViewController
            
            //Pass the data object to the destination view controller object
            movieViewController.movieDataPassed = movieDataToPass
            
        }
    }
    
}
