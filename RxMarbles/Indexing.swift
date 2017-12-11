//
//  Indexing.swift
//  RxMarbles
//
//  Created by Yury Korolev on 1/22/16.
//  Copyright © 2016 AnjLab. All rights reserved.
//

import Foundation
import RxSwift
import CoreSpotlight

private let IndexVersion = "v2"

enum UserActivityType: String {
    case OperatorView
}

extension Operator {
    static var all: [Operator] {
        return
            [.Amb,
             .Buffer,
             .CatchError,
             .CatchErrorJustReturn,
             .CombineLatest,
             .Concat,
             .Debounce,
             .DelaySubscription,
             .DistinctUntilChanged,
             .ElementAt,
             .Empty,
             .Filter,
             .FlatMap,
             .FlatMapFirst,
             .FlatMapLatest,
             .IgnoreElements,
             .Interval,
             .Just,
             .Map,
             .Merge,
             .Never,
             .Of,
             .Reduce,
             .RepeatElement,
             .Retry,
             .Sample,
             .Scan,
             .Single,
             .Skip,
             .SkipDuration,
             .SkipUntil,
             .SkipWhile,
             .StartWith,
             .SwitchLatest,
             .Take,
             .TakeDuration,
             .TakeLast,
             .TakeUntil,
             .TakeWhile,
             .Throttle,
             .Throw,
             .Timeout,
             .Timer,
             .ToArray,
             .WithLatestFrom,
             .Zip
        ]
    }
}

extension Operator {
    func userActivity() -> NSUserActivity {
        let activity = NSUserActivity(activityType: UserActivityType.OperatorView.rawValue)
        
        activity.title = description
        activity.keywords = _keywords()
        activity.isEligibleForSearch = true
        activity.isEligibleForPublicIndexing = true
        activity.userInfo = ["operator": rawValue]
        
        
        activity.contentAttributeSet = _searchableAttributes()
        return activity
    }
    
    private func _keywords() -> Set<String> {
        return ["Rx", "Reactive", "Operator", "Marbles", description]
    }
    
    private func _searchableAttributes() -> CSSearchableItemAttributeSet {
        let attributes = CSSearchableItemAttributeSet(itemContentType: "url")
        
        attributes.title = description
        attributes.contentDescription = text
        attributes.keywords = Array<String>(_keywords())
        attributes.identifier = rawValue
        attributes.relatedUniqueIdentifier = rawValue
        
        return attributes
    }
    
    
    private func _searchableItem() -> CSSearchableItem {
        return CSSearchableItem(
            uniqueIdentifier: rawValue,
            domainIdentifier: "operators",
            attributeSet: _searchableAttributes()
        )
    }
    
    static func index() {
        guard CSSearchableIndex.isIndexingAvailable() else { return }
        
        let userDefaults = UserDefaults.standard
        
        let indexVersionKey = "indexVersion"
        
        if let indexVersion = userDefaults.string(forKey: indexVersionKey)
            , indexVersion == IndexVersion {
            return debugPrint("already indexed")
        }
        
        let index = CSSearchableIndex.default()
        let items = Operator.all.map { $0._searchableItem() }
        index.deleteAllSearchableItems { error in
            if let e = error {
                return debugPrint(e)
            }
            
            index.indexSearchableItems(items, completionHandler: { error in
                if let e = error {
                    return debugPrint("failed to index items \(e)")
                }
                
                userDefaults.set(IndexVersion, forKey: indexVersionKey)
                userDefaults.synchronize()
            })
        }
    }
}
