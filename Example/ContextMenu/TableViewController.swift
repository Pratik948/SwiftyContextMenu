//
//  TableViewController.swift
//  ContextMenu_Example
//
//  Created by Hubilo Softech Private Limited on 02/03/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import SwiftyContextMenu

class TableViewController: UITableViewController {

    private lazy var contextMenu: ContextMenu = {
        let favoriteAction = ContextMenuAction(title: "Looooooooooooong title",
                                               image: UIImage(named: "heart.fill")?.withRenderingMode(.alwaysTemplate),
                                               tintColor: UIColor.lightGray,
                                               tintColorDark: UIColor.lightGray,
                                               radialMenuHighlightBackgroundColor: UIColor.red,
                                               radialMenuHighlightImageTintColor: UIColor.white,
                                               radialMenuBackgroundColor: UIColor.white,
                                               radialMenuDarkBackgroundColor: UIColor.darkGray,
                                               action: { _ in print("favorite") })
        let shareAction = ContextMenuAction(title: "Share",
                                            image: UIImage(named: "square.and.arrow.up.fill")?.withRenderingMode(.alwaysTemplate),
                                            tintColor: UIColor.lightGray,
                                            tintColorDark: UIColor.lightGray,
                                            radialMenuHighlightBackgroundColor: UIColor.red,
                                            radialMenuHighlightImageTintColor: UIColor.white,
                                            radialMenuBackgroundColor: UIColor.white,
                                            radialMenuDarkBackgroundColor: UIColor.darkGray,
                                            action: { _ in print("share") })
        let deleteAction = ContextMenuAction(title: "Delete",
                                             image: UIImage(named: "trash.fill")?.withRenderingMode(.alwaysTemplate),
                                             tintColor: UIColor.lightGray,
                                             tintColorDark: UIColor.lightGray,
                                             radialMenuHighlightBackgroundColor: UIColor.red,
                                             radialMenuHighlightImageTintColor: UIColor.white,
                                             radialMenuBackgroundColor: UIColor.white,
                                             radialMenuDarkBackgroundColor: UIColor.darkGray,
                                             action: { _ in print("delete") })
        let actions: [ContextMenuAction] = [favoriteAction, shareAction, deleteAction]
        let contextMenu = ContextMenu(
            title: nil,
            actions: actions,
            layout: ContextMenuLayout.init(radialMenuRadius: 80, radialSubMenuRadius: 20),
            delegate: self,
            menuStyle: .radial)
        return contextMenu
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 200
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = "Cell \(indexPath.row+1)"
        cell.addContextMenu(contextMenu, for: .longPress(duration: 0.3))
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension TableViewController: ContextMenuDelegate {
    
    func contextMenuWillAppear(_ contextMenu: ContextMenu) {
        print("context menu will appear")
    }
    
    func contextMenuDidAppear(_ contextMenu: ContextMenu) {
        print("context menu did appear")
    }
}

