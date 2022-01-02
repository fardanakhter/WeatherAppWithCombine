import SwiftUI
import Combine
import MapKit


class WeeklyWeatherViewModel: ObservableObject, Identifiable{
  
  @Published var city: String = ""
  @Published var dataSource: [DailyWeatherRowViewModel] = []
  
  private var disposables = Set<AnyCancellable>()
  
  private let weatherFetcher: WeatherFetchable
  
  init(weatherFetcher: WeatherFetchable, scheduler: DispatchQueue = DispatchQueue(label: "WeatherViewModel")){
    self.weatherFetcher = weatherFetcher
    $city
      .dropFirst(1)
      .debounce(for: 0.5, scheduler: scheduler)
      .sink(receiveValue: fetchWeather(forCity:))
      .store(in: &disposables)
  }
  
  func fetchWeather(forCity city: String) {
    
    weatherFetcher.weeklyWeatherForecast(forCity: city)
      
      .map{
        $0.list.map(DailyWeatherRowViewModel.init(item:))
      }
      .map(Array.removeDuplicates)
    
      .receive(on: DispatchQueue.main)
    
      .sink { [weak self] value in
        guard let self = self else { return }
        
        switch value {
        case .failure:
          self.dataSource = []
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

extension WeeklyWeatherViewModel {
  
  var currentWeatherView: some View {
    return WeeklyWeatherBuilder.makeCurrentWeatherView(
      withCity: city,
      weatherFetcher: weatherFetcher
    )
  }
}
