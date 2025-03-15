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
        // Our custom yearly grid widgets
        YearlyGridWidget()
        AppIconYearlyGridWidget()
    }
}
