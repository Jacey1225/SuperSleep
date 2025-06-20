import Foundation

struct SleepQualityService {
    static func getSleepQuality(uuid: String, completion: @escaping (Result<Int, Error>) -> Void) {
        guard let url = URL(string: "http://localhost:8000/get-sleep-quality?uuid=\(uuid)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let percent = json["sleep_quality"] as? Int else {
                    completion(.failure(NSError(domain: "Invalid response", code: 0)))
                    return
                }
                completion(.success(percent))
            }
        }.resume()
    }
}