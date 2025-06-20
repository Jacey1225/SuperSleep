import Foundation

struct GroupService {
    static func getGroupId(uuid: String, completion: @escaping (Result<String?, Error>) -> Void) {
        guard let url = URL(string: "http://localhost:8000/get-group-id?uuid=\(uuid)") else {
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
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    completion(.failure(NSError(domain: "Invalid response", code: 0)))
                    return
                }
                let groupId = json["group_id"] as? String
                completion(.success(groupId))
            }
        }.resume()
    }

    static func getTopFriends(groupId: String, completion: @escaping (Result<[(String, CGFloat)], Error>) -> Void) {
        guard let url = URL(string: "http://localhost:8000/top-friends?group_id=\(groupId)") else {
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
                      let leaderboard = json["leaderboard"] as? [[Any]] else {
                    completion(.failure(NSError(domain: "Invalid response", code: 0)))
                    return
                }
                let friends = leaderboard.compactMap { entry -> (String, CGFloat)? in
                    if entry.count == 2, let name = entry[0] as? String, let percent = entry[1] as? NSNumber {
                        return (name, CGFloat(truncating: percent))
                    }
                    return nil
                }
                completion(.success(friends))
            }
        }.resume()
    }

    static func getAllFriends(groupId: String, completion: @escaping (Result<[(String, CGFloat)], Error>) -> Void) {
        guard let url = URL(string: "http://localhost:8000/all-friends?group_id=\(groupId)") else {
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
                      let friends = json["friends"] as? [[Any]] else {
                    completion(.failure(NSError(domain: "Invalid response", code: 0)))
                    return
                }
                let allFriends = friends.compactMap { entry -> (String, CGFloat)? in
                    if entry.count == 2, let name = entry[0] as? String, let percent = entry[1] as? NSNumber {
                        return (name, CGFloat(truncating: percent))
                    }
                    return nil
                }
                completion(.success(allFriends))
            }
        }.resume()
    }

    static func createGroup(uuid: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "http://localhost:8000/create-group?uuid=\(uuid)") else {
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

    static func joinGroup(uuid: String, groupId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "http://localhost:8000/join-group?uuid=\(uuid)&group_id=\(groupId)") else {
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

    static func inviteToGroup(uuid: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "http://your-api-url/invite-to-group?uuid=\(uuid)") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let groupId = json["group_id"] as? String {
                    completion(.success(groupId))
                } else if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let errorMsg = json["error"] as? String {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMsg])))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unexpected response"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    static func leaveGroup(uuid: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "http://localhost:8000/leave-group?uuid=\(uuid)") else {
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