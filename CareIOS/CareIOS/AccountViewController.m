//
//  AccountViewController.m
//  CareIOS
//
//  Created by 谢 创 on 12-12-1.
//  Copyright (c) 2012年 ThankCreate. All rights reserved.
//

#import "AccountViewController.h"
#import "CareAppDelegate.h"

@interface AccountViewController ()
@property (strong, nonatomic) IBOutlet UILabel *lblSinaWeiboName;
@property (strong, nonatomic) IBOutlet UILabel *lblSinaWeiboFollowerName;
@property (strong, nonatomic) IBOutlet UITableView *table;

@end

@implementation AccountViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    [self initUISinaWeibo];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)initUISinaWeibo
{
    SinaWeibo* sinaweibo = [self sinaweibo];
    sinaweibo.delegate = self;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* name = [defaults objectForKey:@"SinaWeibo_NickName"];
    if(name != nil)
    {
        self.lblSinaWeiboName.text = name;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger sec = [indexPath section];
    NSInteger row = [indexPath row];
    // 新浪区
    if(sec ==0)
    {
        // 登陆
        if(row == 0)
        {
            SinaWeibo *sinaweibo = [self sinaweibo];
            [sinaweibo logIn];
        }
    }
    // 人人区
    else if (sec == 1)
    {
        
    }
    // 豆瓣区
    else if (sec == 2)
    {
        
    }
    
    
    // 清除选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    
    // Navigation logic may go here. Create and push another view controller.
    /*
    ￼ *detailViewController = [[￼ alloc] initWithNibName:@"￼" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    */
}





#pragma mark - SinaWeibo Delegate

- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:sinaweibo.userID forKey:@"SinaWeibo_ID"];
    [defaults setValue:sinaweibo.accessToken forKey:@"SinaWeibo_Token"];
    [defaults setValue:sinaweibo.expirationDate forKey:@"SinaWeibo_ExpirationDate"];
    [self sinaweiboRefreshUserInfo];
    NSLog(@"sinaweiboDidLogIn userID = %@ accesstoken = %@ expirationDate = %@ refresh_token = %@", sinaweibo.userID, sinaweibo.accessToken, sinaweibo.expirationDate,sinaweibo.refreshToken);
    

}

#pragma mark - SinaWeiboRequest Delegate 
- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    if ([request.url hasSuffix:@"users/show.json"])
    {
        NSDictionary* dic = result;
        NSString *name = [dic objectForKey:@"screen_name"];        
        NSString *avatar = [dic objectForKey:@"profile_image_url"];
        
        // 存到本地
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:name forKey:@"SinaWeibo_NickName"];
        [defaults setValue:avatar forKey:@"SinaWeibo_Avatar"];
        [defaults synchronize];
        
        // 设置标签
        self.lblSinaWeiboName.text = name;
        [self.lblSinaWeiboName sizeToFit];
        
    }
}

#pragma mark - SinaWeibo Logic

- (SinaWeibo *)sinaweibo
{
    CareAppDelegate *delegate = (CareAppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.sinaweibo;
}


- (void)sinaweiboRefreshUserInfo
{
    SinaWeibo *sinaweibo = [self sinaweibo];
    [sinaweibo requestWithURL:@"users/show.json"
                       params:[NSMutableDictionary dictionaryWithObject:sinaweibo.userID forKey:@"uid"]
                   httpMethod:@"GET"
                     delegate:self];
}
@end