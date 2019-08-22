//
//  TurnProtocol.swift
//  SceneKitTest
//
//  Created by Rajat Mittal on 8/22/19.
//  Copyright © 2019 Rajat Mittal. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

protocol TurnProtocol {
    //all these variables and methods are in both turn classes
    var upStreetArray:[[Double]] { get set }
    var leftStreetArray:[[Double]] { get set }
    var downStreetArray:[[Double]] { get set }
    var rightStreetArray:[[Double]] { get set }
    var mainArray:[[Double]] { get set }
    var pointReached: Int { get set }
    var car:Car { get set }
    
    func turnCar()
}
