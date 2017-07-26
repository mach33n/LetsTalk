//
//  TruthOrDareReplyCell.swift
//  Let's Talk
//
//  Created by Cameron Bennett on 7/19/17.
//  Copyright © 2017 Cameron Bennett. All rights reserved.
//

import UIKit

class TruthOrDareReplyCell: UITableViewCell {

    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var replyLabel: UILabel!
    
    @IBOutlet weak var sendersNameLabel: UILabel!
    
    var postID = String()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func Trash(_ sender: Any) {
        var indexval = Let_sTalkFeedViewController.TruthOrDareReplies[replyLabel.text!]
        FIRDatabase.database().reference().child("Posts").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").child("Truth Or Dare Replies").child("\(postID)").child(indexval!).removeValue()
        Let_sTalkFeedViewController().refreshData()
    }
    
}
