//
//  SearchUserTableViewController.swift
//  Let's Talk
//
//  Created by Cameron Bennett on 6/1/17.
//  Copyright © 2017 Cameron Bennett. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class SearchUserTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate, CustomSearchControllerDelegate, UIApplicationDelegate {

    @IBOutlet var tblSearchResults: UITableView!
    
    var window: UIWindow?
    
    var ref = FIRDatabase.database().reference()
    
    static var users = [String:Any]()
    
    var allUsers = Array(SearchUserTableViewController.users.keys)
    
    var allUserIDs = Array(SearchUserTableViewController.users.values)
    
    var friendlyUsers = Array(FriendsListViewController.Friends.keys)
    
    var filteredArray = [String]()
    
    var shouldShowSearchResults = false
    
    var searchController: UISearchController!
    
    var customSearchController: CustomSearchController!
    
    var handle: UInt = 0
    
    static var notAddedFriends = [String]()
    
    static var notAddedIDs = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("NotAddedFriends #1: \(SearchUserTableViewController.notAddedFriends)")
        
        tblSearchResults.delegate = self
        tblSearchResults.dataSource = self
        tblSearchResults.allowsSelection = true
        configureCustomSearchController()
        
        loadDatabase()
        tableView.reloadData()
       
           }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        if shouldShowSearchResults {
            return filteredArray.count
        }
        else {
        return 0
    }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        if shouldShowSearchResults {
            cell.textLabel?.text = filteredArray[indexPath.row]
        }
        else {
           
        }
    
        return cell
    }
        
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        var id = ""
        
            for bleh in SearchUserTableViewController.users{
                if bleh.value as! String == tableView.cellForRow(at: indexPath)?.textLabel?.text as! String{
                    id = bleh.key
                    print(id)
                }
            }
        
        var myIndex = indexPath.row
        
            if FIRAuth.auth()?.currentUser?.uid == id as! String{
                
            }else{
            
        FIRDatabase.database().reference().child("FriendsList").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").child("FriendRequest").child("\(id as! String)").setValue(true)
                
                 self.handle = FIRDatabase.database().reference().child("FriendsList").child(id as! String).child("FriendRequest").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").observe(.value, with: { (picshot) in
                    if picshot.exists() == true{
                    if picshot.value as! Bool == true {
                        
                    FIRDatabase.database().reference().child("FriendsList").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").child("Friends").child("\(id as! String)").setValue(cell.detailTextLabel?.text as! String)
                        
                        FIRDatabase.database().reference().child("FriendsList").child("\(id as! String)").child("Friends").child("\(self.allUsers[self.find(objecToFind: FIRAuth.auth()?.currentUser?.uid)!])").setValue(FIRAuth.auth()?.currentUser?.uid as! String)
                    self.ref.child("FriendsList").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").child("FriendRequest").child("\(id as! String)").removeValue(completionBlock: { (error, ref) in
                        if error != nil {
                            print("error \(error)")
                        }
                    })
                    }else{
                        //send request
                    }
                    }else{
                        FIRDatabase.database().reference().child("FriendsList").child(id as! String).child("FriendRequest").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").setValue(false)
                    }
                })
                
                
    
                
                
            self.loadDatabase()
            tableView.reloadData()
            }
        
    }
    
    @IBAction func refreshButton(_ sender: Any) {
        loadDatabase()
        tableView.reloadData()
        tableView.reloadData()
    }
    
    @IBAction func doneButton(_ sender: Any) {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let left = storyboard.instantiateViewController(withIdentifier: "left")
        let middle = storyboard.instantiateViewController(withIdentifier: "middle")
        let right = storyboard.instantiateViewController(withIdentifier: "right")
        
        
        let snapContainer = SnapContainerViewController.containerViewWith(left,
                                                                          middleVC: middle,
                                                                          rightVC: right,
                                                                          initialStartingPoint: left
        )
        
        appdelegate.window!.rootViewController = snapContainer
        
        self.window?.rootViewController = snapContainer
        self.window?.makeKeyAndVisible()
        
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
        print("Not added Friends: \(SearchUserTableViewController.notAddedFriends)")
    }
    func configureSearchController() {
        // Initialize and perform a minimum configuration to the search controller.
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self as? UISearchResultsUpdating
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.delegate = self as? UISearchBarDelegate
        searchController.searchBar.sizeToFit()
        
        // Place the search bar view to the tableview headerview.
        tblSearchResults.tableHeaderView = searchController.searchBar
    }

    func configureCustomSearchController() {
        customSearchController = CustomSearchController(searchResultsController: self, searchBarFrame: CGRect(x: 0.0, y: 0.0, width: tblSearchResults.frame.size.width, height: 50.0), searchBarFont: UIFont(name: "Futura", size: 16.0)!, searchBarTextColor: UIColor.black, searchBarTintColor: UIColor.orange)
        
        customSearchController.customSearchBar.placeholder = "Add Friends!"
        tblSearchResults.tableHeaderView = customSearchController.customSearchBar
        
        customSearchController.customDelegate = self as! CustomSearchControllerDelegate
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        shouldShowSearchResults = true
        tblSearchResults.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        tblSearchResults.reloadData()
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            tblSearchResults.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }

    func updateSearchResults(for searchController: UISearchController) {
        guard let searchString = searchController.searchBar.text else {
            return
        }
        
        
        filteredArray = SearchUserTableViewController.notAddedFriends.filter({ (user) -> Bool in
            let userSearchText:NSString = user as NSString
            
            return (userSearchText.range(of: searchString, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound
        })
        
        // Reload the tableview.
        tblSearchResults.reloadData()
    }
    
    
    // MARK: CustomSearchControllerDelegate functions
    
    func didStartSearching() {
        shouldShowSearchResults = true
        tblSearchResults.reloadData()
    }
    
    
    func didTapOnSearchButton() {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            tblSearchResults.reloadData()
        }
    }
    
    
    func didTapOnCancelButton() {
        shouldShowSearchResults = false
        tblSearchResults.reloadData()
    }
    
    
    func didChangeSearchText(_ searchText: String) {
        // Filter the data array and get only those countries that match the search text.
        filteredArray = SearchUserTableViewController.notAddedFriends.filter({ (user) -> Bool in
            let userSearchText: NSString = user as NSString
            
            return (userSearchText.range(of: searchText, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound
        })
        
        // Reload the tableview.
        tblSearchResults.reloadData()
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
