import UIKit
class WordObject: NSObject {
    let word:String
    let definitions:[String]
    override var description: String {
        return "Word:\(word) \n Definition:\(definitions)\n"
    }
    required init?(coder aDecoder: NSCoder) {
        guard let word = aDecoder.decodeObject(forKey: "word") as? String, let definition = aDecoder.decodeObject(forKey: "definition") as? [String] else {
            return nil
        }
        self.word = word
        self.definitions = definition
        super.init()
    }
    init(word:String, definitions:[String]) {
        self.word = word
        self.definitions = definitions
        super.init()
    }
    init?(withDictionary responseDict:[String:Any]) {
        guard let word = responseDict["word"] as? String, let definitions = responseDict["defs"] as? [String] else {
            return nil
        }
        self.word = word
        var sanitizedDefinitions:[String] = []
        for definition in definitions {
            sanitizedDefinitions += [WordObject.getSanitizedDefinitionFrom(rawDefinition: definition)]
        }
        self.definitions = sanitizedDefinitions
        super.init()
    }
    static func getSanitizedDefinitionFrom(rawDefinition:String) -> String {
        var tabCharacterIndex:UInt?
        for (i, scalar) in rawDefinition.unicodeScalars.enumerated() {
            if scalar.value == 9 {
                tabCharacterIndex = UInt(i)
            }
        }
        if let tabCharacterIndex = tabCharacterIndex {
            return String.init(rawDefinition.dropFirst(Int(tabCharacterIndex + 1)))
        }
        else {
            return rawDefinition
        }
    }
}
extension WordObject:NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.word, forKey: "word")
        aCoder.encode(self.definitions, forKey: "definition")
    }
}
