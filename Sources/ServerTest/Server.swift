//
//  Server.swift
//  ServerTestPackageDescription
//
//  Created by Rhys Morgan on 09/11/2017.
//

// Based on [this](https://github.com/hoffmanjon/MasteringSwift/tree/master/Networking/echoServerSingleThread)

import Foundation
import Socket

class Server {
	
	let bufferSize = 12
	let port: Int
	var listenSocket: Socket? = nil
	var connected = [Int32: Socket]()
	var acceptNewConnection = true
	
	init(port: Int) {
		self.port = port
	}
	
	deinit {
		for socket in connected.values {
			socket.close()
		}
		listenSocket?.close()
	}
	
	func start() throws {
		let socket = try Socket.create()
		
		listenSocket = socket
		try socket.listen(on: port)
		print("Listening port: \(socket.listeningPort)")
		repeat {
			let connectedSocket = try socket.acceptClientConnection()
			print("Connection from: \(connectedSocket.remoteHostname)")
			newConnection(socket: connectedSocket)
		} while acceptNewConnection
	}
	
	func newConnection(socket: Socket) {
		connected[socket.socketfd] = socket
		defer {
			socket.close()
			connected.removeValue(forKey: socket.socketfd)
		}
	
		var dataRead = Data(capacity: bufferSize)
		repeat {
			do {
				let bytes = try socket.read(into: &dataRead)
				if bytes > 0 {
					if let readStr = String(data: dataRead, encoding: .utf8) {
						print("Received: \(readStr)")
						let reversedString = String(readStr.reversed())
						print(reversedString)
						
						try socket.write(from: reversedString)
						
						dataRead.count = 0
					}
				}
			} catch let error {
				print("error: \(error)")
			}
		} while true
	}
}
