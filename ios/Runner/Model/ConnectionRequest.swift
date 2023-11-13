//
//  ConnectionRequest.swift
//  Runner
//
//  Created by ahhyun lee on 11/13/23.
//

import UIKit
import Flutter
import NearbyConnections
import Foundation

struct ConnectionRequest: Identifiable {
    let id: UUID
    let endpointID: EndpointID
    let endpointName: String
    let pin: String
    let shouldAccept: ((Bool) -> Void)
}
