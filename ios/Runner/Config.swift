//
//  Config.swift
//  Runner
//
//  Created by ahhyun lee on 11/13/23.
//

import Foundation
import NearbyConnections
import UIKit

class Config {
    static let serviceId = "com.google.location.nearby.apps.helloconnections"
    static let defaultStategy = Strategy.cluster
    static let defaultAdvertisingState = false
    static let defaultDiscoveryState = false
    static let bytePayload = "hello world"

#if os(iOS) || os(watchOS) || os(tvOS)
    static let defaultEndpointName = UIDevice.current.name
#elseif os(macOS)
    static let defaultEndpointName = Host.current().localizedName ?? "Unknown macOS Device"
#else
    static let defaultEndpointName = "Unknown Device"
#endif
}
