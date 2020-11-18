//
//  SearchTrainInteractor.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import Foundation
import XMLParsing

class SearchTrainInteractor: PresenterToInteractorProtocol {
    var _sourceStationCode = String()
    var _destinationStationCode = String()
    var presenter: InteractorToPresenterProtocol?

    func fetchallStations() {
        if Reach().isNetworkReachable() == true {
            let urlString = "http://api.irishrail.ie/realtime/realtime.asmx/getAllStationsXML"
            let url = URL(string: urlString)
            var request = URLRequest(url: url!)
            request.httpMethod = "GET"
            request.addValue("application/xml", forHTTPHeaderField:"Content-Type")
            request.addValue("application/xml", forHTTPHeaderField: "Accept")
            
            URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
                do {
                    let xmlDecoder = XMLDecoder()
                    let station = try xmlDecoder.decode(Stations.self, from: data!)
                    self.presenter!.stationListFetched(list: station.stationsList)
                } catch {
                    print("XML Serialization error")
                }
            }).resume()
            
        } else {
            self.presenter!.showNoInterNetAvailabilityMessage()
        }
    }

    func fetchTrainsFromSource(sourceCode: String, destinationCode: String) {
        _sourceStationCode = sourceCode
        _destinationStationCode = destinationCode
       
        if Reach().isNetworkReachable() {
            let urlString = "http://api.irishrail.ie/realtime/realtime.asmx/getStationDataByCodeXML?StationCode=\(sourceCode)"
            let url = URL(string: urlString)
            var request = URLRequest(url: url!)
            request.httpMethod = "GET"
            request.addValue("application/xml", forHTTPHeaderField:"Content-Type")
            request.addValue("application/xml", forHTTPHeaderField: "Accept")
            
            URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
                do {
                    let xmlDecoder = XMLDecoder()
                    let stationData = try xmlDecoder.decode(StationData.self, from: data!)
                    let _trainsList = stationData.trainsList
                    if _trainsList.count > 0{
                        self.proceesTrainListforDestinationCheck(trainsList: _trainsList)
                    } else {
                        self.presenter!.showNoTrainAvailbilityFromSource()
                    }
                } catch {
                    print("XML Serialization error")
                }
            }).resume()
        } else {
            self.presenter!.showNoInterNetAvailabilityMessage()
        }
    }
    
    private func proceesTrainListforDestinationCheck(trainsList: [StationTrain]) {
        var _trainsList = trainsList
        let today = Date()
        let group = DispatchGroup()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let dateString = formatter.string(from: today)
        
        for index  in 0...trainsList.count-1 {
            group.enter()
            
            if Reach().isNetworkReachable() {
                let _urlString = "http://api.irishrail.ie/realtime/realtime.asmx/getTrainMovementsXML?TrainId=\(trainsList[index].trainCode)&TrainDate=\(dateString)"
                let url = URL(string: _urlString)
                var request = URLRequest(url: url!)
                request.httpMethod = "POST"
                request.addValue("application/xml", forHTTPHeaderField:"Content-Type")
                request.addValue("application/xml", forHTTPHeaderField: "Accept")
                
                URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
                    do {
                        let xmlDecoder = XMLDecoder()
                        let trainMovements = try xmlDecoder.decode(TrainMovementsData.self, from: data!)
                        let _movements = trainMovements.trainMovements
                        let sourceIndex = _movements.firstIndex(where: {$0.locationCode.caseInsensitiveCompare(self._sourceStationCode) == .orderedSame})
                        let destinationIndex = _movements.firstIndex(where: {$0.locationCode.caseInsensitiveCompare(self._destinationStationCode) == .orderedSame})
                        let desiredStationMoment = _movements.filter{$0.locationCode.caseInsensitiveCompare(self._destinationStationCode) == .orderedSame}
                        let isDestinationAvailable = desiredStationMoment.count == 1

                        if isDestinationAvailable  && sourceIndex! < destinationIndex! {
                                _trainsList[index].destinationDetails = desiredStationMoment.first
                        }
                        
                        group.leave()
                    } catch {
                        print("XML Serialization error")
                    }
                }).resume()
            } else {
                self.presenter!.showNoInterNetAvailabilityMessage()
            }
        }

        group.notify(queue: DispatchQueue.main) {
            let sourceToDestinationTrains = _trainsList.filter{$0.destinationDetails != nil}
            self.presenter!.fetchedTrainsList(trainsList: sourceToDestinationTrains)
        }
    }
}
