import UIKit
import Flutter
import NearbyConnections
import Foundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
     @Published private(set) var endpoints: [DiscoveredEndpoint] = []
     @Published private(set) var requests: [ConnectionRequest] = []
     @Published private(set) var connections: [ConnectedEndpoint] = []
     private var eventChannel: FlutterEventChannel?
     private let eventHandler = EventHandler()
     
     var connectionManager: ConnectionManager = ConnectionManager(serviceID: Config.serviceId, strategy: Strategy.star)
     var advertiser: Advertiser?
     var discoverer: Discoverer?
     var isAdvertising = Config.defaultAdvertisingState
     var isDiscovering = Config.defaultDiscoveryState
     var endpointName = Config.defaultEndpointName
   
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
      let channel = FlutterMethodChannel(name: "nportverse_nearby_method_channel", binaryMessenger: controller.binaryMessenger)
    
      channel.setMethodCallHandler({
          (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
          
          switch(call.method) {
          case "getNearbyOnOffState":
                  if let args = call.arguments as? Dictionary<String, Any> {
                                       if let mode = args["mode"] as? String {
                                           if let isEnabled = args["isEnabled"] as? Bool {
                                               if(mode == "sender"){
                                                   invalidateSending(isEnabled: !isEnabled)
                                               }else{
                                                   invalidateDiscovery(isEnabled: !isEnabled)
                                               }
                                            
                                           }
                        
                                       }
                                   }
        
              break
//          case "getUserName":
//              result(Config.defaultEndpointName)
//              break
          case "shouldAccept":
              if let args = call.arguments as? Dictionary<String, Any> {
                                   if let endpointID = args["endpointID"] as? String{
                                       self.acceptEndPoint(ep: endpointID)
                                       result(true)
                                   }
                               }
              break
          case "sendBytes":
              if let args = call.arguments as? Dictionary<String, Any> {
                  if let endpointID = args["endpointID"] as? String{
                  //    self.requestConnection(to: endpointID) //파일 받을때 요청
                         self.sendBytes(to: [endpointID]) // 파일 보낼때 요청
                      result(true)
                  }
                               }
          default :
              break
          }
          
      })
      
      func invalidateSending(isEnabled:Bool) {
          defer {
              isAdvertising = isEnabled
          }
          if isAdvertising {
              advertiser?.stopAdvertising()
          }
          if !isEnabled{
              return
          }
          connectionManager.delegate = self
          advertiser = Advertiser(connectionManager: connectionManager)
          advertiser?.delegate = self
          advertiser?.startAdvertising(using: endpointName.data(using: .utf8)!)
      }

      
      func invalidateDiscovery(isEnabled:Bool) {
         defer {
             isDiscovering = isEnabled
         }
         if isDiscovering {
             discoverer?.stopDiscovery()
         }
         if !isEnabled {
             return
         }
         
         connectionManager.delegate = self
         discoverer = Discoverer(connectionManager: connectionManager)
         discoverer?.delegate = self
         discoverer?.startDiscovery()
     }
      
      eventChannel = FlutterEventChannel(name: "nportverse_nearby_event_channel", binaryMessenger: controller.binaryMessenger)
      eventChannel?.setStreamHandler(eventHandler)
      
          GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    
    func acceptEndPoint(ep:String){
        let connectionRequest = requests.first { $0.endpointID == ep }
        connectionRequest?.shouldAccept(true)
    }

    
    
    
    func requestConnection(to endpointID: EndpointID) {
 //       discoverer?.requestConnection(to: endpointID, using: endpointName.data(using: .utf8)!)
    }

    
    func disconnect(from endpointID: EndpointID) {
        connectionManager.disconnect(from: endpointID)
    }
    

    func sendBytes(to endpointIDs: [EndpointID]) {
        let payloadID = PayloadID.unique()
        let token = connectionManager.send(Config.bytePayload.data(using: .utf8)!, to: endpointIDs, id: payloadID)
        let payload = Payload(
            id: payloadID,
            type: .bytes,
            status: .inProgress(Progress()),
            isIncoming: false,
            cancellationToken: token
        )
        for endpointID in endpointIDs {
            let a = connections.first?.endpointID
            guard let index = connections.firstIndex(where: { $0.endpointID == endpointID }) else {
                return
            }
            connections[index].payloads.insert(payload, at: 0)
        }
    }
    
    
}

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


