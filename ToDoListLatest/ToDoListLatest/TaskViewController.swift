//
//  TaskViewController.swift
//  ToDoListLatest
//
//  Created by Jh Xing on 21/04/2021.
//

import UIKit
import RealmSwift

class TaskViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    public var item: ToDoListItem?
    public var deletionHandler: (() -> Void)?
    
    @IBOutlet var itemLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var detailsTextView: UITextView?
    @IBOutlet var importanceLabel: UILabel!
    @IBOutlet var taskSubTaskTable: UITableView!
    
    private let realm = try! Realm()
    
    private var taskSubTaskSearchData = [ToDoListItem]()
    // Format de la date
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        taskSubTaskTable.delegate = self
        taskSubTaskTable.dataSource = self
        
        // Tire les informations de Realm
        
        itemLabel.text = item?.item
        dateLabel.text = Self.dateFormatter.string(from: item!.date)
        detailsTextView?.text = item?.details
        
        importanceLabel?.text = item?.importance
        taskSubTaskSearchData = item?.subTasks ?? []
        print(taskSubTaskSearchData)
        

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didTapDelete))
    }
    
    
    //Table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskSubTaskSearchData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskSubTaskTableCell", for: indexPath)
        
        cell.textLabel?.text = taskSubTaskSearchData[indexPath.row].item
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc private func didTapDelete() {
        guard let myItem = self.item else {
            return
        }
        
        // Mise à jout de l'objet Realm
        
        realm.beginWrite()
        realm.delete(myItem)
        try! realm.commitWrite()
        
        // Les Handler mettent à jour la base de données Realm

        deletionHandler?()
        navigationController?.popToRootViewController(animated: true)
        
    }


}
