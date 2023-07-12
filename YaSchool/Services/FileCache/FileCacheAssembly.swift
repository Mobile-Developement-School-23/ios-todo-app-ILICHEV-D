import FileCache

class FileCacheAssembly {

    static func build(filename: String, type: FileType) -> FileCacheType {
        let service = FileCache(filename: filename, fileType: type)
        return service
    }

}
