//
//  Petition.swift
//  Project 9, White House petitions with GCD option
//
//  Created by Igor Polousov on 03.08.2021.
//

import Foundation

struct Petition: Codable {
    var title: String
    var body: String
    var signatureCount: Int
}
