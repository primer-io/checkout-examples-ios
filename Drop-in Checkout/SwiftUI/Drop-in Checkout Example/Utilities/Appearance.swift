//
//  Appearance.swift
//  Drop-in Checkout Example
//
//  Created by Jack Newcombe on 07/12/2023.
//

import UIKit

final class Appearance {
    static func setup() {
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().backgroundColor = .black
        UINavigationBar.appearance().barTintColor = .black
        UINavigationBar.appearance().isTranslucent = false
        UIBarButtonItem.appearance().tintColor = .white
    }
}
