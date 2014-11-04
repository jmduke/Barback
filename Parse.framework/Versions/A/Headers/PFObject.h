//
//  PFObject.h
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <Parse/PFACL.h>
#import <Parse/PFConstants.h>
#else
#import <ParseOSX/PFACL.h>
#import <ParseOSX/PFConstants.h>
#endif

@protocol PFSubclassing;
@class BFTask;
@class PFRelation;

/*!
 The `PFObject` class is a local representation of data persisted to the Parse cloud.
 This is the main class that is used to interact with objects in your app.
*/
NS_REQUIRES_PROPERTY_DEFINITIONS
@interface PFObject : NSObject {
    BOOL dirty;

    // An array of NSDictionary of NSString -> PFFieldOperation.
    // Each dictionary has a subset of the object's keys as keys, and the
    // changes to the value for that key as its value.
    // There is always at least one dictionary of pending operations.
    // Every time a save is started, a new dictionary is added to the end.
    // Whenever a save completes, the new data is put into fetchedData, and
    // a dictionary is removed from the start.
    NSMutableArray *operationSetQueue;

    // Our best estimate as to what the current data is, based on
    // the last fetch from the server, and the set of pending operations.
    NSMutableDictionary *estimatedData;
}

///--------------------------------------
/// @name Creating a PFObject
///--------------------------------------

/*!
 @abstract Creates a new PFObject with a class name.

 @param className A class name can be any alphanumeric string that begins with a letter.
 It represents an object in your app, like a 'User' or a 'Document'.

 @returns Returns the object that is instantiated with the given class name.
 */
+ (instancetype)objectWithClassName:(NSString *)className;

/*!
 @abstract Creates a reference to an existing PFObject for use in creating associations between PFObjects.

 @discussion Calling <isDataAvailable> on this object will return `NO` until <fetchIfNeeded> has been called.
 No network request will be made.

 @param className The object's class.
 @param objectId The object id for the referenced object.

 @returns A `PFObject` instance without data.
 */
+ (instancetype)objectWithoutDataWithClassName:(NSString *)className
                                      objectId:(NSString *)objectId;

/*!
 @abstract Creates a new `PFObject` with a class name, initialized with data
 constructed from the specified set of objects and keys.

 @param className The object's class.
 @param dictionary An `NSDictionary` of keys and objects to set on the new `PFObject`.

 @returns A PFObject with the given class name and set with the given data.
 */
+ (PFObject *)objectWithClassName:(NSString *)className dictionary:(NSDictionary *)dictionary;

/*!
 @abstract Initializes a new empty `PFObject` instance with a class name.

 @param newClassName A class name can be any alphanumeric string that begins with a letter.
 It represents an object in your app, like a 'User' or a 'Document'.

 @returns Returns the object that is instantiated with the given class name.
 */
- (instancetype)initWithClassName:(NSString *)newClassName;

///--------------------------------------
/// @name Managing Object Properties
///--------------------------------------

/*!
 @abstract The class name of the object.
 */
@property (strong, readonly) NSString *parseClassName;

/*!
 @abstract The id of the object.
 */
@property (nonatomic, strong) NSString *objectId;

/*!
 @abstract When the object was last updated.
 */
@property (nonatomic, strong, readonly) NSDate *updatedAt;

/*!
 @abstract When the object was created.
 */
@property (nonatomic, strong, readonly) NSDate *createdAt;

/*!
 @abstract The ACL for this object.
 */
@property (nonatomic, strong) PFACL *ACL;

/*!
 @abstract Returns an array of the keys contained in this object.

 @discussion This does not include `createdAt`, `updatedAt`, `authData`, or `objectId`.
 It does include things like username and ACL.
 */
- (NSArray *)allKeys;

///--------------------------------------
/// @name Accessors
///--------------------------------------

/*!
 @abstract Returns the value associated with a given key.

 @param key The key for which to return the corresponding value.
 */
- (id)objectForKey:(NSString *)key;

/*!
 @abstract Sets the object associated with a given key.

 @param object The object.
 @param key The key.
 */
- (void)setObject:(id)object forKey:(NSString *)key;

