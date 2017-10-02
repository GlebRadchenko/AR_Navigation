//
//  SearchTableViewController.swift
//  AR_Navigation
//
//  Created by Gleb on 10/2/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import UIKit
import MapKit

extension MKMapItem: SearchResultDisplayable {
    var mainInfo: String {
        return ""
    }
    
    var subInfo: String {
        return ""
    }
}

class SearchTableViewController<T: SearchResultDisplayable>: UITableViewController {

    var items: [T] = []
    
    var multipleSelectionEnabled: Bool {
        set { tableView.allowsMultipleSelection = newValue }
        get { return tableView.allowsMultipleSelection }
    }
    
    var onSelectItem: ((_ item: T) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearsSelectionOnViewWillAppear = true
        
        view.backgroundColor = .clear
        tableView.backgroundColor = .clear
        
        tableView.register(SearchResultTableViewCell.self)
        tableView.allowsSelection = true
    }
    
    func reload(with items: [T], multipleSelectionEnabled: Bool = false) {
        self.items = items
        self.multipleSelectionEnabled = multipleSelectionEnabled
        
        tableView.reloadData()
    }
    
    func clear() {
        items.removeAll()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelectItem?(items[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SearchResultTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        
        cell.configure(with: items[indexPath.row])
        
        return cell
    }
}
