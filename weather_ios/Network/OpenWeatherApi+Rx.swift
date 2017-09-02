import Foundation
import RxSwift
import Moya

enum ApiError: Swift.Error {
    case badRequest
    case notFound
    case unknown
    case invalidJson
    
    static func from(statusCode: Int) -> ApiError {
        switch statusCode {
        case 400:
            return .badRequest
        case 404:
            return .notFound
        default:
            return .unknown
        }
    }
}

extension ObservableType where E: Response {
    
    func successfulStatusCodes() -> Observable<E> {
        return statusCodes(200...299)
    }
    
    func statusCodes(_ range: ClosedRange<Int>) -> Observable<E> {
        return flatMap { response -> Observable<E> in
            
            guard range.contains(response.statusCode) else {
                throw ApiError.from(statusCode: response.statusCode)
            }
            
            return Observable.just(response)
        }
    }
    
    func mapToDomain<T: Swift.Codable>() -> Observable<T> {
        return map { response -> T in
            do {
                let decoded = try JSONDecoder().decode(T.self, from: response.data)
                return decoded
            } catch {
                throw error
            }
        }
    }
}
