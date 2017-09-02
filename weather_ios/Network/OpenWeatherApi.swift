import Foundation
import Moya

enum OpenWeatherApi {
    case find(lat: Double, lon: Double, numberOfCities: Int)
    case icon(id: String)
}

extension OpenWeatherApi: TargetType {
    var baseURL: URL { return URL(string: EnviromentUtil.baseUrl)! }
    
    var path: String {
        switch self {
        case .find(_, _, _):
            return "/data/2.5/find"
        case .icon(let id):
            return "/img/w/\(id).png"
        }
    }
    
    var method: Moya.Method {
        return Moya.Method.get
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .find(let lat, let lon, let numberOfCities):
            return ["lat": lat, "lon": lon, "cnt": numberOfCities, "APPID": EnviromentUtil.openWeatherMapApiKey]
        default: return nil
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        return .request
    }
    
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
}

func endpointsClosure() -> (OpenWeatherApi) -> Endpoint<OpenWeatherApi> {
    return { (target: OpenWeatherApi) -> Endpoint<OpenWeatherApi> in
        let parameterEncoding: Moya.ParameterEncoding = (target.method == .post) ? JSONEncoding() : URLEncoding()

        return Endpoint<OpenWeatherApi>(url: url(target), sampleResponseClosure: { () -> EndpointSampleResponse in
            return EndpointSampleResponse.networkResponse(200, target.sampleData)
        }, method: target.method, parameters: target.parameters, parameterEncoding: parameterEncoding)
    }
}

func url(_ route: TargetType) -> String {
    return route.baseURL.appendingPathComponent(route.path).absoluteString
}
