//
//  GameSceneViewController.swift
//  Geo Loco
//
//  Created by Kedrick Karasek on 11/21/23.
//

import UIKit
import MapKit //need this for maps
import CoreLocation
import Accelerate

class GameSceneViewController: UIViewController , MKLookAroundViewControllerDelegate, MKMapViewDelegate{
    
    @IBOutlet weak var streetViewContainerView: UIView!
    @IBOutlet weak var userSelectionMap: MKMapView!
    @IBOutlet weak var Pannel: UIImageView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var secondRemainingLabel: UILabel!
    //weak var lookAroundDelegate: MKLookAroundDelegate?
        
    var lookAroundVC: MKLookAroundViewController?
    
    let selectionMap : MKMapView = {
        let map = MKMapView()
        map.overrideUserInterfaceStyle = .dark
        return map
    }()
    
    var randomLocation : MKPointAnnotation?
    
    var pinPlaced = false;
    
    var coordinate : CLLocationCoordinate2D?
    
    var distanceCoordinate : CLLocationCoordinate2D?
    
    var locationList : [GeoLocation]?
    
    var currentSelected : CGPoint?
    
    var yesButton : UIButton?
    
    var noButton : UIButton?
    
    var gameTimerInterval: TimeInterval = 1.0
    
    var gameTimer: Timer?
    
    var Score: Double = 0.0
    
    var gameIsOver = false
    
    var placementButtonsOnScreen = false
    
    var distanceMile = ""
    
    var timeRemaining = 240{
        didSet{
            self.updateTimerLabel()
            print(timeRemaining) //change with some text
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMapConstraints()
        self.navigationController?.navigationBar.isHidden = true
        self.view.bringSubviewToFront(Pannel)
        self.view.bringSubviewToFront(timerLabel)
        self.view.bringSubviewToFront(secondRemainingLabel)
       // selectionMap.addAnnotation(randomLocation!)
       // self.selectionMap.removeConstraints(self.selectionMap.constraints)
        print("\n\n\n\n")
        if let file = Bundle.main.url(forResource: "cities", withExtension: "json") {
            let fileData = (try? Data(contentsOf: file))!
            let json = try? JSONDecoder().decode(Array<GeoLocation>.self, from: fileData)
            //print(json![0].city)
            locationList = json
        } else {
            print("FAILED TO LOAD JSON FILE")
        }
        print("\n\n\n\n")
        self.selectionMap.delegate = self
        coordinate = generateRandomLocation()
        setupLookAround(coordinate: coordinate!)
        self.gameTimer = self.createGameTimer()
            
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
                selectionMap.addGestureRecognizer(longPressGesture)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.gameTimer?.invalidate()
        
    }
    
    //gesture recognizer for placing pin
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer){
        if(!pinPlaced && !gameIsOver){ //to make sure only one pin is placed for the user
            if gestureRecognizer.state == .ended{
                currentSelected = gestureRecognizer.location(in: selectionMap)
                placePinButton()
                noPinButton()
                self.placementButtonsOnScreen = true
            }
        }
    }
    
    func setUpMapConstraints(){
        view.addSubview(selectionMap)
        
        selectionMap.translatesAutoresizingMaskIntoConstraints = false
        selectionMap.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        selectionMap.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        selectionMap.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        selectionMap.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    }
    
