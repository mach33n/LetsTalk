//
//  SignUpViewController.swift
//  Let's Talk
//
//  Created by Cameron Bennett on 5/30/17.
//  Copyright © 2017 Cameron Bennett. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase

class SignUpViewController: UIViewController, UIApplicationDelegate, UITextFieldDelegate{

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var emailText: UITextField!

    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    var ref: FIRDatabaseReference!
    var window: UIWindow?
    var userStorage: FIRStorageReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        
        self.emailText.delegate = self
        self.usernameText.delegate = self
        self.passwordText.delegate = self
        
        
        let storage = FIRStorage.storage().reference(forURL: "gs://lets-talk-bbf3f.appspot.com/")
        
        ref = FIRDatabase.database().reference()
        userStorage = storage.child("users")
        
        // Do any additional setup after loading the view.
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        usernameText.resignFirstResponder()
        emailText.resignFirstResponder()
        passwordText.resignFirstResponder()
        return (true)
    }
    
    @IBAction func CreateAccount(_ sender: Any) {
        if emailText.text != "" || usernameText.text != "" || passwordText.text != "" {
            
            
            
                    FIRAuth.auth()?.createUser(withEmail: emailText.text!, password: passwordText.text!, completion: { (user, error) in
                
                        if error != nil{
                        if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                            
                            switch errCode {
                            case .errorCodeInvalidEmail:
                                self.errorLabel.text = "Invalid Email address"
                            case .errorCodeEmailAlreadyInUse:
                                self.errorLabel.text = "Email in use"
                            case .errorCodeOperationNotAllowed:
                                self.errorLabel.text = "Email account is not enabled"
                            case .errorCodeWeakPassword:
                                self.errorLabel.text = "Make a Stronger password"
                            default:
                                print("Create User Error: \(error!)")
                            }
                        }
                }else{
                    
                
            self.ref.child("users").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").setValue("\(self.usernameText.text!)")
            
            self.ref.child("user information").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").child("email").setValue("\(self.emailText.text!)")
            self.ref.child("user information").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").child("password").setValue("\(self.passwordText.text!)")
            
                            let imageRef = self.userStorage.child("\(FIRAuth.auth()?.currentUser?.uid as! String).jpg")
                            
                            let data = UIImageJPEGRepresentation(#imageLiteral(resourceName: "default-pupil-profile.png"), 0.5)
                            
                            let uploadTask = imageRef.put(data!, metadata: nil, completion: { (metadata, err) in
                                if err != nil {
                                    print(err!.localizedDescription)
                                }
                                
                                imageRef.downloadURL(completion: { (url, er) in
                                    if er != nil {
                                        print(er!.localizedDescription)
                                    }
                                    if let url = url{
                                        self.ref.child("user information").child("\(FIRAuth.auth()?.currentUser?.uid as! String)").child("image").setValue("\(url.absoluteString as! String)")
                                    }
                                }
                                )
                                
                            }
                            )
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
                            
                }
            })
            
           
        }else{
            errorLabel.text = "Fill out all fields!"
            
        }
        
    }
    
    
   

}
