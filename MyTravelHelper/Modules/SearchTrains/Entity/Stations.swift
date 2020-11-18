//
//  Stations.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import Foundation

struct Stations: Codable {
    var stationsList: [Station]

    enum CodingKeys: String, CodingKey {
        case stationsList = "objStation"
    }
}

struct Station: Codable {
    var stationDesc: String
    var stationLatitude: Double
    var stationLongitude: Double
    var stationCode: String
    var stationId: Int

    enum CodingKeys: String, CodingKey {
        case stationDesc = "StationDesc"
        case stationLatitude = "StationLatitude"
        case stationLongitude = "StationLongitude"
        case stationCode = "StationCode"
        case stationId = "StationId"
    }

    init(desc: String, latitude: Double, longitude: Double, code: String, stationId: Int) {
        self.stationDesc = desc
        self.stationLatitude = latitude
        self.stationLongitude = longitude
        self.stationCode = code
        self.stationId = stationId
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let desc = try values.decode(String.self, forKey: .stationDesc)
        let lat = try values.decode(Double.self, forKey: .stationLatitude)
        let long = try values.decode(Double.self, forKey: .stationLongitude)
        let code = try values.decode(String.self, forKey: .stationCode)
        let stationId = try values.decode(Int.self, forKey: .stationId)

        self.init(desc: desc, latitude: lat, longitude: long, code: code, stationId: stationId)
    }
}

