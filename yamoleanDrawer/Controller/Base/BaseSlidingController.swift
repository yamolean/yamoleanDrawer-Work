//
//  BaseSlidingController.swift
//  yamoleanDrawer
//
//  Created by 矢守叡 on 2019/10/31.
//  Copyright © 2019 yamolean. All rights reserved.
//

import UIKit

final class RightContainerView: UIView {
    
}

final class MenuContainerView: UIView {
    
}

final class DarkCoverView: UIView {
    
}

final class BaseSlidingController: UIViewController {
    
    var rightContainerViewLeadingConstraint: NSLayoutConstraint!
    var rightContainerViewTrailingConstraint: NSLayoutConstraint!
    fileprivate let menuWidth :CGFloat = 300
    fileprivate let velocityOpenThreshold :CGFloat = 500
    fileprivate var isMenuOpened = false
    
    let rightContainerView: RightContainerView = {
        let v = RightContainerView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let menuContainerView: MenuContainerView = {
        let v = MenuContainerView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let darkCoverView: DarkCoverView = {
        let v = DarkCoverView()
        v.backgroundColor = UIColor(white: 0, alpha: 0.7)
        v.alpha = 0
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupViews()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        view.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss))
        darkCoverView.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func handleTapDismiss() {
        closeMenu()
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer){
        let translation = gesture.translation(in: view)
        var x = translation.x
        
        x = isMenuOpened ? x + menuWidth : x
        x = min(menuWidth, x)
        x = max(0, x)
        
        rightContainerViewLeadingConstraint.constant = x
        rightContainerViewTrailingConstraint.constant = x
        darkCoverView.alpha = x / menuWidth
        
        if gesture.state == .ended {
            handleEnded(gesture: gesture)
        }
        
    }
    
    fileprivate func handleEnded(gesture: UIPanGestureRecognizer){
        
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        if isMenuOpened {
            if abs(velocity.x) > velocityOpenThreshold{
                closeMenu()
                return
            }
            
            if abs(translation.x) < menuWidth / 2 {
                openMenu()
            } else {
                closeMenu()
            }
        } else {
            if velocity.x > velocityOpenThreshold {
                openMenu()
                return
            }
            
            if translation.x < menuWidth / 2 {
                closeMenu()
            } else {
                openMenu()
            }
        }
    }
    
    func openMenu() {
        isMenuOpened = true
        rightContainerViewLeadingConstraint.constant = menuWidth
        rightContainerViewTrailingConstraint.constant = menuWidth
        performAnimations()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func closeMenu() {
        isMenuOpened = false
        rightContainerViewLeadingConstraint.constant = 0
        rightContainerViewTrailingConstraint.constant = 0
        performAnimations()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        //時刻等の部分を白くする
        return isMenuOpened ? .lightContent : .default
        
    }
    
    func didSelectedMenuItem(indexPath: IndexPath) {
        
        performRightViewCleanUp()
        closeMenu()
        
        switch indexPath.row {
            
        case 0:
            rightViewController = UINavigationController(rootViewController: HomeController())
        case 1:
            rightViewController = UINavigationController(rootViewController: ListController())
        case 2:
            rightViewController = BookmarksController()
        default:
            let tabBarController = UITabBarController()
            let momentsController = UIViewController()
            momentsController.navigationItem.title = "Moments"
            momentsController.view.backgroundColor = .orange
            let navController = UINavigationController(rootViewController: momentsController)
            navController.tabBarItem.title = "tab Sample"
            tabBarController.viewControllers = [navController]
            rightViewController = tabBarController
            
        }
        
        rightContainerView.addSubview(rightViewController.view)
        addChild(rightViewController)
        
        rightContainerView.bringSubviewToFront(darkCoverView)
        closeMenu()
        
    }
    
    //ここに任意のHomeViewControllerを入れる
    var rightViewController: UIViewController = UINavigationController(rootViewController: HomeController())
    
    //ここに任意のViewControllerを入れる
    let menuController = MenuController()
    //let menuController = ChatroomMenuContainerController()
    
    fileprivate func performRightViewCleanUp() {
        rightViewController.view.removeFromSuperview()
        rightViewController.removeFromParent()
    }
    
    fileprivate func performAnimations() {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            
            self.view.layoutIfNeeded()
            self.darkCoverView.alpha = self.isMenuOpened ? 1 : 0
            
        })
        
    }
    
    fileprivate func setupViews() {
        
        view.addSubview(rightContainerView)
        view.addSubview(menuContainerView)
        
        NSLayoutConstraint.activate([
            rightContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            rightContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            menuContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            menuContainerView.trailingAnchor.constraint(equalTo: rightContainerView.leadingAnchor),
            menuContainerView.widthAnchor.constraint(equalToConstant: menuWidth),
            menuContainerView.bottomAnchor.constraint(equalTo: rightContainerView.bottomAnchor)
            ])
        
        rightContainerViewLeadingConstraint = rightContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 0)
        rightContainerViewLeadingConstraint.isActive = true
        
        rightContainerViewTrailingConstraint = rightContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        rightContainerViewTrailingConstraint.isActive = true
        
        setupViewController()
        
    }
    
    fileprivate func setupViewController() {
        
        let homeView = rightViewController.view!
        let menuView = menuController.view!
        
        homeView.translatesAutoresizingMaskIntoConstraints = false
        menuView.translatesAutoresizingMaskIntoConstraints = false
        
        rightContainerView.addSubview(homeView)
        menuContainerView.addSubview(menuView)
        rightContainerView.addSubview(darkCoverView)
        
        NSLayoutConstraint.activate([
            //top leading bottom trailing ,anchors
            homeView.topAnchor.constraint(equalTo: rightContainerView.topAnchor),
            homeView.leadingAnchor.constraint(equalTo: rightContainerView.leadingAnchor),
            homeView.bottomAnchor.constraint(equalTo: rightContainerView.bottomAnchor),
            homeView.trailingAnchor.constraint(equalTo: rightContainerView.trailingAnchor),
            
            menuView.topAnchor.constraint(equalTo: menuContainerView.topAnchor),
            menuView.leadingAnchor.constraint(equalTo: menuContainerView.leadingAnchor),
            menuView.bottomAnchor.constraint(equalTo: menuContainerView.bottomAnchor),
            menuView.trailingAnchor.constraint(equalTo: menuContainerView.trailingAnchor),
            
            darkCoverView.topAnchor.constraint(equalTo: rightContainerView.topAnchor),
            darkCoverView.leadingAnchor.constraint(equalTo: rightContainerView.leadingAnchor),
            darkCoverView.bottomAnchor.constraint(equalTo: rightContainerView.bottomAnchor),
            darkCoverView.trailingAnchor.constraint(equalTo: rightContainerView.trailingAnchor)
            ])
        
        addChild(rightViewController)
        addChild(menuController)
    }
    
}
