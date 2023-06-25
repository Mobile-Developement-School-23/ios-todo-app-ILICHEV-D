class FileCacheAssembly { // : Assembly

    static func build(filename: String, type: FileType) -> FileCacheType {
        let service = FileCache(filename: "example", fileType: .json)
        return service
    }

}
