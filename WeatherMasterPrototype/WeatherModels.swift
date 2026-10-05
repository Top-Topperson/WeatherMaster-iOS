import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: WeatherViewModel
    @State private var cityText = "London"

    init(viewModel: WeatherViewModel = .init()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.blue.opacity(0.9), Color.indigo.opacity(0.7), Color.black.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    HStack {
                        TextField("City", text: $cityText)
                            .textFieldStyle(.roundedBorder)
                            .foregroundStyle(.black)
                        Button("Update") {
                            Task {
                                await viewModel.fetchWeather(for: cityText)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.horizontal)

                    if viewModel.isLoading {
                        ProgressView("Loading weather...")
                            .tint(.white)
                            .padding()
                    } else if let weather = viewModel.currentWeather {
                        ScrollView {
                            VStack(spacing: 20) {
                                VStack(spacing: 8) {
                                    Text(weather.locationName)
                                        .font(.largeTitle.bold())
                                        .foregroundStyle(.white)

                                    Text(weather.summary)
                                        .font(.title2)
                                        .foregroundStyle(.white.opacity(0.9))

                                    Text("\(weather.temperatureString)")
                                        .font(.system(size: 64, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)

                                    Text("Feels like \(weather.feelsLikeString)")
                                        .font(.headline)
                                        .foregroundStyle(.white.opacity(0.9))
                                }
                                .padding(.top, 12)

                                HStack(spacing: 16) {
                                    WeatherMetricCard(title: "Humidity", value: weather.humidityString)
                                    WeatherMetricCard(title: "Wind", value: weather.windString)
                                }
                                .padding(.horizontal)

                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Next 7 days")
                                        .font(.title3.bold())
                                        .foregroundStyle(.white)

                                    ForEach(weather.dailyForecast.prefix(7), id: \ .date) { item in
                                        HStack {
                                            Text(item.dayLabel)
                                                .frame(width: 80, alignment: .leading)
                                                .foregroundStyle(.white)

                                            Image(systemName: item.symbol)
                                                .frame(width: 30)
                                                .foregroundStyle(.white)

                                            Spacer()

                                            Text("\(item.minTemp)°")
                                                .foregroundStyle(.white.opacity(0.8))
                                            Text("\(item.maxTemp)°")
                                                .fontWeight(.semibold)
                                                .foregroundStyle(.white)
                                        }
                                        .padding(.vertical, 6)
                                    }
                                }
                                .padding()
                                .background(Color.white.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .padding(.horizontal)
                            }
                        }
                    } else if let errorMessage = viewModel.errorMessage {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 42))
                                .foregroundStyle(.yellow)
                            Text(errorMessage)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.white)
                            Button("Retry") {
                                Task {
                                    await viewModel.fetchWeather(for: cityText)
                                }
                            }
                        }
                        .padding()
                    }

                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("WeatherMaster")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await viewModel.fetchWeather(for: cityText)
        }
    }
}

struct WeatherMetricCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.75))
            Text(value)
                .font(.headline)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    ContentView()
}
