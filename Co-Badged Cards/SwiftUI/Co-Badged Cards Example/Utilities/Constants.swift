//
//  Constants.swift
//  Co-Badged Cards Example
//
//  Created by Jack Newcombe on 23/02/2024.
//

import Foundation

struct ErrorMessages {
    private init() {}

    static let sdkStart = "There was an error starting the SDK - check your configuration."

    static func clientTokenFetch(clientTokenUrl: String) -> String {
"""
Could not fetch a client token from:
POST \(clientTokenUrl)
Make sure the server is running and that your network connection is working.
"""
    }

}
