//
//  AdvertiserDelegate.swift
//  Runner
//
//  Created by ahhyun lee on 11/13/23.
//

import UIKit
import Flutter
import NearbyConnections
import Foundation


extension AppDelegate: AdvertiserDelegate {
    func advertiser(_ advertiser: Advertiser, didReceiveConnectionRequestFrom endpointID: EndpointID, with context: Data, connectionRequestHandler: @escaping (Bool) -> Void) {
        print("8")
        print("endpoints===>\(endpoints)")
        guard let endpointName = String(data: context, encoding: .utf8) else {
            return
        }
        let endpoint = DiscoveredEndpoint(
            id: UUID(),
            endpointID: endpointID,
            endpointName: endpointName
        )
        endpoints.insert(endpoint, at: 0)
        let endpointInfo: [String: Any?] = ["id": UUID().uuidString,"endpointID": endpointID,"endpointName":endpointName]
    
        eventHandler.handleEndpoint(endpointInfo)
        connectionRequestHandler(true)
    }
}
