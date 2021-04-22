//
//  AddSubTaskViewController.swift
//  ToDoListLatest
//
//  Created by Jh Xing on 21/04/2021.
//

import UIKit
import RealmSwift

class AddSubTaskViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate {

    @IBOutlet var subTaskSearchTable: UITableView!
    
    public var completionHandler: (() -> Void)?
    
    let searchController = UISearchController()
    
    private let realm = try! Realm()
    private var subTaskSearchData = [ToDoListItem]()
    var filteredData = [ToDoListItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSearchController()
        
        subTaskSearchData = realm.objects(ToDoListItem.self).map({ $0 })
        
        subTaskSearchTable.register(UITableViewCell.self, forCellReuseIdentifier: "subTaskSearchCell")
        subTaskSearchTable.delegate = self
        subTaskSearchTable.dataSource = self
        
    }
    
    // Search Controller
    
    func initSearchController(){
        searchController.loadViewIfNeeded()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.searchBar.returnKeyType = UIReturnKeyType.done
        definesPresentationContext  = true
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let searchText = searchBar.text ?? ""
        
        filterForSearchText(searchText: searchText)
        
    }
    
    func filterForSearchText(searchText: String){
        filteredData = subTaskSearchData.filter{
            task in
            if(searchController.searchBar.text != ""){
                let searchTextMatch = task.item.lowercased().contains(searchText.lowercased())
                
                return searchTextMatch
            } else {
                return true
            }
        }
        
        subTaskSearchTable.reloadData()

    }
    
    //TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //conditionnels pour utiliser la liste filtrée
        
        if(searchController.isActive){
            return filteredData.count
        }
        return subTaskSearchData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subTaskSearchCell", for: indexPath)
        
        //conditionnels pour utiliser la liste filtrée

        if(searchController.isActive){
            cell.textLabel?.text = filteredData[indexPath.row].item
        } else {
            cell.textLabel?.text = subTaskSearchData[indexPath.row].item
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        var item = subTaskSearchData[indexPath.row]
        
        //conditionnels pour utiliser la liste filtrée

        if(searchController.isActive){
            item = filteredData[indexPath.row]
        }
        
        
        // Retour à EntryViewController
        
        guard let vc = storyboard?.instantiateViewController(identifier: "enter") as? EntryViewController else {
           return
        }
//
//        vc.item = item
//
//        vc.item?.subTasks.append(item)
        
        DataMemory.globalSubTaskData.append(item)
        
        
        // Les Handler mettent à jour la base de données Realm
        
        vc.completionHandler = {[weak self] in
            self?.refresh()
        }
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.title = item.item
        navigationController?.popViewController(animated: true)
    }
    
    func refresh(){
        subTaskSearchData = realm.objects(ToDoListItem.self).map({ $0 })
        subTaskSearchTable.reloadData()
    }

}
