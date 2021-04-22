//
//  EntryViewController.swift
//  ToDoListLatest
//
//  Created by Jh Xing on 21/04/2021.
//

import RealmSwift
import UIKit

class DataMemory {
    static var globalSubTaskData = [ToDoListItem]()
}

class EntryViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet var textField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var detailsField: UITextView?
    @IBOutlet var importancePicker: UIPickerView!
    @IBOutlet var subTaskTable: UITableView!
    
    private let importancePickerData: [String] = ["Pas important", "Peu important", "Moyennement important", "Important", "Très important"]
    
    private var subTaskData: [ToDoListItem] = [ToDoListItem]()
    public var item: ToDoListItem?
    
    private let realm = try! Realm()
    public var completionHandler: (() -> Void)?
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // unwrap de item
        
        if (item != nil){
            subTaskData = item!.subTasks
        }
        
        
        
        // Positionner le "curseur" sur le champ de nom de la tâche
        textField.becomeFirstResponder()
        
        textField.delegate = self
        detailsField?.delegate = self
        importancePicker.delegate = self
        subTaskTable.delegate = self
        
        importancePicker.dataSource = self
        subTaskTable.dataSource = self
        
        datePicker.setDate(Date(), animated: true)
        
        DataMemory.globalSubTaskData = subTaskData
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSaveButton))
    }
    
    // code à exécuter quand on revient de "Ajouter une nouvelle sous-tâche"
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        subTaskData = DataMemory.globalSubTaskData
        subTaskTable.reloadData()

    }
    
    // Retrait du clavier
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    // Importance Picker
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return importancePickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return importancePickerData[row]
    }
    
    // TableView des sous-tâches
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subTaskData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subTaskTableCell", for: indexPath)
        
        cell.textLabel?.text = subTaskData[indexPath.row].item
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
            
        //suppression des sous-tâches en cliquant
        
        DataMemory.globalSubTaskData.remove(at: indexPath.row)
        subTaskData.remove(at: indexPath.row)
        
        subTaskTable.reloadData()

    }
    
    func refresh(){
        subTaskTable.reloadData()
    }
    
    
    
    // Action de sauvegarde d'une nouvelle tâche
    
    @objc func didTapSaveButton(){

        if let text = textField.text, !text.isEmpty {
            let date = datePicker.date
            let details = detailsField?.text
            let imp = importancePickerData[importancePicker.selectedRow(inComponent: 0)]
            let subT = subTaskData
            
            
            // Mise à jout de l'objet Realm
            
            realm.beginWrite()
            
            let newItem = ToDoListItem()
            newItem.date = date
            newItem.item = text
            newItem.details = details
            newItem.importance = imp
            newItem.subTasks = subT
            realm.add(newItem)
            try! realm.commitWrite()
            
            // Les Handler mettent à jour la base de données Realm
            
            completionHandler?()
            navigationController?.popToRootViewController(animated: true)
        }else{
            print("Add something")
        }
    }
    
    @IBAction func didTapAddSubTaskButton(){
        
        guard let vc = storyboard?.instantiateViewController(identifier: "addSubTask") as? AddSubTaskViewController else {
            return
        }
        
        vc.completionHandler = {[weak self] in
            self?.refresh()
        }
        
        vc.title = "Ajouter une sous-tâche"
        navigationController?.pushViewController(vc, animated: true)

    }

}
