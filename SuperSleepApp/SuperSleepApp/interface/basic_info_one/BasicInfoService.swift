import Foundation

struct BasicInfoService {
    static func sendBasicInfo(
        uuid: String,
        username: String,
        age: Int,
        gender: String,
        weight: Int,
        height: Double,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let url = URL(string:
            "http://localhost:8000/basic-info?uuid=\(uuid)&username=\(username)&age=\(age)&gender=\(gender)&weight=\(weight)&height=\(height)"
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