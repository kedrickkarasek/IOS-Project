//
//  ViewController.swift
//  Geo Loco
//
//  Created by Kedrick Karasek on 11/21/23.
//

import UIKit

class MainMenuViewController: UIViewController {
    
    weak var gameVC: GameSceneViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        assignbackground()
        // Do any additional setup after loading the view.
    }
    
    func assignbackground(){
            let background = UIImage(named: "Geo Loco")

            var imageView : UIImageView!
            imageView = UIImageView(frame: view.bounds)
            imageView.contentMode =  UIView.ContentMode.scaleAspectFill
            imageView.clipsToBounds = true
            imageView.image = background
            imageView.center = view.center
            view.addSubview(imageView)
            self.view.sendSubviewToBack(imageView)
        }

}

