
import Foundation

enum NetworkError: Error {
    case badURL
    case noData
    case permissionDenied
    case unauthorized
    case decodingError
}

class HTTPClient {
    static func signInProc(
        ip: String,
        port: Int,
        id: String,
        pw: String,
        completion: @escaping (Result<UUID, NetworkError>) -> Void) {
        guard let url = URL(string:"http://" + ip + ":" + String(port) + "/api/auth/signin") else {
            return completion(.failure(.badURL))
        }
        let sendData = try! JSONSerialization.data(withJSONObject: ["userId" : id, "userPw" : pw], options: [])
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = sendData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let response = response as? HTTPURLResponse else {
                return completion(.failure(.noData))
            }
            if response.statusCode == 401 {
                return completion(.failure(.unauthorized))
            }
            if response.statusCode == 403 {
                return completion(.failure(.permissionDenied))
            }
            guard let data = data, error == nil else {
                return completion(.failure(.noData))
            }
            guard let rawuuid = try? JSONDecoder().decode(String.self, from: data) else {
                return completion(.failure(.decodingError))
            }
            guard let uuid = UUID(uuidString: rawuuid) else {
                return completion(.failure(.decodingError))
            }
            completion(.success(uuid))
        }.resume()
    }
    
    static func signOutProc(
        ip: String,
        port: Int,
        session: UUID,
        completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        guard let url = URL(string:"http://" + ip + ":" + String(port) + "/api/auth/signout") else {
            return completion(.failure(.badURL))
        }
            let sendData = try! JSONSerialization.data(withJSONObject: ["sessionKey" : session.uuidString], options: [])
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = sendData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let response = response as? HTTPURLResponse else {
                return completion(.failure(.noData))
            }
            if response.statusCode == 401 {
                return completion(.failure(.unauthorized))
            }
            if response.statusCode == 403 {
                return completion(.failure(.permissionDenied))
            }
            guard error == nil else {
                return completion(.failure(.noData))
            }
            completion(.success(true))
        }.resume()
    }
    
    static func getFileListProc(
        ip: String,
        port: Int,
        session: UUID,
        path: String,
        completion: @escaping (Result<[[String:String]], NetworkError>) -> Void) {
        guard let url = URL(string:"http://" + ip + ":" + String(port) + "/api/file/list") else {
            return completion(.failure(.badURL))
        }
        let sendData = try! JSONSerialization.data(withJSONObject: ["sessionKey" : session.uuidString, "path" : path], options: [])
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = sendData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let response = response as? HTTPURLResponse else {
                return completion(.failure(.noData))
            }
            if response.statusCode == 401 {
                return completion(.failure(.unauthorized))
            }
            if response.statusCode == 403 {
                return completion(.failure(.permissionDenied))
            }
            guard let data = data, error == nil else {
                return completion(.failure(.noData))
            }
            guard let list = try? JSONDecoder().decode([[String:String]].self, from: data) else {
                return completion(.failure(.decodingError))
            }
            completion(.success(list))
        }.resume()
    }
}
