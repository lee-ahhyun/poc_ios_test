//
//  DiscovererDelegate.swift
//  Runner
//
//  Created by ahhyun lee on 11/13/23.
//

import UIKit
import Flutter
import NearbyConnections
import Foundation


extension AppDelegate: DiscovererDelegate {
    func discoverer(_ discoverer: Discoverer, didFind endpointID: EndpointID, with context: Data) {
        print("6")
        guard let endpointName = String(data: context, encoding: .utf8) else {
            print("6-1")
            return
        }
        let endpoint = DiscoveredEndpoint(
            id: UUID(),
            endpointID: endpointID,
            endpointName: endpointName
        )
        let endpointInfo: [String: Any?] = ["id": UUID().uuidString,"endpointID": endpointID,"endpointName":endpointName]
        eventHandler.handleEndpoint(endpointInfo)
        endpoints.insert(endpoint, at: 0)
        print("6-2")
    }

    func discoverer(_ discoverer: Discoverer, didLose endpointID: EndpointID) {
        print("7")
        guard let index = endpoints.firstIndex(where: { $0.endpointID == endpointID }) else {
            return
        }
        endpoints.remove(at: index)
    }
}