extension AppDelegate: DiscovererDelegate {
    func discoverer(_ discoverer: Discoverer, didFind endpointID: EndpointID, with context: Data) {
        guard let endpointName = String(data: context, encoding: .utf8) else {
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
    }

    func discoverer(_ discoverer: Discoverer, didLose endpointID: EndpointID) {
        guard let index = endpoints.firstIndex(where: { $0.endpointID == endpointID }) else {
            return
        }
        endpoints.remove(at: index)
    }
}

extension AppDelegate: AdvertiserDelegate {
    func advertiser(_ advertiser: Advertiser, didReceiveConnectionRequestFrom endpointID: EndpointID, with context: Data, connectionRequestHandler: @escaping (Bool) -> Void) {
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

extension AppDelegate: ConnectionManagerDelegate {
    func connectionManager(_ connectionManager: ConnectionManager, didReceive verificationCode: String, from endpointID: EndpointID, verificationHandler: @escaping (Bool) -> Void) {

        guard let index = endpoints.firstIndex(where: { $0.endpointID == endpointID }) else {
            return
        }
        let endpoint = endpoints.remove(at: index)
        let request = ConnectionRequest(
            id: endpoint.id,
            endpointID: endpointID,
            endpointName: endpoint.endpointName,
            pin: verificationCode,
            shouldAccept: { accept in
                verificationHandler(accept)
            }
        )
        
        requests.insert(request, at: 0)
    }

    func connectionManager(_ connectionManager: ConnectionManager, didReceive data: Data, withID payloadID: PayloadID, from endpointID: EndpointID) {
        let payload = Payload(
            id: payloadID,
            type: .bytes,
            status: .success,
            isIncoming: true,
            cancellationToken: nil
        )

        let a = connections.first?.endpointID
        // 이벤트 핸들ㄹ러  추가
        guard let index = connections.firstIndex(where: { $0.endpointID == endpointID }) else {
            return
        }
        connections[index].payloads.insert(payload, at: 0)
    }

    func connectionManager(_ connectionManager: ConnectionManager, didReceive stream: InputStream, withID payloadID: PayloadID, from endpointID: EndpointID, cancellationToken token: CancellationToken) {
        let payload = Payload(
            id: payloadID,
            type: .stream,
            status: .success,
            isIncoming: true,
            cancellationToken: token
        )
      
        guard let index = connections.firstIndex(where: { $0.endpointID == endpointID }) else {
            return
        }
        connections[index].payloads.insert(payload, at: 0)
    }

    func connectionManager(_ connectionManager: ConnectionManager, didStartReceivingResourceWithID payloadID: PayloadID, from endpointID: EndpointID, at localURL: URL, withName name: String, cancellationToken token: CancellationToken) {
        let payload = Payload(
            id: payloadID,
            type: .file,
            status: .inProgress(Progress()),
            isIncoming: true,
            cancellationToken: token
        )
    
        guard let index = connections.firstIndex(where: { $0.endpointID == endpointID }) else {
            return
        }
        connections[index].payloads.insert(payload, at: 0)
    }

    func connectionManager(_ connectionManager: ConnectionManager, didReceiveTransferUpdate update: TransferUpdate, from endpointID: EndpointID, forPayload payloadID: PayloadID) {
        guard let connectionIndex = connections.firstIndex(where: { $0.endpointID == endpointID }),
              let payloadIndex = connections[connectionIndex].payloads.firstIndex(where: { $0.id == payloadID }) else {
            return
        }
      
        switch update {
        case .success:
            connections[connectionIndex].payloads[payloadIndex].status = .success
        case .canceled:
            connections[connectionIndex].payloads[payloadIndex].status = .canceled
        case .failure:
            connections[connectionIndex].payloads[payloadIndex].status = .failure
        case let .progress(progress):
            connections[connectionIndex].payloads[payloadIndex].status = .inProgress(progress)
        }
    }

    func connectionManager(_ connectionManager: ConnectionManager, didChangeTo state: ConnectionState, for endpointID: EndpointID) {
        switch (state) {
        case .connecting:
            break
        case .connected:
            guard let index = requests.firstIndex(where: { $0.endpointID == endpointID }) else {
                return
            }
            let request = requests.remove(at: index)
            let connection = ConnectedEndpoint(
                id: request.id,
                endpointID: endpointID,
                endpointName: request.endpointName
            )
            connections.insert(connection, at: 0)
        case .disconnected:
            guard let index = connections.firstIndex(where: { $0.endpointID == endpointID }) else {
                return
            }
            connections.remove(at: index)
        case .rejected:
            guard let index = requests.firstIndex(where: { $0.endpointID == endpointID }) else {
                return
            }
            requests.remove(at: index)
        }
    }
}

class EventHandler:NSObject, FlutterStreamHandler {

    var eventSink: FlutterEventSink?
    
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

struct ConnectedEndpoint: Identifiable {
    let id: UUID
    let endpointID: EndpointID
    let endpointName: String
    var payloads: [Payload] = []
}

struct DiscoveredEndpoint: Identifiable {
    let id: UUID
    let endpointID: EndpointID
    let endpointName: String
}


struct ConnectionRequest: Identifiable {
    let id: UUID
    let endpointID: EndpointID
    let endpointName: String
    let pin: String
    let shouldAccept: ((Bool) -> Void)
}

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
