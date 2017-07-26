//
//  TruthOrDareTableViewCell.swift
//  Let's Talk
//
//  Created by Cameron Bennett on 6/16/17.
//  Copyright © 2017 Cameron Bennett. All rights reserved.
//

import UIKit
import Firebase

class TruthOrDareTableViewCell: UITableViewCell {

    @IBOutlet weak var sendersNameLabel: UILabel!
    
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var ResponseTextView: UITextView!
    
    var postID = String()
    
    var ref = FIRDatabase.database().reference()
    
    var UIDs = Array(Let_sTalkFeedViewController.TruthOrDareQuestions.keys)
    
    var Questions = Array(Let_sTalkFeedViewController.TruthOrDareQuestions.values)
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func Trash(_ sender: Any) {
        var indexval = Let_sTalkFeedViewController.TruthOrDareQuestions[questionLabel.text!]
        FIRDatabase.database().reference().child("Posts").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").child("Truth Or Dare Questions").child("\(postID)").child(indexval!).removeValue()
        Let_sTalkFeedViewController().refreshData()
        
    }
    
    @IBAction func Reply(_ sender: Any) {
        let num = Questions.index(of: questionLabel.text!)
        ref.child("Posts").child("\(UIDs[num!] )").child("Truth Or Dare Replies").child((FIRAuth.auth()?.currentUser?.uid)!).child(questionLabel.text!).setValue(ResponseTextView.text!)
        var indexval = Let_sTalkFeedViewController.TruthOrDareQuestions[questionLabel.text!]
        FIRDatabase.database().reference().child("Posts").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").child("Truth Or Dare Questions").child("\(postID)").child(indexval!).removeValue()
        Let_sTalkFeedViewController().refreshData()
    }
    
}
