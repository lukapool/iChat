//
//  StringTool.swift
//  iChat
//
//  Created by Luka on 2017/8/22.
//  Copyright © 2017年 Luka. All rights reserved.
//

import Foundation


extension String {
    func trmmingHeadAndFootSpace() -> String {
        let newLineAndWhiteSpaces = CharacterSet.whitespacesAndNewlines
        let trimmedName = trimmingCharacters(in: newLineAndWhiteSpaces)
        return trimmedName
    }
}
