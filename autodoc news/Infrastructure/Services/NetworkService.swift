import Foundation

class NetworkService {
    
    private let decoder = JSONDecoder()
    private lazy var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30.0
        configuration.waitsForConnectivity = true
        return URLSession(configuration: configuration)
    }()
    
    func request<E: Endpoint, Response: Decodable>(endpoint: E) async -> Response? where E.Response == Response {
        guard let data = await requestData(endpoint: endpoint) else {
            return nil
        }
        
        do {
            let response = try decoder.decode(Response.self, from: data)
            return response
        } catch {
            return nil
        }
    }
    
    func requestData<E: Endpoint>(endpoint: E) async -> Data? {
        guard let urlRequest = try? endpoint.urlRequest() else {
            return nil
        }
        
        return await retriableRequest(urlRequest: urlRequest)
    }
    
    func retriableRequest(urlRequest: URLRequest, currentRetryAmount: Int = 0) async -> Data? {
        guard currentRetryAmount < NetworkServiceValues.maxRetries else {
            return nil
        }
        
        do {
            return try await urlSession.data(for: urlRequest).0
        } catch {
            return await retriableRequest(urlRequest: urlRequest, currentRetryAmount: currentRetryAmount + 1)
        }
    }
}

fileprivate enum NetworkServiceValues {
    static let maxRetries = 3
}
