//
//  FileCaching.swift
//  Adka
//
//  Created by Amr ELghadban on 6/27/18.
//  Copyright © 2018 Amr Elghadban. All rights reserved.
//

import UIKit

class FileCaching {
    static let cacheDirectoryPrefix = "com.adka.cache."
    static let dispatchQueueNamePrefix = "FileCaching.dispatchQueueName."
    var cachePath: String
    /// Name of cache
    open var name: String = ""

    let queue: DispatchQueue
    let fileManager: FileManager

    static let defult = FileCaching(name: "\(FileCaching.dispatchQueueNamePrefix)default")

    /// Specify distinc name param, it represents folder name for disk cache
    public init(name: String, path: String? = nil) {
        self.name = name

        self.cachePath = path ?? NSSearchPathForDirectoriesInDomains(.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
        self.cachePath = (cachePath as NSString).appendingPathComponent(FileCaching.cacheDirectoryPrefix + name)

        self.queue = DispatchQueue(label: FileCaching.dispatchQueueNamePrefix + name)

        self.fileManager = FileManager()
    }
}

// MARK: Store data

extension FileCaching {
    func setData(_ data: Data, forKey key: String) {
        self.writeDataToDisk(data: data, key: key)
    }

    func data(forKey key: String) -> Data? {
        let data = self.readDataFromDisk(forKey: key)
        return data
    }
}

extension FileCaching {
    private func cachePath(forKey key: String) -> String {
        let fileName = key
        return (cachePath as NSString).appendingPathComponent(fileName)
    }

    private func writeDataToDisk(data: Data, key: String) {
        self.queue.async {
            if self.fileManager.fileExists(atPath: self.cachePath) == false {
                do {
                    try self.fileManager.createDirectory(atPath: self.cachePath, withIntermediateDirectories: true, attributes: nil)
                }
                catch {
                    print("Error while creating cache folder")
                }
            }

            let isSuccess = self.fileManager.createFile(atPath: self.cachePath(forKey: key), contents: data, attributes: nil)
            debugPrint(isSuccess)
        }
    }

    /// Read data from disk for key
    private func readDataFromDisk(forKey key: String) -> Data? {
        guard self.hasDataOnDiskForKey(forKey: key) else {
            return nil
        }
        let data = self.fileManager.contents(atPath: cachePath(forKey: key))
        return data
    }

    /// Check if has data on disk
    func hasDataOnDiskForKey(forKey key: String) -> Bool {
        return self.fileManager.fileExists(atPath: self.cachePath(forKey: key))
    }
}
