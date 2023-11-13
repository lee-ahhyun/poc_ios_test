//
//  Payload.swift
//  Runner
//
//  Created by ahhyun lee on 11/13/23.
//

import UIKit
import Flutter
import NearbyConnections
import Foundation

struct Payload: Identifiable {
    let id: PayloadID
    var type: PayloadType
    var status: Status
    let isIncoming: Bool
    let cancellationToken: CancellationToken?

    enum PayloadType {
        case bytes, stream, file
    }
    enum Status {
        case inProgress(Progress), success, failure, canceled
    }
}
