import QuartzCore

public extension CGRect {
  public init(center: CGPoint, size: CGSize) {
    self.init(origin: center.applying(CGAffineTransform(translationX: size.width / -2, y: size.height / -2)), size: size)
  }
  
  public var center: CGPoint {
    return CGPoint(x: midX, y: midY)
  }
  
  public var largestContainedSquare: CGRect {
    let side = min(width, height)
    return CGRect(center: center, size: CGSize(width: side, height: side))
  }
  
  public var smallestContainingSquare: CGRect {
    let side = max(width, height)
    return CGRect(center: center, size: CGSize(width: side, height: side))
  }
}
