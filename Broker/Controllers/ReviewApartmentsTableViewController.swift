//
//  ReviewApartmentsTableViewController.swift
//  Broker
//
//  Created by to0 on 5/13/15.
//  Copyright (c) 2015 roomhunter. All rights reserved.
//

import UIKit

class ReviewApartmentsTableViewController: UITableViewController {
    
    let list = ApartmentProfileList()
    var isRefreshing = false

    override func viewDidLoad() {
        super.viewDidLoad()
        list.refreshData({
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        })
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: "refreshTable:", forControlEvents: UIControlEvents.ValueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func refreshTable(sender: UIRefreshControl) {
        // because this method always excuted in main thread, so it is safe. more investigation required
        if isRefreshing == true {
            return
        }
        isRefreshing == true
        list.refreshData({
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                self.isRefreshing = false
            })
        })
    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return list.data.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ReviewApartmentCell", forIndexPath: indexPath) as! ReviewApartmentCell
        let row = indexPath.row
        let item = list.data[row]
        cell.addressLabel.text = item.address
        cell.priceLabel.text = item.priceString
        cell.status = item.status
        cell.coverImageView.sd_setImageWithURL(item.thumbnail)
        return cell
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        let row = indexPath.row
        let item = list.data[row]
        if item.status == .SoldOut {
            return false
        }
        else {
            return true
        }
    }
    

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let row = indexPath.row
            APIModel.sharedInstance.removeApartment(list.data[row].id, success: {
                (res: NSDictionary) in
                
                }, fail: {
                    (err: NSError) in
            })
            list.data.removeAtIndex(row)
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
        return "Remove"
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
