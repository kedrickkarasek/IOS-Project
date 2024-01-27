//
//  ViewController.swift
//  MatchEmNav
//
//  Created by Kedrick Karasek on 10/31/23.
//

import UIKit

enum GameState {
    case started
    case paused
    case stopped
    case initialLaunch
}

class GameViewController: UIViewController {
    
    @IBOutlet weak var scoreTimerLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    
    
    
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
    
    var gameState: GameState = .initialLaunch
    
    var backgroundColor: UIColor? = .white
    
    var textColor: UIColor? = .black
    
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
    
    var gameDuration = 12
    //reset game button
    var resetButton: UIButton?
    
    var startButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwipeGesture()
        self.view.backgroundColor = backgroundColor
        self.scoreTimerLabel.textColor = textColor
        
        //rectangle interval stuff
        if let pairInterval = UserDefaults.standard.value(forKey: "newPairInterval") as? Double {
            self.newPairInterval = pairInterval
        }
        
        //game time stuff
        if let timeRemaining = UserDefaults.standard.value(forKey: "timeRemaining") as? Int {
            self.timeRemaining = timeRemaining
            self.gameDuration = timeRemaining
        }
        
            //background color stuff
        if let rgb = UserDefaults.standard.dictionary(forKey: "newBackgroundColor") {
            self.backgroundColor = UIColor(red: rgb["r"] as! CGFloat, green: rgb["g"] as! CGFloat, blue: rgb["b"] as! CGFloat, alpha: 1.0)
        }
        
        if let rgb2 = UserDefaults.standard.dictionary(forKey: "newTextColor") {
            self.textColor = UIColor(red: rgb2["r"] as! CGFloat, green: rgb2["g"] as! CGFloat, blue: rgb2["b"] as! CGFloat, alpha: 1.0)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if gameState == .paused{
            self.gameStart()
        }
        if  gameState == .initialLaunch {
            self.gameState = .stopped
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
        if gameState == .stopped {
            self.timeRemaining = gameDuration
            self.view.backgroundColor = backgroundColor
            
            self.scoreTimerLabel.textColor = textColor
        }
    }
    
    //function that starts the game
    @objc func startGame(_ Sender: UIButton){
        Sender.removeFromSuperview()
        self.gameStart()
    }
    
    func gameStart(){
        self.gameState = .started
        self.gameTimer = self.createGameTimer()
        self.pairTimer = self.createPairTimer()
    }
    
    func createPairTimer() -> Timer{
        return Timer.scheduledTimer(withTimeInterval: self.newPairInterval, repeats: true, block: { Timer in
            self.createPair()
            //self.updateLabel()
        })
    }
    
    func createGameTimer() -> Timer{ //function that return the timer
        return Timer.scheduledTimer(withTimeInterval: self.gameTimerInterval, repeats: true, block: {Timer in
            if self.timeRemaining > 0 { //this is where im trying to pause game
                self.timeRemaining -= 1
            }else if self.timeRemaining <= 0{
                self.pairTimer?.invalidate()
                self.gameTimer?.invalidate()
                self.pairTimer = nil
                self.gameTimer = nil
                self.createResetButton()
                self.gameState = .stopped
            }
        })
    }
    
    func updateLabel(){
        self.scoreTimerLabel.text = "Created: \(self.numberOfPairs) - Time: \(self.timeRemaining) - Score: \(self.score) - Matched Pairs: \(self.matchedPairs)"
    }
    
    //function that creates a pair of rectangles
    func createPair(){
        if self.gameState == .started{
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
            self.view.bringSubviewToFront(self.pauseButton)
            
            self.matchRec[MatchOne] = pairTag
            self.matchRec[MatchTwo] = pairTag
            self.pairTag += 1
            self.numberOfPairs += 1
        }
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
        let y = CGFloat.random(in: (topSafeInset + (rectSize.height / 2))...(scoreTimerLabel.frame.minY  - (rectSize.height)))
        return CGPoint(x: x, y: y)
    }
    
    func randColor() -> UIColor{
        return UIColor(red: CGFloat.random(in:0...1), green: CGFloat.random(in:0...1), blue: CGFloat.random(in:0...1) , alpha: 1.0)
    }
    
    //function for how we handle the tap
    @objc func handleTap(_ Sender: UIButton){
        if(self.gameState == .started){
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
        let rectLoc = CGPoint(x: 50, y: self.view.safeAreaInsets.top)
        let rectFrame = CGRect(origin: rectLoc, size: rectSize)
        
        
        
        let resetButton = UIButton(frame: rectFrame) // creating first match
        resetButton.addTarget(self, action: #selector(self.resetButtonFunc(_:)), for: .touchUpInside)
        resetButton.setTitle("Reset" , for: .normal)
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
        
        self.view.addSubview(resetButton)
    }
    
    @objc func resetButtonFunc(_ Sender: UIButton){
        
        print("test")
        score = 0
        numberOfPairs = 0
        matchedPairs = 0
        timeRemaining = self.gameDuration
        
        for rect in self.matchRec.keys {
            rect.removeFromSuperview()
        }
        self.matchRec = [:]
        /*if let btn = self.startButton{
            self.view.addSubview(self.startButton!)
        }*/
        self.gameState = .started
        self.gameStart()
        Sender.removeFromSuperview()
    }
    
    func setupSwipeGesture() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeGesture.direction = .left
        
        self.view.addGestureRecognizer(swipeGesture)
    }
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            if self.gameState == .started{
                self.pairTimer?.invalidate()
                self.gameTimer?.invalidate()
                self.gameState = .paused
            }
            performSegue(withIdentifier: "Settings", sender: self)
        }
    }
    
    @IBAction func pause(_ sender: Any) {
        if self.gameState == .started {
            self.gameState = .paused
            self.pairTimer?.invalidate()
            self.gameTimer?.invalidate()
        }else{
            self.gameState = .started
            self.gameStart()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Settings" {
            let destination = segue.destination as? ConfigViewController
            destination?.gameVC = self
            destination?.gameDuration = gameDuration
            destination?.pairInterval = newPairInterval
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}


