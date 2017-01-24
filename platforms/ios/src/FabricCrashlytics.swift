import Foundation

extension CDVInvokedUrlCommand {
    func getStringAt(_ index: UInt) -> String {
        return argument(at: index) as! String
    }

    func getDoubleAt(_ index: UInt) -> Double {
        return (argument(at: index) as AnyObject).doubleValue
    }

    func getFloatAt(_ index: UInt) -> Float {
        return (argument(at: index) as AnyObject).floatValue
    }

    func getIntAt(_ index: UInt) -> Int32 {
        return (argument(at: index) as AnyObject).int32Value
    }

    func getBoolAt(_ index: UInt) -> Bool {
        return argument(at: index) as! Bool
    }
}

@objc(FabricCrashlytics)
class FabricCrashlytics: CDVPlugin {

    // MARK: - Cordova Commands

    @objc(log:)
    func log(_ command: CDVInvokedUrlCommand) {
        logmsg(command)
    }

    @objc(logException:)
    func logException(_ command: CDVInvokedUrlCommand) {
        logmsg(command) {
            Crashlytics.sharedInstance().throwException()
        }
    }

    @objc(crash:)
    func crash(_ command: CDVInvokedUrlCommand) {
        logmsg(command) {
            Crashlytics.sharedInstance().crash()
        }
    }

    @objc(setBool:)
    func setBool(_ command: CDVInvokedUrlCommand) {
        let key = command.getStringAt(0)
        let value = command.getBoolAt(1)
        frame(command) {
            Crashlytics.sharedInstance().setBoolValue(value, forKey: key)
        }
    }

    @objc(setDouble:)
    func setDouble(_ command: CDVInvokedUrlCommand) {
        let key = command.getStringAt(0)
        let value = command.getDoubleAt(1)
        frame(command) {
            Crashlytics.sharedInstance().setObjectValue(value, forKey: key)
        }
    }

    @objc(setFloat:)
    func setFloat(_ command: CDVInvokedUrlCommand) {
        let key = command.getStringAt(0)
        let value = command.getFloatAt(1)
        frame(command) {
            Crashlytics.sharedInstance().setFloatValue(value, forKey: key)
        }
    }

    @objc(setInt:)
    func setInt(_ command: CDVInvokedUrlCommand) {
        let key = command.getStringAt(0)
        let value = command.getIntAt(1)
        frame(command) {
            Crashlytics.sharedInstance().setIntValue(value, forKey: key)
        }
    }

    @objc(setUserIdentifier:)
    func setUserIdentifier(_ command: CDVInvokedUrlCommand) {
        let value = command.getStringAt(0)
        frame(command) {
            Crashlytics.sharedInstance().setUserIdentifier(value)
        }
    }

    @objc(setUserName:)
    func setUserName(_ command: CDVInvokedUrlCommand) {
        let value = command.getStringAt(0)
        frame(command) {
            Crashlytics.sharedInstance().setUserName(value)
        }
    }

    @objc(setUserEmail:)
    func setUserEmail(_ command: CDVInvokedUrlCommand) {
        let value = command.getStringAt(0)
        frame(command) {
            Crashlytics.sharedInstance().setUserEmail(value)
        }
    }

    // MARK: - Private Utillities

    fileprivate func fork(_ proc: @escaping () -> Void) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.utility).async(execute: proc)
    }

    fileprivate func frame(_ command: CDVInvokedUrlCommand, _ proc: @escaping () -> Void) {
        fork {
            proc()
            self.commandDelegate!.send(CDVPluginResult(status: CDVCommandStatus_OK), callbackId: command.callbackId)
        }
    }

    fileprivate func logmsg(_ command: CDVInvokedUrlCommand, _ proc: () -> Void = {}) {
        frame(command) {
            if let v = command.arguments.first {
                if (!(v is NSNull)) {
                    let msg = String(describing: v).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    if (!msg.isEmpty) {
                        CLSLogv("%@", getVaList([msg]))
                    }
                }
            }
            proc()
        }
    }
}
