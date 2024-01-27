//
//  ViewController.swift
//  MatchEm
//
//  Created by Kedrick Karasek on 9/28/23.
//

import UIKit

class GameSceneViewController: UIViewController {
    
    
    @IBOutlet weak var scoreTimerLabel: UILabel!
    @IBOutlet weak var startButtonOutlet: UIButton!
    
    
    //dictionary that holds matching rectangles
    var matchRec: [UIButton:Int] = [:]
    
    var firstMatch: UIButton?
    var secondMatch: UIButton?
    
    //time will tick by 1 every second
    var gameTimerInterval: TimeInterval = 1.0
    //a new pair is added to the screen every 5 second
    var newPairInterval: TimeInterval = 1.0
    
    //creating timer for game
    var gameTimer: Timer?
    //creating timer for pair creation
    var pairTimer: Timer?
    //variable checking if game is over
    var gameOver = false
    
    //tag to keep track of pair
    var pairTag = 0
    //tracking score
    var score = 0 {
        didSet{
            self.updateLabel()
        }
    }
    //counting the number of pairs
    var numberOfPairs = 0 {
        didSet{
            self.updateLabel()
        }
    }
    //counting the number of matched pairs
    var matchedPairs = 0 {
        didSet{
            self.updateLabel()
        }
    }
    //game time
    var timeRemaining = 12 {
        didSet{
            self.updateLabel()
        }
    }
    //reset game button
    var resetButton: UIButton?
    
    var startButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let rectSize = CGSize(width: 100, height: 100)
        let rectLoc = CGPoint(x: (self.view.frame.width / 2) - (rectSize.width / 2), y: (self.view.frame.height / 2) - (rectSize.height / 2)) //how do I get in center of screen
        let rectFrame = CGRect(origin: rectLoc, size: rectSize)
        
        self.startButton = UIButton(frame: rectFrame) // creating first match
        self.startButton?.addTarget(self, action: #selector(self.startGame(_:)), for: .touchUpInside)
        self.startButton?.setTitle("Start Game" , for: .normal)
        self.startButton?.setTitleColor(.white, for: .normal)
        self.startButton?.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
        
        self.view.addSubview(self.startButton!)
    }
    
    //function that starts the game
    @objc func startGame(_ Sender: UIButton){
        Sender.removeFromSuperview()
        self.gameTimer = Timer.scheduledTimer(withTimeInterval: self.gameTimerInterval, repeats: true, block: {Timer in
            if self.timeRemaining > 0{
                self.timeRemaining -= 1
            }else{
                self.pairTimer?.invalidate()
                self.gameTimer?.invalidate()
                self.pairTimer = nil
                self.gameTimer = nil
                self.view.backgroundColor = .red
                self.createResetButton()
                self.gameOver = true
            }
        })
        
        self.pairTimer = Timer.scheduledTimer(withTimeInterval: self.newPairInterval, repeats: true, block: { Timer in
            self.createPair()
            //self.updateLabel()
        })
    }
    
    func updateLabel(){
        self.scoreTimerLabel.text = "Created: \(self.numberOfPairs) - Time: \(self.timeRemaining) - Score: \(self.score) - Matched Pairs: \(self.matchedPairs)"
    }
    
