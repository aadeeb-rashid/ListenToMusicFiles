//
//  ManagerFactory.swift
//  ListenToMusicFiles
//
//  Created by aadeeb rashid on 10/19/22.
//

import Foundation
class Manager : NSObject
{
    
}

class ManagerFactory
{
    var managers: [Manager] = []
    
    lazy var errorManager: ErrorManager =
    {
        let manager = ErrorManager()
        self.managers.append(manager)
        return manager
    }()
    
    lazy var userManager: UserManager =
    {
        let manager = UserManager()
        self.managers.append(manager)
        return manager
    }()
    
    lazy var networkManager: NetworkManager =
    {
        let manager = NetworkManager()
        self.managers.append(manager)
        return manager
    }()
    
    lazy var audioManager: AudioManager =
    {
        let manager = AudioManager()
        self.managers.append(manager)
        return manager
    }()
    
    lazy var deviceDataManager : DeviceDataManager =
    {
        let manager = DeviceDataManager()
        self.managers.append(manager)
        return manager
    }()

}
