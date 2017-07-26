//
//  ProfileViewController.swift
//  
//
//  Created by Cameron Bennett on 6/8/17.
//
//

import UIKit
import Firebase
import FirebaseStorage

class ProfileViewController: UIViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    var window: UIWindow?
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
   
    let picker = UIImagePickerController()
    var userStorage: FIRStorageReference!
    var ref = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        picker.delegate = self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
        
        let storage = FIRStorage.storage().reference(forURL: "gs://lets-talk-bbf3f.appspot.com/")
        
        ref = FIRDatabase.database().reference()
        userStorage = storage.child("users")
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SelectButton(_ sender: Any) {
        
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        
        present(picker, animated: true, completion: nil)
        
    }
    
    @objc(imagePickerController:didFinishPickingMediaWithInfo:) func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String:Any]){
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            self.profileImage.image = image
            //backButton.isHidden = false
        }
        self.dismiss(animated: true, completion: nil)
    
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        let imageRef = self.userStorage.child("\(FIRAuth.auth()?.currentUser?.uid as! String).jpg")
        
        if self.profileImage.image != nil{
        let data = UIImageJPEGRepresentation(self.profileImage.image as! UIImage, 0.5)
        
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
        
        }else{
           
        }
    }
    @IBAction func BackButton(_ sender: Any) {
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


