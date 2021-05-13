//
//  ContextMenuViewController.swift
//  ContextMenu
//
//  Created by Mario Iannotta on 14/06/2020.
//

import UIKit

protocol ContextMenuViewControllerDelegate: AnyObject {

    func contextMenuViewControllerDidDismiss(_ contextMenuViewController: ContextMenuViewController)
}

class ContextMenuViewController: UIViewController {

    private let contextMenu: ContextMenu
    private weak var delegate: ContextMenuViewControllerDelegate?

    private let blurView: ContextMenuBackgroundBlurView
    private let overlayView = UIView(frame: .zero)
    private let snapshotImageView = UIImageView(frame: .zero)
    private let contextMenuTableView = ContextMenuTableView()
    private let contextMenuView = UIView()

    private let cellIdentifier = "ContextMenuCell"

    private var isContextMenuUp: Bool {
        switch self.contextMenu.menuStyle {
        case .default:
            return (contextMenu.sourceViewInfo?.targetFrame.midY ?? 0) > UIScreen.main.bounds.height / 2
        case .radial:
            if let originalFrame = contextMenu.sourceViewInfo?.originalFrame {
                return (originalFrame.minY - (menuRadius + maxRadialSubMenuTitleHeight)) >= 0
            }
            return false
        }
    }
    private var isContextMenuRight: Bool { (contextMenu.sourceViewInfo?.targetFrame.midX ?? 0) > UIScreen.main.bounds.width / 2 }
    private var isContextMenuCenter: Bool { return (contextMenu.sourceViewInfo?.originalFrame.midX ?? 0) == (UIScreen.main.bounds.width / 2) }
    //Radial Menu
    var radialMenu:RadialMenu?
    private var menuRadius: CGFloat = 100
    private var subMenuRadius: CGFloat = 20.0
    private let font = UIFont.systemFont(ofSize: 24, weight: .bold)
    private lazy var radialSubMenuTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = font
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    private lazy var maxRadialSubMenuTitleHeight: CGFloat = {
        let padding: CGFloat = 12
        return CGFloat((font.lineHeight * 2) + padding)
    } ()
    //Haptic Feedback
    private var selectionFeedback: UISelectionFeedbackGenerator?
    private var impactFeedback: UIImpactFeedbackGenerator?
    
