import Foundation
import Alamofire
protocol WordSearchDelegate {
    func didPerformSearchSuccessfully(forQuery query:String)
    func didFailToSearch(query:String)
}
class WordSearch {
    static let apiEndpoint = "https://api.datamuse.com/words"
    fileprivate var delegate:WordSearchDelegate?
    fileprivate var currentQuery:String?
    var searchResults = [WordObject]()
    fileprivate var currentRequestID:Int?
    func performSearch(withQuery query:String, delegate:WordSearchDelegate) {
        if let url = getSearchURLWith(Query: query) {
            currentQuery = query
            self.delegate = delegate
            let dataRequestObject =  WDAPIManager.sharedInstance.getRequestWith(url: url, params: nil, delegate:self)
            currentRequestID = dataRequestObject.request?.hashValue
        }
    }
    fileprivate func getSearchURLWith(Query query:String?) -> String? {
        guard let query = query, query.isEmpty == false else {
            return nil
        }
        let queryString = query.replacingOccurrences(of: " ", with: "")
        return "\(WordSearch.apiEndpoint)?sp=\(queryString)*&md=d&max=50"
    }
    func clearSearch() {
        currentQuery = nil
        searchResults.removeAll()
    }
}
extension WordSearch:WDAPIManagerDelegate {
    func didRecieve(response: [String : Any], params: [String : Any]?) {
        let currentQueryURLPath = getSearchURLWith(Query: currentQuery)
        if let requestURL = params?["request_url"] as? String, requestURL == currentQueryURLPath  {
            searchResults.removeAll()
            if let wordsResponseList = response["response"] as? Array<Any> {
                for wordObject in wordsResponseList {
                    if let wordObjectResponse = wordObject as? Dictionary<String,Any>, let wordObject = WordObject.init(withDictionary:wordObjectResponse )  {
                        searchResults += [wordObject]
                    }
                }
            }
            delegate?.didPerformSearchSuccessfully(forQuery: currentQuery ?? "")
        }
    }
    func didFail(withParams params: [String : Any]?) {
        delegate?.didFailToSearch(query:currentQuery ?? "")
    }
}
