//
//  CacheManager.swift
//  GifMakerSwift
//
//  Created by Mohammad Noor on 27/1/25.
//
import Foundation

class MemeMakerPickerFileManager {
    static let shared = MemeMakerPickerFileManager()
    
    private init() {}
    
   // private var activeDownloadTasks: [URL: URLSessionDownloadTask] = [:]
    
    // Function to get file path for the specified folder name
    func getFilePath(folderName: String, fileURL url: String) -> URL {
        let fileManager = FileManager.default
        
        let documentDirectory = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first ?? fileManager.temporaryDirectory
        
        let pickerFolder = documentDirectory.appendingPathComponent("Picker")
        let tenorFolder = pickerFolder.appendingPathComponent(folderName)
        
        if !fileManager.fileExists(atPath: tenorFolder.path) {
            do {
                try fileManager.createDirectory(
                    at: tenorFolder,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
                print(folderName+"Folder Created.")
            } catch {
                print(folderName+"Folder Creation Failed: \(error.localizedDescription)")
            }
        }
        
        let fileName = url.sha256HashValue
        //url.split(separator: "/").last ?? "tenorDefault.gif" //returns substring not string
        let filePath = tenorFolder.appendingPathComponent(fileName ?? "tenorDefault.gif")
        
        return filePath
    }
    
    // Function to save the file locally if it doesn't exist
    func downloadAsset(url: String, folderName: String, completion: @escaping (URL?, Error?) -> Void) {
        let filePath = getFilePath(folderName: folderName, fileURL: url)
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath.path) {
            completion(filePath, nil)
            return
        } else {
            guard let url = URL(string: url) else {
                completion(nil, MemePickerError.assetDownloadFailed)
                return
            }
            
           // cancelDownload(url: url)
            
            let downloadTask =  URLSession.shared.downloadTask(with: url) { tempLocation, _, error in
                if let error = error {
                    print("Failed to download: \(error.localizedDescription)")
                    completion(nil, MemePickerError.assetDownloadFailed)
                    return
                }
                
                guard let tempLocation = tempLocation else {
                    print("Invalid temporary location")
                    completion(nil, MemePickerError.assetDownloadFailed)
                    return
                }
                
                let fileManager = FileManager.default
                
                if fileManager.fileExists(atPath: filePath.path) {
                    completion(filePath, nil)
                    return
                }
                
                do {
                    try fileManager.moveItem(at: tempLocation, to: filePath)
                    print("File saved at \(filePath.path)")
                    completion(filePath, nil)
                } catch {
                    print("Failed to save file: \(error.localizedDescription)")
                    completion(nil, MemePickerError.assetDownloadFailed)
                }
            }
            //activeDownloadTasks[url] = downloadTask
            
            downloadTask.resume()
        }
    }
    
    func isFileExists(fileUrl url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.path)
    }
//    func cancelDownload(url: URL) {
//        if let task = activeDownloadTasks[url] {
//            task.cancel()
//            activeDownloadTasks.removeValue(forKey: url)
//            print("Download task cancelled for URL: \(url)")
//        }
//    }
//    
//    // Function to cancel all active download tasks
//    func cancelAllDownloads() {
//        for (url, task) in activeDownloadTasks {
//            task.cancel()
//            print("Download task cancelled for URL: \(url)")
//        }
//        activeDownloadTasks.removeAll()
//    }
}

