//
//  CollectionViewController.swift
//  ContextMenu_Example
//
//  Created by Hubilo Softech Private Limited on 02/03/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import SwiftyContextMenu

class CollectionViewController: UICollectionViewController {
    
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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 300
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuseIdentifier", for: indexPath)
        cell.addContextMenu(contextMenu, for: .longPress(duration: 0.3))
        if #available(iOS 13.0, *) {
            cell.backgroundColor = [UIColor.systemGray4, UIColor.systemGray3, UIColor.systemGray2, UIColor.systemGray].randomElement()
        } else {
            cell.backgroundColor = [UIColor.lightGray, UIColor.darkGray, UIColor.gray, UIColor.systemGray].randomElement()
        }
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension CollectionViewController: ContextMenuDelegate {
    
    func contextMenuWillAppear(_ contextMenu: ContextMenu) {
        print("context menu will appear")
    }
    
    func contextMenuDidAppear(_ contextMenu: ContextMenu) {
        print("context menu did appear")
    }
}

