import List "mo:base/List";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Time "mo:base/Time";
import Debug "mo:base/Debug";

actor zenoway {
    type User = {
        address: Text;
        username: Text;
        profileImageAddress: Text;
        bio: Text;
        followers: List.List<Principal>;
        following: List.List<Principal>;
        postCount: Nat;
        userNotifications: List.List<Notification>;
    };

    type Post = {
        postId: Nat;
        creatorAddress: Principal;
        imageAddress: Text;
        postCaption: Text;
        timeCreated: Time.Time;
        likes: List.List<Principal>;
    };

    type Notification = {
        address: Principal;
        action: Text;
        time: Time.Time;
    };

    var posts: List.List<Post> = List.nil<Post>();
    var users: HashMap.HashMap<Principal, User> = HashMap.HashMap<Principal, User>(1_024, Principal.equal, Principal.hash);

    // public func addUser(userAddress: Principal) {
    // if (users.get(userAddress) == null) {
    //         var newUser: User = {
    //             address = Principal.toText(userAddress);
    //             username = "";
    //             profileImageAddress = "";
    //             bio = "";
    //             followers = List.nil<Principal>();
    //             following = List.nil<Principal>();
    //             postCount = 0;
    //             userNotifications = List.nil<Notification>();
    //         };

    //         users.put(userAddress, newUser);
    //     }
    // };


    // Create Post
    public shared(msg) func createPost(imageAddress: Text, postCaption: Text) {
        if(imageAddress.size()<=0 or postCaption.size()<=0){
            assert(false);
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
            var newUser: User = {
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
        }else{
            Debug.print(debug_show(users.get(msg.caller)));
            var u = users.get(msg.caller);


            // var newUser: User = {
            //     address = Principal.toText(msg.caller);
            //     username = u.username;
            //     profileImageAddress = u.imageAddress;
            //     bio = u.bio;
            //     followers = u.followers;
            //     following = u.following;
            //     postCount = 1;
            //     userNotifications = u.userNotifications;
            // };

            // users.put(msg.caller, newUser);
        };
    };

    // // Like Post
    // public func likePost(postId: Nat) {
    //     assert (postId < List.size(posts), "Post does not exist");
    //     assert ((hasLiked(postId, Principal.fromActor(this))==false), "Already Liked");
    //     var p = List.nth(posts, postId);
    //     p.likes := List.append(p.likes, List.singleton(Principal.fromActor(this)));
    //     posts := List.replace<Nat, Post>(posts, postId, p);
    //     if (p.creatorAddress != Principal.fromActor(this)) {
    //         var creatorUser = users[p.creatorAddress];
    //         let newNotification: Notification = {
    //             address = Principal.fromActor(this);
    //             action = "like";
    //             time = Time.now();
    //         };
    //         creatorUser.userNotifications := List.append(creatorUser.userNotifications, List.singleton(newNotification));
    //         users[p.creatorAddress] := creatorUser;
    //     }
    // };

    // // Check if user has liked a post
    // private func hasLiked(postId: Nat, address: Principal): Bool {
    //     let p = List.nth(posts, postId);
    //     return List.member(p.likes, address, Principal.equal);
    // };

    //     // Unlike Post
    // public func unlikePost(postId: Nat) {
    //     assert (postId < List.size(posts), "Post does not exist");
    //     var p = List.nth(posts, postId);
    //     let filteredLikes = List.filter(p.likes, func(x) { x != Principal.fromActor(this) });
    //     p.likes := filteredLikes;
    //     posts := List.replace<Nat, Post>(posts, postId, p);
    // };

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