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
        var thisDeviceName = ""
        for person in SearchUserTableViewController.users{
            if person.key == FIRAuth.auth()?.currentUser?.uid as! String{
                thisDeviceName = person.value as! String
            }
        }
        
        if requestID != ""{
            FIRDatabase.database().reference().child("FriendsList").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").child("FriendRequest").child("\(requestID as! String)").setValue(true)
            
            FIRDatabase.database().reference().child("FriendsList").child(requestID as! String).child("FriendRequest").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").observe(.value, with: { (picshot) in
                if picshot.exists() == true{
                    
                    FIRDatabase.database().reference().child("FriendsList").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").child("Friends").child("\(self.requestID as! String)").setValue(self.requestName.text as! String)
                        
                        FIRDatabase.database().reference().child("FriendsList").child("\(self.requestID as! String)").child("Friends").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").setValue(thisDeviceName as! String)
                    
                        FIRDatabase.database().reference().child("FriendsList").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").child("FriendRequest").child("\(self.requestID as! String)").removeValue(completionBlock: { (error, ref) in
                            if error != nil {
                                print("error \(error)")
                            }
                        })
                    
                }else{
                    FIRDatabase.database().reference().child("FriendsList").child(self.requestID as! String).child("FriendRequest").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").setValue(false)
                }
            })
            
            
        }
    
    }
    
    @IBAction func reject(_ sender: Any) {
        var thisDeviceName = ""
        for person in SearchUserTableViewController.users{
            if person.key == FIRAuth.auth()?.currentUser?.uid as! String{
                thisDeviceName = person.value as! String
            }
        }
        if requestID != ""{
        FIRDatabase.database().reference().child("FriendsList").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").child("FriendRequest").child("\(requestID as! String)").setValue(false)
        
            self.handle = FIRDatabase.database().reference().child("FriendsList").child(requestID as! String).child("FriendRequest").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").observe(.value, with: { (picshot) in
                if picshot.exists() == true{
                    FIRDatabase.database().reference().child("FriendsList").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").child("FriendRequest").child("\(self.requestID)").removeValue()
                    
                    FIRDatabase.database().reference().child("FriendsList").child("\(self.requestID as! String)").child("FriendRequest").child("\(thisDeviceName)").removeValue()
                    
                    FIRDatabase.database().reference().child("FriendsList").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").child("FriendRequest").child("\(self.requestID)").removeValue(completionBlock: { (error, ref) in
                        
                        if error != nil {
                            print("error \(error)")
                        }
                    })
                    
                }
            })
            
        }
    }
    
}

