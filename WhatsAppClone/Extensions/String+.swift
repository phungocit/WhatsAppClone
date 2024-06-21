//
//  String+.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 3/22/24.
//

import Foundation

extension String {
    var isEmptyOrWhiteSpace: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
