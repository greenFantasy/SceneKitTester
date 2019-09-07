//
//  GameViewController.swift
//  SceneKitTest
//
//  Created by Rajat Mittal on 6/28/19.
//  Copyright © 2019 Rajat Mittal. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import RealmSwift

enum BodyType: Int {
    case sphere = 1
    case wall = 2
}

class GameViewController: UIViewController, SCNPhysicsContactDelegate {
    
    private var scoreLabel = UILabel()
    
    private var pauseButton = UIButton(frame: CGRect(x: 668/2 - 50, y: 20, width: 100, height: 20))
    
    private var pauseView = UIView(frame: CGRect(x: 0, y: 0, width: 668, height: 378))
    private var resumeButton = UIButton(frame: CGRect(x: 275, y: 40, width: 100, height: 20))
    
    private var gameView = SCNView(frame: CGRect(x: 0, y: 0, width: 668, height: 378))
    
    private var gameOverView = SCNView(frame: CGRect(x: 0, y: 0, width: 668, height: 378))
    private var restartButton = UIButton(frame: CGRect(x: 275, y: 40, width: 100, height: 20))
    
    private var user: User!
    private var score = 0  // Score variable
    private var timer:Timer? // Creates optional of type Timer
    private var timeLeft = 60  // Variable used in timer for setting amount of time left
    private var count = 0
    private var counter = 0
    private var ship:SCNNode?
    // fix plane to frame size
    private var plane = SCNPlane(width: 100, height: 100)
    private var scene:SCNScene = SCNScene(named: "art.scnassets/ship.scn")!
    private var carArray:[Car] = []
    private var twoWayHorizontalArray:[TwoWayHorizontal] = []
    private var twoWayVerticalArray:[TwoWayVertical] = []
    private var lightArray:[TrafficLight] = []
    private var intersectionArray:[Intersection] = []
    private var carsThrough = 0
    private var scale = 0.35
    private var isOver = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        if realm.objects(User.self).count == 0 {
            try! realm.write {
                let newUser = User()
                
                newUser.highScore = 0
                newUser.level = 1
                
                realm.add(newUser)
                user = newUser
            }
        } else {
            user = realm.objects(User.self)[0]
        }
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: true)
        
        timer?.tolerance = 0.15 // Makes the timer more efficient
        
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.common) // Helps UI stay responsive even with timer
        
        /*  The timer above is now initialized using a few key properties: the timeInterval is the interval in which the timer will update, target is where the timer will be applied, selector specifies a function to run when the timer updates based on the time interval, userInfo can supply information to the selector function, and repeats allows the timer to run continuously until invalidated.
         */
        
        // create a new scene

        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        scene.physicsWorld.contactDelegate = self
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: -10.5, z: 15)
        cameraNode.runAction(SCNAction.rotateBy(x: 0.5, y: 0, z: 0, duration: 0))

        //add plane to the scene
        let planeNode = SCNNode()
        let material = SCNMaterial()
        // 126, 173, 76
        material.diffuse.contents = UIImage(named: "grass")
        material.isDoubleSided = true
        plane.firstMaterial = material
        planeNode.geometry = plane
        planeNode.position = SCNVector3(0, 0, -0.1)
        scene.rootNode.addChildNode(planeNode)

        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: -20, z: 20)
        scene.rootNode.addChildNode(lightNode)

        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)

        // retrieve the ship node
        let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        self.ship = ship

        // animate the 3d object
        //ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 0, z: 0, duration: 1)))
        // run the update function repeatedly

        self.view.addSubview(gameView)
        
        // retrieve the SCNView
        let scnView = gameView
        scnView.delegate = self
        scnView.scene?.physicsWorld.contactDelegate = self
        // set the scene to the view
        scnView.scene = scene
        
        // ADDING LABELS
        
        
        
        
        scnView.addSubview(scoreLabel)
        
        pauseButton.setTitle("Pause", for: .normal)

        scnView.addSubview(pauseButton)
        pauseButton.addTarget(self, action: #selector(pauseGame), for: .touchUpInside)
        
        pauseView.isHidden = true
        self.view.addSubview(pauseView)
        
        gameOverView.isHidden = true
        self.view.addSubview(gameOverView)
        
        resumeButton.setTitle("Resume", for: .normal)
        resumeButton.addTarget(self, action: #selector(resumeGame), for: .touchUpInside)
        pauseView.addSubview(resumeButton)
        
        pauseView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
        gameOverView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
        
        restartButton.setTitle("Restart", for: .normal)
        restartButton.addTarget(self, action: #selector(restartGame), for: .touchUpInside)
        gameOverView.addSubview(restartButton)
        
        // END ADDING LABELS

        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true

        // show statistics such as fps and timing information
        scnView.showsStatistics = true

        // configure the view
        scnView.backgroundColor = UIColor.black
        
        scoreLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        scoreLabel.center = CGPoint(x: scnView.frame.midX, y: scnView.frame.midY)
        scoreLabel.textAlignment = NSTextAlignment.center
        scnView.addSubview(scoreLabel)
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)

        let v1 = createTwoWayVertical(midline: 5)
        let v2 = createTwoWayVertical(midline: -5)
        let h1 = createTwoWayHorizontal(midline: -5)
        let h2 = createTwoWayHorizontal(midline: 5)
        createCar(0, 20, leftStreet: v1.getDownStreet())
        createCar(-20, 0, leftStreet: h1.getRightStreet())
        createCar(0, -20, leftStreet: v2.getUpStreet())
        addStreetHorizontal()
        addStreetVertical()
        addBuildingsToScene(-1.5, 0, "blue", 0)
        addBuildingsToScene(1.5, 0, "yellow", .pi/2)
        addBuildingsToScene(0, -2.2, "red", .pi)
        var offset = 0.0

        for _ in 0...2 {
            let number = Int.random(in: 0 ..< 3)

            switch number {
            case 0:
               addBuildingsToScene(offset + 8, -2.2, "red", .pi)
               addBuildingsToScene(offset + 8, 1.0, "blue", 0)
            case 1:
                addBuildingsToScene(offset + 8, -2.2, "blue", .pi)
                addBuildingsToScene(offset + 8, 1.0, "yellow", 0)
            case 2:
                addBuildingsToScene(offset + 8, -2.2, "yellow", .pi)
                addBuildingsToScene(offset + 8, 1.0, "red", 0)
            default:
                break
            }
            offset += 3
        }

        offset = 0.0
        for _ in 0...2 {
            let number = Int.random(in: 0 ..< 3)

            switch number {
            case 0:
                addBuildingsToScene(offset - 8, -2.2, "red", .pi)
                addBuildingsToScene(offset - 8, 1.0, "yellow", 0)
            case 1:
                addBuildingsToScene(offset - 8, -2.2, "blue", .pi)
                addBuildingsToScene(offset - 8, 1.0, "red", 0)
            case 2:
                addBuildingsToScene(offset - 8, -2.2, "yellow", .pi)
                addBuildingsToScene(offset - 8, 1.0, "blue", 0)
            default:
                break
            }
            offset -= 3
        }

        intersectionCreator()
        addLineToScene(2.0, 6.0, 0, height: 2)
        addLineToScene(6.0, 2.0, 0, width: 2)
        //var a = UpStreetLeftTurn()
//        addLineToScene(-22, 0, 1, height: 15)
//        addLineToScene(22, 0, 1, height: 15)
//        addLineToScene(0, -12, 1, width: 15)
//        addLineToScene(0, 14, 1, width: 15)
    }

    @objc func onTimerFires() {
        timeLeft -= 1
        scoreLabel.text = "\(timeLeft) sec left  Score: " + String(carsThrough)
        
        if timeLeft <= 0 {
            timer?.invalidate()
            timer = nil
            gameOverScreen()
        }
    }
    
    
    func addBoxToScene() -> SCNNode {
        let geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0)
        let node = SCNNode(geometry: geometry)
        node.position = SCNVector3(0, counter, 0)
        scene.rootNode.addChildNode(node)
        return node
    }

    func isOutsideScreen(car: Car) -> Bool {
        let x = car.getXPos()
        let y = car.getYPos()
        if (-22 < x && x < 22 && -12 < y && y < 14) {
            return false
        }
        return true
    }

    func addBoxToScene(_ xPos: Double, _ yPos: Double, _ zPos:Double) -> SCNNode {
        let geometry = SCNBox(width: 1.2, height: 1.2, length: 1.2, chamferRadius: 0)
        let node = SCNNode(geometry: geometry)
        node.position = SCNVector3(xPos, yPos, zPos)
        scene.rootNode.addChildNode(node)
        return node
    }


    func addLineToScene(_ xPos: Double, _ yPos: Double, _ zPos:Double, width: Double) {
        let geometry = SCNBox(width: CGFloat(width), height: 0.5, length: 0.5, chamferRadius: 0)
        let node = SCNNode(geometry: geometry)
        node.position = SCNVector3(xPos, yPos, zPos)
        scene.rootNode.addChildNode(node)
    }

    func addLineToScene(_ xPos: Double, _ yPos: Double, _ zPos:Double, height: Double) -> SCNNode {
        let geometry = SCNBox(width: 0.5, height: CGFloat(height), length: 0.5, chamferRadius: 0)
        let node = SCNNode(geometry: geometry)
        node.position = SCNVector3(xPos, yPos, zPos)
        scene.rootNode.addChildNode(node)
        return node
    }

    func addCarToScene(_ xPos: Double, _ yPos: Double, _ zPos:Double, _ color:String) -> SCNNode {
        let newScene = SCNScene(named: "art.scnassets/Car" + color + ".scn")
        let node = newScene!.rootNode.childNode(withName: "Car", recursively: true)!
        node.runAction(SCNAction.rotateBy(x: .pi/2, y: 0, z: 0, duration: 0))
        node.runAction(SCNAction.scale(by: CGFloat(scale), duration: 0))
        node.position = SCNVector3(xPos, yPos, zPos)
        node.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: SCNBox(width: CGFloat(0.9 * scale/0.4), height: CGFloat(1.8 * scale/0.4), length: CGFloat(1.0 * scale/0.4), chamferRadius: 0.0)))
        node.physicsBody?.categoryBitMask = BodyType.sphere.rawValue
        node.physicsBody?.collisionBitMask = BodyType.sphere.rawValue
        node.physicsBody?.contactTestBitMask = BodyType.sphere.rawValue
        node.physicsBody?.isAffectedByGravity = false
        scene.rootNode.addChildNode(node)
        return node
    }

    func addBuildingsToScene(_ xPos: Double, _ yPos: Double, _ color:String, _ rotation:Double) {
        let newScene = SCNScene(named: "art.scnassets/building.scn")
        let node = newScene!.rootNode.childNode(withName: "apartments2_000", recursively: true)!
        node.runAction(SCNAction.rotateBy(x: .pi/2, y: 0, z: CGFloat(rotation), duration: 0))
        node.runAction(SCNAction.scale(by: 0.3, duration: 0))
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: color)
        node.geometry?.firstMaterial = material
        let max = node.boundingBox.max
        let h = CGFloat(max.y)
        node.position = SCNVector3(xPos, yPos, Double(h/2))
        scene.rootNode.addChildNode(node)
    }

    func createCar(_ xPos:Double, _ yPos:Double, leftStreet: StreetProtocol) {
        // let number = Int.random(in: -700 ... 300)
        var create = true
        for vehicle in carArray {
            if (absoluteValue(xPos, vehicle.getXPos()) < 2.0 && absoluteValue(yPos, vehicle.getYPos()) < 2.0) {
                create = false
            }
        }
        
        if create {
            let car = Car(x: xPos, y: yPos, street: leftStreet)
            var color = ""
            let number = Int.random(in: 0 ..< 3)
            switch number {
            case 0:
                color = "Red"
            case 1:
                color = "Blue"
            case 2:
                color = "Yellow"
            default:
                break
            }
            let node = addCarToScene(xPos, yPos, 0, color)
            car.setNode(node: node)
            carArray.append(car)
        }
    }

    func createTwoWayHorizontal(midline: Double) -> TwoWayHorizontal {
        let twoWayHorizontal = TwoWayHorizontal(midline: midline)
        twoWayHorizontalArray.append(twoWayHorizontal)
//        self.addChild(twoWayHorizontal.getNode())
        return twoWayHorizontal
    }

    func createTwoWayVertical(midline: Double) -> TwoWayVertical {
        let twoWayVertical = TwoWayVertical(midline: midline)
        twoWayVerticalArray.append(twoWayVertical)
//        self.addChild(twoWayVertical.getNode())
        return twoWayVertical
    }

    func intersectionCreator() {
        for horizontalTwoWay in twoWayHorizontalArray {
            for verticalTwoWay in twoWayVerticalArray {
                let intersection = Intersection(horizontal: horizontalTwoWay, vertical: verticalTwoWay)
                intersectionArray.append(intersection)
                addImageOfIntersection(coordinates: intersection.getPosition())
//                addLineToScene(intersection.getXFrame()[0], intersection.getPosition()[1], 0, height: 4.0)
//                addLineToScene(intersection.getXFrame()[1], intersection.getPosition()[1], 0, height: 4.0)
//                addLineToScene(intersection.getPosition()[0], intersection.getYFrame()[0], 0, width: 4.0)
//                addLineToScene(intersection.getPosition()[0], intersection.getYFrame()[1], 0, width: 4.0)
                for trafficLight in intersection.getAllLights() {
                    createLight(trafficLight: trafficLight)
                }
            }
        }
    }

    func addStreetHorizontal() {
        for horizontalTwoWay in twoWayHorizontalArray {
            var offset = 0.0
            for _ in 0...100 {
                let streetPlane = SCNPlane(width: 0.739, height: 4.027)
                let planeNode = SCNNode()
                let material = SCNMaterial()
                material.diffuse.contents = UIImage(named: "streetHorizontal")
                material.isDoubleSided = true
                streetPlane.firstMaterial = material
                planeNode.geometry = streetPlane
                planeNode.position = SCNVector3(30 - offset, horizontalTwoWay.getMidline() + 0.025, 0)
                scene.rootNode.addChildNode(planeNode)
                offset += 0.739
            }
        }
    }

    func addStreetVertical() {
        for verticalTwoWay in twoWayVerticalArray {
            var offset = 0.0
            for _ in 0...50 {
                let streetPlane = SCNPlane(width: 4.027, height: 0.739)
                let planeNode = SCNNode()
                let material = SCNMaterial()
                material.diffuse.contents = UIImage(named: "streetVertical")
                material.isDoubleSided = true
                streetPlane.firstMaterial = material
                planeNode.geometry = streetPlane
                planeNode.position = SCNVector3(verticalTwoWay.getMidline() - 0.025, 15 - offset, 0)
                scene.rootNode.addChildNode(planeNode)
                offset += 0.739
            }
        }
    }

    func addImageOfIntersection(coordinates: [Double]) {
        let streetPlane = SCNPlane(width: 10, height: 10)
        let planeNode = SCNNode()
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "intersection")
        material.isDoubleSided = true
        streetPlane.firstMaterial = material
        planeNode.geometry = streetPlane
        planeNode.position = SCNVector3(coordinates[0], coordinates[1], 0.001)
        scene.rootNode.addChildNode(planeNode)
    }

    func createLight(trafficLight: TrafficLight) {
        let light = trafficLight
        let node = addBoxToScene(light.getXPos(),light.getYPos(),light.getZPos())
        light.setNode(node: node)
        lightArray.append(light)
        light.getNode().name = String(lightArray.count - 1)
    }

    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = gameView
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]

            let node = result.node
            if let name = node.name {
                if let index = Int(name) {
                    lightArray[index].changeState()
                    if (index % 2 == 0) {
                        lightArray[index+1].changeState()
                    } else {
                        lightArray[index-1].changeState()
                    }
                }
            }
        }
    }
    
    @objc func pauseGame() {
        print("Pause Method is running")
        
        timer?.invalidate()
        
        scene.isPaused = true
        
        pauseView.isHidden = false
        
        gameView.isUserInteractionEnabled = false
    }
    
    @objc func resumeGame() {
        print("Resume Method is running")
        
        pauseView.isHidden = true
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: true)
        
        timer?.tolerance = 0.15 // Makes the timer more efficient
        
        scene.isPaused = false
        
        gameView.isUserInteractionEnabled = true
    }
    
    @objc func restartGame() {
        print("Restart Method is running")
        
        gameOverView.isHidden = false // this line is just for temporary app testing
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    func calcXDistance(car1: Car?, car2: Car?) -> Double {
        //        let boundingBox1 = car1.getNode().path!.boundingBox
        //        let vehicleWidth1 = boundingBox1.size.width/2
        //        let boundingBox2 = car2.getNode().path!.boundingBox
        //        let vehicleWidth2 = boundingBox2.size.width/2
        //        return car1.getXPos() - car2.getXPos() - Int(vehicleWidth1) - Int(vehicleWidth2)
        if let vehicle1 = car1 {
            if let vehicle2 = car2 {
                return absoluteValue(vehicle1.getXPos(), vehicle2.getXPos())
            } else {
                return 1000000
            }
        } else {
            return 1000000
        }
    }

    func calcYDistance(car1: Car?, car2: Car?) -> Double {
        //        let boundingBox1 = car1.getNode().path!.boundingBox
        //        let vehicleWidth1 = boundingBox1.size.width/2
        //        let boundingBox2 = car2.getNode().path!.boundingBox
        //        let vehicleWidth2 = boundingBox2.size.width/2
        //        return car1.getXPos() - car2.getXPos() - Int(vehicleWidth1) - Int(vehicleWidth2)
        if let vehicle1 = car1 {
            if let vehicle2 = car2 {
                return absoluteValue(vehicle1.getYPos(),vehicle2.getYPos())
            } else {
                return 1000000
            }
        } else {
            return 1000000
        }
    }

    func absoluteValue(_ a:Double, _ b:Double) -> Double {
        if (a>b) {
            return a-b
        } else {
            return b-a
        }
    }

    func absoluteValue(_ a:Double) -> Double {
        if (a>=0) {
            return a
        } else {
            return -a
        }
    }

    func speedModifier(distance:Double) -> Double {
        let minDistance = 2.0
        let highSpeedDistance = 4.25
        if distance <= minDistance {
            return 0
        } else if (distance <= highSpeedDistance) {
            return (distance - minDistance)/(highSpeedDistance-minDistance)
        }
        else {
            return 1
        }
    }

    func moveCarForward(vehicle: Car) {
        let vec = vehicle.directionToVector()

        vehicle.move(xVel: Double(vec[0]) * vehicle.getTopSpeed() * speedModifier(distance: absoluteValue(calcXDistance(car1: vehicle, car2: vehicle.getClosestCar()))), yVel: Double(vec[1]) * vehicle.getTopSpeed() * speedModifier(distance: absoluteValue(calcYDistance(car1: vehicle, car2: vehicle.getClosestCar()))))
    }

    func move() {
        var elementsToRemove:[Int] = []
        for i in 0...carArray.count-1 {
            let vehicle = carArray[i]
            var moveVehicle = true
            let tempLight = vehicle.findLight()
            if let lightInFront = tempLight {
                if (isVehicleCloseToLight(vehicle: vehicle, light: lightInFront) && lightInFront.isRed()) {
                    moveVehicle = false
                    vehicle.setCurrentSpeed(speed: 0.02)
                }
            }

            if (moveVehicle) {
                if let intersection = isCarAtAnyIntersectionChecker(vehicle) {
                    _ = vehicle.addToIntersectionArray(intersection: intersection)
                    if (vehicle.getLastTurn() == 0 || vehicle.isLastTurnCompleted()) {
                        moveCarForward(vehicle: vehicle)
                    } else if vehicle.getLastTurn() == 1 {
                        vehicle.makeRightTurn(intersection: intersection)
                    } else if vehicle.getLastTurn() == 2 {
                        vehicle.makeLeftTurn(intersection: intersection)
                    }
                } else {
                    moveCarForward(vehicle: vehicle)
                }
            }
            if (isOutsideScreen(car: vehicle)) {
                if (vehicle.getDirection() == 0 && vehicle.getXPos() < 0) {
                    createCar(30, vehicle.getYPos(), leftStreet: vehicle.getStreet())
                    createCar(40, vehicle.getYPos(), leftStreet: vehicle.getStreet())
                    elementsToRemove.append(i)
                    removeCar(vehicle)
                } else if (vehicle.getDirection() == 1 && vehicle.getXPos() > 0) {
                    createCar(-30, vehicle.getYPos(), leftStreet: vehicle.getStreet())
                    createCar(-40, vehicle.getYPos(), leftStreet: vehicle.getStreet())
                    elementsToRemove.append(i)
                    removeCar(vehicle)
                } else if (vehicle.getDirection() == 2 && vehicle.getYPos() < 0) {
                    createCar(vehicle.getXPos(), 20, leftStreet: vehicle.getStreet())
                    createCar(vehicle.getXPos(), 30, leftStreet: vehicle.getStreet())
                    elementsToRemove.append(i)
                    removeCar(vehicle)
                } else if (vehicle.getDirection() == 3 && vehicle.getYPos() > 0) {
                    createCar(vehicle.getXPos(), -20, leftStreet: vehicle.getStreet())
                    createCar(vehicle.getXPos(), -30, leftStreet: vehicle.getStreet())
                    elementsToRemove.append(i)
                    removeCar(vehicle)
                }
            }
        }
        removeElementsFromArray(elementsToRemove: elementsToRemove, array: &carArray)
    }

    func removeCar(_ vehicle: Car) {
        vehicle.getNode().removeFromParentNode()
        vehicle.getStreet().removeCar(car: vehicle)
        carsThrough += 1
    }

    func removeElementsFromArray(elementsToRemove: [Int], array: inout [Car]) {
        let elementsReversed = elementsToRemove.reversed()
        for i in elementsReversed {
            array.remove(at: i)
        }
    }

    func isVehicleCloseToLight(vehicle: Car, light: TrafficLight) -> Bool {
        let width = light.getIntersection().getWidth() + 5.0 * light.getRadius()
        let height = light.getIntersection().getHeight() + 5.0 * light.getRadius()
        if vehicle.getDirection() == 0 {
            return vehicle.getXPos() > light.getXPos() + width && vehicle.getXPos() < light.getXPos() + width + 0.5
        } else if vehicle.getDirection() == 2 {
            return vehicle.getYPos() > light.getYPos() + height && vehicle.getYPos() < light.getYPos() + height + 0.5
        } else if vehicle.getDirection() == 1 {
            return vehicle.getXPos() < light.getXPos() - width && vehicle.getXPos() > light.getXPos() - width - 0.5
        } else {
            return vehicle.getYPos() < light.getYPos() - height && vehicle.getYPos() > light.getYPos() - height - 0.5
        }
    }

    func isCarAtAnyIntersectionChecker(_ car: Car) -> Intersection? {
        for intersection in intersectionArray {
//            if (intersection.isCarAtIntersection(car)) {
//                return intersection
//            }
            if (car.isAtIntersection2(intersection: intersection)) {
                return intersection
            }
        }
        return nil
    }

    func checkCollisions() {

        var hitCars: [Car] = []
        let displaySize: CGRect = UIScreen.main.bounds
        let displayWidth = displaySize.width
        let displayHeight = displaySize.height
        print(displayWidth, displayHeight)
        for i in 0...carArray.count-2 {
//            if (carArray[i].getXPos() > -Int(scene!.frame.width)/2 && carArray[i].getXPos() <  Int(scene!.frame.width)/2 && carArray[i].getYPos() > -Int(scene!.size.height)/2 && carArray[i].getYPos() < Int(scene!.size.height)/2)
//            {
                for j in i+1...carArray.count-1 {
                    if (carArray[i].getNode().frame.intersects(carArray[j].getNode().frame) && (!carArray[i].getIntersected() || !carArray[j].getIntersected()) )
                    {
                        print("test")
                        hitCars.append(carArray[j])
                        hitCars.append(carArray[i])
                    }


             //   }
            }

        }

        if (hitCars.count>0){

            for i in 0...hitCars.count-1 {

                if (i%2==1) {
                    if (hitCars[i].getLastTurn() == 2 && hitCars[i-1].getLastTurn() == 2) {
                        print("two left turning hit cars, no issue")
                    } else {
                        //hitCounter += 1
                    //    hitCars[i].changeIntersected()
                    //    hitCars[i-1].changeIntersected()
                       // print("Car Hit #" + String(hitCounter))
                        gameOverScreen()
                    }
                }

            }

        }

    }

    func gameOverScreen() {
        timer?.invalidate()
        timer = nil
        
       // endView.isHidden = false

        var isHighScore = false
        
        DispatchQueue.main.async {
            self.gameOverView.isHidden = false
        }
        
        //gameOverView.isHidden = false
//        if user.highScore < score {
//            isHighScore = true
//            let realm = try! Realm()
//
//            try! realm.write {
//                user.highScore = score
//            }
//        }

//        let labels = getLabelsInView(view: endView)
//        for label in labels {
    
//        if isHighScore {
//            scoreLabel.text = "Game over!  Score: " + String(carsThrough) + "! Highscore"
//        } else {
//            scoreLabel.text = "Game over!  Score: " + String(carsThrough)
//        }
        //label.frame.origin = CGPoint(x: frame.midX, y: frame.midY)
       // }
        print("Collision")
    }

    func getLabelsInView(view: UIView) -> [UILabel] {
        var results = [UILabel]()
        for subview in view.subviews as [UIView] {
            if let labelView = subview as? UILabel {
                results += [labelView]
            } else {
                results += getLabelsInView(view: subview)
            }
        }
        return results
    }


    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let contactMask = contact.nodeA.categoryBitMask | contact.nodeB.categoryBitMask
        stopCar(car: getCarFromNode(node: contact.nodeA))
        stopCar(car: getCarFromNode(node: contact.nodeB))
        gameOverScreen()
        count += 1
    }

    func getCarFromNode(node: SCNNode) -> Car? {
        for car in carArray {
            if (node === car.getNode()) {
                return car
            }
        }
        return nil
    }

    func stopCar(car: Car?) {
        if let vehicle = car {
            vehicle.changeIntersected()
        }
    }

}


extension GameViewController: SCNSceneRendererDelegate {
    // 2
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // 3
        counter += 1

        if let spaceShip = ship {
            spaceShip.position = SCNVector3(spaceShip.position.x, spaceShip.position.y, spaceShip.position.z-1)
        }
        move()
     //   checkCollisions()
    }
}
