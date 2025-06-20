import Foundation

struct AddCompletionService {
    static func addCompletion(uuid: String, habit: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let encodedHabit = habit.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? habit
        let urlString = "http://localhost:8000/add-completion?uuid=\(uuid)&habit=\(encodedHabit)"
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