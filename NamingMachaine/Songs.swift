//
//  Songs.swift
//  Replace with your project name. 
//
//  Created by iJSON Model Generator on 2021/06/29.
//  Copyright © 2021 Replace with your organization name. All rights reserved.
//

import Foundation

struct Songs: Decodable {
    var data: [String] = []

    enum CodingKeys: String, CodingKey {
        case data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode([String].self, forKey: .data)
    }
    
    static func toOption(From data: Data) -> Songs? {
        return try? JSONDecoder().decode(Songs.self, from: data)
    }
}
