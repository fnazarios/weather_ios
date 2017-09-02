import UIKit
import RxSwift
import RxCocoa
import RxNuke
import Nuke

class CityTableViewCell: UITableViewCell {
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var conditionIconImage: UIImageView!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var minTemperatureLabel: UILabel!
    @IBOutlet weak var maxTemperatureLabel: UILabel!
    
    private let viewModel: CityCellViewModelType = CityCellViewModel()
    private let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bindViewModel()
    }
    
    func configure(withCity city: City, preferredUnit: PreferredUnit) {
        viewModel.inputs.configure(with: city, preferredUnit: preferredUnit)
    }
    
    private func bindViewModel() {
        viewModel.outputs.cityName
            .bind(to: cityNameLabel.rx.text)
            .addDisposableTo(disposeBag)
        
        viewModel.outputs.conditions
            .bind(to: conditionLabel.rx.text)
            .addDisposableTo(disposeBag)
        
        viewModel.outputs.temperature
            .bind(to: temperatureLabel.rx.text)
            .addDisposableTo(disposeBag)
        
        viewModel.outputs.min
            .bind(to: minTemperatureLabel.rx.text)
            .addDisposableTo(disposeBag)
        
        viewModel.outputs.max
            .bind(to: maxTemperatureLabel.rx.text)
            .addDisposableTo(disposeBag)
        
        viewModel.outputs.conditionsIcon
            .flatMap { Nuke.Manager.shared.loadImage(with: $0) }
            .bind(to: conditionIconImage.rx.image)
            .addDisposableTo(disposeBag)
    }
}
