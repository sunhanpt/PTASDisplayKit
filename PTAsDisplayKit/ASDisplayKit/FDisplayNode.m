//
//  FDisplayNode.m
//  PTAsDisplayKit
//
//  Created by 净枫 on 15/12/24.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#import "FDisplayNode.h"
#import <UIKit/UIKit.h>
#import "_FDisplayLayer.h"
#import "FDisplayNodeInternal.h"
#import "ASAssert.h"


@implementation FDisplayNode

CGFloat FDisplayNodeScreenScale()
{
    static CGFloat screenScale = 0.0;
    static dispatch_once_t onceToken;
    FDispatchOnceOnMainThread(&onceToken, ^{
        screenScale = [[UIScreen mainScreen] scale];
    });
    return screenScale;
}

static void FDispatchOnceOnMainThread(dispatch_once_t *predicate, dispatch_block_t block)
{
    if ([NSThread isMainThread]) {
        dispatch_once(predicate, block);
    } else {
        if (DISPATCH_EXPECT(*predicate == 0L, NO)) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                dispatch_once(predicate, block);
            });
        }
    }
}

static bool FDisplayNodeThreadIsMain(){
    return [NSThread isMainThread];
}

void FDisplayNodePerformBlockOnMainThread(void (^block)())
{
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    }
}




+ (Class)layerClass{
    return [_FDisplayLayer class];
}

- (id)init{
    if(self = [super init]){
        _contentsScale = FDisplayNodeScreenScale();
        _displaySentinel = [[ASSentinel alloc]init];
        _flags.displaysAsynchronously = YES;
        _layerBacked = YES ;
        
        _flags.implementsDrawRect = ([[self class] respondsToSelector:@selector(drawRect:withParameters:isCancelled:isRasterizing:)] ? 1 : 0);
        _flags.implementsImageDisplay = ([[self class] respondsToSelector:@selector(displayWithParameters:isCancelled:)] ? 1 : 0);
        _flags.implementsDrawParameters = ([self respondsToSelector:@selector(drawParametersForAsyncLayer:)] ? 1 : 0);
    }
    return self ;
}


- (CALayer *)_layerToLoad{
    CALayer *layer ;
    if(!_layerClass){
        _layerClass = [self.class layerClass];
    }
    layer = [[_layerClass alloc] init] ;
    return layer ;
}

//现在暂时用layer ，所以这里传入的都是YES
- (void)_loadViewOrLayerIsLayerBacked:(BOOL)isLayerBacked{
    
    //todo :_isDeallocating  and __shouldLoadViewOrLayer
    
    if(isLayerBacked){
        _layer = [self _layerToLoad];
        _layer.delegate = self ;
    }
    _layer.asyncdisplaykit_node = self ;
    self.asyncLayer.asyncDelegate = self ;
    
    //_applyPendingStateToViewOrLayer
    {
        [self _addSubnodeLayers];
    }
    {
        [self didLoadLayer];
    }
    
    
}




- (void)setNeedsDisplay{
    
}
- (void)setNeedsLayout{
    
}

- (BOOL)_shouldSize
{
    return YES;
}

- (CGSize)measure:(CGSize)constrainedSize{
    
    return [self _measure:constrainedSize] ;
}

//计算过程
- (CGSize)_measure:(CGSize)constrainedSize{
    //node在主线程
    ASDisplayNodeAssertMainThread();
    if(![self _shouldSize]){
        return CGSizeZero ;
    }
    
    if(!_flags.isMeasured || !CGSizeEqualToSize(constrainedSize, _constrainedSize)) {
        _size = [self calculateSizeThatFits:constrainedSize];
        _constrainedSize = constrainedSize ;
        _flags.isMeasured = YES ;
    }
    
    ASDisplayNodeAssertTrue(_size.width >= 0.0);
    ASDisplayNodeAssertTrue(_size.height >= 0.0);
    return _size ;
    
}