    //Orientation
    private var wasGeneratingDeviceOrientationNotifications: Bool = false
    //Init
    init(contextMenu: ContextMenu, delegate: ContextMenuViewControllerDelegate?) {
        self.delegate = delegate
        self.contextMenu = contextMenu
        self.blurView = ContextMenuBackgroundBlurView(contextMenu.style)
        self.menuRadius = contextMenu.layout.radialMenuRadius
        self.subMenuRadius = contextMenu.layout.radialSubMenuRadius
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if contextMenu.menuStyle == .default {
            addBlurView()
        }
        addBlackOverlay()
        addSnapshotView()
        if contextMenu.menuStyle == .default {
            addContextMenuTableView()
        }
        else {
            addContextMenuRadialView()
        }
        impactFeedback = UIImpactFeedbackGenerator()
        impactFeedback?.prepare()
        wasGeneratingDeviceOrientationNotifications = UIDevice.current.isGeneratingDeviceOrientationNotifications
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        feedback(of: .menuVisible)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fadeIn()
        if selectionFeedback == nil {
            selectionFeedback = UISelectionFeedbackGenerator()
        }
        if !wasGeneratingDeviceOrientationNotifications {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if !wasGeneratingDeviceOrientationNotifications {
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    @objc
    private
    func orientationDidChange(_ notification: Notification) {
        self.close()
    }
    
    func close() {
        self.fadeOutAndClose()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .clear
    }

    private func addBlurView() {
        blurView.alpha = 0
        view.fill(with: blurView)
    }

    private func addBlackOverlay() {
        overlayView.alpha = 0
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        view.fill(with: overlayView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDismissGestureRecognizer))
        overlayView.addGestureRecognizer(tapGesture)
    }

    private func addSnapshotView() {
        snapshotImageView.image = contextMenu.sourceViewInfo?.snapshot
        snapshotImageView.frame = contextMenu.sourceViewInfo?.originalFrame ?? .zero
        snapshotImageView.clipsToBounds = true
        snapshotImageView.layer.cornerRadius = contextMenu.layout.sourceViewCornerRadius
        view.addSubview(snapshotImageView)
    }

    private func addContextMenuTableView() {
        contextMenuTableView.delegate = self
        contextMenuTableView.dataSource = self
        contextMenuTableView.rowHeight = UITableView.automaticDimension
        contextMenuTableView.estimatedRowHeight = 44
        contextMenuTableView.register(ContextMenuActionTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        let arrangedSubviews = [makeTitleView(), contextMenuTableView].compactMap { $0 }
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews, axis: .vertical)
        
        let blurView = ContextMenuContentBlurView(contextMenu.style)
        blurView.layer.cornerRadius = 14
        blurView.clipsToBounds = true
        blurView.contentView.fill(with: stackView)

        contextMenuView.alpha = 0
        contextMenuView.layer.cornerRadius = 14
        contextMenuView.layer.shadowColor = UIColor.black.cgColor
        contextMenuView.layer.shadowOffset = CGSize(width: 2, height: 5)
        contextMenuView.layer.shadowRadius = 6
        contextMenuView.layer.shadowOpacity = 0.08
        contextMenuView.translatesAutoresizingMaskIntoConstraints = false
        contextMenuView.fill(with: blurView)
        view.addSubview(contextMenuView)

        let edgeConstraint: NSLayoutConstraint
        let verticalConstraint: NSLayoutConstraint
        let horizontalConstraint: NSLayoutConstraint
        if isContextMenuUp {
            edgeConstraint = contextMenuView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor,
                                                                  constant: contextMenu.layout.padding)
            verticalConstraint = snapshotImageView.topAnchor.constraint(equalTo: contextMenuView.bottomAnchor,
                                                                        constant: contextMenu.layout.spacing)
        } else {
            edgeConstraint = bottomAnchor.constraint(greaterThanOrEqualTo: contextMenuView.bottomAnchor,
                                                     constant: contextMenu.layout.padding)
            verticalConstraint = contextMenuView.topAnchor.constraint(equalTo: snapshotImageView.bottomAnchor,
                                                                      constant: contextMenu.layout.spacing)
        }
        if isContextMenuRight {
            horizontalConstraint = snapshotImageView.trailingAnchor.constraint(equalTo: contextMenuView.trailingAnchor)
        } else {
            horizontalConstraint = contextMenuView.leadingAnchor.constraint(equalTo: snapshotImageView.leadingAnchor)
        }
        NSLayoutConstraint.activate([
            contextMenuView.widthAnchor.constraint(equalToConstant: 250),
            horizontalConstraint,
            verticalConstraint,
            edgeConstraint
        ])
    }
    
    private func addContextMenuRadialView() {
        // Setup radial menu
        var subMenus: [RadialSubMenu] = []
        for i in 0..<self.contextMenu.actions.count {
            subMenus.append(self.createSubMenu(i))
        }
        let radialMenu = RadialMenu(menus: subMenus, radius: menuRadius)
        view.addSubview(radialMenu)
        view.addSubview(radialSubMenuTitleLabel)
        radialSubMenuTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        radialSubMenuTitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        if isContextMenuUp {
            radialSubMenuTitleLabel.bottomAnchor.constraint(equalTo: radialMenu.topAnchor, constant: -20).isActive = true
        }
        else {
            radialSubMenuTitleLabel.topAnchor.constraint(equalTo: radialMenu.bottomAnchor, constant: 20).isActive = true
        }
        radialMenu.layer.cornerRadius = menuRadius
        radialMenu.openDelayStep = 0.05
        radialMenu.closeDelayStep = 0.00
        let minAngle:Int
        let maxAngle:Int
        let center: CGPoint
        if self.isContextMenuCenter {
            if isContextMenuUp {
                minAngle = 225
                maxAngle = 315
                center = CGPoint.init(x: snapshotImageView.frame.midX, y: snapshotImageView.frame.minY)
            }
            else {
                minAngle = 45
                maxAngle = 135
                center = CGPoint.init(x: snapshotImageView.frame.midX, y: snapshotImageView.frame.maxY)
            }
            radialSubMenuTitleLabel.textAlignment = .center
        }
        else if self.isContextMenuUp {
            if self.isContextMenuRight {
                minAngle = 180
                maxAngle = 270
                var origin = snapshotImageView.frame.origin
                origin.x = snapshotImageView.frame.minX
                origin.y = snapshotImageView.frame.minY
                center = origin
                radialSubMenuTitleLabel.textAlignment = .left
            }
            else {
                minAngle = 270
                maxAngle = 360
                var origin = snapshotImageView.frame.origin
                origin.x = snapshotImageView.frame.maxX
                origin.y = snapshotImageView.frame.minY
                center = origin
                radialSubMenuTitleLabel.textAlignment = .right
            }
        }
        else {
            if self.isContextMenuRight {
                minAngle = 90
                maxAngle = 180
                var origin = snapshotImageView.frame.origin
                origin.x = snapshotImageView.frame.minX
                origin.y = snapshotImageView.frame.maxY
                center = origin
                radialSubMenuTitleLabel.textAlignment = .left
            }
            else {
                minAngle = 0
                maxAngle = 90
                var origin = snapshotImageView.frame.origin
                origin.x = snapshotImageView.frame.maxX
                origin.y = snapshotImageView.frame.maxY
                center = origin
                radialSubMenuTitleLabel.textAlignment = .right
            }
        }
        radialMenu.center = center
        radialMenu.minAngle = minAngle
        radialMenu.maxAngle = maxAngle
        radialMenu.activatedDelay = 1.0
        radialMenu.backgroundView.alpha = 0.0
        radialMenu.openAtPosition(center)
        radialMenu.shrinkSubMenus()
        self.radialMenu = radialMenu
        view.bringSubviewToFront(radialMenu)
        radialMenu.onHighlight = { [weak self] submenu in
            UIView.animate(withDuration: 0.1) {
                submenu.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                if let index = subMenus.firstIndex(of: submenu), let action = self?.contextMenu.actions[index] {
                    self?.radialSubMenuTitleLabel.text = action.title
                    submenu.backgroundColor = action.radialMenuHighlightBackgroundColor
                    submenu.imageView?.tintColor = action.radialMenuHighlightImageTintColor
                }
            }
            self?.feedback(of: .menuHighlight)
        }
        radialMenu.onUnhighlight = { [weak self] submenu in
            UIView.animate(withDuration: 0.1) {
                submenu.transform = CGAffineTransform.identity
                if let index = subMenus.firstIndex(of: submenu), let action = self?.contextMenu.actions[index] {
                    submenu.backgroundColor = submenu.isDarkMode ? action.radialMenuDarkBackgroundColor : action.radialMenuBackgroundColor
                    submenu.imageView?.tintColor = submenu.isDarkMode ? action.tintColorDark : action.tintColor
                }
            }
            self?.radialSubMenuTitleLabel.text = ""
        }
        radialMenu.onActivate = { [weak self] submenu in
            if let index = subMenus.firstIndex(of: submenu), let action = self?.contextMenu.actions[index] {
                action.action?(action)
                self?.fadeOutAndClose()
            }
        }
    }
    
    private func makeTitleView() -> UIView? {
        guard
            let title = contextMenu.title
            else {
                return nil
            }
        let titleLabelContainterView = UIView(frame: .zero)
        titleLabelContainterView.backgroundColor = .clear
        let titleLabel = ContextMenuTitleLabel(frame: .zero, style: contextMenu.style)
        titleLabel.text = title
        titleLabel.sizeToFit()
        titleLabelContainterView.fill(with: titleLabel, insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        
        return titleLabelContainterView
    }

    private func fadeIn() {
        contextMenu.delegate?.contextMenuWillAppear(contextMenu)
        contextMenuView.transform = contextMenu.optionsViewFirstTransform(isContextMenuUp: isContextMenuUp)
        showSourceView {
            self.contextMenu.delegate?.contextMenuDidAppear(self.contextMenu)
            self.showContextMenu()
        }
    }

    private func showSourceView(completion: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0.2,
            animations: {
                self.overlayView.alpha = 1
                if self.contextMenu.menuStyle == .default {
                    self.blurView.alpha = 1
                }
                self.snapshotImageView.transform = self.contextMenu.sourceViewFirstStepTransform
            },
            completion: { _ in
                UIView.animate(
                    withDuration: 0.2,
                    animations: {
                        self.snapshotImageView.transform = self.contextMenu.sourceViewSecondTransform
                    },
                    completion: { _ in completion() })
                })
    }

    private func showContextMenu() {
        UIView.animate(
            withDuration: 0.5,
            delay: 0.0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 5,
            options: .curveLinear,
            animations: {
                self.contextMenuView.alpha = 1
                self.contextMenuView.transform = self.contextMenu.optionsViewSecondTransform

                let transform = self.contextMenu.sourceViewThirdTransform(
                    isContextMenuUp: self.isContextMenuUp,
                    isContextMenuRight: self.isContextMenuRight
                )
                
                self.snapshotImageView.transform = transform
            },
            completion: { _ in
                UIView.animate(
                    withDuration: 0.2,
                    animations: {
                        self.contextMenuView.transform = self.contextMenu.optionsViewThirdTransform
                })
            })
    }

    private func fadeOutAndClose() {
        if self.contextMenu.menuStyle == .radial {
            self.radialMenu?.close()
        }
        UIView.animate(
            withDuration: 0.3,
            animations: {
                if self.contextMenu.menuStyle == .default {
                    self.blurView.alpha = 0
                }
                self.contextMenuView.alpha = 0
                self.snapshotImageView.transform = .identity
                self.contextMenuView.transform = self.contextMenu.optionsViewFirstTransform(isContextMenuUp: self.isContextMenuUp)
            },
            completion: { _ in
                self.delegate?.contextMenuViewControllerDidDismiss(self)
            })
    }

    @objc private func handleDismissGestureRecognizer() {
        fadeOutAndClose()
    }
}

extension ContextMenuViewController: UITableViewDataSource, UITableViewDelegate {

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contextMenu.actions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ContextMenuActionTableViewCell
            else {
                return UITableViewCell()
            }
        cell.configure(action: contextMenu.actions[indexPath.row], with: contextMenu.style)
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let action = contextMenu.actions[indexPath.row]
        action.action?(action)
        fadeOutAndClose()
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        feedback(of: .menuHighlight)
        return true
    }
}
extension ContextMenuViewController {
    // MARK - RadialSubMenu helpers
    
