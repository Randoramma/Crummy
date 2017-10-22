//
//  StringExtension.swift
//  Crummy
//
//  Created by Josh Nagel on 4/20/15.
//  Copyright (c) 2015 CF. All rights reserved.
//

import Foundation

extension String {
    //TODO: Redo this.. looks weird like garbage.
    func validForUsername() -> Bool {
        let regex: NSRegularExpression?
        let elements = characters.count
        let range = NSMakeRange(0,elements)
        do {
            regex = try NSRegularExpression(pattern: "[^.-@0-9a-zA-Z\n_'\'-]", options: .caseInsensitive)
            if let matches = regex?.numberOfMatches(in: self,
                                                    options:NSRegularExpression.MatchingOptions.reportCompletion,
                                                    range: range) {
                if matches > 0 {
                    return false
                }
                return true
            }
        } catch {
            assertionFailure();
            return false
        }
        return false
    }
}
