import Foundation
class WDWordListManager {
    static let sharedInstance = WDWordListManager()
    fileprivate let SavedWordsKey = "wordist_saved_words"
    fileprivate var filePath:URL {
        get {
            return WDHelpers.documentsDirectory().appendingPathComponent("user_saved_words.plist")
        }
    }
    fileprivate var savedWords:[WordObject] = []
    init() {
        savedWords = loadSavedWords()
        NotificationCenter.default.addObserver(self, selector: #selector(saveWords), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(saveWords), name: Notification.Name.UIApplicationWillTerminate, object: nil)
    }
    func save(word:WordObject) {
        guard  isWordSaved(word:word).exists == false else {
            return
        }
        savedWords.insert(word, at: 0)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationDidSaveWord), object: word)
    }
    func remove(word:WordObject) {
        let (exists,index) = isWordSaved(word:word)
        guard exists == true else {
            return
        }
        savedWords.remove(at: index)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationDidRemoveWord), object: word)
    }
    func getWords() -> [WordObject] {
        return savedWords
    }
    @objc func saveWords() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(savedWords, forKey: SavedWordsKey)
        archiver.finishEncoding()
        do {
            try data.write(to: filePath, options: .atomic)
        }
        catch {
            print("Failed to save words in documents!")
        }
    }
    func isWordSaved(word:WordObject) -> (exists:Bool, index:Int) {
        for (i,savedWord) in savedWords.enumerated() {
            if word.word.localizedCompare(savedWord.word) == .orderedSame {
                return (true, i)
            }
        }
        return (false , -1)
    }
    func removeAllWords() {
        savedWords.removeAll()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationDidRemoveAllWords), object: nil)
    }
    fileprivate func loadSavedWords() -> [WordObject] {
        var loadedWords:[WordObject] = []
        if let data = try? Data(contentsOf: filePath) {
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            loadedWords = unarchiver.decodeObject(forKey: SavedWordsKey) as! [WordObject]
            unarchiver.finishDecoding()
        }
        return loadedWords
    }
}
