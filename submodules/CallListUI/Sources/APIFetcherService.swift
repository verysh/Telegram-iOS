//
//  APIFetcherService.swift
//  Telegram
//
//  Created by Bogdan Nikolaev on 02.08.2022.
//

import Foundation
import SwiftSignalKit

class APIFetcherService {

    static var dataTask: URLSessionDataTask?
    static let defaultSession = URLSession(configuration: .default)

    static func getCurrentDate() -> Signal<Int32, NoError> {
        return Signal { subscriber in
            dataTask?.cancel()

            if let urlComponents = URLComponents(string: "http://worldtimeapi.org/api/timezone/Europe/Moscow") {
                guard let url = urlComponents.url else {
                    return EmptyDisposable
                }
                dataTask = defaultSession.dataTask(with: url) { data, response, error in
                    defer {
                        dataTask = nil
                    }

                    if let data = data,
                       let response = response as? HTTPURLResponse,
                       response.statusCode == 200 {
                        let responseDictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        DispatchQueue.main.async {
                            guard let unixtime = responseDictionary?["unixtime"] as? Int32 else {
                                return
                            }
                            subscriber.putNext(unixtime)
                        }
                    }
                }
            }
            dataTask?.resume()
            return EmptyDisposable
        }
    }
}
