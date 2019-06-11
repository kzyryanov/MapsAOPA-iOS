import UIKit

open class InsetKeyboardHandler: KeyboardHandler {
    
    open weak var scrollView: UIScrollView?
    open var originalInsets: UIEdgeInsets?
    
    public init() {}
    
    open func willShow(_ info: KeyboardInfo) {
        originalInsets = originalInsets ?? scrollView?.contentInset ?? .zero
        var insets = originalInsets ?? .zero
        
        var view: UIView? = self.scrollView
        while nil != view?.superview {
            view = view?.superview
        }
        
        let scrollViewBounds = self.scrollView?.bounds ?? .zero
        let globalBounds = view?.bounds ?? .zero
        let globalScrollViewRect = view?.convert(scrollViewBounds, from: self.scrollView) ?? .zero
        
        insets.bottom = info.height - (globalBounds.maxY - globalScrollViewRect.maxY)
        
        UIView.animate(withDuration: info.duration, delay: 0, options: info.animation, animations: { [weak self] in
            self?.scrollView?.contentInset = insets
            self?.scrollView?.scrollIndicatorInsets = insets
            }, completion: nil)
    }
    
    open func willHide(_ info: KeyboardInfo) {
        
        let insets = originalInsets ?? .zero
        UIView.animate(withDuration: info.duration, delay: 0, options: info.animation, animations: { [weak self] in
            self?.scrollView?.contentInset = insets
            self?.scrollView?.scrollIndicatorInsets = insets
            }, completion: nil)
    }
}
