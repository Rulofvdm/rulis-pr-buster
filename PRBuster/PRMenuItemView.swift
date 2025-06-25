import Cocoa
    
class PRMenuItemView: NSView {
    private let statusLabel = NSTextField(labelWithString: "")
    private let reviewerTypeLabel = NSTextField(labelWithString: "")
    private let titleLabel = NSTextField(labelWithString: "")
    private let authorLabel = NSTextField(labelWithString: "")
    private let branchLabel = NSTextField(labelWithString: "")
    private let reviewersStatusLabel = NSTextField(labelWithString: "")
    private let unresolvedLabel = NSTextField(labelWithString: "")
    private var onClick: (() -> Void)?
    private var isHovered: Bool = false {
        didSet { needsDisplay = true }
    }
    private var unresolvedCommentsCount: Int = 0 {
        didSet {
            updateUnresolvedLabel()
        }
    }
    public let url: URL

    override var acceptsFirstResponder: Bool { true }

    // Convenience initializer for use with PRMenuItemData
    convenience init(data: PRMenuItemData, onClick: (() -> Void)? = nil) {
        self.init(
            approval: data.approval,
            approvalColor: {
                switch data.approvalColor {
                case "green": return .systemGreen
                case "red": return .systemRed
                case "orange": return .systemOrange
                default: return .secondaryLabelColor
                }
            }(),
            reviewerType: data.reviewerType.rawValue,
            title: data.title,
            author: data.author,
            branch: data.branch,
            reviewersStatus: data.reviewersStatus,
            url: data.url,
            isOverdue: data.isOverdue,
            onClick: onClick
        )
    }

    init(approval: String, approvalColor: NSColor, reviewerType: String, title: String, author: String, branch: String, reviewersStatus: String? = nil, url: URL, isOverdue: Bool = false, onClick: (() -> Void)? = nil) {
        self.url = url
        super.init(frame: .zero)
        self.onClick = onClick
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor

        // Monospaced font for alignment
        let monoFont = NSFont.monospacedSystemFont(ofSize: 16, weight: .bold)
        statusLabel.stringValue = approval
        statusLabel.textColor = approvalColor
        statusLabel.font = monoFont
        statusLabel.alignment = .center
        statusLabel.backgroundColor = .clear
        statusLabel.isBordered = false
        statusLabel.isEditable = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        if reviewerType != "A" {
            reviewerTypeLabel.stringValue = reviewerType
            reviewerTypeLabel.textColor = .secondaryLabelColor
            reviewerTypeLabel.font = monoFont
            reviewerTypeLabel.backgroundColor = .clear
            reviewerTypeLabel.isBordered = false
            reviewerTypeLabel.isEditable = false
            reviewerTypeLabel.alignment = .center
            reviewerTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        } else {
            reviewerTypeLabel.isHidden = true
        }

        titleLabel.stringValue = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        titleLabel.textColor = isOverdue ? .systemRed : .labelColor
        titleLabel.backgroundColor = .clear
        titleLabel.isBordered = false
        titleLabel.isEditable = false
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        if reviewerType != "A" {
            authorLabel.stringValue = "by \(author)"
            authorLabel.font = .systemFont(ofSize: 12, weight: .light)
            authorLabel.textColor = .secondaryLabelColor
            authorLabel.backgroundColor = .clear
            authorLabel.isBordered = false
            authorLabel.isEditable = false
            authorLabel.lineBreakMode = .byTruncatingTail
            authorLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        } else {
            authorLabel.isHidden = true
        }

        branchLabel.stringValue = "→ \(branch)"
        branchLabel.font = .systemFont(ofSize: 12, weight: .light)
        branchLabel.textColor = .tertiaryLabelColor
        branchLabel.backgroundColor = .clear
        branchLabel.isBordered = false
        branchLabel.isEditable = false
        branchLabel.lineBreakMode = .byTruncatingTail
        branchLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        reviewersStatusLabel.stringValue = reviewersStatus ?? ""
        reviewersStatusLabel.font = .systemFont(ofSize: 12, weight: .light)
        reviewersStatusLabel.textColor = .secondaryLabelColor
        reviewersStatusLabel.backgroundColor = .clear
        reviewersStatusLabel.isBordered = false
        reviewersStatusLabel.isEditable = false
        reviewersStatusLabel.lineBreakMode = .byTruncatingTail
        reviewersStatusLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        reviewersStatusLabel.translatesAutoresizingMaskIntoConstraints = false

        unresolvedLabel.font = .systemFont(ofSize: 12, weight: .bold)
        unresolvedLabel.textColor = .systemRed
        unresolvedLabel.backgroundColor = .clear
        unresolvedLabel.isBordered = false
        unresolvedLabel.isEditable = false
        unresolvedLabel.isHidden = true
        unresolvedLabel.translatesAutoresizingMaskIntoConstraints = false

        let stack = NSStackView(views: [statusLabel, reviewerTypeLabel, titleLabel, unresolvedLabel, authorLabel, branchLabel, reviewersStatusLabel])
        stack.orientation = .horizontal
        stack.spacing = 8
        stack.alignment = .centerY
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2)
        ])

        // Track mouse enter/exit for highlight
        let trackingArea = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect], owner: self, userInfo: nil)
        addTrackingArea(trackingArea)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        onClick?()
        // Default behavior: menu closes after click
    }

    override func mouseEntered(with event: NSEvent) {
        isHovered = true
    }

    override func mouseExited(with event: NSEvent) {
        isHovered = false
    }

    override var intrinsicContentSize: NSSize {
        return NSSize(width: 600, height: 24)
    }

    override func draw(_ dirtyRect: NSRect) {
        if isHovered {
            NSColor.controlAccentColor.setFill()
            dirtyRect.fill()
        }
        super.draw(dirtyRect)
    }

    func setUnresolvedCommentsCount(_ count: Int) {
        unresolvedCommentsCount = count
    }

    private func updateUnresolvedLabel() {
        if unresolvedCommentsCount > 0 {
            unresolvedLabel.stringValue = "\(unresolvedCommentsCount) unresolved"
            unresolvedLabel.isHidden = false
        } else {
            unresolvedLabel.isHidden = true
        }
    }
} 
