//
//  ViewController.swift
//  ClassExample
//
//  Created by Kedrick Karasek on 9/7/23.
//

import UIKit

class ViewController: UIViewController {
  
    @IBOutlet weak var createBoxRef: UIButton!

    @IBAction func createBox(_ sender: Any){
        print("Welcome Home master")
        createRandomBox()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func createRandomBox(){
        let width = CGFloat.random(in: 75...125)
        let height = CGFloat.random(in: 75...125)
        let x = CGFloat.random(in: 0...(self.view.frame.maxX - width - 2.0 ))
        let y = CGFloat.random(in: 0...(self.createBoxRef.frame.minY - 2.0))
        
        let box = Box(frame: CGRect(x: x, y: y, width: width, height: height))
      //  box.addGestureRecognizer(UITapGestureRecognizer(target: self, action: <#T##Selector?#>))
        
        box.backgroundColor = UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1) , blue: CGFloat.random(in: 0...1), alpha: 1)
        
        view.addSubview(box)
    }
     
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let box = sender.view as? Box
        //
    }
                               
}

class Box: UIView{
    
    override init(frame:CGRect){
        super.init(frame:frame)
    }
    
    required init?(coder: NSCoder){
        fatalError("*init(coder:) has not been implemented")
    }
    
}

enum Direction: String, CaseIterable{
    case up = "⬆️"
    case right = "➡️"
    case down = "⬇️"
    case left = "⬅️"
    
    mutating func rotateNextDir(){
        guard 
    }
}




