import Foundation

struct WeatherService {
    func fetchWeather(for city: String) async throws -> WeatherData {
        let geoURL = URL(string: "https://geocoding-api.open-meteo.com/v1/search?name=\(city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city)&count=1&language=en&format=json")!

        let geoData = try await URLSession.shared.data(from: geoURL).0
        let geoResponse = try JSONDecoder().decode(GeoResponse.self, from: geoData)

        guard let firstLocation = geoResponse.results?.first else {
            throw WeatherError.locationNotFound
        }

        let forecastURLString = "https://api.open-meteo.com/v1/forecast?latitude=\(firstLocation.latitude)&longitude=\(firstLocation.longitude)&current=temperature_2m,apparent_temperature,relative_humidity_2m,weather_code,wind_speed_10m&daily=weather_code,temperature_2m_min,temperature_2m_max&timezone=auto&forecast_days=7"

        guard let forecastURL = URL(string: forecastURLString) else {
            throw WeatherError.invalidURL
        }

        let forecastData = try await URLSession.shared.data(from: forecastURL).0
        let response = try JSONDecoder().decode(WeatherResponse.self, from: forecastData)

        let dailyForecast = zip(response.daily.time, response.daily.weatherCode).enumerated().map { index, item in
            let date = item.0
            let code = item.1
            let min = Int(round(response.daily.temperature2mMin[index]))
            let max = Int(round(response.daily.temperature2mMax[index]))
            return DailyForecastItem(date: date, minTemp: min, maxTemp: max, weatherCode: code)
        }

        return WeatherData(
            locationName: firstLocation.name,
            temperature: response.current.temperature,
            feelsLike: response.current.apparentTemperature,
            humidity: response.current.relativeHumidity,
            windSpeed: response.current.windSpeed,
            weatherCode: response.current.weatherCode,
            dailyForecast: dailyForecast
        )
    }
}

struct GeoResponse: Decodable {
    let results: [GeoLocation]?
}

struct GeoLocation: Decodable {
    let name: String
    let latitude: Double
    let longitude: Double
}

enum WeatherError: Error, LocalizedError {
    case locationNotFound
    case invalidURL

    var errorDescription: String? {
        switch self {
        case .locationNotFound:
            return "No weather data was found for that city. Try another location."
        case .invalidURL:
            return "There was an issue creating the request URL."
        }
    }
}
