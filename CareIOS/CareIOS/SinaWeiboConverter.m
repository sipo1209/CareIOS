//
//  SinaWeiboConverter.m
//  CareIOS
//
//  Created by 谢 创 on 12-12-3.
//  Copyright (c) 2012年 ThankCreate. All rights reserved.
//

#import "SinaWeiboConverter.h"
#import "ItemViewModel.h"
#import "PictureItemViewModel.h"
#import "MiscTool.h"
#import "MainViewModel.h"
#import "CommentViewModel.h"
#import "FriendViewModel.h"
@implementation SinaWeiboConverter

+(FriendViewModel*) convertFrendToCommon:(id)friend
{
    FriendViewModel* model = [[FriendViewModel alloc] init];
    @try {
        model.name =[friend objectForKey:@"screen_name"];
        model.description =[friend objectForKey:@"description"];
        model.avatar =[friend objectForKey:@"profile_image_url"];
        model.avatar2 =[friend objectForKey:@"avatar_large"];
        model.ID =[[friend objectForKey:@"id"] stringValue];
    }
    @catch (NSException *exception) {
        model = nil;
    }
    @finally {
        return model;
    }
}

+(CommentViewModel*) convertCommentToCommon:(id)comment
{
    CommentViewModel* model = [[CommentViewModel alloc] init];
    @try {
        id user = [comment objectForKey:@"user"];
        if(user == nil)
            return nil;
        model.title = [user objectForKey:@"name"];
        model.iconURL = [user objectForKey:@"profile_image_url"];
        model.uid = [[user objectForKey:@"id"] stringValue];
        model.content = [comment objectForKey:@"text"];
        model.ID = [[comment objectForKey:@"id"] stringValue];
        id rawTime = [comment objectForKey:@"created_at"];
        model.time = [self convertSinaWeiboDateStringToDate:rawTime];
        model.type = EntryType_SinaWeibo;
    }
    @catch (NSException *exception) {
        model = nil;
    }
    @finally {
        return model;
    }
}

+(ItemViewModel*) convertStatusToCommon:(id)status 
{
    ItemViewModel* model = [[ItemViewModel alloc] init];
    @try {
        // 先做图片过滤
        [self convertPictureToCommon:status];
        
        id user = [status objectForKey:@"user"];
        if(user == nil)
            return nil;
        
        model.iconURL = [user objectForKey:@"profile_image_url"];
        model.largeIconURL = [user objectForKey:@"avatar_large"];
        model.title = [user objectForKey:@"name"];
        model.content = [status objectForKey:@"text"];
        // TODO: confirm gif format can show well
        model.imageURL = [status objectForKey:@"thumbnail_pic"];
        model.midImageURL = [status objectForKey:@"bmiddle_pic"];
        model.fullImageURL = [status objectForKey:@"original_pic"];
        
        id rawTime = [status objectForKey:@"created_at"];
        model.time = [self convertSinaWeiboDateStringToDate:rawTime];
        
        model.ID = [[status objectForKey:@"id"] stringValue];
        model.type = EntryType_SinaWeibo;
        model.sharedCount = [[status objectForKey:@"reposts_count"] stringValue];
        model.commentCount = [[status objectForKey:@"comments_count"] stringValue];
        
        id forward = [status objectForKey:@"retweeted_status"];
        if(forward != nil)
        {
            model.forwardItem = [[ItemViewModel alloc] init];
            id forwardUser = [forward objectForKey:@"user"];
            if(user == nil)
                return nil;
            model.forwardItem.iconURL = [forwardUser objectForKey:@"profile_image_url"];
            model.forwardItem.largeIconURL = [forwardUser objectForKey:@"avatar_large"];
            model.forwardItem.title = [forwardUser objectForKey:@"name"];
            model.forwardItem.content = [forward objectForKey:@"text"];
            // TODO: confirm gif format can show well
            model.forwardItem.imageURL = [forward objectForKey:@"thumbnail_pic"];
            model.forwardItem.midImageURL = [forward objectForKey:@"bmiddle_pic"];
            model.forwardItem.fullImageURL = [forward objectForKey:@"original_pic"];
            model.forwardItem.time = [self convertSinaWeiboDateStringToDate:[forward objectForKey:@"created_at"]];
            model.forwardItem.ID = [[forward objectForKey:@"id"] stringValue];
            model.forwardItem.type = EntryType_SinaWeibo;
            model.forwardItem.sharedCount = [[forward objectForKey:@"reposts_count"] stringValue];
            model.forwardItem.commentCount = [[forward objectForKey:@"comments_count"] stringValue];
        }
    }
    @catch (NSException *exception) {
        model = nil;
    }
    @finally {
        return model;
    }
}

