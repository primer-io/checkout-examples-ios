//
//  Formatters.swift
//  Co-Badged Cards Example
//
//  Created by Jack Newcombe on 06/12/2023.
//

import Foundation

class SimpleFormatter: Formatter {

    open func format(_ string: String) -> String { string }

    override func string(for obj: Any?) -> String? {
        guard let string = obj as? String else {
            return nil
        }
        return format(string)
    }
    
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        obj?.pointee = format(string) as NSString
        return true
    }
}

class EmptyFormatter: SimpleFormatter {}

class CardNumberFormatter: SimpleFormatter {
    
    override func format(_ string: String) -> String {
        var cardNumber = Array(string.filter { $0.isNumber }.prefix(19).map { $0 })
        var result: String = ""

        while !cardNumber.isEmpty {
            let chunkSize = min(cardNumber.count, 4)
            let chunk = cardNumber[0..<chunkSize]
            cardNumber.removeFirst(chunkSize)
            result += chunk
            result += cardNumber.isEmpty ? "" : " "
        }
        
        return result
    }
}
