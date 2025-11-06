import Cocoa
    
class PRMenuItemView: NSView {
    private let statusLabel = NSTextField(labelWithString: "")
    private let reviewerTypeLabel = NSTextField(labelWithString: "")
    private let titleLabel = NSTextField(labelWithString: "")
    private let authorLabel = NSTextField(labelWithString: "")
    private let branchLabel = NSTextField(labelWithString: "")
    private let reviewersStatusLabel = NSTextField(labelWithString: "")
    private let unresolvedLabel = NSTextField(labelWithString: "")
    private let projectLabel = NSTextField(labelWithString: "")
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
    private var statusIndicator: NSTextField? = nil

    override var acceptsFirstResponder: Bool { true }

    // Modified: accept statusText and statusColor
    convenience init(data: PRMenuItemData, showTargetBranch: Bool = true, onClick: (() -> Void)? = nil) {
        self.init(
            approval: data.approval,
            approvalColor: {
                switch data.approvalColor {
                case "green": return .systemGreen
                case "red": return .systemRed
                case "orange": return .systemOrange
                case "blue": return .systemBlue
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
            projectName: data.projectName,
            statusText: data.statusText,
            statusColor: data.statusColor,
            showTargetBranch: showTargetBranch,
            onClick: onClick
        )
    }

    init(approval: String, approvalColor: NSColor, reviewerType: String, title: String, author: String, branch: String, reviewersStatus: String? = nil, url: URL, isOverdue: Bool = false, projectName: String = "", statusText: String, statusColor: String, showTargetBranch: Bool = true, onClick: (() -> Void)? = nil) {
        self.url = url
        super.init(frame: .zero)
        self.onClick = onClick
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor

        // Monospaced font for alignment
        let monoFont = NSFont.monospacedSystemFont(ofSize: 16, weight: .bold)

        // Status indicator at the lead
        let statusIndicatorField = NSTextField(labelWithString: statusText)
        statusIndicatorField.font = NSFont.systemFont(ofSize: 13, weight: .semibold)
        statusIndicatorField.textColor = {
            switch statusColor {
            case "red": return .systemRed
            case "green": return .systemGreen
            case "blue": return .systemBlue
            case "orange": return .systemOrange
            default: return .secondaryLabelColor
            }
        }()
        statusIndicatorField.backgroundColor = .clear
        statusIndicatorField.isBordered = false
        statusIndicatorField.isEditable = false
        statusIndicatorField.translatesAutoresizingMaskIntoConstraints = false
        self.statusIndicator = statusIndicatorField

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
        branchLabel.isHidden = !showTargetBranch

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

        projectLabel.stringValue = "[\(projectName)]"
        projectLabel.font = .systemFont(ofSize: 11, weight: .medium)
        projectLabel.textColor = .tertiaryLabelColor
        projectLabel.backgroundColor = .clear
        projectLabel.isBordered = false
        projectLabel.isEditable = false
        projectLabel.lineBreakMode = .byTruncatingTail
        projectLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        projectLabel.translatesAutoresizingMaskIntoConstraints = false

        // Adjust stack view order: titleLabel, statusIndicatorField, branch, ...
        // Only include branchLabel if showTargetBranch is true
        var stackViews: [NSView] = [statusLabel, reviewerTypeLabel, titleLabel, statusIndicatorField, authorLabel]
        if showTargetBranch {
            stackViews.append(branchLabel)
        }
        stackViews.append(contentsOf: [projectLabel, reviewersStatusLabel])
        let stack = NSStackView(views: stackViews)
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
            unresolvedLabel.stringValue = "\(unresolvedCommentsCount) unresolved comment(s)"
            unresolvedLabel.isHidden = false
        } else {
            unresolvedLabel.isHidden = true
        }
    }

    public func updateStatus(text: String, color: String) {
        guard let label = self.statusIndicator else { return }
        label.stringValue = text
        switch color {
        case "red": label.textColor = .systemRed
        case "green": label.textColor = .systemGreen
        case "blue": label.textColor = .systemBlue
        case "orange": label.textColor = .systemOrange
        default: label.textColor = .secondaryLabelColor
        }
    }
} 
