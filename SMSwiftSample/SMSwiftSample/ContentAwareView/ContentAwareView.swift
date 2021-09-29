//
// Copyright (c) 2021 Soul Machines. All rights reserved.
//

import SMDarwin
import UIKit

class ContentAwareView: UIView, Content {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func getId() -> String {
        // Each content item within the ContentAwareness should have a unique Id, as duplicate Ids will replace existing items.
        return "UniqueIdRepresentingView"
    }

    func getBounds() -> PointRect {
        return PointRect(x1: Int(frame.origin.x),
                         y1: Int(frame.origin.y),
                         x2: Int(frame.origin.x + frame.size.width),
                         y2: Int(frame.origin.y + frame.size.height))
    }

    func getMetadata() -> [String: Any] {
        return [:]
    }
}
