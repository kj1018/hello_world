import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import List "mo:base/List";

actor Zenoway {
    type User = {
        userAddress: Principal;
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
        userAddress: Principal;
        action: Text;
        time: Time.Time;
    };

    var allUsers: List.List<Principal> = List.nil();
    var posts: List.List<Post> = List.nil();
    var users: [Principal, User] = [];

    public func addUser(userAddress: Principal) {
        if (List.member(allUsers, userAddress, Principal.equal)) == false {
            allUsers := List.append(allUsers, List.singleton(userAddress));
        }
    }

    // Create Post
    public func createPost(imageAddress: Text, postCaption: Text) {
        assert (imageAddress.size() > 0 or postCaption.size() > 0, "Empty Field");
        let postId = List.size(posts);
        let newPost: Post = {
            postId = postId;
            creatorAddress = Principal.fromActor(this);
            imageAddress = imageAddress;
            postCaption = postCaption;
            timeCreated = Time.now();
            likes = List.nil();
        };
        posts := List.append(posts, List.singleton(newPost));
        var u = users[Principal.fromActor(this)];
        u.postCount += 1;
        users[Principal.fromActor(this)] := u;
    }

    // Like Post
    public func likePost(postId: Nat) {
        assert (postId < List.size(posts), "Post does not exist");
        assert (!hasLiked(postId, Principal.fromActor(this)), "Already Liked");
        var p = List.nth(posts, postId);
        p.likes := List.append(p.likes, List.singleton(Principal.fromActor(this)));
        posts := List.replace<Nat, Post>(posts, postId, p);
        if (p.creatorAddress != Principal.fromActor(this)) {
            var creatorUser = users[p.creatorAddress];
            let newNotification: Notification = {
                userAddress = Principal.fromActor(this);
                action = "like";
                time = Time.now();
            };
            creatorUser.userNotifications := List.append(creatorUser.userNotifications, List.singleton(newNotification));
            users[p.creatorAddress] := creatorUser;
        }
    }

    // Check if user has liked a post
    private func hasLiked(postId: Nat, userAddress: Principal): Bool {
        let p = List.nth(posts, postId);
        return List.member(p.likes, userAddress, Principal.equal);
    }

        // Unlike Post
    public func unlikePost(postId: Nat) {
        assert (postId < List.size(posts), "Post does not exist");
        var p = List.nth(posts, postId);
        let filteredLikes = List.filter(p.likes, func(x) { x != Principal.fromActor(this) });
        p.likes := filteredLikes;
        posts := List.replace<Nat, Post>(posts, postId, p);
    }

    // Follow User
    public func followUser(userToFollow: Principal) {
        assert (userToFollow != Principal.fromActor(this), "You cannot follow yourself");
        var user = users[userToFollow];
        user.followers := List.append(user.followers, List.singleton(Principal.fromActor(this)));
        var currentUser = users[Principal.fromActor(this)];
        currentUser.following := List.append(currentUser.following, List.singleton(userToFollow));
        let newNotification: Notification = {
            userAddress = Principal.fromActor(this);
            action = "follow";
            time = Time.now();
        };
        user.userNotifications := List.append(user.userNotifications, List.singleton(newNotification));
        users[userToFollow] := user;
        users[Principal.fromActor(this)] := currentUser;
    }

    // Unfollow User
    public func unfollowUser(userToUnfollow: Principal) {
        var user = users[userToUnfollow];
        user.followers := List.filter(user.followers, func(x) { x != Principal.fromActor(this) });
        var currentUser = users[Principal.fromActor(this)];
        currentUser.following := List.filter(currentUser.following, func(x) { x != userToUnfollow });
        users[userToUnfollow] := user;
        users[Principal.fromActor(this)] := currentUser;
    }

    // Check Following
    public func isFollowing(follower: Principal, following: Principal): Bool {
        let user = users[following];
        return List.member(user.followers, follower, Principal.equal);
    }

    // Get Notifications
    public func getUserNotifications(userAddress: Principal): List.List<Notification> {
        let user = users[userAddress];
        return user.userNotifications;
    }

    // Clear Notifications
    public func clearNotifications() {
        var currentUser = users[Principal.fromActor(this)];
        currentUser.userNotifications := List.nil();
        users[Principal.fromActor(this)] := currentUser;
    }

    // Get Notification Count
    public func getNotificationCount(userAddress: Principal): Nat {
        let user = users[userAddress];
        return List.size(user.userNotifications);
    }

    // Read All Posts
    public func readPosts(): List.List<Post> {
        return posts;
    }

    // Read User Posts
    public func readUserPosts(userAddress: Principal): List.List<Post> {
        return List.filter(posts, func(x) { x.creatorAddress == userAddress });
    }

    // Read Following Posts
    public func readFollowingPosts(userAddress: Principal): List.List<Post> {
        let currentUser = users[userAddress];
        return List.filter(posts, func(p) { List.member(currentUser.following, p.creatorAddress, Principal.equal) });
    }

    // Set and Get Profile Information
    public func setUserName(newName: Text) {
        assert (newName.size() > 0, "Empty Field");
        var currentUser = users[Principal.fromActor(this)];
        currentUser.username := newName;
        users[Principal.fromActor(this)] := currentUser;
    }

    public func setUserProfileImage(newImage: Text) {
        assert (newImage.size() > 0, "Empty Field");
        var currentUser = users[Principal.fromActor(this)];
        currentUser.profileImageAddress := newImage;
        users[Principal.fromActor(this)] := currentUser;
    }

    public func setUserBio(newBio: Text) {
        assert (newBio.size() > 0, "Empty Field");
        var currentUser = users[Principal.fromActor(this)];
        currentUser.bio := newBio;
        users[Principal.fromActor(this)] := currentUser;
    }

    public func getUserName(userAddress: Principal): Text {
        let user = users[userAddress];
        return user.username;
    }

    public func getUserProfileImage(userAddress: Principal): Text {
        let user = users[userAddress];
        return user.profileImageAddress;
    }

    public func getUserBio(userAddress: Principal): Text {
        let user = users[userAddress];
        return user.bio;
    }

    // Get Post, Follower, Following Counts
    public func getUserPostsCount(userAddress: Principal): Nat {
        let user = users[userAddress];
        return user.postCount;
    }

    public func getFollowingsCount(userAddress: Principal): Nat {
        let user = users[userAddress];
        return List.size(user.following);
    }

    public func getFollowersCount(userAddress: Principal): Nat {
        let user = users[userAddress];
        return List.size(user.followers);
    }

    public func getPostLikes(postId: Nat): List.List<Principal> {
        assert (postId < List.size(posts), "Post does not exist");
        let post = List.nth(posts, postId);
        return post.likes;
    }

}
