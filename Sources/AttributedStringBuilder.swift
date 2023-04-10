//
//  Copyright © 2017-2023 Pavel Sharanda. All rights reserved.
//

import Foundation

public final class AttributedStringBuilder {
    public let string: String
    public private(set) var baseAttributes: AttributesProvider

    private struct AttributesRangeInfo {
        let attributes: AttributesProvider
        let range: Range<String.Index>
        let level: Int
    }
    
    private var currentMaxLevel: Int = 0
    
    private var attributesRangeInfo: [AttributesRangeInfo]

    private init(string: String, attributesRangeInfo: [AttributesRangeInfo], baseAttributes: AttributesProvider) {
        self.string = string
        self.attributesRangeInfo = attributesRangeInfo
        self.baseAttributes = baseAttributes
    }

    public convenience init(string: String, baseAttributes: AttributesProvider = [NSAttributedString.Key: Any]()) {
        self.init(string: string, attributesRangeInfo: [], baseAttributes: baseAttributes)
    }

    public convenience init(attributedString: NSAttributedString, baseAttributes: AttributesProvider = [NSAttributedString.Key: Any]()) {
        let string = attributedString.string
        var info: [AttributesRangeInfo] = []

        attributedString.enumerateAttributes(in: NSMakeRange(0, attributedString.length), options: []) { attributes, range, _ in
            if let range = Range(range, in: string) {
                info.append(AttributesRangeInfo(attributes: attributes, range: range, level: -1))
            }
        }

        self.init(string: string, attributesRangeInfo: info, baseAttributes: baseAttributes)
    }

    public convenience init(
        htmlString: String,
        baseAttributes: AttributesProvider = [NSAttributedString.Key: Any](),
        tags: [String: TagTuning] = [:]
    ) {
        let (string, tagsInfo) = htmlString.detectTags(tags: tags)
        var info: [AttributesRangeInfo] = []

        var newLevel = 0
        tagsInfo.forEach { t in
            newLevel = max(t.level, newLevel)
            if let style = tags[t.tag.name] {
                info.append(AttributesRangeInfo(attributes: style.style(tag: t.tag), range: t.range, level: t.level))
            }
        }

        self.init(string: string, attributesRangeInfo: info, baseAttributes: baseAttributes)
        currentMaxLevel = newLevel
    }

    public var attributedString: NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string, attributes: baseAttributes.attributes)

        let info = attributesRangeInfo.sorted {
            $0.level < $1.level
        }

        for i in info {
            let attributes = i.attributes
            if attributes.attributes.count > 0 {
                attributedString.addAttributes(attributes.attributes, range: NSRange(i.range, in: string))
            }
        }

        return attributedString
    }

    public func styleHashtags(_ attributes: AttributesProvider) -> Self {
        return style(ranges: string.detectHashtags(),
                     attributes: attributes)
    }

    public func styleMentions(_ attributes: AttributesProvider) -> Self {
        return style(ranges: string.detectMentions(),
                     attributes: attributes)
    }

    public func style(regex: String, options: NSRegularExpression.Options = [], attributes: AttributesProvider) -> Self {
        return style(ranges: string.detect(regex: regex, options: options),
                     attributes: attributes)
    }

    public func style(textCheckingTypes: NSTextCheckingResult.CheckingType, attributes: AttributesProvider) -> Self {
        return style(ranges: string.detect(textCheckingTypes: textCheckingTypes),
                     attributes: attributes)
    }

    public func stylePhoneNumbers(_ attributes: AttributesProvider) -> Self {
        return style(ranges: string.detectPhoneNumbers(),
                     attributes: attributes)
    }

    public func styleLinks(_ attributes: AttributesProvider) -> Self {
        return style(ranges: string.detectLinks(),
                     attributes: attributes)
    }

    public func style(range: Range<String.Index>, attributes: AttributesProvider) -> Self {
        return style(ranges: [range], attributes: attributes)
    }

    public func style(ranges: [Range<String.Index>], attributes: AttributesProvider) -> Self {
        currentMaxLevel += 1
        let info = ranges.map { range in
            AttributesRangeInfo(attributes: attributes,
                                range: range,
                                level: currentMaxLevel)
        }

        attributesRangeInfo.append(contentsOf: info)
        return self
    }

    public func styleBase(_ attributes: AttributesProvider) -> Self {
        baseAttributes = attributes
        return self
    }
}
