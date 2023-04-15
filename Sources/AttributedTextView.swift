//
//  Copyright © 2017-2023 Pavel Sharanda. All rights reserved.
//

#if os(iOS)

    import UIKit

    @IBDesignable
    open class AttributedTextView: BaseAttributedTextView {
        private class UITextViewBackend: TextViewBackend {
            var attributedText: NSAttributedString? {
                set {
                    textView.attributedText = newValue
                }
                get {
                    return textView.attributedText
                }
            }

            var numberOfLines: Int {
                set {
                    textView.textContainer.maximumNumberOfLines = newValue
                }
                get {
                    return textView.textContainer.maximumNumberOfLines
                }
            }

            @available(iOS 10.0, *)
            var adjustsFontForContentSizeCategory: Bool {
                set {
                    textView.adjustsFontForContentSizeCategory = newValue
                }
                get {
                    return textView.adjustsFontForContentSizeCategory
                }
            }

            var lineBreakMode: NSLineBreakMode {
                set {
                    textView.textContainer.lineBreakMode = newValue
                }
                get {
                    return textView.textContainer.lineBreakMode
                }
            }

            var textOrigin: CGPoint {
                return CGPoint(x: textView.textContainerInset.left, y: textView.textContainerInset.top)
            }

            var view: UIView {
                return textView
            }

            let textView: UITextView

            func enumerateEnclosingRects(forGlyphRange glyphRange: NSRange, using block: @escaping (CGRect) -> Bool) {
                textView.layoutManager.enumerateEnclosingRects(
                    forGlyphRange: glyphRange,
                    withinSelectedGlyphRange: NSRange(location: NSNotFound, length: 0),
                    in: textView.textContainer
                ) { rect, stop in
                    if block(rect) {
                        stop.pointee = true
                    }
                }
            }

            class TextView: UITextView {
                override var attributedText: NSAttributedString! {
                    didSet {
                        needsResetContentOffset = true
                    }
                }

                var needsResetContentOffset = false

                override func layoutSubviews() {
                    super.layoutSubviews()
                    if needsResetContentOffset {
                        needsResetContentOffset = false
                        if #available(iOS 11.0, *) {
                            contentOffset = CGPoint(x: 0, y: -adjustedContentInset.top)
                        } else {
                            contentOffset = .zero
                        }
                    }
                }
            }

            init() {
                if #available(iOS 16.0, *) {
                    textView = TextView(usingTextLayoutManager: false)
                } else {
                    textView = TextView()
                }
                textView.isUserInteractionEnabled = false
                textView.textContainer.lineFragmentPadding = 0
                textView.textContainerInset = .zero
                textView.isEditable = false
                textView.isScrollEnabled = false
                textView.isSelectable = false
                textView.backgroundColor = nil
            }
        }

        private var _textView: UITextView!

        override func makeBackend() -> TextViewBackend {
            let backend = UITextViewBackend()
            _textView = backend.textView
            return backend
        }

        @IBInspectable open var isSelectable: Bool {
            get {
                return _textView.isSelectable && _textView.isUserInteractionEnabled
            }
            set {
                _textView.isSelectable = newValue
                _textView.isUserInteractionEnabled = newValue || _textView.isScrollEnabled
            }
        }

        @IBInspectable open var isScrollEnabled: Bool {
            get {
                return _textView.isScrollEnabled && _textView.isUserInteractionEnabled
            }
            set {
                _textView.isScrollEnabled = newValue
                _textView.isUserInteractionEnabled = newValue || _textView.isSelectable
            }
        }

        @IBInspectable open var alwaysBounceVertical: Bool {
            get {
                return _textView.alwaysBounceVertical
            }
            set {
                _textView.alwaysBounceVertical = newValue
            }
        }

        @IBInspectable open var alwaysBounceHorizontal: Bool {
            get {
                return _textView.alwaysBounceHorizontal
            }
            set {
                _textView.alwaysBounceHorizontal = newValue
            }
        }

        @available(iOS 11.0, *)
        open var contentInsetAdjustmentBehavior: UIScrollView.ContentInsetAdjustmentBehavior {
            get {
                return _textView.contentInsetAdjustmentBehavior
            }
            set {
                _textView.contentInsetAdjustmentBehavior = newValue
            }
        }

        @IBInspectable open var textContainerInset: UIEdgeInsets {
            get {
                return _textView.textContainerInset
            }
            set {
                _textView.textContainerInset = newValue
            }
        }

        open func flashScrollIndicators() {
            _textView.flashScrollIndicators()
        }
    }

#endif
