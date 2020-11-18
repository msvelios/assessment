//
//  StationInfo.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import Foundation

struct StationData: Codable {
    var trainsList: [StationTrain]

    enum CodingKeys: String, CodingKey {
        case trainsList = "objStationData"
    }
}

struct StationTrain: Codable {
    var trainCode: String
    var stationFullName: String
    var stationCode: String
    var trainDate: String
    var dueIn: Int
    var lateBy:Int
    var expArrival:String
    var expDeparture:String
    var destinationDetails:TrainMovement?

    enum CodingKeys: String, CodingKey {
        case trainCode = "Traincode"
        case stationFullName = "Stationfullname"
        case stationCode = "Stationcode"
        case trainDate = "Traindate"
        case dueIn = "Duein"
        case lateBy = "Late"
        case expArrival = "Exparrival"
        case expDeparture = "Expdepart"
    }

    init(trainCode: String, fullName: String, stationCode: String, trainDate: String, dueIn: Int,lateBy:Int,expArrival:String,expDeparture:String) {
        self.trainCode = trainCode
        self.stationFullName = fullName
        self.stationCode = stationCode
        self.trainDate = trainDate
        self.dueIn = dueIn
        self.lateBy = lateBy
        self.expArrival = expArrival
        self.expDeparture = expDeparture
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let trainCode = try values.decode(String.self, forKey: .trainCode)
        let fullName = try values.decode(String.self, forKey: .stationFullName)
        let code = try values.decode(String.self, forKey: .stationCode)
        let trainDate = try values.decode(String.self, forKey: .trainDate)
        let dueIn = try values.decode(Int.self, forKey: .dueIn)
        let late = try values.decode(Int.self, forKey: .lateBy)
        let arrival = try values.decode(String.self, forKey: .expArrival)
        let departure = try values.decode(String.self, forKey: .expDeparture)

        self.init(trainCode: trainCode, fullName: fullName, stationCode: code, trainDate: trainDate, dueIn: dueIn, lateBy: late, expArrival: arrival, expDeparture: departure)
    }
}

