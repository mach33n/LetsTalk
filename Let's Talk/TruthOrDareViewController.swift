//
//  TruthOrDareViewController.swift
//  Let's Talk
//
//  Created by Cameron Bennett on 6/15/17.
//  Copyright © 2017 Cameron Bennett. All rights reserved.
//

import UIKit
import Firebase

class TruthOrDareViewController: UIViewController {

    var window: UIWindow?
    static var TruthorDareQuestion: String?
    
    @IBOutlet weak var TruthOrDareQuestionText: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeToDare(_ sender: Any) {
        TruthOrDareQuestionText.placeholder = "Dare"
    }

    @IBAction func RandomQuestion(_ sender: Any) {
        
    }
    
    @IBAction func TruthOrDareSend(_ sender: Any) {
        if TruthOrDareQuestionText.text != ""{
            
        TruthOrDareViewController.TruthorDareQuestion = TruthOrDareQuestionText.text
            
            performSegue(withIdentifier: "toSend", sender: nil)
    }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let left = storyboard.instantiateViewController(withIdentifier: "left")
        let middle = storyboard.instantiateViewController(withIdentifier: "middle")
        let right = storyboard.instantiateViewController(withIdentifier: "right")
        
        
        let snapContainer = SnapContainerViewController.containerViewWith(left,
                                                                          middleVC: middle,
                                                                          rightVC: right, initialStartingPoint: right
        )
        
        appdelegate.window!.rootViewController = snapContainer
        
        self.window?.rootViewController = snapContainer
        self.window?.makeKeyAndVisible()
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
