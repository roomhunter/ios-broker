//
//  ReviewApartmentsTableViewController.swift
//  Broker
//
//  Created by to0 on 5/13/15.
//  Copyright (c) 2015 roomhunter. All rights reserved.
//

import UIKit

class ReviewApartmentsTableViewController: UITableViewController, UIScrollViewDelegate {
    
    let myList = ApartmentProfileList()
    var isLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: "refreshControlChanged:", forControlEvents: UIControlEvents.ValueChanged)
        refreshTable()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func refreshControlChanged(sender: UIRefreshControl) {
        refreshTable()
    }
    func refreshTable() {
        // because this method always excuted in main thread, so it is safe. more investigation required
        if isLoading == true {
            return
        }
        isLoading = true
        myList.refreshDataThen({
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                self.isLoading = false
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
        return myList.data.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ReviewApartmentCell", forIndexPath: indexPath) as! ReviewApartmentCell
        let row = indexPath.row
        let item = myList.data[row]
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
        let item = myList.data[row]
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
            APIModel.sharedInstance.removeApartment(myList.data[row].id, success: {
                (res: NSDictionary) in
                
                }, fail: {
                    (err: NSError) in
            })
            myList.data.removeAtIndex(row)
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
        return "Remove"
    }
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // is not the last row
        if indexPath.row != myList.data.count - 1 {
            return
        }
        // only executed in main queue
        if isLoading {
            return
        }
        isLoading = true
        myList.tryLoadingMore({ [unowned self] in
            dispatch_async(dispatch_get_main_queue(), {
                let currentItems = self.tableView.numberOfRowsInSection(0)
                let targetItems = self.myList.data.count
                var newIndexPaths = [NSIndexPath]()
                
                for index in currentItems..<targetItems {
                    newIndexPaths.append(NSIndexPath(forRow: index, inSection: 0))
                }
                
                self.tableView.beginUpdates()
                self.tableView.insertRowsAtIndexPaths(newIndexPaths, withRowAnimation: .Top)
                self.tableView.endUpdates()
                self.isLoading  = false

            })
            }, faild: { [unowned self] in
                dispatch_async(dispatch_get_main_queue(), {
                    self.isLoading = false
                })
        })
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
