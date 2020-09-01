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


struct BreadStorage {
    var storage = [Bread]()
    var isAvalible = false
    
    mutating func push() {
        let bread = Bread.make()
        storage.append(bread)
        print("Хлеб в печи")
    }
    
    mutating func pop() {
        storage.removeLast().bake()
    }
}

//поток для создания
class ParentThread: Thread {
    var bread = BreadStorage()
    var conditional = NSCondition()
    
    override func main() {
        let myTimer = Timer(timeInterval: 2, target: self, selector: #selector(pushInThread), userInfo: nil, repeats: true)
        RunLoop.current.add(myTimer, forMode: RunLoop.Mode.common)
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 20))
        print("ХЛЕБОПЕЧКА ЗАКРЫТА!")
    }
    
    @objc func pushInThread() {
        conditional.lock()
        self.bread.push()
        bread.isAvalible = true
        conditional.signal()
        conditional.unlock()
    }
}

let parentThread = ParentThread()
//поток для работы
class WorkingThread: Thread {
    
    override func main() {
        let mySecondTimer = Timer(timeInterval: 0 , target: self, selector: #selector(popInThread), userInfo: nil, repeats: true)
        RunLoop.current.add(mySecondTimer, forMode: RunLoop.Mode.common)
        RunLoop.current.run()
    }
    
    @objc func popInThread() {
        while (!parentThread.bread.isAvalible) {
            print("жду")
            parentThread.conditional.wait()
        }
        parentThread.bread.pop()
        parentThread.bread.isAvalible = false
        print("вытащил")
    }
}

let workingThread = WorkingThread()

parentThread.start()
workingThread.start()


