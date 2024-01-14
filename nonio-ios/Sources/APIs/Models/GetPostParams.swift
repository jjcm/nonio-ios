import Foundation

struct GetPostParams: Equatable {
    
    enum Sort: String, CaseIterable {
        case popular, new, top
        
        var display: String {
            rawValue.capitalized
        }
    }
    
    enum Time: String, CaseIterable {
        case all, day, week, month, year
        
        var display: String {
            rawValue.capitalized
        }
    }
    
    var tag: String
    var sort: Sort?
    var time: Time?
    init(tag: String, sort: Sort?, time: Time?) {
        self.tag = tag
        self.sort = sort
        self.time = time
    }
}

extension GetPostParams {
    var toRequestParams: [String: Any] {
        let params =  [
            "tag": tag,
            "sort": sort?.rawValue,
            "time": time?.rawValue,
        ]
        return params.compactMapValues { $0 }
    }
    
    static let all =  GetPostParams(tag: "all", sort: .top, time: nil)
}
