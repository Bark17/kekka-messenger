//
//  AuthSession.m
//  MessengerApp
//
//  Created by Vlad on 10.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import "AuthSession.h"
#import "User.h"
#import "UserMO+CoreDataClass.h"
#import "AppDelegate.h"
@import FirebaseAuth;

@implementation AuthSession


#pragma mark - Current user session singleton
+ (instancetype)currentSession {
    static AuthSession *current = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        current = [[AuthSession alloc] init];
    });
    return current;
}


#pragma mark - Initalization
- (instancetype)init {
    self = [super init];
    if (self) {
        self.user = [User new];
        FIRUser *currentUser = [[FIRAuth auth] currentUser];
        if (currentUser) {
            User *fetchedUser = [self fetchCurrentUserWithUid:currentUser.uid];
            if (fetchedUser) {
                self.user = fetchedUser;
            }
            self.user.uid = currentUser.uid;
        }
    }
    return self;
}

- (void)configureWithUser:(User *)user {
    [self deleteCoreDataEntries];
    User *currentUser = self.user;
    currentUser.uid = user.uid;
    currentUser.name = user.name;
    currentUser.email = user.email;
    currentUser.phoneNumber = user.phoneNumber;
    currentUser.avatarURL = user.avatarURL;
    NSLog(@"Configuring");
    [self saveCurrentUser];
}

#pragma mark - For testing 
- (void)deleteCoreDataEntries {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    NSError *deleteError = nil;
    [context executeRequest:delete error:&deleteError];
}

- (void)saveCurrentUser {
    if (!self.isValid) {
        return;
    }
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    UserMO *currentUserMO = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    currentUserMO.uid = self.user.uid;
    currentUserMO.name = self.user.name;
    currentUserMO.email = self.user.email;
    currentUserMO.phoneNumber = self.user.phoneNumber;
    if (self.user.avatarURL) {
        currentUserMO.avatarUrlString = [self.user.avatarURL absoluteString];
    }
    NSError *saveError = nil;
    [context save:&saveError];
    NSLog(@"Save completed; Error: %@", saveError.localizedDescription);
}

- (void)updateAvatarURL:(NSURL *)url {
    AuthSession.currentSession.user.avatarURL = url;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    NSFetchRequest *fetchRequest = [UserMO fetchRequest];
    NSPredicate *currentUserPredicate = [NSPredicate predicateWithFormat:@"uid == %@", [[FIRAuth auth] currentUser].uid];
    [fetchRequest setPredicate:currentUserPredicate];
    NSError *error = nil;
    NSArray *currentUserArray = [context executeFetchRequest:fetchRequest error:&error];
    if (error || currentUserArray.count < 1) {
        return;
    } else if (currentUserArray.count > 0) {
        UserMO *currentUserMO = [currentUserArray objectAtIndex:0];
        currentUserMO.avatarUrlString = [self.user.avatarURL absoluteString];
        NSError *saveError = nil;
        [context save:&saveError];
    }
}

#pragma mark - Private
- (User *)fetchCurrentUserWithUid:(NSString *)uid {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    NSFetchRequest *fetchRequest = [UserMO fetchRequest];
    NSPredicate *currentUserPredicate = [NSPredicate predicateWithFormat:@"uid == %@", uid];
    [fetchRequest setPredicate:currentUserPredicate];
    NSError *error = nil;
    NSArray *currentUserArray = [context executeFetchRequest:fetchRequest error:&error];
    if (error || currentUserArray.count < 1) {
        return nil;
    } else if (currentUserArray.count > 0) {
        UserMO *currentUserMO = [currentUserArray objectAtIndex:0];
        User *currentUser = [[User alloc] initWithManagedObject:currentUserMO];
        NSLog(@"FETCHED CURRENT USER WITH UID: %@", currentUser.uid);
        return currentUser;
    }
    return nil;
}


#pragma mark - Getters

- (BOOL)isValid {
    if (self.user.uid) {
        return true;
    }
    return false;
}



@end







