//
//  ViewController.swift
//  Gardener
//
//  Created by 유현진 on 2023/03/18.
//

import UIKit
import FirebaseAuth
class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        connectNavigationControllerToTabBarController()
        setUI()
        loginThenShowUserInfo()
    }
    func connectNavigationControllerToTabBarController(){
        let gardenViewController = UINavigationController(rootViewController: GardenViewController())
        let communityViewController = UINavigationController(rootViewController: CommunityViewController())
        let homeViewController = UINavigationController(rootViewController: HomeViewController())
        let shopViewController = UINavigationController(rootViewController: ShopViewController())
        let myViewController = UINavigationController(rootViewController: MyViewController())
        
        viewControllers = [gardenViewController,communityViewController,homeViewController,shopViewController,myViewController]
    }
    
    func loginThenShowUserInfo(){
        let user = Auth.auth().currentUser
        if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            let uid = user.uid
            let email = user.email
            let firstName = user.displayName
            let phoneNumber = user.phoneNumber
            print("uid = \(uid)")
            print("email = \(email)")
            print("displayName = \(firstName)")
            print("phoneNumber = \(phoneNumber)")
        }
    }
    
    func setUI(){
        setUITabBarItem()
        setUITabBar()
    }
    
    func setUITabBar(){
        // 배경
        if #available(iOS 15.0, *){
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
        // set tabbar shadow
        tabBar.layer.masksToBounds = false
        tabBar.layer.shadowColor = UIColor.lightGray.cgColor
        tabBar.layer.shadowOpacity = 0.2
        tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        tabBar.layer.shadowRadius = 6
    }
    
    func setUITabBarItem(){
        if let items = self.tabBar.items{
            let imageConfiguartion = UIImage.SymbolConfiguration(pointSize: 15, weight: .light, scale: .large)
            
            items[0].selectedImage = UIImage(systemName: "sun.haze.fill", withConfiguration: imageConfiguartion)
            items[0].image = UIImage(systemName: "sun.haze", withConfiguration: imageConfiguartion)
            items[0].title = "가드닝"
            
            items[1].selectedImage = UIImage(systemName: "bubble.left.and.bubble.right.fill", withConfiguration: imageConfiguartion)
            items[1].image = UIImage(systemName: "bubble.left.and.bubble.right", withConfiguration: imageConfiguartion)
            items[1].title = "게시판"
            
            items[2].selectedImage = UIImage(systemName: "house.fill", withConfiguration: imageConfiguartion)
            items[2].image = UIImage(systemName: "house", withConfiguration: imageConfiguartion)
            items[2].title = "홈"
            
            items[3].selectedImage = UIImage(systemName: "bag.fill", withConfiguration: imageConfiguartion)
            items[3].image = UIImage(systemName: "bag", withConfiguration: imageConfiguartion)
            items[3].title = "쇼핑"
            
            items[4].selectedImage = UIImage(systemName: "person.circle.fill", withConfiguration: imageConfiguartion)
            items[4].image = UIImage(systemName: "person.circle", withConfiguration: imageConfiguartion)
            items[4].title = "내 정보"
        }
        // set tabbar tintColor
        tabBar.tintColor = .green
    }
}
