import SwiftUI
import Combine

class CurrentWeatherViewModel: ObservableObject, Identifiable{
  
  @Published var dataSource: CurrentWeatherRowViewModel?
  
  var city: String = ""
  private var disposables = Set<AnyCancellable>()
  private let weatherFetcher: WeatherFetchable
  
  init(city: String, weatherFetcher: WeatherFetchable){
    self.weatherFetcher = weatherFetcher
    self.city = city
  }
  
  func refreshes() {
    
    weatherFetcher
      .currentWeatherForecast(forCity: city)
      .map(CurrentWeatherRowViewModel.init(item:))
      .receive(on: DispatchQueue.main)
    
      .sink { [weak self] value in
        guard let self = self else { return }
        
        switch value {
        case .failure:
          self.dataSource = nil
        case .finished:
          break
        }
        
      } receiveValue: { [weak self] dataSource in
        guard let self = self else { return }
        
        self.dataSource = dataSource
      }
      
      .store(in: &disposables)
  }
  
}
