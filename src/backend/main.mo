import List "mo:base/List";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Time "mo:base/Time";
import Debug "mo:base/Debug";
import Option "mo:base/Option";

actor zenoway {
    public type User = {
        address: Text;
        username: Text;
        profileImageAddress: Text;
        bio: Text;
        followers: List.List<Principal>;
        following: List.List<Principal>;
        postCount: Nat;
        userNotifications: List.List<Notification>;
    };

    public type Post = {
        postId: Nat;
        creatorAddress: Principal;
        imageAddress: Text;
        postCaption: Text;
        timeCreated: Time.Time;
        likes: List.List<Principal>;
    };

    public type Notification = {
        address: Principal;
        action: Text;
        time: Time.Time;
    };

    var posts: List.List<Post> = List.nil<Post>();
    var users: HashMap.HashMap<Principal, User> = HashMap.HashMap<Principal, User>(1_024, Principal.equal, Principal.hash);

    public shared(msg) func hello(name: Text): async Text{
        Debug.print(name);
        return (name # " " #Principal.toText(msg.caller));
    };


    // Create Post
    public shared(msg) func createPost(imageAddress: Text, postCaption: Text): async Nat{
        if (imageAddress.size() <= 0 or postCaption.size() <= 0) {
            assert(true);
        };

        let postId = List.size(posts);
        let newPost: Post = {
            postId = postId;
            creatorAddress = msg.caller;
            imageAddress = imageAddress;
            postCaption = postCaption;
            timeCreated = Time.now();
            likes = List.nil();
        };

        posts := List.push(newPost, posts);

        if (users.get(msg.caller) == null) {
            let newUser: User = {
                address = Principal.toText(msg.caller);
                username = "";
                profileImageAddress = "";
                bio = "";
                followers = List.nil<Principal>();
                following = List.nil<Principal>();
                postCount = 1;
                userNotifications = List.nil<Notification>();
            };

            users.put(msg.caller, newUser);
        } else {
            let optionalUser: ?User = users.get(msg.caller);

            let user: User = switch (optionalUser) {
                case (?u) { u };
                case (null) {
                    {
                        address = "";
                        username = "";
                        profileImageAddress = "";
                        bio = "";
                        followers = List.nil<Principal>();
                        following = List.nil<Principal>();
                        postCount = 0;
                        userNotifications = List.nil<Notification>();
                    }
                }
            };

            let updatedUser: User = { user with postCount = user.postCount + 1 };

            users.put(msg.caller, updatedUser);

            Debug.print(debug_show(updatedUser));
        };

        return 200;
    };

    // Check if user has liked a post
    private func hasLiked(postId: Nat, address: Principal): Bool {
        let optionalPost: ?Post = List.find<Post>(posts, func(post: Post): Bool {
            post.postId == postId
        });

        switch (optionalPost) {
            case (?post) {
                return List.foldLeft<Principal, Bool>(post.likes, false, func(acc: Bool, liker: Principal): Bool {
                    acc or (liker == address)
                });
            };
            case (null) {
                return false;
            };
        }
    };

    // Like Post
    public shared(msg) func likePost(postId: Nat): async Nat {
        if (hasLiked(postId, msg.caller)) {
            let optionalPost: ?Post = List.find<Post>(posts, func(post: Post): Bool {
                post.postId == postId
            });

            return switch (optionalPost) {
                case (?post) { List.size(post.likes) };
                case (null) { 0 }; 
            };
        };

        posts := List.map<Post, Post>(posts, func(post: Post): Post {
            if (post.postId == postId) {
                let updatedLikes = List.push(msg.caller, post.likes);
                return { post with likes = updatedLikes };
            };
            post
        });

        let updatedPost: ?Post = List.find<Post>(posts, func(post: Post): Bool {
            post.postId == postId
        });

        switch (updatedPost) {
            case (?post) { return List.size(post.likes); };
            case (null) { return 0; }; 
        }
    };

    

    // Unlike Post
    public shared(msg) func unlikePost(postId: Nat) {
        if (hasLiked(postId, msg.caller) == true) {
            return; // User has not liked the post, nothing to do
        };

        posts := List.map<Post, Post>(posts, func(post: Post): Post {
            if (post.postId == postId) {
                let updatedLikes = List.filter<Principal>(post.likes, func(liker: Principal): Bool {
                    liker != msg.caller
                });
                return { post with likes = updatedLikes };
            };
            post
        });
    };

    private func isFollowing(follower: Principal, followee: Principal): Bool {
        let optionalUser: ?User = users.get(follower);
        switch (optionalUser) {
            case (?user) {
                return Option.isSome(List.find<Principal>(user.following, func(u: Principal): Bool {
                    u == followee
                }));
            };
            case (null) { return false; };
        };
    };

    public shared(msg) func followUser(userToFollow: Principal) {
        if (msg.caller == userToFollow) {
            return;
        };

        if (isFollowing(msg.caller, userToFollow)) {
            return;
        };

        let optionalFollower: ?User = users.get(msg.caller);
        let optionalFollowee: ?User = users.get(userToFollow);

        switch (optionalFollower, optionalFollowee) {
            case (?follower, ?followee) {
                let updatedFollower: User = {
                    follower with
                    following = List.push(userToFollow, follower.following)
                };

                let updatedFollowee: User = {
                    followee with
                    followers = List.push(msg.caller, followee.followers)
                };

                users.put(msg.caller, updatedFollower);
                users.put(userToFollow, updatedFollowee);
            };
            case (null, _) { 
                Debug.print("Follower not found");
            };
            case (_, null) { 
                Debug.print("Followee not found");
            };
        }
    };

    public shared(msg) func unfollowUser(userToUnfollow: Principal) {
        if (msg.caller == userToUnfollow) {
            return; // Users cannot unfollow themselves
        };

        if (isFollowing(msg.caller, userToUnfollow) == false) {
            return; // User is not following the target user
        };

        let optionalFollower: ?User = users.get(msg.caller);
        let optionalFollowee: ?User = users.get(userToUnfollow);

        switch (optionalFollower, optionalFollowee) {
            case (?follower, ?followee) {
                // Update the follower's following list
                let updatedFollowing = List.filter<Principal>(follower.following, func(u: Principal): Bool {
                    u != userToUnfollow
                });
                let updatedFollower: User = { follower with following = updatedFollowing };

                // Update the followee's followers list
                let updatedFollowers = List.filter<Principal>(followee.followers, func(u: Principal): Bool {
                    u != msg.caller
                });
                let updatedFollowee: User = { followee with followers = updatedFollowers };

                // Store the updated users back in the map
                users.put(msg.caller, updatedFollower);
                users.put(userToUnfollow, updatedFollowee);
            };
            case (null, _) { // Follower not found
                Debug.print("Follower not found");
            };
            case (_, null) { // Followee not found
                Debug.print("Followee not found");
            };
        };
    };

    public shared func readAllPosts(): async [Post] {
        return List.toArray(posts);
    };

    public shared func readUserPosts(userAddress: Principal): async [Post] {
        let userPosts = List.filter<Post>(posts, func(post: Post): Bool {
            post.creatorAddress == userAddress
        });
        return List.toArray(userPosts);
    };

    public shared(msg) func readFollowingPosts(): async [Post] {
        let optionalUser: ?User = users.get(msg.caller);

        switch (optionalUser) {
            case (?user) {
                let followingList = user.following;
                let followingPosts = List.filter<Post>(posts, func(post: Post): Bool {
                    Option.isSome(List.find<Principal>(followingList, func(followee: Principal): Bool {
                        followee == post.creatorAddress
                    }))
                });
                return List.toArray(followingPosts);
            };
            case (null) {
                return []; // Return an empty array if the user is not found
            };
        };
    };


    // // Follow User
    // public func followUser(userToFollow: Principal) {
    //     assert (userToFollow != Principal.fromActor(this), "You cannot follow yourself");
    //     var user = users[userToFollow];
    //     user.followers := List.append(user.followers, List.singleton(Principal.fromActor(this)));
    //     var currentUser = users[Principal.fromActor(this)];
    //     currentUser.following := List.append(currentUser.following, List.singleton(userToFollow));
    //     let newNotification: Notification = {
    //         address = Principal.fromActor(this);
    //         action = "follow";
    //         time = Time.now();
    //     };
    //     user.userNotifications := List.append(user.userNotifications, List.singleton(newNotification));
    //     users[userToFollow] := user;
    //     users[Principal.fromActor(this)] := currentUser;
    // };

    // // Unfollow User
    // public func unfollowUser(userToUnfollow: Principal) {
    //     var user = users[userToUnfollow];
    //     user.followers := List.filter(user.followers, func(x) { x != Principal.fromActor(this) });
    //     var currentUser = users[Principal.fromActor(this)];
    //     currentUser.following := List.filter(currentUser.following, func(x) { x != userToUnfollow });
    //     users[userToUnfollow] := user;
    //     users[Principal.fromActor(this)] := currentUser;
    // };

    // // Check Following
    // public func isFollowing(follower: Principal, following: Principal): Bool {
    //     let user = users[following];
    //     return List.member(user.followers, follower, Principal.equal);
    // };

    // // Get Notifications
    // public func getUserNotifications(address: Principal): List.List<Notification> {
    //     let user = users[address];
    //     return user.userNotifications;
    // };

    // // Clear Notifications
    // public func clearNotifications() {
    //     var currentUser = users[Principal.fromActor(this)];
    //     currentUser.userNotifications := List.nil();
    //     users[Principal.fromActor(this)] := currentUser;
    // };

    // // Get Notification Count
    // public func getNotificationCount(address: Principal): Nat {
    //     let user = users[address];
    //     return List.size(user.userNotifications);
    // };

    // // Read All Posts
    // public func readPosts(): List.List<Post> {
    //     return posts;
    // };

    // // Read User Posts
    // public func readUserPosts(address: Principal): List.List<Post> {
    //     return List.filter(posts, func(x) { x.creatorAddress == address });
    // };

    // // Read Following Posts
    // public func readFollowingPosts(address: Principal): List.List<Post> {
    //     let currentUser = users[address];
    //     return List.filter(posts, func(p) { List.member(currentUser.following, p.creatorAddress, Principal.equal) });
    // };

    // // Set and Get Profile Information
    // public func setUserName(newName: Text) {
    //     assert (newName.size() > 0, "Empty Field");
    //     var currentUser = users[Principal.fromActor(this)];
    //     currentUser.username := newName;
    //     users[Principal.fromActor(this)] := currentUser;
    // };

    // public func setUserProfileImage(newImage: Text) {
    //     assert (newImage.size() > 0, "Empty Field");
    //     var currentUser = users[Principal.fromActor(this)];
    //     currentUser.profileImageAddress := newImage;
    //     users[Principal.fromActor(this)] := currentUser;
    // };

    // public func setUserBio(newBio: Text) {
    //     assert (newBio.size() > 0, "Empty Field");
    //     var currentUser = users[Principal.fromActor(this)];
    //     currentUser.bio := newBio;
    //     users[Principal.fromActor(this)] := currentUser;
    // };

    // public func getUserName(address: Principal): Text {
    //     let user = users[address];
    //     return user.username;
    // };

    // public func getUserProfileImage(address: Principal): Text {
    //     let user = users[address];
    //     return user.profileImageAddress;
    // };

    // public func getUserBio(address: Principal): Text {
    //     let user = users[address];
    //     return user.bio;
    // };

    // // Get Post, Follower, Following Counts
    // public func getUserPostsCount(address: Principal): Nat {
    //     let user = users[address];
    //     return user.postCount;
    // };

    // public func getFollowingsCount(address: Principal): Nat {
    //     let user = users[address];
    //     return List.size(user.following);
    // };

    // public func getFollowersCount(address: Principal): Nat {
    //     let user = users[address];
    //     return List.size(user.followers);
    // };

    // public func getPostLikes(postId: Nat): List.List<Principal> {
    //     assert (postId < List.size(posts), "Post does not exist");
    //     let post = List.nth(posts, postId);
    //     return post.likes;
    // };
}


// https://curly-palm-tree-7jg5qr9vv943qpx-4943.app.github.dev/?canisterId=be2us-64aaa-aaaaa-qaabq-cai&id=bw4dl-smaaa-aaaaa-qaacq-cai