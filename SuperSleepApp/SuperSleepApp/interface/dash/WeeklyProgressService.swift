import Foundation

struct WeeklyProgressService {
    static func getWeeklyProgress(uuid: String, completion: @escaping (Result<[(String, CGFloat)], Error>) -> Void) {
        guard let url = URL(string: "http://localhost:8000/weekly-progress?uuid=\(uuid)") else {
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
                      let weekly = json["weekly_progress"] as? [[Any]],
                      !weekly.isEmpty else {
                    completion(.failure(NSError(domain: "Invalid response", code: 0)))
                    return
                }
                let result: [(String, CGFloat)] = weekly.compactMap {
                    if let day = $0[0] as? String, let percent = $0[1] as? NSNumber {
                        return (day, CGFloat(truncating: percent))
                    }
                    return nil
                }
                completion(.success(result))
            }
        }.resume()
    }
}