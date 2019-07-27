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

class GameViewController: UIViewController {
    
    
    private var counter = 0
    private var ship:SCNNode?
    private var scene:SCNScene = SCNScene(named: "art.scnassets/ship.scn")!
    private var carArray:[Car] = []
    private var twoWayHorizontalArray:[TwoWayHorizontal] = []
    private var twoWayVerticalArray:[TwoWayVertical] = []
    private var lightArray:[TrafficLight] = []
    private var intersectionArray:[Intersection] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 30)
        
        //add plane to the scene
        //scene.rootNode.addChildNode(SCNNode(geometry: plane))
        
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 300, z: 20)
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
        
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        scnView.delegate = self
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        let v1 = createTwoWayVertical(midline: 5)
        let v2 = createTwoWayVertical(midline: -5)
        let h1 = createTwoWayHorizontal(midline: -5)
        let h2 = createTwoWayHorizontal(midline: 5)
        createCar(0, 20, leftStreet: v1.getDownStreet())
        createCar(-20, 0, leftStreet: h1.getRightStreet())
        createCar(0, -15, leftStreet: v2.getUpStreet())
        intersectionCreator()
    }
    
    func addBoxToScene() -> SCNNode {
        let geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0)
        let node = SCNNode(geometry: geometry)
        node.position = SCNVector3(0, counter, 0)
        scene.rootNode.addChildNode(node)
        return node
    }
    
    func addBoxToScene(_ xPos: Double, _ yPos: Double, _ zPos:Double) -> SCNNode {
        let geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0)
        let node = SCNNode(geometry: geometry)
        node.position = SCNVector3(xPos, yPos, zPos)
        scene.rootNode.addChildNode(node)
        return node
    }
    
    func createCar(_ xPos:Double, _ yPos:Double, leftStreet: StreetProtocol) {
        // let number = Int.random(in: -700 ... 300)
        let streetCarArray = leftStreet.getCars()
        let car = Car(x: xPos, y: yPos, street: leftStreet)
        let node = addBoxToScene()
        car.setNode(node: node)
        carArray.append(car)
        for vehicle in streetCarArray {
            if let car2 = car.getClosestCar() {
                if (leftStreet.getDirection() == 0 && car2.getXPos() < vehicle.getXPos() && car.getXPos() > vehicle.getXPos()) {
                    vehicle.setClosestCar(car: vehicle)
                }
                if (leftStreet.getDirection() == 1 && car2.getXPos() > vehicle.getXPos() && car.getXPos() < vehicle.getXPos()) {
                    
                    vehicle.setClosestCar(car: vehicle)
                }
            }
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
                for trafficLight in intersection.getAllLights() {
                    createLight(trafficLight: trafficLight)
                }
            }
        }
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
        let scnView = self.view as! SCNView
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            let node = result.node
            print(node)
            if let name = node.name {
                print(name)
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
    
    func update() {
        print("updating")
        
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
        let highSpeedDistance = 10.0
        if distance <= minDistance {
            return 0
        } else if (distance <= highSpeedDistance) {
            return Double((distance - minDistance))/Double(highSpeedDistance-minDistance)
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
        }
    }
    
    func isVehicleCloseToLight(vehicle: Car, light: TrafficLight) -> Bool {
        let width = light.getIntersection().getWidth() + 2 * light.getRadius()
        let height = light.getIntersection().getHeight() + 2 * light.getRadius()
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
            if (intersection.isCarAtIntersection(car)) {
                return intersection
            }
        }
        return nil
    }
}

// 1
extension GameViewController: SCNSceneRendererDelegate {
    // 2
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // 3
        counter += 1
        
        if let spaceShip = ship {
            spaceShip.position = SCNVector3(spaceShip.position.x, spaceShip.position.y, spaceShip.position.z-1)
        }
        move()
    }
}