/*!
 @abstract Unsets a key on the object.

 @param key The key.
 */
- (void)removeObjectForKey:(NSString *)key;

/*!
 @abstract Returns the value associated with a given key.

 @discussion This method enables usage of literal syntax on `PFObject`.
 E.g. `NSString *value = object[@"key"];`

 @see objectForKey:

 @param key The key for which to return the corresponding value.
 */
- (id)objectForKeyedSubscript:(NSString *)key;

/*!
 @abstract Returns the value associated with a given key.

 @discussion This method enables usage of literal syntax on `PFObject`.
 E.g. `object[@"key"] = @"value";`

 @see setObject:forKey:

 @param object The object.
 @param key The key.
 */
- (void)setObject:(id)object forKeyedSubscript:(NSString *)key;

/*!
 @abstract Returns the relation object associated with the given key.

 @param key The key that the relation is associated with.
 */
- (PFRelation *)relationForKey:(NSString *)key;

/*!
 @abstract Returns the relation object associated with the given key.

 @param key The key that the relation is associated with.

 @deprecated Please use `[PFObject relationForKey:]` instead.
 */
- (PFRelation *)relationforKey:(NSString *)key PARSE_DEPRECATED("Please use -relationForKey: instead.");

///--------------------------------------
/// @name Array Accessors
///--------------------------------------

/*!
 @abstract Adds an object to the end of the array associated with a given key.

 @param object The object to add.
 @param key The key.
 */
- (void)addObject:(id)object forKey:(NSString *)key;

/*!
 @abstract Adds the objects contained in another array to the end of the array associated with a given key.

 @param objects The array of objects to add.
 @param key The key.
 */
- (void)addObjectsFromArray:(NSArray *)objects forKey:(NSString *)key;

/*!
 @abstract Adds an object to the array associated with a given key, only if it is not already present in the array.

 @discussion The position of the insert is not guaranteed.

 @param object The object to add.
 @param key The key.
 */
- (void)addUniqueObject:(id)object forKey:(NSString *)key;

/*!
 @abstract Adds the objects contained in another array to the array associated with a given key,
 only adding elements which are not already present in the array.

 @dicsussion The position of the insert is not guaranteed.

 @param objects The array of objects to add.
 @param key The key.
 */
- (void)addUniqueObjectsFromArray:(NSArray *)objects forKey:(NSString *)key;

/*!
 @abstract Removes all occurrences of an object from the array associated with a given key.

 @param object The object to remove.
 @param key The key.
 */
- (void)removeObject:(id)object forKey:(NSString *)key;

/*!
 @abstract Removes all occurrences of the objects contained in another array from the array associated with a given key.

 @param objects The array of objects to remove.
 @param key The key.
 */
- (void)removeObjectsInArray:(NSArray *)objects forKey:(NSString *)key;

///--------------------------------------
/// @name Increment
///--------------------------------------

/*!
 @abstract Increments the given key by `1`.

 @param key The key.
 */
- (void)incrementKey:(NSString *)key;

/*!
 @abstract Increments the given key by a number.

 @param key The key.
 @param amount The amount to increment.
 */
- (void)incrementKey:(NSString *)key byAmount:(NSNumber *)amount;

///--------------------------------------
/// @name Saving Objects
///--------------------------------------

/*!
 @abstract *Synchronously* saves the `PFObject`.

 @returns Returns whether the save succeeded.
 */
- (BOOL)save;

/*!
 @abstract *Synchronously* saves the `PFObject` and sets an error if it occurs.

 @param error Pointer to an NSError that will be set if necessary.

 @returns Returns whether the save succeeded.
 */
- (BOOL)save:(NSError **)error;

/*!
 @abstract Saves the `PFObject` *asynchronously*.

 @returns The task, that encapsulates the work being done.
 */
- (BFTask *)saveInBackground;

/*!
 @abstract Saves the `PFObject` *asynchronously* and executes the given callback block.

 @param block The block to execute.
 It should have the following argument signature: `^(BOOL succeeded, NSError *error)`.
 */
- (void)saveInBackgroundWithBlock:(PFBooleanResultBlock)block;

