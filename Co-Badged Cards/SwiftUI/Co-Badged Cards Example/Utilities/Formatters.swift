//
//  Formatters.swift
//  Co-Badged Cards Example
//
//  Created by Jack Newcombe on 06/12/2023.
//

import Foundation
import PrimerSDK

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
        let cardNumber = String(string.filter { $0.isNumber }.prefix(19).map { $0 })

        let cardNetwork = CardNetwork(cardNumber: string)
        
        if [.amex, .diners].contains(cardNetwork) {
            return split(cardNumber, at: [4, 10]).joined(separator: " ")
        } else {
            return split(cardNumber, at: [4, 8, 12, 16]).joined(separator: " ")
        }
    }
    
    func split(_ string: String, at indices: [Int]) -> [String] {
        var string = string
        var lastIndex = 0
        var result = indices.reduce(into: [String]()) { strings, index in
            let size = index - lastIndex
            if string.count >= size {
                strings.append(String(string.prefix(size)))
                string.removeFirst(size)
                lastIndex = index
            }
        }
        if !string.isEmpty {
            result.append(string)
        }
        return result
    }
}
