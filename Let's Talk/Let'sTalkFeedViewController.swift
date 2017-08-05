//
//  Let'sTalkFeedViewController.swift
//  Let's Talk
//
//  Created by Cameron Bennett on 6/6/17.
//  Copyright © 2017 Cameron Bennett. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import CoreData

class Let_sTalkFeedViewController: UIViewController, UIApplicationDelegate, UITableViewDelegate, UITableViewDataSource {

    var window: UIWindow?
    var userStorage: FIRStorageReference!
    var ref = FIRDatabase.database().reference()
    var selectedIndex: IndexPath?
    var isExpanded = false
    static var TruthOrDareQuestions = [String:String]()
    static var TruthOrDareReplies = [String:String]()
    static var friendRequests = [String:Bool]()
    var Users = [String]()
    var refresh = UIRefreshControl()
    
    var Questions = Array(Let_sTalkFeedViewController.TruthOrDareQuestions.values)
    var Replies = Array(Let_sTalkFeedViewController.TruthOrDareReplies.values)
    var Requests: Array<String> = []
    
    @IBOutlet weak var feedView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        loadAllUsers()
        loadFriends()
        updateFriends()
        loadPosts()
        loadReplies()
        loadRequests()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAllUsers()
        loadFriends()
        updateFriends()
        loadPosts()
        loadReplies()
        loadRequests()
        
        refresh.backgroundColor = UIColor.clear
        loadRefreshControl()
        refresh.addTarget(self, action: #selector(Let_sTalkFeedViewController.refreshData), for: UIControlEvents.valueChanged)
        
        self.feedView.addSubview(refresh)
        
        //print("Questions:" + "\(Let_sTalkFeedViewController.TruthOrDareQuestions.count)")
        feedView.register(TruthOrDareTableViewCell.self, forCellReuseIdentifier: "cell")
        
        
        
    }
    
    
    
        // Do any additional setup after loading the view.
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshData(){
        loadAllUsers()
        loadFriends()
        updateFriends()
        loadPosts()
        loadReplies()
        loadRequests()
        loadDatabase()
        feedView.reloadData()
        refresh.endRefreshing()
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var RowCount = Let_sTalkFeedViewController.TruthOrDareQuestions.count + Let_sTalkFeedViewController.TruthOrDareReplies.count + Let_sTalkFeedViewController.friendRequests.count
        return RowCount
// your number of cell here
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath
        self.didExpandCell()
        let cell = feedView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isExpanded && self.selectedIndex == indexPath{
            if feedView.cellForRow(at: indexPath)?.tag == 2{
               
                return 150
            }else{
            
            return 262
        }
        }
        return 150
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row <= Questions.count - 1 {
        let cell = Bundle.main.loadNibNamed("TruthOrDareTableViewCell", owner: self, options: nil)?.first as! TruthOrDareTableViewCell
        
        cell.questionLabel?.text! = Questions[indexPath.row]
        var sender = ref.child("users").value(forKey: Users[indexPath.row])
        cell.postID = sender as! String
        cell.sendersNameLabel?.text! = sender as! String
            return cell
            
        }else if indexPath.row <= Questions.count + Replies.count - 1{
            
        let cell = Bundle.main.loadNibNamed("TruthOrDareReplyCell", owner: self, options: nil)?.first as! TruthOrDareReplyCell
        //cell.questionLabel.text =
        cell.replyLabel?.text! = Replies[indexPath.row - Questions.count]
        var sender = ref.child("users").value(forKey: Users[indexPath.row])
        cell.postID = sender as! String
        cell.sendersNameLabel?.text! = sender as! String
            return cell
            
        }else{
            let cell = Bundle.main.loadNibNamed("FriendRequestTableViewCell", owner: self, options: nil)?.first as! FriendRequestTableViewCell
            if self.Requests.count >= 0{
            cell.requestID = Requests[indexPath.row - (Questions.count + Replies.count)]
            ref.child("users").observe(.value, with: { (snapshot) in
                let sender = snapshot.childSnapshot(forPath: self.Requests[indexPath.row - (self.Questions.count + self.Replies.count)]).value
                cell.requestName?.text! = sender as! String
            })
            }
            
            return cell
        }

    }
    
    func loadRefreshControl(){
        let refreshContents = Bundle.main.loadNibNamed("refreshView", owner: self, options: nil)
        
        var customView = refreshContents?[0] as! UIView
        customView.frame = refresh.bounds
        customView.backgroundColor = UIColor.clear
        
        var customLbl = customView.viewWithTag(1) as! UILabel
        
        customLbl.textColor = UIColor.red
        customView.backgroundColor = UIColor.blue
        
        self.refresh.addSubview(customView)
        
    }
    
    func didExpandCell(){
        self.isExpanded = !isExpanded
        self.feedView.reloadRows(at: [selectedIndex!], with: .fade)
    }
    
    func loadAllUsers(){
        
        //Loads All Users and their Corresponding ID's
        FIRDatabase.database().reference().child("users").observe(.value, with: { (snapshot) in
            for child in snapshot.value as! [String:Any]{
                SearchUserTableViewController.users.updateValue(child.value as! String, forKey: child.key as! String)
            }}
        )
    }
    