    func generateRandomLocation() -> CLLocationCoordinate2D{
        let randomLocNum = Int.random(in: 0...999)
        
        var latitude = CLLocationDegrees(locationList![randomLocNum].latitude)
        var longitude = CLLocationDegrees(locationList![randomLocNum].longitude)
        
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude:longitude)
        distanceCoordinate = coordinate
        print(coordinate)
        return coordinate
    }
    
    func setupLookAround(coordinate: CLLocationCoordinate2D) {
       // let coordinate2 = CLLocationCoordinate2D(latitude: 40.66211, longitude: -74.21516) // Example
            let sceneRequest = MKLookAroundSceneRequest(coordinate: coordinate)
            // Request a Look Around scene using getSceneWithCompletionHandler
            sceneRequest.getSceneWithCompletionHandler { [weak self] (scene, error) in
                guard let self = self, let scene = scene else {
                    print(error?.localizedDescription ?? "Unknown error occurred")
                    var newCoordinates = self!.generateRandomLocation()
                    self!.setupLookAround(coordinate: newCoordinates)
                    return;
                }
                
                // Inside the completion handler after error checking
                let lookAroundVC = MKLookAroundViewController(scene: scene)
                lookAroundVC.delegate = self
                
                self.addChild(lookAroundVC)
                let width = self.view.frame.width / 2
                let height = width * 2/3
                let x = 16.0
                let y = self.view.frame.height - self.view.safeAreaInsets.bottom - height
                let frame = CGRect(x: x, y: y, width: width, height: height)
                lookAroundVC.view.frame = frame
                
                self.view.addSubview(lookAroundVC.view)
                
                lookAroundVC.didMove(toParent: self)
                
                self.lookAroundVC = lookAroundVC
            }
        }
    
    func lookAroundViewControllerDidPresentFullScreen(_ viewController: MKLookAroundViewController) {
        let rectSize = CGSize(width: 1000, height: 1000)
        let x = 0
        let y = 0
        let rectLoc = CGPoint(x: x , y: y)
        let rectFrame = CGRect(origin: rectLoc, size: rectSize)
        
        let hideText = UIButton(frame: rectFrame) // creating first match
        hideText.setTitle("" , for: .normal)
        hideText.setTitleColor(.white, for: .normal)
        hideText.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
        hideText.translatesAutoresizingMaskIntoConstraints = false
        
        viewController.view.addSubview(hideText)
        viewController.showsRoadLabels = false
        viewController.view.bringSubviewToFront(hideText)
        print("\n\nVIEWS: \n")
        viewController.isNavigationEnabled = false
    }
    
    func placePinButton(){
        let rectSize = CGSize(width: 200, height: 100)
        let rectLoc = CGPoint(x: self.view.frame.midX - 100, y: self.view.frame.midY - 150)
        let rectFrame = CGRect(origin: rectLoc, size: rectSize)
        
        
        
        let placePinButton = UIButton(frame: rectFrame) // creating first match
        placePinButton.addTarget(self, action: #selector(self.placePinButtonFunc(_:)), for: .touchUpInside)
        placePinButton.setTitle("Confirm Placement" , for: .normal)
        placePinButton.setTitleColor(.white, for: .normal)
        if let backgroundImg = UIImage(named: "Green Marble") {
            placePinButton.setBackgroundImage(backgroundImg, for: .normal )
        }else{
            print("Button Image Was Unable To Load")
        }
        
        self.yesButton = placePinButton
        self.view.addSubview(yesButton!)
        
        placePinButton.layer.cornerRadius = 10
        placePinButton.clipsToBounds = true
        
        placePinButton.layer.borderWidth = 3.0
        placePinButton.layer.borderColor = UIColor.black.cgColor
    }
    
    @objc func placePinButtonFunc(_ Sender: UIButton){
        let coordinate = selectionMap.convert(currentSelected!, toCoordinateFrom: selectionMap)
                
        var selectedAnnotation = MKPointAnnotation()
        selectedAnnotation.coordinate = coordinate
        selectionMap.addAnnotation(selectedAnnotation)
        
        var randomLocAnnotation = MKPointAnnotation()
        randomLocAnnotation.coordinate = distanceCoordinate!
        selectionMap.addAnnotation(randomLocAnnotation)
        
        let selectedLoc = CLLocation(latitude: selectedAnnotation.coordinate.latitude, longitude: selectedAnnotation.coordinate.longitude)
        
        let randomLoc = CLLocation(latitude: randomLocAnnotation.coordinate.latitude, longitude: randomLocAnnotation.coordinate.longitude)
    
        let distanceInMeters = selectedLoc.distance(from: randomLoc)
        let distanceInMiles = distanceInMeters / 1609.344
        distanceMile = String(distanceInMiles.description.prefix(8))
        calculateScore(number: distanceInMiles)
        print("miles below") //replace with setting some text
        print(distanceInMiles)
        
        // not working
        let coordinates: [CLLocationCoordinate2D] = [selectedAnnotation.coordinate, randomLocAnnotation.coordinate]
        let polyLine = MKPolyline(coordinates: coordinates, count: coordinates.count)
        
        self.selectionMap.addOverlay(polyLine)
        // section above not working
        pinPlaced.toggle()
        
        
        self.gameTimer?.invalidate()
        yesButton!.removeFromSuperview()
        noButton!.removeFromSuperview()
        placementButtonsOnScreen = false
        gameOver()
    }
    
    func noPinButton(){
        let rectSize = CGSize(width: 200, height: 100)
        let rectLoc = CGPoint(x: self.view.frame.midX - 100, y: self.view.frame.midY)
        let rectFrame = CGRect(origin: rectLoc, size: rectSize)
        
        
        
        let noPinButton = UIButton(frame: rectFrame) // creating first match
        noPinButton.addTarget(self, action: #selector(self.noPinButtonFunc(_:)), for: .touchUpInside)
        noPinButton.setTitle("Deny Placement" , for: .normal)
        noPinButton.setTitleColor(.black, for: .normal)
        if let backgroundImg = UIImage(named: "Red Marble") {
            noPinButton.setBackgroundImage(backgroundImg, for: .normal )
        }else{
            print("Button Image Was Unable To Load")
        }
        self.noButton = noPinButton
        
        self.view.addSubview(noButton!)
        
        noPinButton.layer.cornerRadius = 10
        noPinButton.clipsToBounds = true
        
        noPinButton.layer.borderWidth = 3.0
        noPinButton.layer.borderColor = UIColor.black.cgColor
    }
    
    @objc func noPinButtonFunc(_ Sender: UIButton){
        yesButton!.removeFromSuperview()
        noButton!.removeFromSuperview()
        placementButtonsOnScreen = false
    }
    
    func createGameTimer() -> Timer{ //function that return the timer
        return Timer.scheduledTimer(withTimeInterval: self.gameTimerInterval, repeats: true, block: {Timer in
            if self.timeRemaining > 0 { //this is where im trying to pause game
                self.timeRemaining -= 1
            }else if self.timeRemaining <= 0{  //if time runs out do this
                self.gameTimer?.invalidate()
                self.gameTimer = nil
                self.gameOver()
            }
        })
    }
    
    func updateTimerLabel(){
        self.timerLabel.text = "\(self.timeRemaining)"
    }
    
    func calculateScore(number: Double) {
        // Assuming the input number ranges from 0 to 40,075,020
        let worldCir: Double = 24901.6796 / 3
        let invertedValue : Double = worldCir - number  // Invert the value
        let scaleFactor : Double = 100.0  // Adjust the scale factor as needed

        let scaledScore = (invertedValue / worldCir) * scaleFactor

        self.Score = scaledScore
        print("score below") // replace with some text on screen
        print(Score)
    }
    
    func gameOver(){
        print("gameIsOver")
        self.gameIsOver = true
        self.gameTimer?.invalidate()
        mainMenuButton()
        createScoreLabels()
        if(placementButtonsOnScreen){
            yesButton!.removeFromSuperview()
            noButton!.removeFromSuperview()
        }
    }
    
    func mainMenuButton(){
        let rectSize = CGSize(width: 200, height: 100)
        let rectLoc = CGPoint(x: self.view.frame.midX - 100, y: self.view.frame.midY - 100)
        let rectFrame = CGRect(origin: rectLoc, size: rectSize)
        
        
        
        let mainMenuButton = UIButton(frame: rectFrame) // creating first match
        mainMenuButton.addTarget(self, action: #selector(self.mainMenuButtonFunc(_:)), for: .touchUpInside)
        mainMenuButton.setTitle("Return To Main Menu" , for: .normal)
        mainMenuButton.setTitleColor(.black, for: .normal)
        if let backgroundImg = UIImage(named: "Red Marble") {
            mainMenuButton.setBackgroundImage(backgroundImg, for: .normal )
        }else{
            print("Button Image Was Unable To Load")
        }
        
        self.view.addSubview(mainMenuButton)
        
        mainMenuButton.layer.cornerRadius = 10
        mainMenuButton.clipsToBounds = true
        
        mainMenuButton.layer.borderWidth = 3.0
        mainMenuButton.layer.borderColor = UIColor.black.cgColor
    }
    
    @objc func mainMenuButtonFunc(_ Sender: UIButton){
        performSegue(withIdentifier: "backToMain", sender: self)
        Sender.removeFromSuperview()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToMain"{
            let destination = segue.destination as? MainMenuViewController
            destination?.navigationController?.setViewControllers([destination!], animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let line = overlay as? MKPolyline {
            let rendered = MKPolylineRenderer(polyline: line)
            rendered.strokeColor = .blue
            rendered.lineWidth = 7
            return rendered
        }
        return MKOverlayRenderer()
    }
    
    func createLabelWithShadow(text: String, textColor: UIColor, textSize: CGFloat) -> UILabel{
        let label = UILabel()
        label.text = text
        label.textColor = textColor
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: textSize)
        
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        label.layer.shadowOpacity = 0.5
        label.layer.shadowRadius = 4.0
        
        return label
    }
    
    func createScoreLabels(){
        //score labels
        let scoreLabel = createLabelWithShadow(text: String(self.Score.description.prefix(4)), textColor: .white, textSize: 25)
        scoreLabel.frame = CGRect(x: self.view.frame.midX - 100,y: self.view.frame.midY + 175,width: 200, height: 100)
        view.addSubview(scoreLabel)
        
        let scoreTextLabel = createLabelWithShadow(text: "New Score", textColor: .red, textSize: 25)
        scoreTextLabel.frame = CGRect(x: self.view.frame.midX - 100,y: self.view.frame.midY + 150,width: 200, height: 100)
        view.addSubview(scoreTextLabel)
        
        //distance labels
        if(pinPlaced){
            let distanceLabel = createLabelWithShadow(text: distanceMile, textColor: .white, textSize: 25)
            distanceLabel.frame = CGRect(x: self.view.frame.midX - 100,y: self.view.frame.midY + 100 ,width: 200, height: 100)
            view.addSubview(distanceLabel)
        }else{
            let distanceLabel = createLabelWithShadow(text: "Too Slow Loser", textColor: .white, textSize: 25)
            distanceLabel.frame = CGRect(x: self.view.frame.midX - 100,y: self.view.frame.midY + 100 ,width: 200, height: 100)
            view.addSubview(distanceLabel)
        }
        let distanceTextLabel = createLabelWithShadow(text: "Distance From Location", textColor: .red, textSize: 25)
        distanceTextLabel.frame = CGRect(x: self.view.frame.midX - 150,y: self.view.frame.midY + 75,width: 300, height: 100)
        view.addSubview(distanceTextLabel)
        
        //game over
        let gameOverLabel = createLabelWithShadow(text: "🎉 GAME OVER 🎉", textColor: .orange, textSize: 40)
        gameOverLabel.frame = CGRect(x: self.view.frame.midX - 175,y: self.view.frame.midY - 250,width: 350, height: 100)
        view.addSubview(gameOverLabel)
    }
}
