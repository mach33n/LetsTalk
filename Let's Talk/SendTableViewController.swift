//
//  SendTableViewController.swift
//  Let's Talk
//
//  Created by Cameron Bennett on 6/15/17.
//  Copyright © 2017 Cameron Bennett. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class SendTableViewController: UITableViewController {

    var window: UIWindow?
    var ref = FIRDatabase.database().reference()
    var friendsUID = Array(FriendsListViewController.Friends.values)
    var friendsToSendTo = [String]()
    var UIDsToSendTo = [String]()
    
    @IBOutlet var SelectableTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDatabase()
        reloadDatabase()
        tableView.reloadData()
        loadDatabase()
        reloadDatabase()
        tableView.reloadData()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return FriendsListViewController.Friends.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var friendsUsernames = Array(FriendsListViewController.Friends.keys)
        let cell = SelectableTableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        cell.textLabel?.text = friendsUsernames[indexPath.row] as! String
        
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var friendsUsernames = Array(FriendsListViewController.Friends.keys)

            self.friendsToSendTo.append(friendsUsernames[indexPath.row])
        self.UIDsToSendTo.append(self.friendsUID[indexPath.row])
        
        self.SelectableTableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        
    }
    
    @IBAction func SendQuestion(_ sender: Any) {
        switch presentingViewController {
            case is TruthOrDareViewController:
                if self.friendsToSendTo.count != 0 && TruthOrDareViewController.TruthorDareQuestion != ""{
                    for ID in self.UIDsToSendTo{
                        ref.child("Posts").child("\(ID)").child("Truth Or Dare Questions").child(FIRAuth.auth()?.currentUser?.uid as! String).childByAutoId().setValue("\(TruthOrDareViewController.TruthorDareQuestion!)")
                    }
            }
                
                let appdelegate = UIApplication.shared.delegate as! AppDelegate
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let left = storyboard.instantiateViewController(withIdentifier: "left")
                let middle = storyboard.instantiateViewController(withIdentifier: "middle")
                let right = storyboard.instantiateViewController(withIdentifier: "right")
                
                
                let snapContainer = SnapContainerViewController.containerViewWith(left,
                                                                                  middleVC: middle,
                                                                                  rightVC: right, initialStartingPoint: middle
                )
                
                appdelegate.window!.rootViewController = snapContainer
                
                self.window?.rootViewController = snapContainer
                self.window?.makeKeyAndVisible()
            
        
        default:
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let left = storyboard.instantiateViewController(withIdentifier: "left")
        let middle = storyboard.instantiateViewController(withIdentifier: "middle")
        let right = storyboard.instantiateViewController(withIdentifier: "right")
        
        
        let snapContainer = SnapContainerViewController.containerViewWith(left,
                                                                          middleVC: middle,
                                                                          rightVC: right, initialStartingPoint: middle
        )
        
        appdelegate.window!.rootViewController = snapContainer
        
        self.window?.rootViewController = snapContainer
        self.window?.makeKeyAndVisible()
        }
        
        
        
    }
    
    func loadDatabase(){
        
        for (key,value) in SearchUserTableViewController.users{
            print("key" + key)
            ref.child("users").child("\(key)").observe(.value, with: { (snapshot) in
                var user = snapshot.key as! String
                var useruid = snapshot.value as! String
                print("user:" + user)
                self.ref.child("FriendsList").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").child("Friends").observe(.value, with: { (snapshot) in
                    if snapshot.exists() == false || snapshot.hasChildren() == false{
                        if useruid != FIRAuth.auth()?.currentUser?.uid as! String{
                            if SearchUserTableViewController.notAddedFriends.contains(user) == false{
                                SearchUserTableViewController.notAddedFriends.append(user)
                            }
                        }else{
                            
                        }
                        
                    }else{
                        for k in snapshot.value as! [String:Any] {
                            print("k: " + "\(k)")
                            if k.key.contains(user) == false {
                                if useruid != FIRAuth.auth()?.currentUser?.uid as! String{
                                    if SearchUserTableViewController.notAddedFriends.contains(user) == false{
                                        SearchUserTableViewController.notAddedFriends.append(user)
                                    }else{
                                        if SearchUserTableViewController.notAddedFriends.contains(user){
                                            SearchUserTableViewController.notAddedFriends.remove(at: SearchUserTableViewController.notAddedFriends.index(of: user)!)
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                })
                
            })
        }
        //print(SearchUserTableViewController.notAddedFriends)
    }
    
    func reloadDatabase(){
        FIRDatabase.database().reference().child("FriendsList").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").child("Friends").observe(.childAdded, with: { (snapshot) in
            for child in snapshot.children{
                FriendsListViewController.Friends.updateValue(snapshot.value as! String, forKey: snapshot.key as! String)
            }
        })
        
        ref.child("users").observe(.childAdded, with: { (snapshot) in
            for child in snapshot.children{
                SearchUserTableViewController.users.updateValue(snapshot.value as! String, forKey: snapshot.key as! String)
            }}
        )
    }

    
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

}