#pragma mark - for subclass
- (CGSize)calculateSizeThatFits:(CGSize)constrainedSize
{
    ASDisplayNodeAssertMainThread();
    return CGSizeZero;
}

- (void)didLoadLayer{
    ASDisplayNodeAssertMainThread();
    
}

- (void)layout{
    ASDisplayNodeAssertMainThread();
}

- (void)layoutDidFinish{

}

- (void)displayWillStart{
    [self _pendingNodeWillDisplay:self];
    [_supernode subnodeDisplayWillStart:self];
    //如果要加 placeHodler，可以在这里加

}

- (void)displayDidFinish{
    [self _pendingNodeDidDisplay:self];
    [_supernode subnodeDisplayDidFinish:self];

    //如果要加 placeHodler，可以在这里加
}

- (void)invalidateCalculatedSize{
    ASDisplayNodeAssertMainThread();
    _flags.isMeasured = NO ;
}

- (void)clearContents{
    self.layer.contents = nil ;
}

#pragma mark setter and getter
- (CALayer *)layer{
    if(!_layer){
        
        [self _loadViewOrLayerIsLayerBacked:YES];
    }
    return _layer ;
}

- (_FDisplayLayer *)asyncLayer{
    return [_layer isKindOfClass:[_FDisplayLayer class]]?(_FDisplayLayer *)_layer :nil ;
}

- (BOOL)isNodeLoaded{
    return self.layerBacked && _layer!=nil ;
}

- (BOOL)displaysAsynchronously{
    return _flags.displaysAsynchronously ;
}

- (void)setDisplaysAsynchronously:(BOOL)displaysAsynchronously{
    ASDisplayNodeAssertMainThread() ;
    if(_flags.displaysAsynchronously == displaysAsynchronously) return ;
    
    _flags.displaysAsynchronously = displaysAsynchronously ;
    self.asyncLayer.displaysAsyncChronously = displaysAsynchronously ;
}

- (BOOL)shouldRasterizeDescendants{
    ASDisplayNodeAssertMainThread() ;
    return _flags.shouldRasterizeDescendants ;
}

- (void)setShouldRasterizeDescendants:(BOOL)shouldRasterizeDescendants{
    ASDisplayNodeAssertMainThread() ;
    if(_flags.shouldRasterizeDescendants == shouldRasterizeDescendants) return ;
    
    _flags.shouldRasterizeDescendants = shouldRasterizeDescendants ;
}

- (CGFloat)contentsScale{
    ASDisplayNodeAssertMainThread() ;
    return _contentsScale ;
}

- (void)setContentsScale:(CGFloat)contentsScale{
    ASDisplayNodeAssertMainThread() ;

    if(_contentsScale == contentsScale) return ;
    
    _contentsScale = contentsScale ;
}

- (BOOL)displaySuspended{
    ASDisplayNodeAssertMainThread() ;

    return _flags.displaySuspended ;
}

- (void)setDisplaySuspended:(BOOL)flag{
    ASDisplayNodeAssertMainThread() ;
    if (_flags.displaySuspended == flag)
        return;
    
    _flags.displaySuspended = flag;
    
    self.asyncLayer.displaySuspended = flag;
    
    if ([self _implementsDisplay]) {
        if (flag) {
            [_supernode subnodeDisplayDidFinish:self];
        } else {
            [_supernode subnodeDisplayWillStart:self];
        }
    }

}


#pragma mark - realize

- (void)displayImmediately{
    ASDisplayNodeAssertMainThread() ;
    [[self asyncLayer] displayImmediately];
}

- (void)_layout{
    ASDisplayNodeAssertMainThread() ;
    if (CGRectEqualToRect(_layer.bounds, CGRectZero)) {
        return;
    }
    [self layout];
    [self layoutDidFinish];
}

- (void)recursivelySetDisplaySuspended:(BOOL)flag{
    
}


- (void)recursivelyClearContents{
    
}