+(void) convertPictureToCommon:(id)status
{
    PictureItemViewModel* model = [[PictureItemViewModel alloc] init];
    model.size = CGSizeZero;
    if(status == nil)
        return;
    @try {
        // 先判断是否有转发图片
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString* useFowardPicture = [defaults objectForKey:@"Global_NeedFetchImageInRetweet"];
        if(useFowardPicture == nil || [useFowardPicture compare:@"YES"] == NSOrderedSame)
        {
            id forward = [status objectForKey:@"retweeted_status"];
            if(forward != nil)
            {
                // 这里之所以重新又变得这么冗余了，是因为用户还是觉得转发图里还是要有本人的评论
                // 修改了description的显示方式  2012/1/13
                PictureItemViewModel* forwardModel = [[PictureItemViewModel alloc] init];
                id forwardUser = [forward objectForKey:@"user"];
                if(forwardUser != nil)
                {
                    forwardModel.title = [forwardUser objectForKey:@"name"];
                }
                forwardModel.size = CGSizeZero;
                forwardModel.smallURL = [forward objectForKey:@"thumbnail_pic"];
                forwardModel.middleURL = [forward objectForKey:@"bmiddle_pic"];
                forwardModel.largeURL = [forward objectForKey:@"original_pic"];
                forwardModel.ID = [forward objectForKey:@"id"];
                forwardModel.description = [NSString stringWithFormat:@"%@//@%@: %@",
                    [status objectForKey:@"text"],
                    [forwardUser objectForKey:@"name"],
                    [forward objectForKey:@"text"]];
                forwardModel.type = EntryType_SinaWeibo;
                 // 这个时间应该是转发的时间
                id rawTime = [status objectForKey:@"created_at"];
                forwardModel.time = [self convertSinaWeiboDateStringToDate:rawTime];
                
                if(forwardModel.smallURL.length)
                {
                    [[MainViewModel sharedInstance].sinaWeiboPictureItems addObject:forwardModel];
                }            
            }
        }
        model.smallURL = [status objectForKey:@"thumbnail_pic"];
        model.middleURL = [status objectForKey:@"bmiddle_pic"];
        model.largeURL = [status objectForKey:@"original_pic"];
        model.ID = [status objectForKey:@"id"];
        model.description = [status objectForKey:@"text"];
        id rawTime = [status objectForKey:@"created_at"];
        model.time = [self convertSinaWeiboDateStringToDate:rawTime];
        model.type = EntryType_SinaWeibo;
        
        
        id user = [status objectForKey:@"user"];
        if(user != nil)
        {
            model.title = [user objectForKey:@"name"];;
        }
        if(model.smallURL.length)
        {
            [[MainViewModel sharedInstance].sinaWeiboPictureItems addObject:model];
        }
    }
    @catch (NSException *exception) {
        model = nil;
    }
    @finally {
        return;
    }
    
}


// 新浪的祼格式是这样的
// Fri Oct 05 11:38:16 +0800 2012
+ (NSDate*) convertSinaWeiboDateStringToDate:(NSString*) plainDate
{    
    if(plainDate == nil)
        return [NSDate date];
    
    NSDate *date = nil;
    @try
    {
        //plainDate = @"Mon Nov 26 00:17:07 2012";
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss zzz yyyy"];
        date=[dateFormatter dateFromString:plainDate];        
    }
    @catch (NSException *exception)
    {
        date = [NSDate date];
    }
    @finally
    {
        if(date == nil)
            date = [NSDate date];
        return date;
    }
}

@end
