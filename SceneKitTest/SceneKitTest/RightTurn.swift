//
//  RightTurn.swift
//  SceneKitTest
//
//  Created by Rajat Mittal on 8/22/19.
//  Copyright © 2019 Rajat Mittal. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

class RightTurn:TurnProtocol {
    
    internal var upStreetArray = [[1.0,-3.0],[0.990525,-2.92102],[0.984613,-2.8417],[0.982275,-2.76219],[0.983516,-2.68266],[0.988334,-2.60326],[0.996718,-2.52416],[1.00865,-2.44552],[1.02411,-2.36749],[1.04307,-2.29024],[1.06548,-2.21392],[1.0913,-2.13869],[1.12048,-2.06469],[1.15295,-1.99208],[1.18867,-1.921],[1.22754,-1.85161],[1.26949,-1.78403],[1.31445,-1.71841],[1.36231,-1.65487],[1.41297,-1.59356],[1.46635,-1.53458],[1.52233,-1.47807],[1.58079,-1.42413],[1.64161,-1.37287],[1.70469,-1.32441],[1.76987,-1.27883],[1.83705,-1.23622],[1.90607,-1.19669],[1.9768,-1.1603],[2.04909,-1.12712],[2.12281,-1.09724],[2.19779,-1.07069],[2.27389,-1.04755],[2.35096,-1.02786],[2.42883,-1.01165],[2.50736,-0.998965],[2.58637,-0.989822],[2.66572,-0.984243],[2.74524,-0.982239],[2.82477,-0.983815],[2.90414,-0.988966],[2.98321,-0.997683]]
    
    internal var leftStreetArray = [[3.0,1.0],[2.92102,0.990525],[2.8417,0.984613],[2.76219,0.982275],[2.68266,0.983516],[2.60326,0.988334],[2.52416,0.996718],[2.44552,1.00865],[2.36749,1.02411],[2.29024,1.04307],[2.21392,1.06548],[2.13869,1.0913],[2.06469,1.12048],[1.99208,1.15295],[1.921,1.18867],[1.85161,1.22754],[1.78403,1.26949],[1.71841,1.31445],[1.65487,1.36231],[1.59356,1.41297],[1.53458,1.46635],[1.47807,1.52233],[1.42413,1.58079],[1.37287,1.64161],[1.32441,1.70469],[1.27883,1.76987],[1.23622,1.83705],[1.19669,1.90607],[1.1603,1.9768],[1.12712,2.04909],[1.09724,2.12281],[1.07069,2.19779],[1.04755,2.27389],[1.02786,2.35096],[1.01165,2.42883],[0.998965,2.50736],[0.989822,2.58637],[0.984243,2.66572],[0.982239,2.74524],[0.983815,2.82477],[0.988966,2.90414],[0.997683,2.98321]]
    
    internal var downStreetArray = [[-1.0,3.0],[-0.990525,2.92102],[-0.984613,2.8417],[-0.982275,2.76219],[-0.983516,2.68266],[-0.988334,2.60326],[-0.996718,2.52416],[-1.00865,2.44552],[-1.02411,2.36749],[-1.04307,2.29024],[-1.06548,2.21392],[-1.0913,2.13869],[-1.12048,2.06469],[-1.15295,1.99208],[-1.18867,1.921],[-1.22754,1.85161],[-1.26949,1.78403],[-1.31445,1.71841],[-1.36231,1.65487],[-1.41297,1.59356],[-1.46635,1.53458],[-1.52233,1.47807],[-1.58079,1.42413],[-1.64161,1.37287],[-1.70469,1.32441],[-1.76987,1.27883],[-1.83705,1.23622],[-1.90607,1.19669],[-1.9768,1.1603],[-2.04909,1.12712],[-2.12281,1.09724],[-2.19779,1.07069],[-2.27389,1.04755],[-2.35096,1.02786],[-2.42883,1.01165],[-2.50736,0.998965],[-2.58637,0.989822],[-2.66572,0.984243],[-2.74524,0.982239],[-2.82477,0.983815],[-2.90414,0.988966],[-2.98321,0.997683]]
    
    internal var rightStreetArray = [[-3.0,-1.0],[-2.92102,-0.990525],[-2.8417,-0.984613],[-2.76219,-0.982275],[-2.68266,-0.983516],[-2.60326,-0.988334],[-2.52416,-0.996718],[-2.44552,-1.00865],[-2.36749,-1.02411],[-2.29024,-1.04307],[-2.21392,-1.06548],[-2.13869,-1.0913],[-2.06469,-1.12048],[-1.99208,-1.15295],[-1.921,-1.18867],[-1.85161,-1.22754],[-1.78403,-1.26949],[-1.71841,-1.31445],[-1.65487,-1.36231],[-1.59356,-1.41297],[-1.53458,-1.46635],[-1.47807,-1.52233],[-1.42413,-1.58079],[-1.37287,-1.64161],[-1.32441,-1.70469],[-1.27883,-1.76987],[-1.23622,-1.83705],[-1.19669,-1.90607],[-1.1603,-1.9768],[-1.12712,-2.04909],[-1.09724,-2.12281],[-1.07069,-2.19779],[-1.04755,-2.27389],[-1.02786,-2.35096],[-1.01165,-2.42883],[-0.998965,-2.50736],[-0.989822,-2.58637],[-0.984243,-2.66572],[-0.982239,-2.74524],[-0.983815,-2.82477],[-0.988966,-2.90414],[-0.997683,-2.98321]]
    
    internal var mainArray:[[Double]]
    internal var pointReached = 1
    internal var car:Car
    
    init(car:Car) {
        self.car = car
        switch car.getPreviousStreet().getDirection() {
        case 0:
            mainArray = leftStreetArray
        case 1:
            mainArray = rightStreetArray
        case 2:
            mainArray = downStreetArray
        case 3:
            mainArray = upStreetArray
        default:
            mainArray = []
        }
    }
    
    func turnCar() {
        if let intersection = car.getCurrentIntersection() {
            if (pointReached < mainArray.count) {
                car.setPos(newX: mainArray[pointReached][0] + intersection.getPosition()[0], newY: mainArray[pointReached][1] + intersection.getPosition()[1])
                pointReached += 1
            }
        }
    }
}