- (void)recursivelyClearFetchedData{
    
}

- (void)recursivelyFetchData{
    
}

#pragma mark node tree 操作

static bool disableNotificationsForMovingBetweenParents(FDisplayNode *from, FDisplayNode *to){
    if(!from || !to) return NO ;
    
    return YES ;
}


- (void)addSubnode:(FDisplayNode *)subnode{
    ASDisplayNodeAssertMainThread();
    
    FDisplayNode *oldParent =  subnode.supernode ;
    if(!subnode || subnode == self || oldParent == self){
        return ;
    }
    //先不进行这种操作
   // BOOL isMovingEquivalentParents = disableNotificationsForMovingBetweenParents(oldParent, self);
    
    [subnode removeFromSupernode];
    if(!_subnodes){
        _subnodes = [[NSMutableArray alloc] init];
    }
    [_subnodes addObject:subnode];
    if(self.nodeLoaded){
        if (FDisplayNodeThreadIsMain()) {
            [self _addSubnodeSublayer:subnode];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self _addSubnodeSublayer:subnode];
            });
        }
    }
    [subnode _setSupernode:self];
}

- (void)_insertSubnode:(FDisplayNode *)subnode atSubnodeIndex:(NSInteger)subnodeIndex sublayerIndex:(NSInteger)sublayerIndex andRemoveSubnode:(FDisplayNode *)oldSubnode{
    if (subnodeIndex == NSNotFound)
        return;
    
    [subnode removeFromSupernode];
    if (!_subnodes)
        _subnodes = [[NSMutableArray alloc] init];
    
    [oldSubnode removeFromSupernode];
    [_subnodes insertObject:subnode atIndex:subnodeIndex];
 
    if (!_flags.shouldRasterizeDescendants && ![self __rasterizedContainerNode]) {
        if (_layer) {
            ASDisplayNodeAssertMainThread();
            ASDisplayNodeAssert(sublayerIndex != NSNotFound, @"Should pass either a valid sublayerIndex");

            if (sublayerIndex != NSNotFound) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wconversion"
                [_layer insertSublayer:subnode.layer atIndex:sublayerIndex];
#pragma clang diagnostic pop
            }
        }
    
    }
    
    [subnode _setSupernode:self];

}

- (void)insertSubnode:(FDisplayNode *)subnode belowSubnode:(FDisplayNode *)below{
    ASDisplayNodeAssertMainThread();
    if(!subnode){
        return ;
    }
    
    if([below _deallocSafeSupernode]!= self){
        return ;
    }
    
    ASDisplayNodeAssert(_subnodes, @"You should have subnodes if you have a subnode");
    NSInteger belowSubnodeIndex = [_subnodes indexOfObjectIdenticalTo:below];
    NSInteger belowSublayerIndex = NSNotFound;
    if (_layer) {
        belowSublayerIndex = [_layer.sublayers indexOfObjectIdenticalTo:below.layer];
        ASDisplayNodeAssert(belowSublayerIndex != NSNotFound, @"Somehow below's supernode is self, yet we could not find it in our layers to reference");
        if (belowSublayerIndex == NSNotFound)
            return;
    }
    
    if ([subnode _deallocSafeSupernode] == self) {
        NSInteger currentIndexInSubnodes = [_subnodes indexOfObjectIdenticalTo:subnode];
        if (currentIndexInSubnodes < belowSubnodeIndex) {
            belowSubnodeIndex--;
        }
        if (_layer) {
            NSInteger currentIndexInSublayers = [_layer.sublayers indexOfObjectIdenticalTo:subnode.layer];
            if (currentIndexInSublayers < belowSublayerIndex) {
                belowSublayerIndex--;
            }
        }
    }
    [self _insertSubnode:subnode atSubnodeIndex:belowSubnodeIndex sublayerIndex:belowSublayerIndex andRemoveSubnode:nil];

}

