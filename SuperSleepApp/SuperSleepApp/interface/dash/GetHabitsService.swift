import Foundation

struct GetHabitsService {
    static func getMicroHabits(uuid: String, completion: @escaping (Result<[String: [Int]], Error>) -> Void) {
        guard let url = URL(string: "http://localhost:8000/get-micro-habits?uuid=\(uuid)") else {
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
                      let habitsDict = json["habits"] as? [String: [Int]] else {
                    completion(.failure(NSError(domain: "Invalid response", code: 0)))
                    return
                }
                completion(.success(habitsDict))
            }
        }.resume()
    }
}