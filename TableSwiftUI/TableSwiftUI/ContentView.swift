import SwiftUI
import MapKit

let data = [
    Item(name: "Don Pedro", neighborhood: "Southside", desc: "This restaurant is a Tex-Mex cuisine which offers all the great Tex Mex foods everyone loves.", lat: 29.3818, long: -98.5148, imageName: "rest1"),
    Item(name: "Sofia's Pizzeria.", neighborhood: "Potranco", desc: "Pizza Company which offers many varieties of Pizza and Sides.", lat:  29.4194, long: -98.7426, imageName: "rest2"),
    Item(name: "Black Bear Diner", neighborhood: "City Base", desc: "Good spot for breakfast and dinner meals", lat: 29.3421, long: -98.4389, imageName: "rest3"),
    Item(name: "Golden Wok", neighborhood: "Wurzbach", desc: "Delicious Chinese cuisine with many of the classic options", lat: 29.5336, long: -98.5860, imageName: "rest4"),
    Item(name: "Rosarios Mexican Restaurant", neighborhood: "Downtown", desc: "Mexican cuisine located on the Riverwalk downtown", lat: 29.4260, long: -98.4886, imageName: "rest5")
]

struct Item: Identifiable {
    let id = UUID()
    let name: String
    let neighborhood: String
    let desc: String
    let lat: Double
    let long: Double
    let imageName: String
}

struct ContentView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 29.4241, longitude: -98.4936), // San Antonio Coordinates
        span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.07) // Adjust zoom level (smaller delta = zoomed in)
    )
    
    @State private var selectedNeighborhood: String = "All Neighborhoods"
    
    var filteredData: [Item] {
        if selectedNeighborhood == "All Neighborhoods" {
            return data
        } else {
            return data.filter { $0.neighborhood == selectedNeighborhood }
        }
    }
    
    var neighborhoods: [String] {
        let uniqueNeighborhoods = Set(data.map { $0.neighborhood })
        return ["All Neighborhoods"] + uniqueNeighborhoods.sorted()
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Neighborhood Picker (Dropdown)
                Picker("Select Neighborhood", selection: $selectedNeighborhood) {
                    ForEach(neighborhoods, id: \.self) { neighborhood in
                        Text(neighborhood)
                    }
                }
                .pickerStyle(MenuPickerStyle()) // Dropdown style
                .padding()
                
                // List of filtered data
                List(filteredData, id: \.name) { item in
                    NavigationLink(destination: DetailView(item: item)) {
                        HStack {
                            Image(item.imageName)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .cornerRadius(10)
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.headline)
                                Text(item.neighborhood)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                
                // Map View with San Antonio region
                Map(coordinateRegion: $region, annotationItems: filteredData) { item in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: item.lat, longitude: item.long)) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                            .font(.title)
                            .overlay(
                                Text(item.name)
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                    .fixedSize(horizontal: true, vertical: false)
                                    .offset(y: 25)
                            )
                    }
                }
                .frame(height: 300)
                .padding(.bottom, -30)
            }
            // **Modified Here**: Set the navigation title and adjust font size and type
            .navigationTitle("San Antonio Restaurants") // Title of the screen
            .navigationBarTitleDisplayMode(.inline)  // Compact navigation title
            .font(.custom("Helvetica Neue", size: 44)) // **Changed Here**: Changed the font and size
            .padding(.top, 20) // Add padding on top for a little spacing from the top
        }
    }
}

struct DetailView: View {
    @State private var region: MKCoordinateRegion
    
    init(item: Item) {
        self.item = item
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: item.lat, longitude: item.long),
            span: MKCoordinateSpan(latitudeDelta: 0.20, longitudeDelta: 0.20)
        ))
    }
    
    let item: Item
    
    var body: some View {
        VStack {
            Image(item.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 200)
            Text("Neighborhood: \(item.neighborhood)")
                .font(.subheadline)
            Text("Description: \(item.desc)")
                .font(.subheadline)
                .padding(10)
            Map(coordinateRegion: $region, annotationItems: [item]) { item in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: item.lat, longitude: item.long)) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.red)
                        .font(.title)
                        .overlay(
                            Text(item.name)
                                .font(.subheadline)
                                .foregroundColor(.black)
                                .fixedSize(horizontal: true, vertical: false)
                                .offset(y: 25)
                        )
                }
            }
            .frame(height: 300)
            .padding(.bottom, -30)
        }
        .navigationTitle(item.name)
        Spacer()
    }
}

#Preview {
    ContentView()
}
