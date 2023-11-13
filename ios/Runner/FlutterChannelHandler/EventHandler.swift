//
//  StreamHandler.swift
//  Runner
//
//  Created by ahhyun lee on 11/13/23.
//

import Foundation
import UIKit
import Flutter
import NearbyConnections
import Foundation

class EventHandler:NSObject, FlutterStreamHandler {

    var eventSink: FlutterEventSink?
//      let userInfo: [String: Any?] = ["userAgent": userAgent,"appVersion": appVer,]
    // links will be added to this queue until the sink is ready to process them
    var queuedLinks = [String: Any?]()

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        queuedLinks.forEach({ events($0) })
        queuedLinks.removeAll()
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }

    func handleEndpoint(_ endpoint: [String: Any?]) -> Bool {
        guard let eventSink = eventSink else {
          //  queuedLinks.append(endpoint)
            return false
        }
        eventSink(endpoint)
        return true
    }
}