    func updateFriends(){
        //Update Friends database dictionary.
        FIRDatabase.database().reference().child("FriendsList").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").child("Friends").observe(.childAdded, with: { (snapshot) in
            for child in snapshot.children{
                FriendsListViewController.Friends.updateValue(snapshot.value as! String, forKey: snapshot.key as! String)
            }
        })
    }
    
    func loadDatabase(){
        //Handles all friend Requests.
            for (key,value) in SearchUserTableViewController.users{
                FIRDatabase.database().reference().child("users").child("\(key)").observe(.value, with: { (snapshot) in
                    var user = value as! String
                    var useruid = value as! String
                    FIRDatabase.database().reference().child("FriendsList").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").child("Friends").observe(.value, with: { (snapshot) in
                        var friendIds = Array(FriendsListViewController.Friends.values)
                        
                        FIRDatabase.database().reference().child("FriendsList").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").child("FriendsRequest").observe(.value, with: { (picshot) in
                            var requesterUID = picshot.key as! String
                            
                            if (snapshot.exists() == false || snapshot.hasChildren() == false) && (picshot.exists() == false || picshot.hasChildren() == false) {
                                if useruid != FIRAuth.auth()?.currentUser?.uid as! String{
                                    if friendIds.contains(useruid) == false{
                                        if requesterUID != useruid{
                                            if SearchUserTableViewController.notAddedFriends.contains(user) == false{
                                                SearchUserTableViewController.notAddedFriends.append(user)
                                            }
                                        }
                                    }
                                }else{
                                    
                                }
                                
                            }else{
                                for k in snapshot.value as! [String:Any] {
                                    print("k: " + "\(k)")
                                    if k.key.contains(user) == false {
                                        if useruid != FIRAuth.auth()?.currentUser?.uid as! String{
                                            if friendIds.contains(useruid) == false{
                                                if requesterUID != useruid{
                                                    if SearchUserTableViewController.notAddedFriends.contains(user) == false{
                                                        SearchUserTableViewController.notAddedFriends.append(user)
                                                    }
                                                }
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
                })
            }
        }
    
    func loadFriends(){
        //Check friends list and adds all friends along with their pictures to a dictionary and pictures to an array of profile pics.
        FIRDatabase.database().reference().child("FriendsList").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").child("Friends").observe(.value, with: { (snapshot) in
            if snapshot.hasChildren() == true {
                for child in snapshot.value as! [String:Any]{
                    FriendsListViewController.Friends.updateValue(child.value as! String, forKey: child.key as! String)
                    FIRDatabase.database().reference().child("user information").child("\(child.value)").child("image").observe(.value, with: { (snapshot) in
                        if snapshot.value == nil || snapshot.value as! String == ""{
                            FriendsListViewController.friendsProfilePics.updateValue("", forKey: child.key)
                        }else{
                            FriendsListViewController.friendsProfilePics.updateValue(snapshot.value as! String, forKey: child.key)
                        }
                    })
                }
            }
        })
        
    }
    
    func loadPosts(){
        //Goes under current users posts and grabs all truth or dare questions and puts them in a dictionary with the post's user ID's.
        self.Users = []
        FIRDatabase.database().reference().child("Posts").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").child("Truth Or Dare Questions").observe(.value, with: { (snapshot) in
            //print("snapshot.key: \(snapshot.key)")
            if snapshot.exists() == true {
                
                var people = snapshot.value as! [String:Any]
                for k in people {
                //print("k: \(k)")
                var thing = k.value as! [String:String]
                    for t in thing{
                        Let_sTalkFeedViewController.TruthOrDareQuestions.updateValue(t.value, forKey: t.key)
                        self.Users.append(k.key)
                }
            }
            }
            })
    }
    
    func loadReplies(){
        //Goes under current users posts and grabs all truth or dare questions and puts them in a dictionary with the post's user ID's.
        self.Users = []
        FIRDatabase.database().reference().child("Posts").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").child("Truth Or Dare Replies").observe(.value, with: { (snapshot) in
            //print("snapshot.key: \(snapshot.key)")
            if snapshot.exists() == true {
                
                var people = snapshot.value as! [String:Any]
                for k in people {
                    //print("k: \(k)")
                    var thing = k.value as! [String:String]
                    for t in thing{
                        Let_sTalkFeedViewController.TruthOrDareReplies.updateValue(t.value, forKey: t.key)
                        self.Users.append(k.key)
                        
                    }
                }
            }
        })
    }
    
    func loadRequests(){
        FIRDatabase.database().reference().child("FriendsList").child(FIRAuth.auth()?.currentUser?.uid as! String).child("FriendRequest").observe(.value, with: { (snapshot) in
            print("Snapthot: \(snapshot.value)")
            for person in snapshot.value as! [String:Any]{
                Let_sTalkFeedViewController.friendRequests.updateValue(person.value as! Bool, forKey: person.key)
                
            }
            for that in Let_sTalkFeedViewController.friendRequests as! [String:Bool]{
                    if that.value == false{
                        self.Requests.append(that.key)
                        print(self.Requests)
                }
                }
        })
    }

    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

