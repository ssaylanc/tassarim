//
//  BucketListView.swift
//  tassarim
//
//  Created by saylanc on 12/12/16.
//  Copyright © 2016 saylanc. All rights reserved.
//

import UIKit
import SwiftyJSON

class BucketListView: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var buckets: [JSON]? = []
    
    @IBOutlet weak var bucketListTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bucketListTableView.dataSource = self
        self.bucketListTableView.delegate = self
        self.bucketListTableView.separatorStyle = .none
        self.loadBucketList()
        
    }
    
    func loadBucketList(){
        DribbbleAPI.sharedInstance.listUsersBuckets{(buckets) in
             if let data = buckets.arrayValue as [JSON]? {
                self.buckets = data
                self.bucketListTableView!.reloadData()
             }
        }
    }
     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.buckets?.count ?? 0
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BucketCell", for: indexPath) as! BucketListTableViewCell
        
        cell.bucketNameLabel.text = self.buckets?[indexPath.row]["name"].string
        
        return cell
    }

}
