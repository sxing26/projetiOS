//
//  ViewController.swift
//  ToDoListLatest
//
//  Created by Jh Xing on 21/04/2021.
//

import UIKit
import RealmSwift




class ToDoListItem: Object {
    @objc dynamic var item: String = ""
    @objc dynamic var date: Date = Date()
    @objc dynamic var details: String? = ""
    @objc dynamic var importance: String = ""
    var subTasks: [ToDoListItem] = [ToDoListItem]()
 //   @objc dynamic var completed: Bool = false
}

class ViewController: UIViewController
//                      , UITableViewDelegate,UITableViewDataSource
{

//    @IBOutlet var table: UITableView!
    @IBOutlet var collectionView: UICollectionView!
    
    /* Initialisation de Realm */
    
    private let realm = try! Realm()
    private var data = [ToDoListItem]()
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        collectionView.collectionViewLayout = layout
        
        collectionView.register(MyCollectionViewCell.nib(), forCellWithReuseIdentifier: MyCollectionViewCell.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
 
        // instantiation initiale de l'objet venant de Realms
        data = realm.objects(ToDoListItem.self).map({ $0 })
        
//        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
//        table.delegate = self
//        table.dataSource = self
    }

//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return data.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//
//        cell.textLabel?.text = data[indexPath.row].item
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        
//        let item = data[indexPath.row]
//
//        // Accès à la vue de tâche unique
//
//        guard let vc = storyboard?.instantiateViewController(identifier: "task") as? TaskViewController else {
//            return
//        }
//
//        vc.item = item
//
//        // Les Handler mettent à jour la base de données Realm
//
//        vc.deletionHandler = {[weak self] in
//            self?.refresh()
//        }
//        vc.navigationItem.largeTitleDisplayMode = .never
//        vc.title = item.item
//        navigationController?.pushViewController(vc, animated: true)
//    }

    
    // Action d'ajout de tâche
    
    @IBAction func didTapAddButton(){
        guard let vc = storyboard?.instantiateViewController(identifier: "enter") as? EntryViewController else {
            return
        }
        
        vc.completionHandler = {[weak self] in
            self?.refresh()
        }
        vc.title = "New Item"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // Raffrachissement des données de Realm
    
    func refresh(){
        data = realm.objects(ToDoListItem.self).map({ $0 })
//        table.reloadData()
        collectionView.reloadData()
    }
}

// Collection View

extension ViewController: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let item = data[indexPath.item]
        
        guard let vc = storyboard?.instantiateViewController(identifier: "task") as? TaskViewController else {
                    return
                }
        
                vc.item = item
        
        vc.deletionHandler = {[weak self] in
                    self?.refresh()
                }
                vc.navigationItem.largeTitleDisplayMode = .never
                vc.title = item.item
                navigationController?.pushViewController(vc, animated: true)
        
    }
}

extension ViewController: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.identifier, for: indexPath) as! MyCollectionViewCell
        
        cell.collectionItemLabel?.text = data[indexPath.item].item
        cell.collectionDateLabel?.text = Self.dateFormatter.string(from: data[indexPath.item].date)
        
        switch data[indexPath.item].importance {
        case "Très important":
            cell.backgroundColor = UIColor(red: 1, green: 0.3, blue: 0, alpha: 1)
            
        case "Important":
            cell.backgroundColor = UIColor(red: 1, green: 0.5, blue: 0, alpha: 1)
            
        case "Moyennement important":
            cell.backgroundColor = UIColor(red: 1, green: 0.8, blue: 0, alpha: 1)
            
        case "Peu important":
            cell.backgroundColor = UIColor(red: 0.8, green: 1, blue: 0, alpha: 1)
            
        case "Pas important":
            cell.backgroundColor = UIColor(red: 0.2, green: 1, blue: 0.2, alpha: 1)
            
        default:
            print("Erreur")
            
        }
        
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
            return CGSize(width: 374, height: 100)
        
        
    }
}