/*!
 @abstract Saves the `PFObject` asynchronously and calls the given callback.

 @param target The object to call selector on.
 @param selector The selector to call.
 It should have the following signature: `(void)callbackWithResult:(NSNumber *)result error:(NSError *)error`.
 `error` will be `nil` on success and set if there was an error.
 `[result boolValue]` will tell you whether the call succeeded or not.
 */
- (void)saveInBackgroundWithTarget:(id)target selector:(SEL)selector;

/*!
 @see saveEventually:
 */
- (void)saveEventually;

/*!
 @abstract Saves this object to the server at some unspecified time in the future,
 even if Parse is currently inaccessible.

 @discussion Use this when you may not have a solid network connection, and don't need to know when the save completes.
 If there is some problem with the object such that it can't be saved, it will be silently discarded. If the save
 completes successfully while the object is still in memory, then callback will be called.

 Objects saved with this method will be stored locally in an on-disk cache until they can be delivered to Parse.
 They will be sent immediately if possible. Otherwise, they will be sent the next time a network connection is
 available. Objects saved this way will persist even after the app is closed, in which case they will be sent the
 next time the app is opened. If more than 10MB of data is waiting to be sent, subsequent calls to <saveEventually>
 will cause old saves to be silently discarded until the connection can be re-established, and the queued objects
 can be saved.

 @param callback The block to execute.
 It should have the following argument signature: `^(BOOL succeeded, NSError *error)`.
 */
- (void)saveEventually:(PFBooleanResultBlock)callback;

///--------------------------------------
/// @name Saving Many Objects
///--------------------------------------

/*!
 @abstract Saves a collection of objects *synchronously all at once.

 @param objects The array of objects to save.

 @returns Returns whether the save succeeded.
 */
+ (BOOL)saveAll:(NSArray *)objects;

/*!
 @abstract Saves a collection of objects *synchronously* all at once and sets an error if necessary.

 @param objects The array of objects to save.
 @param error Pointer to an `NSError` that will be set if necessary.

 @returns Returns whether the save succeeded.
 */
+ (BOOL)saveAll:(NSArray *)objects error:(NSError **)error;

/*!
 @abstract Saves a collection of objects all at once *asynchronously*.

 @param objects The array of objects to save.

 @returns The task, that encapsulates the work being done.
 */
+ (BFTask *)saveAllInBackground:(NSArray *)objects;

/*!
 @abstract Saves a collection of objects all at once `asynchronously` and executes the block when done.

 @param objects The array of objects to save.
 @param block The block to execute.
 It should have the following argument signature: `^(BOOL succeeded, NSError *error)`.
 */
+ (void)saveAllInBackground:(NSArray *)objects
                      block:(PFBooleanResultBlock)block;

/*!
 @abstract Saves a collection of objects all at once *asynchronously* and calls a callback when done.

 @param objects The array of objects to save.
 @param target The object to call selector on.
 @param selector The selector to call.
 It should have the following signature: `(void)callbackWithResult:(NSNumber *)number error:(NSError *)error`.
 `error` will be `nil` on success and set if there was an error.
 `[result boolValue]` will tell you whether the call succeeded or not.
 */
+ (void)saveAllInBackground:(NSArray *)objects
                     target:(id)target
                   selector:(SEL)selector;

///--------------------------------------
/// @name Deleting Many Objects
///--------------------------------------

/*!
 @abstract *Synchronously* deletes a collection of objects all at once.

 @param objects The array of objects to delete.

 @returns Returns whether the delete succeeded.
 */
+ (BOOL)deleteAll:(NSArray *)objects;

/*!
 @abstract *Synchronously* deletes a collection of objects all at once and sets an error if necessary.

 @param objects The array of objects to delete.
 @param error Pointer to an `NSError` that will be set if necessary.

 @returns Returns whether the delete succeeded.
 */
+ (BOOL)deleteAll:(NSArray *)objects error:(NSError **)error;

/*!
 @abstract Deletes a collection of objects all at once asynchronously.
 @param objects The array of objects to delete.
 @returns The task, that encapsulates the work being done.
 */
+ (BFTask *)deleteAllInBackground:(NSArray *)objects;

