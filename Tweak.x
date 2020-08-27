#import <objc/runtime.h>

@interface SPTPlaylistCosmosModel : NSObject
-(void)createPlaylistWithName:(NSString *)arg1 completion:(void (^)(NSURL *, NSError *))arg2;
-(void)synchronisePlaylistURL:(NSURL *)arg1;
-(id)initWithDictionaryDataLoader:(id)arg1 dataLoader:(id)arg2 timeGetter:(id)arg3;
-(void)trackURLsForPlaylistURL:(NSURL *)arg1 completion:(void (^)(NSArray *, NSError *))arg2;
-(void)addTrackURLs:(NSArray *)arg1 toPlaylistURL:(NSURL *)arg2 completion:(void (^)(NSError *))arg3;
- (void)modifyPlaylist:(id)arg1 withBodyDict:(id)arg2 completion:(id)arg3;
-(void)updatePhotoForPlaylistURL:(NSURL *)playlistURI withPhoto:(NSString *)arg2;
@end

@protocol SPTContextMenuAction <NSObject>
-(id)performAction;
-(NSString *)title;
@end

@interface SPTDuplicatePlaylistAction : NSObject <SPTContextMenuAction>
@property (retain, nonatomic) NSURL *playlistURIToDuplicate;
@property (retain, nonatomic) NSString *playlistTitle;
-(void)performAction;
-(NSString *)title;
@end

@interface SPTContextMenuHeaderView : UIView
@property(retain, nonatomic) UILabel *titleLabel;
@end

SPTPlaylistCosmosModel *cosmosModel;

%hook SPTPlaylistCosmosModel

-(SPTPlaylistCosmosModel *)initWithDictionaryDataLoader:(id)arg1 dataLoader:(id)arg2 timeGetter:(id)arg3 {
	return (cosmosModel = %orig);
}

%end


@implementation SPTDuplicatePlaylistAction

-(void)performAction {
	[cosmosModel createPlaylistWithName:[NSString stringWithFormat:@"%@ copy", self.playlistTitle] completion:^(NSURL *newPlaylistURI, id a2) {
		[cosmosModel trackURLsForPlaylistURL:self.playlistURIToDuplicate completion:^(NSArray *tracks, NSError *err) {
			[cosmosModel addTrackURLs:tracks toPlaylistURL:newPlaylistURI completion:^(NSError *err) {
				[cosmosModel synchronisePlaylistURL:newPlaylistURI];
			}];
		}];
	}];
}

-(NSString *)title {
	return @"Duplicate playlist";
}

@end


%hook SPTContextMenuViewController

- (SPTContextMenuViewController *)initWithHeaderImageURL:(id)arg1 actions:(id)arg2 entityURL:(id)arg3 imageLoader:(id)arg4 headerView:(SPTContextMenuHeaderView *)arg5 modalPresentationController:(id)arg6 options:(id)arg7 theme:(id)arg8 notificationCenter:(id)arg9 {
	NSMutableArray *newActions = [arg2 mutableCopy];
	SPTDuplicatePlaylistAction *duplicatePlaylistAction = [[objc_getClass("SPTDuplicatePlaylistAction") alloc] init];
	duplicatePlaylistAction.playlistURIToDuplicate = arg3;
	duplicatePlaylistAction.playlistTitle = arg5.titleLabel.text;
	[newActions addObject:duplicatePlaylistAction];
	arg2 = newActions;
	return %orig;
}

%end
