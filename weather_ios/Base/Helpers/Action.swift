import Foundation
import RxSwift
import RxCocoa

typealias CocoaAction = Action<Void, Void>

final class Action<Input, Element> {
    typealias WorkFactory = (Input) -> Observable<Element>

    let workFactory: WorkFactory

    let inputs = PublishSubject<Input>()
    let errors: Observable<ApiError>
    let elements: Observable<Element>
    let executing: Observable<Bool>
    let executionObservables: Observable<Observable<Element>>
    
    private let disposeBag = DisposeBag()
    
    init(workFactory: @escaping WorkFactory) {
        self.workFactory = workFactory

        let errorsSubject = PublishSubject<ApiError>()
        errors = errorsSubject.asObservable()

        executionObservables = inputs
            .flatMap { params -> Observable<Observable<Element>> in
                return Observable.of(workFactory(params)
                    .do(onError: {
                        guard let respError = $0 as? ApiError else { return }
                        
                        errorsSubject.onNext(respError)
                    })
                    .shareReplay(1))
            }
            .share()
        
        elements = executionObservables
            .flatMap { $0.catchError { _ in Observable.empty() } }
        
        executing = executionObservables
            .flatMap { execution -> Observable<Bool> in
                let execution = execution
                    .flatMap { _ in Observable<Bool>.empty() }
                    .catchError { _ in Observable.empty()}
                
                return Observable.concat([Observable.just(true), execution, Observable.just(false)])
            }
            .startWith(false)
            .shareReplay(1)
    }
    
    @discardableResult
    func execute(_ value: Input) -> Observable<Element> {
        defer {
            inputs.onNext(value)
        }
        
        let subject = ReplaySubject<Element>.createUnbounded()
        
        let work = executionObservables
            .map {
                $0.catchError {
                    guard let e = $0 as? ApiError else { throw ApiError.unknown }
                    
                    throw e
                }
        }
        
        let error = errors
            .map { Observable<Element>.error($0) }
        
        work.amb(error)
            .take(1)
            .flatMap { $0 }
            .subscribe(subject)
            .addDisposableTo(disposeBag)
        
        return subject.asObservable()
    }
}

