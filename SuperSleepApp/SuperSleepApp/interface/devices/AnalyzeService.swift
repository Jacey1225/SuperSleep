import Foundation

struct AnalyzeService {
    static func analyzeData(uuid: String, hasDevice: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "http://localhost:8000/analyze-data?uuid=\(uuid)&has_device=\(hasDevice)"
        guard let url = URL(string: urlString) else {
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