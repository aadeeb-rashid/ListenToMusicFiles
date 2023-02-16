//
//  LocalFile.swift
//  ListenToMusicFiles
//
//  Created by aadeeb rashid on 1/18/23.
//

import CoreData

@objc(LocalFile)
class LocalFile : NSManagedObject
{
    @NSManaged var fileName : String
}