/*!
 @abstract Deletes a collection of objects all at once *asynchronously* and executes the block when done.

 @param objects The array of objects to delete.
 @param block The block to execute.
 It should have the following argument signature: `^(BOOL succeeded, NSError *error)`.
 */
+ (void)deleteAllInBackground:(NSArray *)objects
                        block:(PFBooleanResultBlock)block;

/*!
 @abstract Deletes a collection of objects all at once *asynchronously* and calls a callback when done.

 @param objects The array of objects to delete.
 @param target The object to call selector on.
 @param selector The selector to call.
 It should have the following signature: `(void)callbackWithResult:(NSNumber *)number error:(NSError *)error`.
 `error` will be `nil` on success and set if there was an error.
 `[result boolValue]` will tell you whether the call succeeded or not.
 */
+ (void)deleteAllInBackground:(NSArray *)objects
                       target:(id)target
                     selector:(SEL)selector;

///--------------------------------------
/// @name Getting an Object
///--------------------------------------

/*!
 @abstract Gets whether the `PFObject` has been fetched.

 @returns `YES` if the PFObject is new or has been fetched or refreshed, otherwise `NO`.
 */
- (BOOL)isDataAvailable;

#if PARSE_IOS_ONLY

/*!
 @abstract Refreshes the PFObject with the current data from the server.

 @deprecated Please use `-fetch` instead.
 */
- (void)refresh PARSE_DEPRECATED("Please use `-fetch` instead.");

/*!
 @abstract *Synchronously* refreshes the PFObject with the current data from the server and sets an error if it occurs.

 @param error Pointer to an NSError that will be set if necessary.

 @deprecated Please use `-fetch:` instead.
 */
- (void)refresh:(NSError **)error PARSE_DEPRECATED("Please use `-fetch:` instead.");

/*!
 @abstract *Synchronously* refreshes the PFObject *asynchronously* and executes the given callback block.

 @param block The block to execute.
 The block should have the following argument signature: `^(PFObject *object, NSError *error)`

 @deprecated Please use `-fetchInBackgroundWithBlock:` instead.
 */
- (void)refreshInBackgroundWithBlock:(PFObjectResultBlock)block PARSE_DEPRECATED("Please use `-fetchInBackgroundWithBlock:` instead.");

/*!
 @abstract *Synchronously* refreshes the PFObject asynchronously and calls the given callback.

 @param target The target on which the selector will be called.
 @param selector The selector to call.
 It should have the following signature: `(void)callbackWithResult:(PFObject *)refreshedObject error:(NSError *)error`.
 `error` will be `nil` on success and set if there was an error.
 `refreshedObject` will be the `PFObject` with the refreshed data.

 @deprecated Please use `fetchInBackgroundWithTarget:selector:` instead.
 */
- (void)refreshInBackgroundWithTarget:(id)target
                             selector:(SEL)selector PARSE_DEPRECATED("Please use `fetchInBackgroundWithTarget:selector:` instead.");

#endif

/*!
 @abstract *Synchronously* fetches the PFObject with the current data from the server.
 */
- (void)fetch;
/*!
 @abstract *Synchronously* fetches the PFObject with the current data from the server and sets an error if it occurs.

 @param error Pointer to an `NSError` that will be set if necessary.
 */
- (void)fetch:(NSError **)error;

/*!
 @abstract *Synchronously* fetches the `PFObject` data from the server if <isDataAvailable> is `NO`.
 */
- (PFObject *)fetchIfNeeded;

/*!
 @abstract *Synchronously* fetches the `PFObject` data from the server if <isDataAvailable> is `NO`.

 @param error Pointer to an `NSError` that will be set if necessary.
 */
- (PFObject *)fetchIfNeeded:(NSError **)error;

/*!
 @abstract Fetches the `PFObject` *asynchronously* and sets it as a result for the task.

 @returns The task, that encapsulates the work being done.
 */
- (BFTask *)fetchInBackground;

/*!
 @abstract Fetches the PFObject *asynchronously* and executes the given callback block.

 @param block The block to execute.
 It should have the following argument signature: `^(PFObject *object, NSError *error)`.
 */
