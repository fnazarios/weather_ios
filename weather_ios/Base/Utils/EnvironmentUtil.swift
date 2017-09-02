import Foundation

class EnviromentUtil {
    static let baseUrl: String = EnviromentUtil.get("BASE_URL") ?? "http://api.openweathermap.org/data/2.5"
    static let openWeatherMapApiKey: String = EnviromentUtil.get("OPEN_WEATHER_MAP_API_KEY") ?? "2614618552061479"
    static let baseUrlIcon: String = EnviromentUtil.get("BASE_URL_ICON") ?? "http://openweathermap.org"

    class func get<T>(_ name: String) -> T? {
        guard let enviromentSetting = Bundle.main.infoDictionary?["EnviromentSetting"] as? [String: AnyObject] else { return nil }
        guard let key = enviromentSetting[name] else { return nil }
        
        return key as? T
    }
}
