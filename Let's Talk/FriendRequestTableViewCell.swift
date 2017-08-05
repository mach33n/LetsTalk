//
//  FriendRequestTableViewCell.swift
//  
//
//  Created by Cameron Bennett on 7/28/17.
//
//

import UIKit

class FriendRequestTableViewCell: UITableViewCell {

    @IBOutlet weak var requestName: UILabel!
    
    
    var allUsers = Array(SearchUserTableViewController.users.keys)
    var allUserIDs = Array(SearchUserTableViewController.users.values)
    var handle: UInt = 0
    var requestID: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func accept(_ sender: Any) {
        if requestID != ""{
            FIRDatabase.database().reference().child("FriendsList").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").child("FriendRequest").child("\(requestID as! String)").setValue(true)
            
            self.handle = FIRDatabase.database().reference().child("FriendsList").child(requestID as! String).child("FriendRequest").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").observe(.value, with: { (picshot) in
                if picshot.exists() == true{
                    if picshot.value as! Bool == true {
                        FIRDatabase.database().reference().child("FriendsList").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").child("Friends").child("\(self.requestID)").setValue(self.requestName.text as! String)
                        
                        FIRDatabase.database().reference().child("FriendsList").child("\(self.requestID as! String)").child("Friends").child("\(self.allUsers[self.find(objecToFind: FIRAuth.auth()?.currentUser?.uid)!])").setValue(FIRAuth.auth()?.currentUser?.uid as! String)
                        FIRDatabase.database().reference().child("FriendsList").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").child("FriendRequest").child("\(self.requestID)").removeValue(completionBlock: { (error, ref) in
                            if error != nil {
                                print("error \(error)")
                            }
                        })
                    }else{
                        //send request
                    }
                }else{
                    FIRDatabase.database().reference().child("FriendsList").child(self.requestID as! String).child("FriendRequest").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").setValue(false)
                }
            })
            
            
        }
    
    }
    
    @IBAction func reject(_ sender: Any) {
        
    }
    
    func find(objecToFind: String?) -> Int? {
        for i in 0...self.allUserIDs.count {
            if self.allUserIDs[i] as! String == objecToFind {
                return i
            }
        }
        return nil
    }
    
}

