//
//  MovieTableViewCell.swift
//  CurrentMovies
//
//  Created by Jesus Fabian on 10/28/16.
//  Copyright © 2016 Jesus Fabian. All rights reserved.
//
import UIKit

class MovieTableViewCell: UITableViewCell {
    
    // Instance variables holding the object references of the table view cell UI objects instantiated in the Storyboard
    @IBOutlet var moviePosterImageView: UIImageView!
    @IBOutlet var movieTitleLabel: UILabel!
    @IBOutlet var audienceScoreLabel: UILabel!
    @IBOutlet var movieStarsLabel: UILabel!
    @IBOutlet var mpaaRatingRuntimeDateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
