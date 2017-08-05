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
   
    override func viewDidLoad() {
        super.viewDidLoad()

        TruthorDareButton.layer.cornerRadius = 25
        TruthorDareButton.layer.borderColor = UIColor.black.cgColor
        TruthorDareButton.layer.borderWidth = 6
        
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
