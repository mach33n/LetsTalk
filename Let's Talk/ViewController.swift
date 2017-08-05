//
//  ViewController.swift
//  Let's Talk
//
//  Created by Cameron Bennett on 5/30/17.
//  Copyright © 2017 Cameron Bennett. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn

class ViewController: UIViewController, GIDSignInUIDelegate, UIApplicationDelegate, UITextFieldDelegate{

    var window: UIWindow?
    
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var googleButton: GIDSignInButton!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailText.delegate = self
        self.passwordText.delegate = self
        /*FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if user != nil {
                self.performSegue(withIdentifier: "toHome", sender: nil)
            } else {
                
            }
        }*/
        
        
        
        // TODO(developer) Configure the sign-in button look/feel
        // ...
    }

    override func viewWillAppear(_ animated: Bool) {
        
        /*if FIRAuth.auth()?.currentUser?.uid != nil {
            performSegue(withIdentifier: "toHome", sender: nil)}
 
        //bypass authentication process
        */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        emailText.resignFirstResponder()
        passwordText.resignFirstResponder()
        return (true)
    }
    
    func loadDatabase(){
        
        FIRDatabase.database().reference().child("users").observe(.value, with: { (snapshot) in
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
    
    
    @IBAction func LogIn(_ sender: Any) {
        
        if emailText.text != "" || passwordText.text != ""{
            
            FIRAuth.auth()?.signIn(withEmail: emailText.text! , password: passwordText.text!, completion: { (user, error) in
                
            
                if error != nil{
                    if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                        
                        
                        switch errCode {
                        case .errorCodeInvalidEmail:
                            self.errorLabel.text = "Invalid Email"
                        case .errorCodeTooManyRequests:
                            self.errorLabel.text = "Servers currently over run"
                        case .errorCodeUserNotFound:
                            self.errorLabel.text = "User Not Found"
                        case .errorCodeNetworkError:
                            self.errorLabel.text = "Network Error check your connection"
                        case .errorCodeOperationNotAllowed:
                            self.errorLabel.text = "Sign Up first."
                        case .errorCodeWrongPassword:
                            self.errorLabel.text = "Incorrect Password."
                        default:
                            print("Create User Error: \(error!)")
                        }
                    }
                }else{
                    
                    
                    
                    
                    let appdelegate = UIApplication.shared.delegate as! AppDelegate
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let left = storyboard.instantiateViewController(withIdentifier: "left")
                    let middle = storyboard.instantiateViewController(withIdentifier: "middle")
                    let right = storyboard.instantiateViewController(withIdentifier: "right")
                    
                    
                    let snapContainer = SnapContainerViewController.containerViewWith(left,
                                                                                      middleVC: middle,
                                                                                      rightVC: right,
                                                                                      initialStartingPoint: middle
                    )
                    
                    appdelegate.window!.rootViewController = snapContainer
                    
                    self.window?.rootViewController = snapContainer
                    self.window?.makeKeyAndVisible()
                    
                    self.loadDatabase()
                    self.loadDatabase()
                }
                
            })
        }else{
            
            errorLabel.text = "Input All Fields!"
        }
    }
    
    
    
   /*
    @IBAction func googleButtonPressed(_ sender: Any) {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        
        func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
            -> Bool {
                return GIDSignIn.sharedInstance().handle(url,
                                                         sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                         annotation: [:])
        }
    }
        
        func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
            
            if error != nil {
                // ...
                return
            }
            
            guard let authentication = user.authentication else { return }
            let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                           accessToken: authentication.accessToken)
            // ...
            FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                // ...
                if error != nil {
                    // ...
                    return
                }
            }
        }
        
        func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
            // Perform any operations when the user disconnects from app here.
            // ...
            
            
        
    }*/
    
    @IBAction func SignUp(_ sender: Any) {
        
    }
    
    



}

