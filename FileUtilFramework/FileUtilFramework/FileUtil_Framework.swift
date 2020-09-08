//
//  FileUtil_Cho.swift
//  ChoFileUtil
//
//  Created by mac on 2020/09/08.
//  Copyright © 2020 Cho. All rights reserved.
//

import Foundation

open class FileUtil_Framework {
    public init() {
    }
    /**
     Get temporary path to store openfile, image or video
     Store first downloaded tmpfile
     ../AppHome/tmp
     */
    open func getTmpFolder() -> URL{  
        return URL(fileURLWithPath: String( NSTemporaryDirectory()), isDirectory:  false)
    }
    
    /**
     Get Document path
     ~/AppHome/Document/
     */
    open func getDocumentFolder() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    
    /**
     Create directory at url given
     
     - Parameters: 
       - dirUrl: directoryUrl you want to create
     
     - Returns: if str is "exist", dir exist or success or fail reason
     */
    open func createDir(_ dirUrl:URL) -> (str:String, check:Bool) {  
        if FileManager.default.fileExists(atPath: dirUrl.path) { return ("exist", true) } // 폴더 있으면
        do {
            try FileManager.default.createDirectory(atPath: dirUrl.path, withIntermediateDirectories: true, attributes: [:])
            return ("success", true)
        }
        catch{ 
            return ("createDir Error \(error)", false )
        }
    }
    
    /**
     Create file at url given
     
     - Parameters: 
       - fileUrl: fileurl you want to create
       - data: data you want to create
     
     - Returns: if str is "exist", dir exist or success or fail reason
     */
    open func createFile(_ fileUrl:URL, data content:Data?) -> (str:String, check:Bool) {  
        
        if !FileManager.default.fileExists(atPath: fileUrl.deletingLastPathComponent().path) {// not exists dir
            let result = self.createDir(fileUrl.deletingLastPathComponent())
            if !result.check { return (result.str, false) }
        }
        if !FileManager.default.fileExists(atPath: fileUrl.path) { //not exists file
            return ("success", FileManager.default.createFile(atPath: fileUrl.path, contents: content, attributes: [:]))    
        }
        return ("exist", true)
    }
    
    /**
     Write file newly with filehandler
     - Parameters:
       - fileUrl: fileurl you want to create
       - data: data you want to create
     
     - Returns: str is reason, check is Bool
     */
    open func writeFile(_ fileUrl:URL, data:Data) -> (str:String, check:Bool) {  
        guard let fileHandle = FileHandle(forWritingAtPath: fileUrl.path) 
            else { 
                return ("Can't Make Handler", false)
        }
        fileHandle.write(data)
        fileHandle.closeFile()
        return ("success", true)
    }
    
    /**
     remove file or folder 
     
     - Parameters:
       - fileUrl: file or folder url you want to delete
       - del: if del is true, delete folder and if del is false delete folder inside. default is false
     */
    open func deleteItem(_ fileUrl:URL, ifFolderDelete del:Bool = false) -> (str:String, check:Bool) {  
        let path = fileUrl.path
        
        if !self.isDir(path) { // if file
            if FileManager.default.isDeletableFile(atPath: fileUrl.path) {
                do { 
                    try FileManager.default.removeItem(at: fileUrl)
                    return ("success", true) 
                } catch { 
                    return ("Delete File Error: \((error as NSError).debugDescription)", false)
                }
            }
        }
        
        if del { // delete entrie folder
            do { try FileManager.default.removeItem(at: fileUrl)
                return ("success", true)            
            }
            catch { return ("Delete Folder Error: \((error as NSError).debugDescription)", false) } 
        }
        
        do { // delete folder inside
            let filePaths = try FileManager.default.contentsOfDirectory(atPath: path) 
            for filePath in filePaths { 
                try FileManager.default.removeItem(at: fileUrl.appendingPathComponent(filePath) ) 
            }
            return ("success", true )
        } 
        catch { return ("Could not clear folder: \((error as NSError).debugDescription)", false) } 
    }
    
    /**
     get File Length
     
     - Parameters: 
       - filePath: filepath you want to get length
     
     - Returns: (reason, length)
     */
    open func getLength(_ filePath:String) -> (str:String, length:Double) {
        do { 
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: filePath)
            
            guard let fileSize = fileAttributes[FileAttributeKey.size] as? Double else { return ("Can't Convert to Double", 0.0) } 
            return ("success", fileSize)
        }
        catch{
            return ("FileUtil.getLength Error is.. \(error)", -1.0)
        }
    }
    
    /**
     check Directory
     */
    open func isDir(_ path: String) -> Bool {
        var isDirectory = ObjCBool(true)
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
    
    /**
     Get All files in dir and subdir 
     
     - Parameters:
       - url: folder url
       - option: ResourceKey you want to know
     */
    open func getAllFile(fromFolder url:URL, option:Set<URLResourceKey>) -> [URLResourceValues] {
        let urls = try! FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        var result = [URLResourceValues]()
        var plusOption = option
        plusOption.insert(.isDirectoryKey)
        for url in urls {
            let resource = try! url.resourceValues(forKeys: option)
            if resource.isDirectory! {
                result.append(contentsOf: self.getAllFile(fromFolder: url, option: option) ) 
            } else {
                result.append(resource)
            }
        }
        return result
    } 
}