    private func createSubMenu(_ i: Int) -> RadialSubMenu {
        let action = contextMenu.actions[i]
        let img = UIImageView(image: action.image)
        let subMenu = RadialSubMenu(imageView: img)
        subMenu.frame = CGRect(x: 0.0, y: 0.0, width: CGFloat(subMenuRadius*2), height: CGFloat(subMenuRadius*2))
        subMenu.layer.cornerRadius = subMenuRadius
        subMenu.tag = i
        img.frame.size = CGSize.init(width: subMenu.frame.size.width - ((action.radialMenuImagePadding ?? 0) * 2), height: subMenu.frame.size.height - ((action.radialMenuImagePadding ?? 0) * 2))
        img.center = subMenu.center
        img.tintColor = view.isDarkMode ? action.tintColorDark : action.tintColor
        subMenu.backgroundColor = view.isDarkMode ? action.radialMenuDarkBackgroundColor : action.radialMenuBackgroundColor
        return subMenu
    }

}

extension ContextMenuViewController {
    //MARK: - Haptic Feedback
    enum FeedbackType {
        case menuVisible
        case menuHighlight
    }
    private func feedback(of type: FeedbackType) {
        switch type {
        case .menuVisible:
            if #available(iOS 13, *) {
                impactFeedback?.impactOccurred(intensity: 1)
            }
            else {
                impactFeedback?.impactOccurred()
            }
        case .menuHighlight:
            selectionFeedback?.selectionChanged()
        }
    }
}
