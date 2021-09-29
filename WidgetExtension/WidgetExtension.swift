//
//  WidgetExtension.swift
//  WidgetExtension
//
//  Created by Seb Vidal on 19/09/2021.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        
        SimpleEntry(date: Date())
        
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        
        let entry = SimpleEntry(date: Date())
        completion(entry)
        
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {

        let currentDate = Date()
        let startOfDay = Calendar.current.startOfDay(for: currentDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let entry = SimpleEntry(date: startOfDay)
        let timeline = Timeline(entries: [entry], policy: .after(endOfDay))
        completion(timeline)
        
    }
    
}

struct SimpleEntry: TimelineEntry {
    
    let date: Date
}

struct WidgetExtensionEntryView : View {
    
    var entry: Provider.Entry

    var body: some View {
        
        ZStack(alignment: .topLeading) {
            
            WidgetBackground()
            
            WidgetDetails()
            
        }
        
    }
    
}

private struct WidgetBackground: View {
    
    var body: some View {
        
        GeometryReader { geo in
            
            ZStack(alignment: .top) {
                
                Image("dust2_background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.height)
                
                LinearGradient(gradient: Gradient(colors: [.black, .black, .clear]), startPoint: .top, endPoint: .bottom)
                    .frame(width: geo.size.width, height: geo.size.height / 3)
                    .opacity(0.25)
                
            }
            
        }
        
    }
    
}

private struct WidgetDetails: View {
    
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Text("Featured")
                .font(font())
                .fontWeight(.semibold)
                .foregroundStyle(.ultraThickMaterial)
                .environment(\.colorScheme, .light)
                .padding(.leading, 8)
                .padding()
            
            Spacer()
            
            if family == .systemLarge || family == .systemExtraLarge {
                
                LazyVStack(alignment: .leading, spacing: 0) {
                    
                    Text("Dust II")
                        .bold()
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    
                    Text("XBox Smoke")
                        .bold()
                        .padding(.top, -2)
                    
                    Text("Smoke Xbox from T Spawn.\n")
                        .font(.callout)
                        .lineLimit(2)
                    
                }
                .padding(12)
                .padding(.leading, 4)
                .background(family == .systemLarge ? .regularMaterial : .bar)
                
            }
            
        }
        
    }
    
    func font() -> Font {
        
        switch family {
            
        case .systemExtraLarge:
            return .largeTitle
            
        case .systemLarge:
            return .largeTitle
            
        case .systemMedium:
            return .title2
            
        case .systemSmall:
            return .title3
            
        @unknown default:
            return .title
            
        }
        
    }
    
}

@main
struct WidgetExtension: Widget {
    
//    init() {
//
//        FirebaseApp.configure()
//
//    }
    
    let kind: String = "WidgetExtension"

    var body: some WidgetConfiguration {
        
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            
            WidgetExtensionEntryView(entry: entry)
            
        }
        .configurationDisplayName("Featured")
        .description("View daily featured grenade line-ups.")
    }
    
}

struct WidgetExtension_Previews: PreviewProvider {
    
    static var previews: some View {
        
        WidgetExtensionEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        WidgetExtensionEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        
        WidgetExtensionEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
        
    }
    
}
