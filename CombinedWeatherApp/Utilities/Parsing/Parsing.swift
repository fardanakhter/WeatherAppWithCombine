import Foundation
import Combine

func decode<T: Decodable>(_ data: Data) -> AnyPublisher<T, WeatherError>{
  let jsonDecoder = JSONDecoder()
  jsonDecoder.dateDecodingStrategy = .secondsSince1970
  
  return Just(data)
    .decode(type: T.self, decoder: jsonDecoder)
    .mapError{ error in
    .parsing(description: error.localizedDescription)
    }
    .eraseToAnyPublisher()
}

