//
//  SupercoldWidgetLiveActivity.swift
//  SupercoldWidget
//
//  Created by Oumar Ka on 15/03/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct SupercoldWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct SupercoldWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SupercoldWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension SupercoldWidgetAttributes {
    fileprivate static var preview: SupercoldWidgetAttributes {
        SupercoldWidgetAttributes(name: "World")
    }
}

extension SupercoldWidgetAttributes.ContentState {
    fileprivate static var smiley: SupercoldWidgetAttributes.ContentState {
        SupercoldWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: SupercoldWidgetAttributes.ContentState {
         SupercoldWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: SupercoldWidgetAttributes.preview) {
   SupercoldWidgetLiveActivity()
} contentStates: {
    SupercoldWidgetAttributes.ContentState.smiley
    SupercoldWidgetAttributes.ContentState.starEyes
}
