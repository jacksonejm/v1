import Foundation

class RIASECScoreCalculator {
    static func calculate(from responses: [RIASECQuestion: Int]) -> [String: Int] {
        return responses.reduce(into: [:]) { scores, response in
            let ratingValue = response.value
            scores[response.key.category, default: 0] += ratingValue
        }
    }
}