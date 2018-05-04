//
//  ViewController.swift
//  Geometry
//
//  Created by Per Friis on 04/05/2018.
//  Copyright © 2018 Per Friis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var aTextField: UITextField!
    @IBOutlet weak var bTextField: UITextField!
    @IBOutlet weak var cTextField: UITextField!
    
    @IBOutlet weak var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Called from all the steppers, the tag value is set in the storyboard editor
    @IBAction func StepperValueChanged(_ sender: UIStepper) {
        switch sender.tag {
        case 0:
            incrementTextField(textField: aTextField,stepper: sender)
            
        case 1:
            incrementTextField(textField: bTextField, stepper: sender)
            
        case 2:
            incrementTextField(textField: cTextField, stepper: sender)
            
        default:
            break
        }
    }
    
    
    @IBAction func submitValues(_ sender: Any) {
        guard let aText = aTextField.text,
            let a = Int(aText),
            let bText = bTextField.text,
            let b = Int(bText),
            let cText = cTextField.text,
            let c = Int(cText),
            c > a, c > b else {
                let alertController = UIAlertController(title: NSLocalizedString("Value error", comment: "value error title"),
                                                        message: NSLocalizedString("There is an issue with one or more of the values, make sure all fields only contains numbers, and C holds the largest value", comment: "message comment"), preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "error - Ok button title"), style: .cancel, handler: nil))
                
                present(alertController, animated: true, completion: nil)
                
                return
        }
        
        submit(a: a, b: b, c: c) { (result, success, error) in
            DispatchQueue.main.async {
                
                
                if success {
                    self.resultLabel.textColor = .blue
                    self.resultLabel.text = result
                } else {
                    self.resultLabel.textColor = .red
                    self.resultLabel.text = "\(result)\nerror:\(error?.localizedDescription ?? "No detail error")"
                }
            }
        }
    }
}



/// utility functions
extension ViewController {
    /// Increment the integer value in the textfield with stepper's value
    func incrementTextField(textField:UITextField,stepper:UIStepper) {
        guard let text = textField.text,
            let value = Int(text)  else {
                textField.textColor = UIColor.red
                return
        }
        textField.textColor = UIColor.blue
        var steppedValue = value + Int(stepper.value)
        if steppedValue < 0 {
            steppedValue = 0
        }
        textField.text = "\(steppedValue)"
        stepper.value = 0
    }
    
    /// Call the backend asyncron, use the block to update the UI
    func submit(a:Int, b:Int, c:Int, completeBlock:@escaping (_ response:String, _ success:Bool, _ error:Error?) -> Void) {
        let url = URL(string: "https://geometric-api.azurewebsites.net/api/Geometry?a=\(a)&b=\(b)&c=\(c)")!
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, urlResponse, error) in
            guard error == nil else {
                completeBlock(NSLocalizedString("Error", comment: "Error response"),false,error)
                return
            }
            
            let httpResponse = urlResponse as! HTTPURLResponse
            guard httpResponse.statusCode == 200 else {
                completeBlock(NSLocalizedString("The api returned an error", comment: "error string"),false,nil)
                return
            }
            
            
            guard let data = data else {
                completeBlock(NSLocalizedString("The Api, didn't return any data", comment: "data error string"),false,nil)
                return
            }
            
            completeBlock(String(data: data, encoding: .utf8) ?? "fatal error",true,nil)
            
        }
        task.resume()        
    }
}

