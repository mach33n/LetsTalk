//
//  QuestionSelectViewController.swift
//  Let's Talk
//
//  Created by Cameron Bennett on 6/14/17.
//  Copyright © 2017 Cameron Bennett. All rights reserved.
//

import UIKit

class QuestionSelectViewController: UIViewController {

    @IBOutlet weak var TruthorDareButton: UIButton!
    @IBOutlet weak var NeverHaveIEverButton: UIButton!
    @IBOutlet weak var WouldYouRatherButton: UIButton!
    @IBOutlet weak var twentyOneQuestionsButton: UIButton!
    @IBOutlet weak var ShortAnswerButton: UIButton!
   
    override func viewDidLoad() {
        super.viewDidLoad()

        TruthorDareButton.layer.cornerRadius = 25
        TruthorDareButton.layer.borderColor = UIColor.black.cgColor
        TruthorDareButton.layer.borderWidth = 6
        
        NeverHaveIEverButton.layer.cornerRadius = 25
        NeverHaveIEverButton.layer.borderColor = UIColor.black.cgColor
        NeverHaveIEverButton.layer.borderWidth = 6
        
        WouldYouRatherButton.layer.cornerRadius = 25
        WouldYouRatherButton.layer.borderColor = UIColor.black.cgColor
        WouldYouRatherButton.layer.borderWidth = 6
        
        twentyOneQuestionsButton.layer.cornerRadius = 25
        twentyOneQuestionsButton.layer.borderColor = UIColor.black.cgColor
        twentyOneQuestionsButton.layer.borderWidth = 6
        
        ShortAnswerButton.layer.cornerRadius = 25
        ShortAnswerButton.layer.borderColor = UIColor.black.cgColor
        ShortAnswerButton.layer.borderWidth = 6
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
