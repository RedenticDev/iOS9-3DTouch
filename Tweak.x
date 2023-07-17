#import <UIKit/UIKit.h>

@interface _UIVisualEffectBackdropView : UIView
-(UIView *)superview;
-(void)setAlpha:(double)arg1;
@end

@interface UIInterfaceActionRepresentationView
-(UIView *)superview;
@end

@interface SBSApplicationShortcutItem : NSObject
@property (nonatomic, retain) NSString *type;
@end

@interface _UIContextMenuActionView : UIView
-(UIView *)superview;
@end

%hook _UIVisualEffectBackdropView

-(void)willMoveToWindow:(id)arg1 {
    %orig;
    if (@available(iOS 14.0, *)) {
        if ([self.superview.superview isMemberOfClass:%c(_UIElasticContextMenuBackgroundView)]) {
            [self setAlpha:0.75];
            NSLog(@"[iOS 9] Alpha reduced for iOS 14");
        }
    } else {
        if ([self.superview.superview.superview isMemberOfClass:%c(UIInterfaceActionGroupView)]) {
            [self setAlpha:0.75];
            NSLog(@"[iOS 9] Alpha reduced for iOS 13");
        }
    }
}

%end

%hook SBIconView

-(NSArray *)applicationShortcutItems {
    NSArray *previous = %orig;
    NSMutableArray *newItems = [[NSMutableArray alloc] init];
    if (@available(iOS 14.0, *)) { // they fixed their typo lol
        for (SBSApplicationShortcutItem *item in previous) {
            if (![item.type isEqual:@"com.apple.springboardhome.application-shortcut-item.remove-app"]
                && ![item.type isEqual:@"com.apple.springboardhome.application-shortcut-item.share"]
                && ![item.type isEqual:@"com.apple.springboardhome.application-shortcut-item.rearrange-icons"]
                && ![item.type isEqual:@"com.apple.SpringBoardServices.application-shortcut-item-type.send-beta-feedback"]) {
                [newItems addObject:item];
            }
        }
    } else {
        for (SBSApplicationShortcutItem *item in previous) {
            if (![item.type isEqual:@"com.apple.springboardhome.application-shotcut-item.delete-app"]
                && ![item.type isEqual:@"com.apple.springboardhome.application-shortcut-item.share"]
                && ![item.type isEqual:@"com.apple.springboardhome.application-shotcut-item.rearrange-icons"]
                && ![item.type isEqual:@"com.apple.SpringBoardServices.application-shortcut-item-type.send-beta-feedback"]) {
                [newItems addObject:item];
            }
        }
    }
    NSLog(@"[iOS 9] Items removed: previous count %lu, now %lu", previous.count, newItems.count);
    return newItems;
}

%end

%hook UIInterfaceActionRepresentationView // iOS 13 only

-(CGSize)intrinsicContentSize {
    CGSize cellSize = %orig;
    if ([self.superview.superview.superview.superview.superview isMemberOfClass:%c(UIInterfaceActionGroupView)]) {
        NSLog(@"[iOS 9] Minimum cell height increased to 60 for iOS 13");
        return CGSizeMake(cellSize.width, cellSize.height < 45 ? 60 : cellSize.height); // Original iOS 9 height?
    }
    return cellSize;
}

%end

%hook _UIContextMenuActionsListCell

-(CGSize)intrinsicContentSize {
    CGSize cellSize = %orig;
    if (cellSize.height < 45) {
        NSLog(@"[iOS 9] Minimum cell height increased to 60 for iOS 14");
        return CGSizeMake(cellSize.width, 60); // Original iOS 9 height?
    }
    return cellSize;
}

-(CGRect)frame {
    for (NSLayoutConstraint *constraint in ((UIView *)self).constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            constraint.constant = 60;
            break;
        }
    }
    return %orig;
}

%end

// %hook _UIContextMenuActionView

// -(UILabel *)titleLabel {
//     UILabel *title = %orig;
//     NSLog(@"[iOS 9] Title font size changed");
//     title.font = [UIFont systemFontOfSize:title.font.pointSize + 1];
//     return title;
// }

// -(UILabel *)subtitleLabel {
//     UILabel *sub = %orig;
//     NSLog(@"[iOS 9] Subtitle font size changed");
//     sub.font = [UIFont systemFontOfSize:sub.font.pointSize + 1];
//     return sub;
// }

// %end

%hook _UIInterfaceActionBlankSeparatorView

-(id)init {
    NSLog(@"[iOS 9] Bold separator line detected and removed");
    return nil;
}

%end

%hook SBHHomeScreenSettings // iOS 13 only

-(BOOL)showWidgets {
    NSLog(@"[iOS 9] 3D Touch widget removed");
	return NO;
}

%end
