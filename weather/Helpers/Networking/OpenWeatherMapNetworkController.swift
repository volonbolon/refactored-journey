import Foundation

final class OpenWeatherMapNetworkController: NetworkController {
    private func buildRequest(url: URL, input: Input) -> URLRequest {
        let location = input.location
        let unit = input.unit.rawValue
        let urlParams = [
            "q": location,
            "units": unit,
            "appid": API.key
        ]
        let url = url.appendingQueryParameters(urlParams)
        var request = URLRequest(url: url)
        request.httpMethod = HTTPVerbs.get.rawValue
        return request
    }

    func fetchCurrentWeatherData(input: Input,
                                 completionHandler: @escaping NetworkController.WeatherCompletionHandler) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather"
        guard let url = URL(string: urlString) else {
            let error = NetworkControllerError.invalidURL(urlString)
            let payload = Either<NetworkControllerError, WeatherData>.left(error)
            completionHandler(payload)
            return
        }

        let session = URLSession.shared
        let request = self.buildRequest(url: url, input: input)
        let task = session.dataTask(with: request) { (data: Data?, _: URLResponse?, error: Error?) in
            guard error == nil else {
                let networkError = NetworkControllerError.forwarded(error!)
                let payload = Either<NetworkControllerError, WeatherData>.left(networkError)
                completionHandler(payload)
                return
            }

            guard let jsonData = data else {
                let payloadError = NetworkControllerError.invalidPayload(url)
                let payload = Either<NetworkControllerError, WeatherData>.left(payloadError)
                completionHandler(payload)
                return
            }

            self.decode(jsonData: jsonData,
                        endpointURL: url,
                        temperatureUnit: input.unit,
                        completionHandler: { (result: Either<NetworkControllerError, WeatherData>) in
                            completionHandler(result)
            })
        }
        task.resume()
    }

    private func decode(jsonData: Data,
                        endpointURL: URL,
                        temperatureUnit: TemperatureUnit,
                        completionHandler: @escaping WeatherCompletionHandler) {
        let decoder = JSONDecoder()
        do {
            let weatherInfo = try decoder.decode(OpenMapWeatherData.self, from: jsonData)
            let condition = (weatherInfo.weather.first?.main ?? "?")
            let weatherData = WeatherData(temperature: weatherInfo.main.temp,
                                          condition: condition,
                                          unit: temperatureUnit)
            let payload = Either<NetworkControllerError, WeatherData>.right(weatherData)
            completionHandler(payload)
        } catch let error {
            let networkError = NetworkControllerError.forwarded(error)
            let payload = Either<NetworkControllerError, WeatherData>.left(networkError)
            completionHandler(payload)
        }
    }
}

private struct API {
    static let key = "36b65349911aab09fc58ef4056b43b66"
}
