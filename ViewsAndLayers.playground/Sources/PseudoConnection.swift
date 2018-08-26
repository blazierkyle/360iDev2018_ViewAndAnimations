import Foundation


public final class PseudoConnection: NSObject {
    
    private var timer: Timer?
    
    public enum State {
        case disconnected
        case connecting
        case connected
    }
    private var state: State = .disconnected {
        didSet {
            stateChangeCallback(state)
        }
    }
    
    public typealias StateChange = ((State) -> ())
    private let stateChangeCallback: StateChange
    
    public init(stateChangeCallback: @escaping StateChange) {
        self.stateChangeCallback = stateChangeCallback
    }
    
    public func connect() {
        state = .connecting
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] _ in
            self?.state = .connected
            self?.timer = nil
        }
    }
    
    public func disconnect() {
        timer?.invalidate()
        state = .disconnected
    }
    
    @objc public func toggle() {
        switch state {
        case .disconnected:
            connect()
        default:
            disconnect()
        }
    }
}
