//
//  Intersection.swift
//  trafficSense
//
//  Created by Rajat Mittal on 6/29/19.
//  Copyright © 2019 Yousef Ahmed. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class Intersection {
    
    // an intersection is created every time two TwoWay intersect
    // each intersection automatically creates 4 traffic lights, which are added to the screen and completely functional
    // each of the 4 traffic lights control one of the 4 directions at the intersection
    
    private var xCenter:Double
    private var yCenter:Double
    private var horizontalTwoWay:TwoWayHorizontal
    private var verticalTwoWay:TwoWayVertical
    private var width = 1.0
    private var height = 1.0
    private var extra = 2.0
    private var lightLeft:TrafficLight
    private var lightRight:TrafficLight
    private var lightDown:TrafficLight
    private var lightUp:TrafficLight
    private var allFourLights:[TrafficLight] = []
    private var lightDistance = 2.0 // just used for placing lights graphically, does not have any logical effect in the code
    
    init (horizontal: TwoWayHorizontal, vertical: TwoWayVertical) {
        xCenter = vertical.getMidline()
        yCenter = horizontal.getMidline()
        horizontalTwoWay = horizontal
        verticalTwoWay = vertical
        lightLeft = TrafficLight(x: xCenter - width/2 - lightDistance, y: yCenter + height/2 + lightDistance, location:  horizontalTwoWay.getLeftStreet())
        lightDown = TrafficLight(x: xCenter - width/2 - lightDistance, y: yCenter - height/2 - lightDistance, location: verticalTwoWay.getDownStreet())
        lightRight = TrafficLight(x: xCenter + width/2 + lightDistance, y: yCenter - height/2 - lightDistance, location: horizontalTwoWay.getRightStreet())
        lightUp = TrafficLight(x: xCenter + width/2 + lightDistance, y: yCenter + height/2 + lightDistance, location: verticalTwoWay.getUpStreet())
        allFourLights.append(lightLeft)
        allFourLights.append(lightRight)
        allFourLights.append(lightDown)
        allFourLights.append(lightUp)
        lightLeft.setIntersection(intersection: self)
        lightRight.setIntersection(intersection: self)
        lightDown.setIntersection(intersection: self)
        lightUp.setIntersection(intersection: self)
    }
    
    func getAllLights() -> [TrafficLight] {
        return allFourLights
    }
    
    func getHorizontalTwoWay() -> TwoWayHorizontal {
        return horizontalTwoWay
    }
    
    func getVerticalTwoWay() -> TwoWayVertical {
        return verticalTwoWay
    }
    
    func getWidth() -> Double {
        return width
    }
    
    func getHeight() -> Double {
        return height
    }
    
    func getPosition() -> [Double] {
        return [xCenter, yCenter]
    }
    
    func isCarAtIntersection(_ car: Car) -> Bool {
        
        let turningMargin = 0.2
        
        // this identifies if a car is at the intersection, first by checking if the car is at a street on the intersection before continuing (that might be unneccesary later but its good practice for now)
        
        // if the car within 3 units of the center of the intersection, the car given the option to turn after this method is called
        
        switch car.getDirection() {
        case 0:
            if (car.getStreet() as! LeftStreet === horizontalTwoWay.getLeftStreet()) {
                return (car.getXPos() - xCenter < turningMargin && car.getXPos() - xCenter > -turningMargin)
            }
        case 1:
            if car.getStreet() as! RightStreet === horizontalTwoWay.getRightStreet() {
                return (car.getXPos() - xCenter < turningMargin && car.getXPos() - xCenter > -turningMargin)
            }
        case 2:
            if car.getStreet() as! DownStreet === verticalTwoWay.getDownStreet() {
                return (car.getYPos() - yCenter < turningMargin && car.getYPos() - yCenter > -turningMargin)
            }
        case 3:
            if car.getStreet() as! UpStreet === verticalTwoWay.getUpStreet() {
                return (car.getYPos() - yCenter < turningMargin && car.getYPos() - yCenter > -turningMargin)
            }
        default:
            return false // does nothing on purpose
        }
        return false
    }
    
    func getOppositeStreet(street: StreetProtocol) -> StreetProtocol {
        if street.getDirection() == 0 {
            return horizontalTwoWay.getRightStreet()
        } else if street.getDirection() == 1 {
            return horizontalTwoWay.getLeftStreet()
        } else if street.getDirection() == 2 {
            return verticalTwoWay.getUpStreet()
        } else {
            return verticalTwoWay.getDownStreet()
        }
    }
    
    func getXFrame() -> [Double] {
        return [xCenter - width - extra, xCenter + width + extra]
    }
    
    func getYFrame() -> [Double] {
        return [yCenter - height - extra, yCenter + height + extra]
    }
    
}
