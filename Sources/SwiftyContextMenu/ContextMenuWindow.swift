//
//  ContextMenuWindow.swift
//  ContextMenu
//
//  Created by Mario Iannotta on 14/06/2020.
//

import UIKit

class ContextMenuWindow: UIWindow, ContextMenuViewControllerDelegate {

    private var onDismiss: (() -> Void)?

    init(contextMenu: ContextMenu, onDismiss: @escaping (() -> Void)) {
        if #available(iOS 13, *) {
            if let windowScene = UIApplication.shared.connectedScenes.filter({ $0.activationState == .foregroundActive }).first as? UIWindowScene {
                super.init(windowScene: windowScene)
            }
            else {
                super.init(frame: UIScreen.main.bounds)
            }
        }
        else {
            super.init(frame: UIScreen.main.bounds)
        }
        self.onDismiss = onDismiss
        rootViewController = ContextMenuViewController(contextMenu: contextMenu, delegate: self)
        windowLevel = UIWindow.Level.statusBar
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func resignKey() {
        super.resignKey()
        onDismiss?()
    }

    func contextMenuViewControllerDidDismiss(_ contextMenuViewController: ContextMenuViewController) {
        resignKey()
    }
}
