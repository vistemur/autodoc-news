import UIKit

class ImageDiskCacheService {
    
    private var imagesData = [String: DiskImageData]()
    private let fileManager = FileManager()
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var memmoryUsed: Int = 0
    
    private var saveTasks = [String: TaskData<Void>]()
    private var readTasks = [String: TaskData<Void>]()
    
    init() {
        setup()
    }
    
    private func setup() {
        var isDirectory: ObjCBool = true
        guard fileManager.fileExists(atPath: ImageDiskCacheServiceValues.imagesDirectoryPath,
                                     isDirectory: &isDirectory),
              isDirectory.boolValue == true else {
            if let fullPath = URL(string: ImageDiskCacheServiceValues.imagesDirectoryPath) {
                try? fileManager.createDirectory(at: fullPath, withIntermediateDirectories: true)
            }
            return
        }
    }
    
    func saveInfo() {
        let data = try? encoder.encode(imagesData)
        let path = ImageDiskCacheServiceValues.imagesDataFilePath
        fileManager.createFile(atPath: path, contents: data)
    }
    
    func loadInfo() async {
        memmoryUsed = 0
        let path = ImageDiskCacheServiceValues.imagesDataFilePath
        if fileManager.fileExists(atPath: path) {
            if let data = fileManager.contents(atPath: path),
               let imagesData = try? decoder.decode([String : DiskImageData].self, from: data) {
                self.imagesData = imagesData
                imagesData.forEach { (_, diskImageData) in
                    memmoryUsed += diskImageData.memmory
                }
            }
        }
    }
    
    func contains(path: String) -> Bool {
        guard let nameSubstring = path.split(separator: "/").last else {
            return false
        }
        
        let name = String(nameSubstring)
        let fullPath = "\(ImageDiskCacheServiceValues.imagesDirectoryPath)/\(name)"
        return imagesData[fullPath] != nil
    }
    
    func get(imageHolder: ImageHolder, completion: @escaping () -> Void) {
        guard let nameSubstring = imageHolder.path.split(separator: "/").last else {
            return
        }

        if readTasks.count >= ImageDiskCacheServiceValues.maximumReadTasks {
            stopOldestReadTask()
        }
        
        let name = String(nameSubstring)
        let fullPath = "\(ImageDiskCacheServiceValues.imagesDirectoryPath)/\(name)"
        
        let readTask = Task {
            readTasks[fullPath]?.status = .ioOperation
            if let _ = imagesData[fullPath],
               let data = fileManager.contents(atPath: fullPath),
               let image = UIImage(data: data) {
                if imageHolder.loadingState != .cleared {
                    imageHolder.image = image
                    imageHolder.loadingState = .loaded
                }
                readTasks[fullPath]?.status = .ending
                imagesData[fullPath]?.lastUpdate = .now
            }
            readTasks[fullPath]?.status = .ending
            readTasks[fullPath] = nil
            completion()
        }
        readTasks[fullPath] = TaskData(task: readTask, creationDate: .now, status: .started)
    }
    
    func set(path: String, image: UIImage) async {
        guard let nameSubstring = path.split(separator: "/").last else {
            return
        }
        
        if saveTasks.count >= ImageDiskCacheServiceValues.maximumSaveTasks {
            stopOldestSaveTask()
        }
        
        let name = String(nameSubstring)
        let fullPath = "\(ImageDiskCacheServiceValues.imagesDirectoryPath)/\(name)"
        
        let saveTask = Task {
            saveTasks[fullPath]?.status = .ioOperation
            if let data = image.jpegData(compressionQuality: 1.0),
               fileManager.createFile(atPath: fullPath, contents: data) {
                saveTasks[fullPath]?.status = .ending
                imagesData[fullPath] = DiskImageData(lastUpdate: .now, memmory: data.count)
                memmoryUsed += data.count
            }
            saveTasks[fullPath] = nil
                        
            if memmoryUsed > ImageDiskCacheServiceValues.maximumSpace {
                deleteOldest(amount: ImageDiskCacheServiceValues.removePerCleanCycle)
            }
        }
        saveTasks[fullPath] = TaskData(task: saveTask, creationDate: .now, status: .started)
    }
    
    private func stopOldestSaveTask() {
        if let min = saveTasks.filter({ $0.value.status != .ioOperation }).min(by: { $0.value.creationDate.compare($1.value.creationDate).rawValue == -1 }) {
            saveTasks[min.key]?.task.cancel()
            saveTasks[min.key] = nil
        }
    }
    
    private func stopOldestReadTask() {
        if let min = readTasks.filter({ $0.value.status != .ioOperation }).min(by: { $0.value.creationDate.compare($1.value.creationDate).rawValue == -1 }) {
            readTasks[min.key]?.task.cancel()
            readTasks[min.key] = nil
        }
    }
    
    private func clear() {
        for path in imagesData.keys {
            delete(path: path)
        }
    }
    
    private func deleteOldest(amount: Int) {
        for _ in 0 ..< amount {
            if let min = imagesData.min(by: { $0.value.lastUpdate.compare($1.value.lastUpdate).rawValue == -1 }) {
                delete(path: min.key)
            }
        }
    }
    
    private func delete(path: String) {
        if let imageDiskData = imagesData[path],
           fileManager.fileExists(atPath: path) {
            try? fileManager.removeItem(atPath: path)
            memmoryUsed -= imageDiskData.memmory
            imagesData[path] = nil
        }
    }
    
    struct DiskImageData: Hashable, Codable {
        var lastUpdate: Date
        let memmory: Int
    }
    
    struct TaskData<ReturnType>: Hashable {
        var task: Task<(ReturnType), Never>
        let creationDate: Date
        var status: Status
        
        enum Status {
            case started
            case ioOperation
            case ending
        }
    }
}

fileprivate enum ImageDiskCacheServiceValues {
    static let startDirectory = URL.cachesDirectory
    static let serviceDirectoryPath = "\(startDirectory.path())ImagesCasheService"
    static let imagesDirectoryPath = "\(serviceDirectoryPath)/Images"
    static let imagesDataFilePath = "\(serviceDirectoryPath)/imagesData.json"
    static let removePerCleanCycle = 5
    static let maximumSpace = 1024 * 1024 * 1024 // bytes (total 1 GB)
    static let maximumSaveTasks = 25
    static let maximumReadTasks = 25
}
