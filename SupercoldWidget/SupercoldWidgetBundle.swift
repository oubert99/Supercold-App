//
//  SupercoldWidgetBundle.swift
//  SupercoldWidget
//
//  Created by Oumar Ka on 15/03/2025.
//

import WidgetKit
import SwiftUI

@main
struct SupercoldWidgetBundle: WidgetBundle {
    var body: some Widget {
        SupercoldWidget()
        SupercoldWidgetControl()
        SupercoldWidgetLiveActivity()
    }
}
