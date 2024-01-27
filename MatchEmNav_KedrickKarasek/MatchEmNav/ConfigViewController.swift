//
//  TestViewController.swift
//  MatchEmNav
//
//  Created by Kedrick Karasek on 10/31/23.
//

import UIKit

class ConfigViewController: UIViewController {

    
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var sliderValueText: UILabel!
    
    @IBOutlet weak var gameSlider: UISlider!
    
    @IBOutlet weak var gameValueText: UILabel!
    
    @IBOutlet weak var colorWell: UIColorWell!
    
    @IBOutlet weak var textColorWell: UIColorWell!
    
    
    weak var gameVC: GameViewController?
    
    var pairInterval : Double?
    
    var gameDuration : Int?
    
    
    
    @IBAction func gameSliderChanged(_ sender: UISlider) {
        self.gameValueText.text = String(sender.value).prefix(2).lowercased()
        
        gameVC?.gameDuration = Int(sender.value)
        UserDefaults.standard.setValue(Double(sender.value), forKey: "timeRemaining")
    }
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        self.sliderValueText.text = String(sender.value).prefix(3).lowercased()
        
        gameVC?.newPairInterval = Double(sender.value)
        UserDefaults.standard.setValue(Double(sender.value), forKey: "newPairInterval")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //pair stuff
        slider.value = Float(pairInterval!)
        sliderValueText.text = String(pairInterval!.description.prefix(3))
        
        //game time stuff
        gameSlider.value = Float(gameDuration!)
        gameValueText.text = String(gameDuration!.description.prefix(3))
        
        //pair spawn stuff
//        if let pairInterval = UserDefaults.standard.value(forKey: "newPairInterval") as? Double {
//            slider.value = Float(pairInterval)
//            sliderValueText.text = String(pairInterval.description.prefix(3))
//        }else{
//            slider.value = Float(gameVC?.newPairInterval ?? 0)
//            sliderValueText.text = String(slider.value)
//        }
//
//        //game time stuff
//        if let timeRemaining = UserDefaults.standard.value(forKey: "timeRemaining") as? Double {
//            gameSlider.value = Float(timeRemaining)
//            gameValueText.text = String(timeRemaining.description.prefix(3))
//        }else{
//            gameSlider.value = Float(gameVC?.timeRemaining ?? 0)
//            gameValueText.text = String(gameSlider.value)
//        }
        
        //color well stuff
        self.colorWell.title = "Select a background color"
        self.colorWell.addTarget(self, action: #selector(self.ColorWellAction(_:)), for: .valueChanged)
        
        self.textColorWell.title = "Select a text color"
        self.textColorWell.addTarget(self, action: #selector(self.textColorWellAction(_:)), for: .valueChanged)
    }
    
    @objc func ColorWellAction(_ Sender: UIColorWell){
        if let rgb = Sender.selectedColor?.cgColor.components {
            UserDefaults.standard.setValue(["r": rgb[0], "g": rgb[1], "b": rgb[2]], forKey: "newBackgroundColor")
            gameVC?.backgroundColor = Sender.selectedColor
        }
    }
    
    @objc func textColorWellAction(_ Sender: UIColorWell){
        if let rgb = Sender.selectedColor?.cgColor.components {
            UserDefaults.standard.setValue(["r": rgb[0], "g": rgb[1], "b": rgb[2]], forKey: "newTextColor")
            gameVC?.textColor = Sender.selectedColor
        }
        
        
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         }
         */
    }
}
