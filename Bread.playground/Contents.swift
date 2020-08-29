import Foundation


public struct Bread {
    public enum BreadType: UInt32 {
        case small = 1
        case medium
        case big
    }
    
    public let breadType: BreadType
    
    public static func make() -> Bread {
        guard let breadType = Bread.BreadType(rawValue: UInt32(arc4random_uniform(3) + 1)) else {
            fatalError("Incorrect random value")
        }
        
        return Bread(breadType: breadType)
    }
    
    public func bake() {
        let bakeTime = breadType.rawValue
        sleep(UInt32(bakeTime))
    }
}

var storage = [Bread]()
var avalible = false
var conditional = NSCondition()

//поток для создания
var firstThread = Thread {
    for _ in 1...10 {
        conditional.lock()
        let done = Bread.make()
        storage.insert(done, at: 0)
        print("Done!")
        avalible = true
        
        conditional.unlock()
        sleep(2)
    }
}
//поток для работы
var secondThread = Thread {
    for _ in 1...10 {
        while (!avalible) {
            conditional.wait()
        }
        storage.removeFirst()
        
        if storage.count < 1 {
            avalible = false
        }
    }
}

firstThread.start()
secondThread.start()




