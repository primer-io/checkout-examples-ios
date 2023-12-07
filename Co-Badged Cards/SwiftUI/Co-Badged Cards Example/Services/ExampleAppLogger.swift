//
//  ExampleLogger.swift
//  Co-Badged Cards Example
//
//  Created by Jack Newcombe on 27/11/2023.
//

import Foundation
import SwiftUI
import OSLog

let logger = ExampleAppLogger()

class ExampleAppLogger {
    
    enum Level {
        case info
        case warn
        case error
    }
    
    private let osLogger = Logger()
    
    private func log(_ message: String, level: Level) {
        let message = "[\(title)] \(message)"
        switch level {
        case .info:
            osLogger.info("\(message)")
        case .warn:
            osLogger.warning("\(message)")
        case .error:
            osLogger.error("\(message)")
        }
    }
    
    private var title: String {
        NSLocalizedString("App.Title", comment: "")
    }
    
    func info(_ message: String) {
        log(message, level: .info)
    }
    
    func warn(_ message: String) {
        log(message, level: .warn)
    }
    
    func error(_ message: String) {
        log(message, level: .error)
    }
}
