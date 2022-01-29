//
//  WidgetExtension.swift
//  WidgetExtension
//
//  Created by Seb Vidal on 19/09/2021.
//

import WidgetKit
import SwiftUI
import Firebase

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), nade: Nade.widgetPreview)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), nade: Nade.widgetPreview)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let startOfDay = Calendar.current.startOfDay(for: currentDate)
        let startOfDay5 = Calendar.current.date(byAdding: .minute, value: 5, to: startOfDay)!
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay5)!
        
        fetchData { nade in
            let entry = SimpleEntry(date: startOfDay5, nade: nade)
            let timeline = Timeline(entries: [entry], policy: .after(endOfDay))
            
            completion(timeline)
        }
    }
    
    func fetchData(completion: @escaping(Nade) -> ()) {
        guard let _ = Auth.auth().currentUser else {
            completion(Nade.empty)
            return
        }
        
        let db = Firestore.firestore()
        let ref = db.collection("featured").document("nade")
        
        ref.getDocument { snapshot, error in
            guard let document = snapshot else {
                completion(Nade.empty)
                return
            }
            
            guard let nadeRef = document.data()?["reference"] as? DocumentReference else {
                completion(Nade.empty)
                return
            }
            
            nadeRef.getDocument { nadeSnapshot, error in
                guard let nadeDocument = nadeSnapshot else {
                    completion(Nade.empty)
                    return
                }
                
                guard let nade = nadeFrom(doc: nadeDocument) else {
                    completion(Nade.empty)
                    return
                }
                
                completion(nade)
            }
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let nade: Nade
}

struct WidgetExtensionEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(spacing: 0) {
            WidgetBackground(nade: entry.nade)
            
            WidgetDetails(nade: entry.nade)
        }
        .widgetURL(URL(string: "popflash://featured/nade?id=\(entry.nade.nadeID)")!)
    }
}

private struct WidgetBackground: View {
    var nade: Nade
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                if let url = URL(string: nade.thumbnail),
                   let data = try? Data(contentsOf: url),
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width,
                               height: geo.size.height + (family == .systemLarge ? 16 : 0))
                }
                
                LinearGradient(gradient: Gradient(colors: [.black, .clear]), startPoint: .top, endPoint: .bottom)
                    .frame(width: geo.size.width, height: geo.size.height / (family == .systemLarge ? 2.5 : 2))
                    .opacity(0.5)
                
                Text("Featured")
                    .font(font())
                    .fontWeight(.semibold)
                    .foregroundStyle(.ultraThickMaterial)
                    .environment(\.colorScheme, .light)
                    .padding(.leading, family == .systemLarge ? 10 : 8)
                    .padding(family == .systemSmall ? 12 : 16)
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

private struct WidgetDetails: View {
    var nade: Nade
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        if family == .systemLarge || family == .systemExtraLarge {
            LazyVStack(alignment: .leading, spacing: 0) {
                Text(nade.map)
                    .bold()
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                
                Text(nade.name)
                    .bold()
                
                Text("\(nade.shortDescription)\n")
                    .font(.callout)
                    .lineLimit(2)
            }
            .padding(12)
            .padding(.leading, 4)
            .background {
                if let url = URL(string: nade.thumbnail),
                   let data = try? Data(contentsOf: url),
                   let uiImage = UIImage(data: data),
                   let cgImage = uiImage.cgImage,
                   let croppedImage = cgImage.cropping(to: CGRect(x: 0, y: cgImage.height - 16, width: cgImage.width, height: 100)) {
                    Image(uiImage: UIImage(cgImage: croppedImage))
                        .resizable()
                        .frame(maxHeight: .infinity)
                        .overlay(.regularMaterial)
                }
            }
        }
    }
}

@main
struct WidgetExtension: Widget {
    init() {
        FirebaseApp.configure()
        
        do {
            try Auth.auth().useUserAccessGroup("DY2GQFY855.com.sebvidal.Popflash")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    let kind: String = "WidgetExtension"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetExtensionEntryView(entry: entry)
        }
        .configurationDisplayName("Featured")
        .description("View daily featured grenade line-ups.")
    }
}

struct WidgetViewPreviews: PreviewProvider {
    static var previews: some View {
        WidgetExtensionEntryView(entry: SimpleEntry(date: .now, nade: .widgetPreview))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        WidgetExtensionEntryView(entry: SimpleEntry(date: .now, nade: .widgetPreview))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        
        WidgetExtensionEntryView(entry: SimpleEntry(date: .now, nade: .widgetPreview))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
