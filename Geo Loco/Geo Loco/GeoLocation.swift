//
//  GeoLocation.swift
//  Geo Loco
//
//  Created by Kedrick Karasek on 12/7/23.
//

import Foundation
import UIKit
import MapKit

struct GeoLocation : Codable{
    let city : String
    let growthFrom2000To2013 : String
    let latitude : Float
    let longitude : Float
    let population : String
    let rank : String
    let state : String
    
    enum CodingKeys : String, CodingKey {
        case city
        case growthFrom2000To2013 = "growth_from_2000_to_2013"
        case latitude
        case longitude
        case population
        case rank
        case state
    }
}
