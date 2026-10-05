import Foundation

struct WeatherResponse: Decodable {
    let current: CurrentWeather
    let daily: DailyWeather
    let timezone: String
}

struct CurrentWeather: Decodable {
    let temperature: Double
    let apparentTemperature: Double
    let relativeHumidity: Int
    let weatherCode: Int
    let windSpeed: Double
}

struct DailyWeather: Decodable {
    let time: [String]
    let weatherCode: [Int]
    let temperature2mMin: [Double]
    let temperature2mMax: [Double]
}

struct WeatherData {
    let locationName: String
    let temperature: Double
    let feelsLike: Double
    let humidity: Int
    let windSpeed: Double
    let weatherCode: Int
    let dailyForecast: [DailyForecastItem]

    var temperatureString: String {
        "\(Int(round(temperature)))°C"
    }

    var feelsLikeString: String {
        "\(Int(round(feelsLike)))°C"
    }

    var humidityString: String {
        "\(humidity)%"
    }

    var windString: String {
        "\(Int(round(windSpeed))) km/h"
    }

    var summary: String {
        weatherCodeTitle(for: weatherCode)
    }
}

struct DailyForecastItem {
    let date: String
    let minTemp: Int
    let maxTemp: Int
    let weatherCode: Int

    var dayLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let dateObj = formatter.date(from: date) {
            formatter.dateFormat = "EEE"
            return formatter.string(from: dateObj)
        }
        return "Today"
    }

    var symbol: String {
        symbolName(for: weatherCode)
    }
}

func weatherCodeTitle(for code: Int) -> String {
    switch code {
    case 0: return "Clear sky"
    case 1, 2, 3: return "Partly cloudy"
    case 45, 48: return "Foggy"
    case 51, 53, 55, 56, 57: return "Drizzle"
    case 61, 63, 65, 66, 67: return "Rain"
    case 71, 73, 75, 77, 79: return "Snow"
    case 80, 81, 82: return "Heavy rain"
    case 85, 86: return "Heavy snow"
    case 95: return "Thunderstorm"
    case 96, 99: return "Thunderstorm with hail"
    default: return "Weather"
    }
}

func symbolName(for code: Int) -> String {
    switch code {
    case 0: return "sun.max.fill"
    case 1, 2: return "cloud.sun.fill"
    case 3: return "cloud.fill"
    case 45, 48: return "cloud.fog.fill"
    case 51, 53, 55, 56, 57: return "cloud.drizzle.fill"
    case 61, 63, 65, 66, 67, 80, 81, 82: return "cloud.rain.fill"
    case 71, 73, 75, 77, 79, 85, 86: return "cloud.snow.fill"
    case 95, 96, 99: return "cloud.bolt.rain.fill"
    default: return "cloud.fill"
    }
}