    //function that creates a pair of rectangles
    func createPair(){
        let rectSize = self.randSize()
        let rectLoc = self.randLocation(rectSize)
        let rectFrame = CGRect(origin: rectLoc, size: rectSize)
        let color = self.randColor()
        
        let rectLocTwo = self.randLocation(rectSize)
        let rectFrameTwo = CGRect(origin: rectLocTwo, size: rectSize)
        
        let MatchOne = UIButton(frame: rectFrame) // creating first match
        MatchOne.addTarget(self, action: #selector(self.handleTap(_:)), for: .touchUpInside)
        MatchOne.backgroundColor = color
        MatchOne.tag = self.pairTag
        
        let MatchTwo = UIButton(frame:rectFrameTwo) //creating second match
        MatchTwo.addTarget(self, action: #selector(self.handleTap(_:)), for: .touchUpInside)
        MatchTwo.backgroundColor = color
        MatchTwo.tag = self.pairTag
        
        self.view.addSubview(MatchOne)
        self.view.addSubview(MatchTwo)
        
        self.view.bringSubviewToFront(self.scoreTimerLabel)
        
        self.matchRec[MatchOne] = pairTag
        self.matchRec[MatchTwo] = pairTag
        self.pairTag += 1
        self.numberOfPairs += 1
    }
    
    func randSize() -> CGSize {
        let width = CGFloat.random(in: 50.0...150.0)
        let height = CGFloat.random(in:50.0...150.0)
        return CGSize(width:width, height:height)
    }
    
    func randLocation(_ rectSize: CGSize) -> CGPoint{
        let x = CGFloat.random(in: 0...(self.view.frame.width - (rectSize.width / 2)))
        let topSafeInset = self.view.safeAreaInsets.bottom
        let bottomSafeInset = self.view.safeAreaInsets.top
        let y = CGFloat.random(in: (topSafeInset + (rectSize.height / 2))...(self.view.frame.height - bottomSafeInset - (rectSize.height / 2)))
        return CGPoint(x: x, y: y)
    }
    
    func randColor() -> UIColor{
        return UIColor(red: CGFloat.random(in:0...1), green: CGFloat.random(in:0...1), blue: CGFloat.random(in:0...1) , alpha: 1.0)
    }
    
    //function for how we handle the tap
    @objc func handleTap(_ Sender: UIButton){
        if(gameOver == false){
            Sender.setTitle("🥳" ,for: .normal)
            if let btn = self.firstMatch{ //if self.firstMatch != nil
                if btn != Sender && self.matchRec[btn] == self.matchRec[Sender]{ //if they do match
                    btn.setTitle("🥳" ,for: .normal)
                    firstMatch = nil
                    score = score + 1
                    matchedPairs = matchedPairs + 1
                    //having to double click to get the sitle
                    //confused on once you click on the two pairs how do we remove the
                    btn.removeFromSuperview()
                    Sender.removeFromSuperview()
                }else{
                    btn.setTitle("", for: .normal)
                    Sender.setTitle("", for: .normal)
                    firstMatch = nil
                }
            }else{ // if self.firstMatch == nil
                self.firstMatch = Sender //set first match to sender
                
            }
        }
    }
    
    func createResetButton(){
        let rectSize = CGSize(width: 100, height: 50)
        let rectLoc = CGPoint(x: 50, y: 50)
        let rectFrame = CGRect(origin: rectLoc, size: rectSize)
        
        
        
        let resetButton = UIButton(frame: rectFrame) // creating first match
        resetButton.addTarget(self, action: #selector(self.reset(_:)), for: .touchUpInside)
        resetButton.setTitle("Reset" , for: .normal)
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
        
        self.view.addSubview(resetButton)
    }
    
    @objc func reset(_ Sender: UIButton){
        score = 0
        numberOfPairs = 0
        matchedPairs = 0
        timeRemaining = 12
        self.view.backgroundColor = .white
        
        for rect in self.matchRec.keys {
            rect.removeFromSuperview()
        }
        self.matchRec = [:]
        if let btn = self.startButton{
            self.view.addSubview(self.startButton!)
        }
        self.gameOver = false
        Sender.removeFromSuperview()
    }
}


/* Notes of Things I am stuck on
 1. how to loop through a dictonary and clearing dictonary
 2. removing reset button from view
 3. fixing where the rectangles spawn (bounds)
 4. getting start button to come back into view after hitting reset button
 5. removing rectangles if they match and gaining points (confused on how the matching works)
 6. if you click on the same rectangle twice it will show the emoji on that (not sure if thats fine since they have the same key because it will give you points for that)
 7.issue with removing text from button when you select the wrong rectangle when trying to match
 */
