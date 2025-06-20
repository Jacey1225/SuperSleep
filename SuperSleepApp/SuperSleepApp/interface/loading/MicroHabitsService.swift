import Foundation

struct MicroHabitsService {
    static func fetchMicroHabits(uuid: String, hasDevice: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "http://localhost:8000/micro-habits?uuid=\(uuid)&has_device=\(hasDevice)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        URLSession.shared.dataTask(with: url) { _, _, error in
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