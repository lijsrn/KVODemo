//
//  Person.h
//  KVODemo
//
//  Created by JH on 2019/8/26.
//  Copyright © 2019 JH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

@property(nonatomic,strong) NSString *name;

@property(nonatomic,assign) BOOL selected;

@end

NS_ASSUME_NONNULL_END