- (void)insertSubnode:(FDisplayNode *)subnode aboveSubnode:(FDisplayNode *)above{
    ASDisplayNodeAssertMainThread();
    if (!subnode)
        return;
    
    ASDisplayNodeAssert([above _deallocSafeSupernode] == self, @"Node to insert above must be a subnode");
    if ([above _deallocSafeSupernode] != self)
        return;
    
    ASDisplayNodeAssert(_subnodes, @"You should have subnodes if you have a subnode");
    NSInteger aboveSubnodeIndex = [_subnodes indexOfObjectIdenticalTo:above];
    NSInteger aboveSublayerIndex = NSNotFound;
    if (!_flags.shouldRasterizeDescendants && ![self __rasterizedContainerNode]) {
        if (_layer) {
            aboveSublayerIndex = [_layer.sublayers indexOfObjectIdenticalTo:above.layer];
            ASDisplayNodeAssert(aboveSublayerIndex != NSNotFound, @"Somehow above's supernode is self, yet we could not find it in our layers to replace");
            if (aboveSublayerIndex == NSNotFound)
                return;
        }
        ASDisplayNodeAssert(aboveSubnodeIndex != NSNotFound, @"Couldn't find above in subnodes");
        
        // If the subnode is already in the subnodes array / sublayers and it's before the below node, removing it to insert it will mess up our calculation
        if ([subnode _deallocSafeSupernode] == self) {
            NSInteger currentIndexInSubnodes = [_subnodes indexOfObjectIdenticalTo:subnode];
            if (currentIndexInSubnodes <= aboveSubnodeIndex) {
                aboveSubnodeIndex--;
            }
            if (_layer) {
                NSInteger currentIndexInSublayers = [_layer.sublayers indexOfObjectIdenticalTo:subnode.layer];
                if (currentIndexInSublayers <= aboveSublayerIndex) {
                    aboveSublayerIndex--;
                }
            }
        }
    }
    [self _insertSubnode:subnode atSubnodeIndex:incrementIfFound(aboveSubnodeIndex) sublayerIndex:incrementIfFound(aboveSublayerIndex) andRemoveSubnode:nil];


}

- (void)insertSubnode:(FDisplayNode *)subnode atIndex:(NSInteger)idx{
    ASDisplayNodeAssertMainThread();
    if (idx > _subnodes.count || idx < 0) {
        NSString *reason = [NSString stringWithFormat:@"Cannot insert a subnode at index %zd. Count is %zd", idx, _subnodes.count];
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
    }
    
    NSInteger sublayerIndex = NSNotFound;
    // Account for potentially having other subviews
    if (_layer && idx == 0) {
        sublayerIndex = 0;
    } else if (_layer) {
        FDisplayNode *positionInRelationTo = (_subnodes.count > 0 && idx > 0) ? _subnodes[idx - 1] : nil;
        if (positionInRelationTo) {
            sublayerIndex = incrementIfFound([_layer.sublayers indexOfObjectIdenticalTo:positionInRelationTo.layer]);
        }
    }
    [self _insertSubnode:subnode atSubnodeIndex:idx sublayerIndex:sublayerIndex andRemoveSubnode:nil];

}

- (void)replaceSubnode:(FDisplayNode *)oldSubnode withSubnode:(FDisplayNode *)replacementSubnode{
    ASDisplayNodeAssertMainThread();
    if (!replacementSubnode || [oldSubnode _deallocSafeSupernode] != self) {
        ASDisplayNodeAssert(0, @"Bad use of api. Invalid subnode to replace async.");
        return;
    }
    
    ASDisplayNodeAssert(!(self.nodeLoaded && !oldSubnode.nodeLoaded), @"ASDisplayNode corruption bug. We have view loaded, but child node does not.");
    ASDisplayNodeAssert(_subnodes, @"You should have subnodes if you have a subnode");
    
    NSInteger subnodeIndex = [_subnodes indexOfObjectIdenticalTo:oldSubnode];
    NSInteger sublayerIndex = NSNotFound;
    
    if (_layer) {
        sublayerIndex = [_layer.sublayers indexOfObjectIdenticalTo:oldSubnode.layer];
        ASDisplayNodeAssert(sublayerIndex != NSNotFound, @"Somehow oldSubnode's supernode is self, yet we could not find it in our layers to replace");
        if (sublayerIndex == NSNotFound) return;
    }
    
    [self _insertSubnode:replacementSubnode atSubnodeIndex:subnodeIndex sublayerIndex:sublayerIndex andRemoveSubnode:oldSubnode];

}

