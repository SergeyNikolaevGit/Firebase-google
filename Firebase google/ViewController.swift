//
//  ViewController.swift
//  AWS with Parse
//
//  Created by Sergey Nikolaev on 2/7/18.
//  Copyright © 2018 Sergey Nikolaev. All rights reserved.
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is furnished
//to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.

import UIKit
import FirebaseDatabase

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var itemsTableView: UITableView!
    @IBOutlet var dataFelds: [UITextField]!
    @IBOutlet var formView: UIView!
    @IBOutlet var blackScreen: UIView!
    @IBOutlet var passwordView: UIView!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var addButton: UIBarButtonItem!
    
    var alertView = UIAlertController()
    
    var ref:DatabaseReference!
    
    var keysArray = Array<String>()
    var dataArray = Array<String>()
    var value1Array = Array<String>()
    var value2Array = Array<String>()
    
    var adminIsLogin = false
    var adminPass:String = "nhfi&63jJd7"
    var enabledEditMode = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formView.isHidden = true
        formView.layer.cornerRadius = 8
        
        blackScreen.isHidden = true
        blackScreen.backgroundColor = UIColor.black
        
        itemsTableView.delegate = self
        itemsTableView.dataSource = self
        
        itemsTableView.layer.cornerRadius = 8
        
        dataFelds[0].placeholder = "Name"
        dataFelds[1].placeholder = "Value 1"
        dataFelds[1].keyboardType = UIKeyboardType.numbersAndPunctuation
        dataFelds[2].placeholder = "value 2"
        dataFelds[2].keyboardType = UIKeyboardType.numbersAndPunctuation
        
        passwordView.isHidden = true
        passwordView.layer.cornerRadius = 8
        
        
        
        ref = Database.database().reference()
        
        let dataSnap = ref.child("dataBase")
        let adminPassSnap = ref.child("pass")
        
        dataSnap.observe(DataEventType.value) { (snapshot) in
            
            self.keysArray = []
            self.dataArray = []
            self.value1Array = []
            self.value2Array = []
            
            for child in (snapshot.children) {
                
                let snap = child as! DataSnapshot
                
                let dict = snap.value as! [String:String]
                let dataName = dict["name"]
                let value1 = dict["value1"]
                let value2 = dict["value2"]
                
                self.keysArray.append(snap.key)
                self.dataArray.append(dataName!)
                self.value1Array.append(value1!)
                self.value2Array.append(value2!)
                
            }
            
            self.itemsTableView.reloadData()
            
        }
        
        adminPassSnap.observe(DataEventType.value) { (snapshot) in
            
            for child in (snapshot.children) {
                
                let snap = child as! DataSnapshot
                
                let dict = snap.value as! [String:NSNumber]
                let password = dict["admin"]
                self.adminPass = String(describing: password!)
                
            }
            
        }
        
    }
    
    @IBAction func addItem(_ sender: Any) {
        
        dataFelds[0].text = ""
        dataFelds[1].text = ""
        dataFelds[2].text = ""
        
        formView.isHidden = false
        blackScreen.isHidden = false
        
        formView.alpha = 0
        blackScreen.alpha = 0
        
        UIView.animate(withDuration: 1) {
            self.formView.alpha = 1
            self.blackScreen.alpha = 0.5
        }
        
    }
    
    @IBAction func saveData(_ sender: Any) {
        
        if dataFelds[0].text != "" && dataFelds[1].text != "" && dataFelds[2].text != "" {
            
            let city = ["name":"\(String(describing: dataFelds[0].text!))",
                "value1":"\(String(describing: dataFelds[1].text!))",
                "value2":"\(String(describing: dataFelds[2].text!))"]
            
            ref.child("dataBase").childByAutoId().setValue(city)
            
            
            UIView.animate(withDuration: 1, animations: {
                self.formView.alpha = 0
            })
            
            self.formView.isHidden = true
            self.blackScreen.isHidden = true
            view.endEditing(true)
            
        } else {
            
            alertView = UIAlertController(title: "Save to base", message: "Please compleate form", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "OK", style: .`default`, handler: { _ in

                
                
            }))
            
            self.present(alertView, animated: true, completion: nil)
        }
        
    }
    

    @IBAction func cancellSaved(_ sender: Any) {
        
        self.formView.isHidden = true
        self.blackScreen.isHidden = true
        view.endEditing(true)
        
    }
    
    
    @IBAction func deleteObjectFromBase(_ sender: UIButton) {

        ref.child("dataBase").child(sender.restorationIdentifier!).removeValue()
        
        
    }
    
    
    
    @IBAction func removeItem(_ sender: Any) {
        
        passwordField.text = ""
        
        if enabledEditMode == true {
            
            addButton.isEnabled = true
            editButton.title = "Edit"
            enabledEditMode = false
            adminIsLogin = false
            itemsTableView.reloadData()
            
            
        } else {
            
            passwordView.isHidden = false
            blackScreen.isHidden = false
            
            passwordView.alpha = 0
            blackScreen.alpha = 0
            
            UIView.animate(withDuration: 1, animations: {
                
                self.passwordView.alpha = 1
                self.blackScreen.alpha = 0.5
                
                
            })
            
        }
        
    }
    
    @IBAction func checkPassword(_ sender: Any) {
        
        if passwordField.text == adminPass {
            
            adminIsLogin = true
            enabledEditMode = true
            
            itemsTableView.reloadData()
            
            passwordView.isHidden = true
            blackScreen.isHidden = true
            view.endEditing(true)
            
            
        } else {
            
            alertView = UIAlertController(title: "Admin login", message: "Password not compare", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "OK", style: .`default`, handler: { _ in
                print("The OK alert occured.")
                
            }))
            
            self.present(alertView, animated: true, completion: nil)
        }
        
        if enabledEditMode == true {
            
            editButton.title = "Out"
            addButton.isEnabled = false
            
        }
        
    }
    
    @IBAction func dismissPassword(_ sender: Any) {
        
        passwordView.isHidden = true
        blackScreen.isHidden = true
        view.endEditing(true)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keysArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCell
        cell.deleteRowButton.setTitle("Dell \(indexPath.row)", for: .normal)
        
        if adminIsLogin == false {
            cell.deleteRowButton.isHidden = true
        } else {
            cell.deleteRowButton.isHidden = false
            cell.deleteRowButton.restorationIdentifier = keysArray[indexPath.row]
        }
        
        cell.cellLabel.text? = dataArray[indexPath.row]
        cell.coordinateLabel.text? = "\(value1Array[indexPath.row]) - \(value2Array[indexPath.row])"
        
        return cell
        
    }
    
}



