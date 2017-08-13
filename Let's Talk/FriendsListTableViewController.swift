//
//  FriendsListTableViewController.swift
//  Let's Talk
//
//  Created by Cameron Bennett on 6/2/17.
//  Copyright © 2017 Cameron Bennett. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class FriendsListViewController: UITableViewController {
    
    var window: UIWindow?
    var ref = FIRDatabase.database().reference()
    static var Friends = [String:String]()
    var friendsUsernames = Array(FriendsListViewController.Friends.values)
    var friendsUID = Array(FriendsListViewController.Friends.keys)
    static var friendsProfilePics = [String:String]()
    var friendsPics = Array(FriendsListViewController.friendsProfilePics.values)
    
    
    override func viewWillAppear(_ animated: Bool) {
        loadDatabase()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        loadDatabase()
        tableView.reloadData()
        
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FriendsListViewController.Friends.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
    
        if FriendsListViewController.Friends.count != 0{
            print(self.friendsUsernames)
        cell.nameLabel.text = self.friendsUsernames[indexPath.row]
        cell.userID = self.friendsUID[indexPath.row]
        cell.userImage.downloadImage(from: FriendsListViewController.friendsProfilePics[self.friendsUsernames[indexPath.row]])
        
        }
        return cell
        
    }
    
    

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    @IBAction func addFriends(_ sender: Any) {
        if SearchUserTableViewController.notAddedFriends.count != 0{
                self.performSegue(withIdentifier: "toFriends", sender: nil)
            }else{
            
                }
        
    }
    func loadDatabase(){
        
        ref.child("users").observe(.value, with: { (snapshot) in
            for child in snapshot.value as! [String:String]{
                SearchUserTableViewController.users.updateValue(child.value as! String, forKey: child.key as! String)
            }}
        )
        
        FIRDatabase.database().reference().child("FriendsList").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").child("Friends").observe(.value, with: { (snapshot) in
            if snapshot.hasChildren() == true{
                for child in snapshot.value as! [String:String]{
                    FriendsListViewController.Friends.updateValue(child.value as! String, forKey: child.key as! String)
                }
            }
        })
        
        for (key,value) in SearchUserTableViewController.users{
            print("key" + key)
            FIRDatabase.database().reference().child("users").child("\(key)").observe(.value, with: { (snapshot) in
                var user = value as! String
                var useruid = key as! String
                print("user:" + user)
                FIRDatabase.database().reference().child("FriendsList").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").child("Friends").observe(.value, with: { (thatshot) in
                    var friendIds = Array(FriendsListViewController.Friends.values)
                    
                    FIRDatabase.database().reference().child("FriendsList").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").child("FriendRequest").observe(.value, with: { (picshot) in
                        print(picshot.value)
                        var requesterUID = ["":false]
                        if picshot.exists() == true{
                            requesterUID = picshot.value as! [String:Bool]
                        }
                        if (snapshot.exists() == false || snapshot.hasChildren() == false) && (picshot.exists() == false || picshot.hasChildren() == false) {
                            if useruid != FIRAuth.auth()?.currentUser?.uid as! String{
                                if friendIds.contains(useruid) == false{
                                    if requesterUID[useruid] != false{
                                        if SearchUserTableViewController.notAddedFriends.contains(user) == false{
                                            SearchUserTableViewController.notAddedFriends.append(user)
                                            SearchUserTableViewController.notAddedIDs.append(useruid)
                                        }
                                    }
                                }
                            }else{
                                
                            }
                            
                        }else{
                            if thatshot.exists() == true{
                                for k in thatshot.value as! [String:Any] {
                                    print("k: " + "\(k)")
                                    if k.key.contains(user) == false {
                                        if useruid != FIRAuth.auth()?.currentUser?.uid as! String{
                                            if friendIds.contains(useruid) == false{
                                                if requesterUID[useruid] != false{
                                                    if SearchUserTableViewController.notAddedFriends.contains(user) == false{
                                                        SearchUserTableViewController.notAddedFriends.append(user)
                                                        SearchUserTableViewController.notAddedIDs.append(useruid)
                                                    }
                                                }
                                            }else{
                                                if SearchUserTableViewController.notAddedFriends.contains(user){
                                                    SearchUserTableViewController.notAddedFriends.remove(at: SearchUserTableViewController.notAddedFriends.index(of: user)!)
                                                    SearchUserTableViewController.notAddedIDs.remove(at: SearchUserTableViewController.notAddedIDs.index(of: useruid)!)
                                                    
                                                    
                                                }
                                            }
                                        }
                                        
                                    }
                                }
                            }else{
                                if useruid != FIRAuth.auth()?.currentUser?.uid as! String{
                                    if friendIds.contains(useruid) == false{
                                        if requesterUID[useruid] != false{
                                            if SearchUserTableViewController.notAddedFriends.contains(user) == false{
                                                SearchUserTableViewController.notAddedFriends.append(user)
                                                SearchUserTableViewController.notAddedIDs.append(useruid)
                                            }
                                        }
                                    }else{
                                        if SearchUserTableViewController.notAddedFriends.contains(user){
                                            SearchUserTableViewController.notAddedFriends.remove(at: SearchUserTableViewController.notAddedFriends.index(of: user)!)
                                            SearchUserTableViewController.notAddedIDs.remove(at: SearchUserTableViewController.notAddedIDs.index(of: useruid)!)
                                            
                                            
                                        }
                                    }
                                    
                                    
                                }
                            }
                            
                        }
                    })
                })
            })
        }
        for friend in SearchUserTableViewController.notAddedIDs{
            FIRDatabase.database().reference().child("FriendsList").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").child("FriendRequest").child(friend).observe(.value , with: { (snapshot) in
                if snapshot.exists() == true{
                    if SearchUserTableViewController.notAddedFriends.contains(SearchUserTableViewController.notAddedFriends[SearchUserTableViewController.notAddedIDs.index(of: friend) as! Int]){
                    SearchUserTableViewController.notAddedFriends.remove(at: SearchUserTableViewController.notAddedIDs.index(of: friend) as! Int)
                    }
                    if SearchUserTableViewController.notAddedIDs.contains(friend){
                    SearchUserTableViewController.notAddedIDs.remove(at: SearchUserTableViewController.notAddedIDs.index(of: friend) as! Int)
                    }
                    
                }
            })
        }
    }
}




    extension UIImageView {
        
        func downloadImage(from imgURL: String!) {
            
            let url = URLRequest(url: URL(string: imgURL)!)
            
            let task = URLSession.shared.dataTask(with: url) {
                (data, response, error) in
                
                if error != nil {
                    print(error!)
                    return
                }
                
                DispatchQueue.main.async {
                    self.image = UIImage(data: data!)
                }
                
            }
            
            task.resume()
        }
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


