import Foundation

struct AdditionalInfoService {
    static func sendAdditionalInfo(
        uuid: String,
        sleepDuration: String,
        activity: String,
        stress: Int,
        disorders: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let url = URL(string:
            "http://localhost:8000/additional-info?uuid=\(uuid)&sleep_duration=\(sleepDuration)&activity=\(activity)&stress=\(stress)&disorders=\(disorders)"
        ) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { _, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }.resume()
    }
}