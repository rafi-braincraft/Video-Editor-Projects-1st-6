import UIKit
import Lottie


@IBDesignable
class CustomTabBar: UITabBar {
    
    let iPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
    
    private var lottieAnimationViews: [LottieAnimationView] = []
    private var staticImageViews: [UIImageView] = []
    private var labels: [UILabel] = []
    
    private let animationNames = ["cleaner","battery", "lock","compress","settings"]
    private let animationLabels = ["Cleaner","Battery", "Secret Space","Compress","Settings"]
    private let animationIconNames = ["icon_cleaner", "icon_battery", "icon_secret_space", "icon_compress", "icon_settings"]
    
    
    let screenWidth = UIScreen.main.bounds.width
    private var customHeight: CGFloat {
        return iPad ? (89 * (screenWidth / 1024)) : (60 * (screenWidth / 414))
    }
    
    private var customIconHeight: CGFloat {
        return iPad ? (37 * (screenWidth / 1024)) : (28 * (screenWidth / 414))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        print(customHeight)
        self.frame.size.height = customHeight
        setupLottieAnimations()
    }
    
    //    override func draw(_ rect: CGRect) {
    //        UIColor.systemBackground.setFill()
    //
    //        frame.size.height = customHeight
    //    }
    
    private func setupLottieAnimations() {
        
        guard lottieAnimationViews.isEmpty, let items = items else { return }
        
        let tabBarItemCount = items.count
        let tabBarPadding = 20.0
        let tabBarWidth = bounds.width / CGFloat(tabBarItemCount) - tabBarPadding
        //let tabBarHeight = bounds.height
        
        for index in 0..<tabBarItemCount {
            
            let lottieView = LottieAnimationView(name: animationNames[index % animationNames.count])
            lottieView.contentMode = .scaleAspectFill
            lottieView.loopMode = .playOnce
            lottieView.animationSpeed = 0.7
            lottieView.isUserInteractionEnabled = false
            addSubview(lottieView)
            lottieAnimationViews.append(lottieView)
            
            let staticImageView = UIImageView(image: UIImage(named: animationIconNames[index % animationIconNames.count]))
            staticImageView.contentMode = .scaleAspectFit
            addSubview(staticImageView)
            staticImageViews.append(staticImageView)
            
            let label = UILabel()
            label.text = animationLabels[index % animationLabels.count]
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 9)
            label.textColor = .gray
            label.sizeToFit()
            lottieView.isUserInteractionEnabled = false
            addSubview(label)
            labels.append(label)
            
            
            let xPosition = CGFloat(index) * tabBarWidth
            
            lottieView.frame = CGRect(
                x: xPosition + (tabBarWidth / 2 - customIconHeight/2),
                y: 0,
                width: customIconHeight,
                height: customIconHeight
            )
            
            staticImageView.frame = lottieView.frame
            
            label.center.x = lottieView.center.x
            label.frame.origin.y = lottieView.frame.maxY + 2
            
        }
        updateTabAppearance(selectedIndex: 0)
    }
    
    func playAnimation(for index: Int) {
        guard index < lottieAnimationViews.count else { return }
        
        updateTabAppearance(selectedIndex: index)
        
        
    }
    
    private func updateTabAppearance(selectedIndex: Int) {
        for (i, lottieView) in lottieAnimationViews.enumerated() {
            let staticImageView = staticImageViews[i]
            let label = labels[i]
            
            if i == selectedIndex {
                
                staticImageView.isHidden = true
                lottieView.isHidden = false
                lottieView.play()
                label.textColor = .systemBlue
            } else {
                
                lottieView.isHidden = true
                staticImageView.isHidden = false
                label.textColor = .systemGray
            }
        }
    }
    
}
