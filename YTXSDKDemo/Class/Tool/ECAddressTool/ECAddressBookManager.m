//
//  ECAddressBookManager.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/26.
//
//

#import "ECAddressBookManager.h"
#import "SearchCoreManager.h"

@interface ECAddressBookManager()

@property(nonatomic, strong) NSMutableDictionary *allContactsDic;

@end

@implementation ECAddressBookManager

+(ECAddressBookManager *)sharedInstance{
    static ECAddressBookManager* manager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[ECAddressBookManager alloc] init];
    });
    return manager;
}

- (NSArray *)allContacts{
    ABAddressBookRef addBook = ABAddressBookCreateWithOptions(NULL, NULL);
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(addBook, ^(bool greanted, CFErrorRef error){
        dispatch_semaphore_signal(sema);
    });
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    NSMutableArray *addressBooks = [NSMutableArray array];
    self.allContactsDic = [NSMutableDictionary dictionary];
    NSArray *personArray = (__bridge NSArray *)(ABAddressBookCopyArrayOfAllPeople(addBook));
    [[SearchCoreManager share] Reset];
    [personArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *firstName = (__bridge NSString *)(ABRecordCopyValue((__bridge ABRecordRef)obj, kABPersonFirstNameProperty));
        NSString *midName = (__bridge NSString *)(ABRecordCopyValue((__bridge ABRecordRef)obj, kABPersonMiddleNameProperty));
        NSString *lastName = (__bridge NSString *)(ABRecordCopyValue((__bridge ABRecordRef)obj, kABPersonLastNameProperty));
        if(!firstName)
            firstName = @"";
        if(!midName)
            midName = @"";
        if(!lastName)
            lastName = @"";
        NSString *name = [NSString stringWithFormat:@"%@%@%@", lastName, midName, firstName];
        if(!name || name.length == 0)
            name = @"";
        ABMultiValueRef phoneRef = ABRecordCopyValue((__bridge ABRecordRef)obj, kABPersonPhoneProperty);
        NSArray *phones = (__bridge NSArray*)ABMultiValueCopyArrayOfAllValues(phoneRef);
        NSString *phone = [phones objectAtIndex:0];
        ECAddressBook *addressBook = [[ECAddressBook alloc] init];
        addressBook.name = name;
        addressBook.phone = phone;
        addressBook.phones = phones;
        addressBook.index = @(idx);
        if([[ECDBManager sharedInstanced].friendMgr queryFriend:[phone stringByReplacingOccurrencesOfString:@"-" withString:@""]] || [[phone stringByReplacingOccurrencesOfString:@"-" withString:@""] isEqualToString:[ECDevicePersonInfo sharedInstanced].userName])
            addressBook.isAdded = YES;
        if(![[phone stringByReplacingOccurrencesOfString:@"-" withString:@""] isEqualToString:[ECDevicePersonInfo sharedInstanced].userName]){
            [addressBooks addObject:addressBook];
            [self.allContactsDic setObject:addressBook forKey:@(idx)];
            [[SearchCoreManager share] AddContact:@(idx) name:addressBook.name phone:phones];
        }
    }];
    return addressBooks;
}

- (NSDictionary *)firstLetterContacts:(NSArray *)contacts{
    NSMutableDictionary *contactDic = [NSMutableDictionary dictionary];
    for (ECAddressBook *book in contacts) {
        NSMutableArray *subArray = [contactDic objectForKey:book.firstLetter];
        if (!subArray) {
            subArray = [NSMutableArray array];
            [contactDic setObject:subArray forKey:book.firstLetter];
        }
        [subArray addObject:book];
    }
    return contactDic;
}

- (NSArray *)recommendContacts {
    NSArray *contacts = self.allContacts;
    if(contacts.count <= 12)
        return  contacts;
    NSMutableArray *recommendArr = [NSMutableArray array];
    NSInteger count = contacts.count;
    while (recommendArr.count <= 12) {
        int random = arc4random() % count;
        ECAddressBook *addressBook = contacts[random];
        if(![recommendArr containsObject:addressBook])
            [recommendArr addObject:contacts[random]];
    }
    return recommendArr;
}

- (NSArray *)searchContacts:(NSString *)text{
    NSMutableArray *searchArr = [NSMutableArray array];
    NSMutableArray *nameArr = [NSMutableArray array];
    NSMutableArray *phoneArr = [NSMutableArray array];
    [[SearchCoreManager share] SearchWithFunc:@"22233344455566677778889999" searchText:text searchArray:nil nameMatch:nameArr phoneMatch:phoneArr];
    if (nameArr.count>0) {
        for (NSNumber *index in nameArr) {
            [searchArr addObject:self.allContactsDic[index]];
        }
    } else if (phoneArr.count>0) {
        for (NSNumber *index in phoneArr) {
            [searchArr addObject:self.allContactsDic[index]];
        }
    }
    return searchArr;
}

@end
