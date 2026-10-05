import SwiftUI

@main
struct WeatherMasterPrototypeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: WeatherViewModel())
        }
    }
}
