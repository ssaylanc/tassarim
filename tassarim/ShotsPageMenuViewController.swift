//
//  ShotsPageMenuViewController.swift
//  tassarim
//
//  Created by saylanc on 23/11/16.
//  Copyright © 2016 saylanc. All rights reserved.
//

import UIKit
import PageMenu

class ShotsPageMenuViewController: UIViewController {

    var pageMenu : CAPSPageMenu?
    var categorie_id: Int!
    var categorie_name: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // MARK: - Scroll menu setup
        
        // Initialize view controllers to display and place in array
        //var controllerArray : [UIViewController] = []
        //let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        
        /*
        let controller1 = mainStoryboard.instantiateViewControllerWithIdentifier("ProductListCollectionView") as! ProductListCollectionViewController
        //controller1.parentNavigationController = self.navigationController
        controller1.title = "Tümü"
        controller1.categorie_id = categorie_id
        controller1.categorie_name = categorie_name
        controllerArray.append(controller1)
        
        let controller2 = mainStoryboard.instantiateViewControllerWithIdentifier("ProductListCollectionView") as! ProductListCollectionViewController
        //controller1.parentNavigationController = self.navigationController
        controller2.title = "Peçete"
        controller2.categorie_id = categorie_id
        controller2.categorie_name = categorie_name
        controllerArray.append(controller2)
        
        let controller3 = mainStoryboard.instantiateViewControllerWithIdentifier("ProductListCollectionView") as! ProductListCollectionViewController
        //controller1.parentNavigationController = self.navigationController
        controller3.title = "Islak Mendil"
        controller3.categorie_id = categorie_id
        controller3.categorie_name = categorie_name
        controllerArray.append(controller3)
        
        let controller4 = mainStoryboard.instantiateViewControllerWithIdentifier("ProductListCollectionView") as! ProductListCollectionViewController
        //controller1.parentNavigationController = self.navigationController
        controller4.title = "Kağıt Havlu"
        controller4.categorie_id = categorie_id
        controller4.categorie_name = categorie_name
        controllerArray.append(controller4)
        /*let controller3 = mainStoryboard.instantiateViewControllerWithIdentifier("Featured") as! FeaturedTableViewController
         //controller1.parentNavigationController = self.navigationController
         controller3.title = "TRENDING"
         controllerArray.append(controller3)
         let controller4 = mainStoryboard.instantiateViewControllerWithIdentifier("Featured") as! FeaturedTableViewController
         //controller1.parentNavigationController = self.navigationController
         controller4.title = "TRENDING"
         controllerArray.append(controller4)*/
        
        
        
        // Customize menu (Optional)
        let parameters: [CAPSPageMenuOption] = [
            .ScrollMenuBackgroundColor(UIColor.whiteColor()),
            .SelectedMenuItemLabelColor(UIColor.orangeColor()),
            .UnselectedMenuItemLabelColor(UIColor.lightGrayColor()),
            .ViewBackgroundColor(UIColor.whiteColor()),
            .SelectionIndicatorColor(UIColor.orangeColor()),
            //.BottomMenuHairlineColor(UIColor(red: 70.0/255.0, green: 70.0/255.0, blue: 80.0/255.0, alpha: 1.0)),
            .MenuItemFont(UIFont(name: "HelveticaNeue-Bold", size: 15.0)!),
            .MenuHeight(40.0),
            .MenuItemWidth(90.0),
            .CenterMenuItems(true)
        ]
        
        // Initialize scroll menu
        /*let navheight = (navigationController?.navigationBar.frame.size.height ?? 0) + UIApplication.sharedApplication().statusBarFrame.size.height
         let frame = CGRectMake(0, navheight, view.frame.width, view.frame.height-navheight)
         pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: frame, pageMenuOptions: parameters)
         self.view.addSubview(pageMenu!.view)*/
        
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0, 0.0, self.view.frame.width, self.view.frame.height), pageMenuOptions: parameters)
        
        self.addChildViewController(pageMenu!)
        self.view.addSubview(pageMenu!.view)
        pageMenu!.didMoveToParentViewController(self)
        
        */
    }

}