- (void)_removeSubnode:(FDisplayNode *)subnode{
    ASDisplayNodeAssertMainThread();
    if (!subnode || [subnode _deallocSafeSupernode] != self)
        return;
    
    [_subnodes removeObjectIdenticalTo:subnode];
    
    [subnode _setSupernode:nil];
}

- (void)removeFromSupernode{
    if (!_supernode)
        return;
    [_supernode _removeSubnode:self];
    if (FDisplayNodeThreadIsMain()) {
            [_layer removeFromSuperlayer];
        
     } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_layer removeFromSuperlayer];
        });
    }

}


- (void)_addSubnodeSublayer:(FDisplayNode *)subnode{
    if(self.isLayerBacked && subnode.isLayerBacked){
        [_layer addSublayer:subnode.layer];
    }
}


- (void)_addSubnodeLayers{
    ASDisplayNodeAssertMainThread();
    
    for (FDisplayNode *node in [_subnodes copy]) {
        [self _addSubnodeSublayer:node];
    }
}

- (FDisplayNode *)_deallocSafeSupernode
{
    return _supernode;
}

- (void)_setSupernode:(FDisplayNode *)supernode{
    _supernode = supernode ;
}


#pragma mark -_FDisplayLayerDelegate

- (void)willDisplayAsyncLayer:(_FDisplayLayer *)layer{
    
}

- (void)didDisplayAsyncLayer:(_FDisplayLayer *)layer{
    
}


#pragma mark - other
- (void)_pendingNodeWillDisplay:(FDisplayNode *)node{
    if (!_pendingDisplayNodes) {
        _pendingDisplayNodes = [[NSMutableSet alloc] init];
    }
    
    [_pendingDisplayNodes addObject:node];
}

- (void)_pendingNodeDidDisplay:(FDisplayNode *)node{
    [_pendingDisplayNodes removeObject:node];

}

- (void)subnodeDisplayWillStart:(FDisplayNode *)subnode
{
    [self _pendingNodeWillDisplay:subnode];
}

- (void)subnodeDisplayDidFinish:(FDisplayNode *)subnode
{
    [self _pendingNodeDidDisplay:subnode];
}

- (BOOL)_implementsDisplay
{
    return _flags.implementsDrawRect == YES || _flags.implementsImageDisplay == YES;
}

- (FDisplayNode *)__rasterizedContainerNode
{
    FDisplayNode *node = self.supernode;
    while (node) {
        if (node.shouldRasterizeDescendants) {
            return node;
        }
        node = node.supernode;
    }
    
    return nil;
}

static NSInteger incrementIfFound(NSInteger i) {
    return i == NSNotFound ? NSNotFound : i + 1;
}

#pragma mark - lifttime
- (void)dealloc{
    self.asyncLayer.asyncDelegate = nil ;
    _layer.asyncdisplaykit_node = nil ;
    for(FDisplayNode *subNode in _subnodes){
        [subNode _setSupernode:nil];
    }
    
    _subnodes = nil ;
    _layer = nil ;
    [self _setSupernode:nil];
    _displaySentinel = nil ;
    
}


@end

@implementation CALayer (FDisplayKit)

- (void)addSubnode:(FDisplayNode *)node
{
    [self addSublayer:node.layer];
}

@end