- (void)fetchInBackgroundWithBlock:(PFObjectResultBlock)block;

/*!
 @abstract Fetches the `PFObject *asynchronously* and calls the given callback.

 @param target The target on which the selector will be called.
 @param selector The selector to call.
 It should have the following signature: `(void)callbackWithResult:(PFObject *)refreshedObject error:(NSError *)error`.
 `error` will be `nil` on success and set if there was an error.
 `refreshedObject` will be the `PFObject` with the refreshed data.
 */
- (void)fetchInBackgroundWithTarget:(id)target selector:(SEL)selector;

/*!
 @abstract Fetches the `PFObject` data *asynchronously* if isDataAvailable is `NO`,
 then sets it as a result for the task.

 @returns The task, that encapsulates the work being done.
 */
- (BFTask *)fetchIfNeededInBackground;

/*!
 @abstract Fetches the `PFObject` data *asynchronously* if <isDataAvailable> is `NO`, then calls the callback block.

 @param block The block to execute.
 It should have the following argument signature: `^(PFObject *object, NSError *error)`.
 */
- (void)fetchIfNeededInBackgroundWithBlock:(PFObjectResultBlock)block;

/*!
 @abstract Fetches the PFObject's data asynchronously if isDataAvailable is false, then calls the callback.

 @param target The target on which the selector will be called.
 @param selector The selector to call.
 It should have the following signature: `(void)callbackWithResult:(PFObject *)fetchedObject error:(NSError *)error`.
 `error` will be `nil` on success and set if there was an error.
 `refreshedObject` will be the `PFObject` with the refreshed data.
 */
- (void)fetchIfNeededInBackgroundWithTarget:(id)target
                                   selector:(SEL)selector;

///--------------------------------------
/// @name Getting Many Objects
///--------------------------------------

/*!
 @abstract *Synchronously* fetches all of the `PFObject` objects with the current data from the server.

 @param objects The list of objects to fetch.
 */
+ (void)fetchAll:(NSArray *)objects;

/*!
 @abstract *Synchronously* fetches all of the `PFObject` objects with the current data from the server
 and sets an error if it occurs.

 @param objects The list of objects to fetch.
 @param error Pointer to an `NSError` that will be set if necessary.
 */
+ (void)fetchAll:(NSArray *)objects error:(NSError **)error;

/*!
 @abstract *Synchronously* fetches all of the `PFObject` objects with the current data from the server.
 @param objects The list of objects to fetch.
 */
+ (void)fetchAllIfNeeded:(NSArray *)objects;

/*!
 @abstract *Synchronously* fetches all of the `PFObject` objects with the current data from the server
 and sets an error if it occurs.

 @param objects The list of objects to fetch.
 @param error Pointer to an `NSError` that will be set if necessary.
 */
+ (void)fetchAllIfNeeded:(NSArray *)objects error:(NSError **)error;

/*!
 @abstract Fetches all of the `PFObject` objects with the current data from the server *asynchronously*.

 @param objects The list of objects to fetch.

 @returns The task, that encapsulates the work being done.
 */
+ (BFTask *)fetchAllInBackground:(NSArray *)objects;

/*!
 @abstract Fetches all of the `PFObject` objects with the current data from the server *asynchronously*
 and calls the given block.

 @param objects The list of objects to fetch.
 @param block The block to execute.
 It should have the following argument signature: `^(NSArray *objects, NSError *error)`.
 */
+ (void)fetchAllInBackground:(NSArray *)objects
                       block:(PFArrayResultBlock)block;

/*!
 @abstract Fetches all of the `PFObject` objects with the current data from the server *asynchronously*
 and calls the given callback.

 @param objects The list of objects to fetch.
 @param target The target on which the selector will be called.
 @param selector The selector to call.
 It should have the following signature: `(void)callbackWithResult:(NSArray *)fetchedObjects error:(NSError *)error`.
 `error` will be `nil` on success and set if there was an error.
 `fetchedObjects` will the array of `PFObject` objects that were fetched.
 */
+ (void)fetchAllInBackground:(NSArray *)objects
                      target:(id)target
                    selector:(SEL)selector;

