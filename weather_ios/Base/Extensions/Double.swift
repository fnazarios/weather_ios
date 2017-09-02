import Foundation

enum PreferredUnit {
    case celsius
    case kelvin
    case fahrenheit
}

extension Double {
    func toPreferedUnit(_ preferedUnit: PreferredUnit) -> String {
        switch preferedUnit {
        case .celsius:
            return self.toCelsius
        case .fahrenheit:
            return self.toFahrenheit
        case .kelvin:
            return String(self)
        }
    }
    
    var toFahrenheit: String {
        let fahrenheitFloat = (self - 273.15) * 9/5 + 32
        let roundedUpFahrenheitInt: Int = Int(ceilf(Float(fahrenheitFloat)))
        
        return String(roundedUpFahrenheitInt)
    }
    
    var toCelsius: String {
        let celsiusFloat = self - 273.15
        let roundedUpCelsiusInt: Int = Int(ceilf(Float(celsiusFloat)))
        
        return String(roundedUpCelsiusInt)
    }
}
