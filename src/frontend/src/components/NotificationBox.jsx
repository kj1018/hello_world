// NotificationBox.js
import React, { useState, useEffect } from "react";
import { timeSince, truncateAddress } from "../functions/utils";
import { getUserDetails } from "../functions/userInteractionFunctions";

function NotificationBox({userAddress, address, action, time}) {
  const [userImage, setUserImage] = useState("");
  const [userName, setUserName] = useState("");

  async function handleReadDetails() {
    const userDetails = await getUserDetails(address);
    setUserImage(userDetails.image);
    setUserName(userDetails.name);
  }

  useEffect(() => {
    handleReadDetails();
  }, [userAddress]);

  return (
    <div className="notification-box">
      <img
        src={
          userImage === ""
            ? "https://gateway.ipfs.io/ipfs/QmQL7iRtD6P5d7bdzxWGrE89mVUvZi1jqn6kmpMtEF6CMv"
            : userImage
        }
        alt="UserImage"
        className="notification-profile-img"
      />

      <div className="notification-content-box">
        <span className="notification-content">
          {userName || truncateAddress(address)}
          {action === "like" ? " liked your post!" : " is following you!"}
        </span>
        <span>{timeSince(time)} ago</span>
      </div>
    </div>
  );
}

export default NotificationBox;