/*!
 @abstract Fetches all of the `PFObject` objects with the current data from the server *asynchronously*.

 @param objects The list of objects to fetch.

 @returns The task, that encapsulates the work being done.
 */
+ (BFTask *)fetchAllIfNeededInBackground:(NSArray *)objects;

/*!
 @abstract Fetches all of the PFObjects with the current data from the server *asynchronously*
 and calls the given block.

 @param objects The list of objects to fetch.
 @param block The block to execute.
 It should have the following argument signature: `^(NSArray *objects, NSError *error)`.
 */
+ (void)fetchAllIfNeededInBackground:(NSArray *)objects
                               block:(PFArrayResultBlock)block;

/*!
 @abstract Fetches all of the PFObjects with the current data from the server *asynchronously*
 and calls the given callback.

 @param objects The list of objects to fetch.
 @param target The target on which the selector will be called.
 @param selector The selector to call.
 It should have the following signature: `(void)callbackWithResult:(NSArray *)fetchedObjects error:(NSError *)error`.
 `error` will be `nil` on success and set if there was an error.
 `fetchedObjects` will the array of `PFObject` objects that were fetched.
 */
+ (void)fetchAllIfNeededInBackground:(NSArray *)objects
                              target:(id)target
                            selector:(SEL)selector;

///--------------------------------------
/// @name Deleting an Object
///--------------------------------------

/*!
 @abstract *Synchronously* deletes the `PFObject`.

 @returns Returns whether the delete succeeded.
 */
- (BOOL)delete;

/*!
 @abstract *Synchronously* deletes the `PFObject` and sets an error if it occurs.

 @param error Pointer to an `NSError` that will be set if necessary.

 @returns Returns whether the delete succeeded.
 */
- (BOOL)delete:(NSError **)error;

/*!
 @abstract Deletes the `PFObject` *asynchronously*.

 @returns The task, that encapsulates the work being done.
 */
- (BFTask *)deleteInBackground;

/*!
 @abstract Deletes the `PFObject` *asynchronously* and executes the given callback block.

 @param block The block to execute.
 It should have the following argument signature: `^(BOOL succeeded, NSError *error)`.
 */
- (void)deleteInBackgroundWithBlock:(PFBooleanResultBlock)block;

/*!
 @abstract Deletes the `PFObject` *asynchronously* and calls the given callback.

 @param target The object to call selector on.
 @param selector The selector to call.
 It should have the following signature: `(void)callbackWithResult:(NSNumber *)result error:(NSError *)error`.
 `error` will be `nil` on success and set if there was an error.
 `[result boolValue]` will tell you whether the call succeeded or not.
 */
- (void)deleteInBackgroundWithTarget:(id)target
                            selector:(SEL)selector;

/*!
 @abstract Deletes this object from the server at some unspecified time in the future,
 even if Parse is currently inaccessible.

 @discussion Use this when you may not have a solid network connection,
 and don't need to know when the delete completes. If there is some problem with the object
 such that it can't be deleted, the request will be silently discarded.

 Delete instructions made with this method will be stored locally in an on-disk cache until they can be transmitted
 to Parse. They will be sent immediately if possible. Otherwise, they will be sent the next time a network connection
 is available. Delete requests will persist even after the app is closed, in which case they will be sent the
 next time the app is opened. If more than 10MB of <saveEventually> or <deleteEventually> commands are waiting
 to be sent, subsequent calls to <saveEventually> or <deleteEventually> will cause old requests to be silently discarded
 until the connection can be re-established, and the queued requests can go through.
 */
- (void)deleteEventually;

///--------------------------------------
/// @name Dirtiness
///--------------------------------------

/*!
 @abstract Gets whether any key-value pair in this object (or its children)
 has been added/updated/removed and not saved yet.

 @returns Returns whether this object has been altered and not saved yet.
 */
- (BOOL)isDirty;

/*!
 @abstract Get whether a value associated with a key has been added/updated/removed and not saved yet.

 @param key The key to check for

 @returns Returns whether this key has been altered and not saved yet.
 */
- (BOOL)isDirtyForKey:(NSString *)key;

@end
