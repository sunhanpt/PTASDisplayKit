//
//  _ASAsyncTransactionContainer.h
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/15.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#ifndef _ASAsyncTransactionContainer_h
#define _ASAsyncTransactionContainer_h

#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>


@class _ASAsyncTransaction;

typedef NS_ENUM(NSUInteger, ASAsyncTransactionContainerState) {
    ASAsyncTransactionContainerStateNoTransactions = 0,
    ASAsyncTransactionContainerStatePendingTransactions,
};

@protocol ASDisplayNodeAsyncTransactionContainer

/**
*  标记是否是container。YES：包含整个层级的异步渲染display指令。默认为NO。
*/
@property (nonatomic, assign, getter=asyncdisplaykit_isAsyncTransactionContainer, setter=asyncdisplaykit_setAsyncTransactionContainer:) BOOL asyncdisplaykit_asyncTransactionContainer;
/**
 *  状态标记，标记是否有正在执行的display，还是已经执行完或者已经取消。
 */
@property (nonatomic, readonly, assign) ASAsyncTransactionContainerState asyncdisplaykit_asyncTransactionContainerState;

/**
 *  取消所有的transactions
 */
- (void)asyncdisplaykit_cancelAsyncTransactions;

/**
 *  container的状态发生改变
 */
- (void)asyncdisplaykit_asyncTransactionContainerStateDidChange;

@end

/**
 *  layer的category，实现transactionContainer的功能
 */
@interface CALayer (ASDisplayNodeAsyncTransactionContainer) <ASDisplayNodeAsyncTransactionContainer>
/**
 *  返回当前的transaction。如果没有就创建。
 */
@property (nonatomic, readonly, retain) _ASAsyncTransaction *asyncdisplaykit_asyncTransaction;

/**
 *  返回asyncdisplaykit_isAsyncTransactionContainer=YES的最深的父节点
 */
@property (nonatomic, readonly, retain) CALayer *asyncdisplaykit_parentTransactionContainer;
@end

@interface CALayer (ASAsyncTransactionContainerTransactions)
/**
 *  储存所有的transaction
 */
@property (nonatomic, retain, setter=asyncdisplaykit_setAsyncLayerTransactions:) NSHashTable *asyncdisplaykit_asyncLayerTransactions;
/**
 *  当前transaction
 */
@property (nonatomic, retain, setter=asyncdisplaykit_setCurrentAsyncLayerTransaction:) _ASAsyncTransaction *asyncdisplaykit_currentAsyncLayerTransaction;
/**
 *  开始调用transaction
 *
 *  @param transaction 传入的事务
 */
- (void)asyncdisplaykit_asyncTransactionContainerWillBeginTransaction:(_ASAsyncTransaction *)transaction;
/**
 *  完成transaction
 *
 *  @param transaction 传入的transaction
 */
- (void)asyncdisplaykit_asyncTransactionContainerDidCompleteTransaction:(_ASAsyncTransaction *)transaction;
@end


#endif /* _ASAsyncTransactionContainer_h */
