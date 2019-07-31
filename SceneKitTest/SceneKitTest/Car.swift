//
//  Car.swift
//  trafficSense
//
//  Created by Rajat Mittal on 6/20/19.
//  Copyright © 2019 Yousef Ahmed. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit
import SceneKit


class Car: SKShapeNode {  // Car implements SKShapeNode class
    
    private var sceneNode = SCNNode(geometry: SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0))
    private var geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0)
    private let topSpeed:Double = 0.2
    private var xPos:Double
    private var yPos:Double
    private var zPos:Double
    private var previousStreet:StreetProtocol
    private var currentStreet:StreetProtocol
    private var closestCar: Car?
    private var intersectionArray:[Intersection] = [] // contains all intersections a car has turned at, a car cannot turn at the same intersection twice
    private var intersected = false
    private var turnArray:[Int] = [] // when 0, it's going to continue straight, when 1, the car will turn right, when 2, the car will turn left
    private var completedTurnsArray:[Bool] = []
    private var currentIntersection: Intersection?
    
    //private let finalDestination
    
    init (x: Double, z: Double, street: StreetProtocol) {
        sceneNode = SCNNode(geometry: geometry)
//        geometry.firstMaterial?.diffuse.contents = UIColor.green
        sceneNode.position = SCNVector3(x, 0, z)
        xPos = x
        yPos = 0
        zPos = z
        currentStreet = street
        
        closestCar = nil
        previousStreet = currentStreet
        super.init()
        
        currentStreet.addCar(car: self)
        fixPosOnStreet()
        updateShapeNodePos()
        updateTurnArray()
    }
    
    func fixPosOnStreet() {
        if (currentStreet.getDirection() <= 1) {
            zPos = Double(currentStreet.getPosition())
        } else {
            xPos = Double(currentStreet.getPosition())
            print(xPos)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {  // Required for SKShapeNode implementation
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateShapeNodePos() {
        sceneNode.position = getSCNVector()
    }
    
    func rotateNodeLeft(){
        sceneNode.runAction(SCNAction.rotateBy(x: 0, y: -.pi/2, z: 0, duration: 0.4))
        //sceneNode.run(SKAction.rotate(byAngle: .pi/2, duration: 0.4))
    }

    func rotateNodeRight(){
        sceneNode.runAction(SCNAction.rotateBy(x: 0, y: .pi/2, z: 0, duration: 0.4))
        //sceneNode.run(SKAction.rotate(byAngle: -.pi/2, duration: 0.4))
    }
    
    func setNode(node: SCNNode) {
        sceneNode = node
    }
    
    func move(xVel:Double, zVel:Double) {
        if let intersection = currentIntersection {
            if !(currentStreet.getDirection() == previousStreet.getDirection()) {
                if !isAtIntersection2(intersection: intersection) {
                    previousStreet.removeCar(car: self)
                    previousStreet = currentStreet
                    currentIntersection = nil
                }
            }
        }
        if (!intersected) {
            xPos += xVel
            zPos += zVel
        } else {
            let number = Int.random(in: 0 ... 30)
            if (number == 10) {
                rotateNodeLeft()
            }
        }
        updateShapeNodePos()
    }
    
    func getDirection() -> Int {
        return currentStreet.getDirection()
    }
    
    func getClosestCar() -> Car? {
        return closestCar
    }
    
    func setClosestCar(car: Car) {
        closestCar = car
    }
    
    func clearClosestCar() {
        closestCar = nil
    }
    
    func setPos(newX: Double, newZ: Double) {
        xPos = newX
        zPos = newZ
        updateShapeNodePos()
    }
    
    func getMovingDirectionPosition() -> Double {
        if (getDirection() == 0 || getDirection() == 1) {
            return getXPos()
        } else {
            return getZPos()
        }
    }
    
    func getNode() -> SCNNode
    {
        return sceneNode
    }
    
    func getTopSpeed() -> Double {
        return topSpeed
    }
    
    func getXPos() -> Double {
        return xPos
    }
    
    func getZPos() -> Double {
        return zPos
    }
    
    func getSCNVector() -> SCNVector3 {
        return SCNVector3(xPos, yPos, zPos)
    }
    
    func getPositionArray() -> [Double] {
        return [xPos,yPos,zPos]
    }
    
    func getStreet() -> StreetProtocol {
        return currentStreet
    }
    
    func findLight() -> TrafficLight? {
        return currentStreet.lightFinder(car: self)
    }
    
    func directionToVector() -> [Int] {
        switch currentStreet.getDirection() {
        case 0:
            return [-1,0]
        case 1:
            return [1,0]
        case 2:
            return [0,-1]
        case 3:
            return [0,1]
        default:
            return [0,0]
        }
    }
    
    func getIntersected() -> Bool {
        return intersected
    }
    
    func changeIntersected(){
        intersected = true
    }
    
//    func isAtIntersection (intersection: Intersection) -> Bool {
//        if (intersection.isCarAtIntersection(self)) {
//            currentIntersection = intersection
//            return true
//        } else {
//            return false
//        }
//    }
    
//    func turn(streetToTurnOn: StreetProtocol, intersection: Intersection) {
//        let number = Int.random(in: 0 ... 2)
//        var used = false
//        for usedIntersection in intersectionArray {
//            if (usedIntersection === intersection) {
//                used = true
//            }
//        }
//        if (number == 0 && !used) {
//            currentStreet.removeCar(car: self)
//            currentStreet = streetToTurnOn
//            streetToTurnOn.addCar(car: self)
//            intersectionArray.append(intersection)
//            fixPosOnStreet()
//        }
//    }
    
    func makeRightTurn(intersection: Intersection) {
        if completedTurnsArray[intersectionArray.count - 1] == false {
            //currentStreet.removeCar(car: self)
            let direction = currentStreet.getDirection()
            if direction == 0 {
                currentStreet = intersection.getVerticalTwoWay().getUpStreet()
            } else if (direction == 1) {
                currentStreet = intersection.getVerticalTwoWay().getDownStreet()
            } else if direction == 2 {
                currentStreet = intersection.getHorizontalTwoWay().getLeftStreet()
            } else if direction == 3 {
                currentStreet = intersection.getHorizontalTwoWay().getRightStreet()
            }
            currentStreet.addCar(car: self)
            fixPosOnStreet()
            rotateNodeRight()
            completedTurnsArray[intersectionArray.count - 1] = true
        }
    }
    
    func makeLeftTurn(intersection: Intersection) {
        let frontTurnMargin = 45.0
        let backTurnMargin = 225.0
        if !isLastTurnCompleted() {
            let oppStreet = intersection.getOppositeStreet(street: currentStreet)
            let direction = currentStreet.getDirection()
            if direction == 0 {
                if let closeCar = oppStreet.isStreetFree(startingPos: intersection.getPosition()[0] + frontTurnMargin, endingPos: intersection.getPosition()[0] - backTurnMargin) {
                    if closeCar.getLastTurn() == 2 && !closeCar.isLastTurnCompleted() {
                        leftTurner(direction: direction, intersection: intersection)
                    }
                } else {
                    leftTurner(direction: direction, intersection: intersection)
                }
            } else if (direction == 1) {
                if let closeCar = oppStreet.isStreetFree(startingPos: intersection.getPosition()[0] - frontTurnMargin, endingPos: intersection.getPosition()[0] + backTurnMargin) {
                    if closeCar.getLastTurn() == 2 && !closeCar.isLastTurnCompleted() {
                        leftTurner(direction: direction, intersection: intersection)
                    }
                } else {
                    leftTurner(direction: direction, intersection: intersection)
                }
            } else if direction == 2 {
                if let closeCar = oppStreet.isStreetFree(startingPos: intersection.getPosition()[1] + frontTurnMargin, endingPos: intersection.getPosition()[1] - backTurnMargin) {
                    if closeCar.getLastTurn() == 2 && !closeCar.isLastTurnCompleted() {
                        leftTurner(direction: direction, intersection: intersection)
                    }
                } else {
                    leftTurner(direction: direction, intersection: intersection)
                }
            } else if direction == 3 {
                if let closeCar = oppStreet.isStreetFree(startingPos: intersection.getPosition()[1] - frontTurnMargin, endingPos: intersection.getPosition()[1] + backTurnMargin) {
                    if closeCar.getLastTurn() == 2 && !closeCar.isLastTurnCompleted() {
                        leftTurner(direction: direction, intersection: intersection)
                    }
                } else {
                    leftTurner(direction: direction, intersection: intersection)
                }
            }
        }
    }
    
    func updateTurnArray() {
//        if (currentStreet.getDirection() == 0) {
//            for _ in 0...20 {
//                var number = Int.random(in: -1 ... 10)
//                if number <= 0 {
//                    number = 0
//                } else if number > 2 {
//                    number = 2
//                }
//                turnArray.append(number)
//                completedTurnsArray.append(number == 0)
//            }
//        } else {
//            for _ in 0...20 {
//                var number = Int.random(in: -3 ... 2)
//                if number <= 0 {
//                    number = 0
//                }
//                turnArray.append(number)
//                completedTurnsArray.append(number == 0)
//            }
//        }
        for _ in 0...20 {
            var number = Int.random(in: -1 ... 2)
            if number <= 0 {
                number = 0
            }
            turnArray.append(number)
            completedTurnsArray.append(number == 0)
        }
    }
    
    func getTurn(index: Int) -> Int {
        return turnArray[index]
    }
    
    func getLastTurn() -> Int {
        if (intersectionArray.count == 0) {
            return turnArray[0]
        } else {
            return turnArray[intersectionArray.count - 1]
        }
    }
    
    func isLastTurnCompleted() -> Bool {
        if (intersectionArray.count == 0) {
            return completedTurnsArray[0]
        } else {
            return completedTurnsArray[intersectionArray.count - 1]
        }
    }
    
    func addToIntersectionArray(intersection: Intersection) -> Bool {
        // returns true if this is the first time the car has approached this intersection, false otherwise
        var contains = false
        for intersect in intersectionArray {
            if intersect === intersection {
                contains = true
            }
        }
        if (!contains) {
            currentIntersection = intersection
            intersectionArray.append(intersection)
        }
        return !contains
    }
    
    func leftTurner(direction: Int, intersection: Intersection) {
        //currentStreet.removeCar(car: self)
        if (direction == 0) {
            currentStreet = intersection.getVerticalTwoWay().getDownStreet()
        } else if (direction == 1) {
            currentStreet = intersection.getVerticalTwoWay().getUpStreet()
        } else if (direction == 2) {
            currentStreet = intersection.getHorizontalTwoWay().getRightStreet()
        } else if (direction == 3) {
            currentStreet = intersection.getHorizontalTwoWay().getLeftStreet()
        }
        currentStreet.addCar(car: self)
        fixPosOnStreet()
        rotateNodeLeft()
        completedTurnsArray[intersectionArray.count - 1] = true
    }
    
    func isAtIntersection2(intersection: Intersection) -> Bool {
        if (Double(intersection.getXFrame()[0]) < getXPos() && getXPos() < Double(intersection.getXFrame()[1])) {
            if (Double(intersection.getZFrame()[0]) < getZPos() && getZPos() < Double(intersection.getZFrame()[1])) {
                return true
            }
        }
        return false
    }
}
