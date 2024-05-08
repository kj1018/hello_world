import React from "react";
import ReactDOM from "react-dom/client";
import { BrowserRouter as Router } from "react-router-dom";
import App from "./pages/App"
// import { AuthClient } from "@dfinity/auth-client";

// const init = async () => {
//   const authClient = await AuthClient.create();

//   if (await authClient.isAuthenticated()) {
//     handleAuthenticated(authClient);
//   } else {
//     await authClient.login({
//       identityProvider: "https://identity.ic0.app/#authorize",
//       onSuccess: () => {
//         handleAuthenticated(authClient);
//         window.location.reload();
//       },
//     });
//   }
// };

// async function handleAuthenticated(authClient) {
//   const identity = await authClient.getIdentity();
//   const userPrincipal = identity._principal.toString();
  const root = ReactDOM.createRoot(document.getElementById("root"));
  const userPrincipal = "kajhdfiul-adf-ads-fadf-sfsdfs";
  root.render(
    <React.StrictMode>
      <Router>
        <App loggedInPrincipal={userPrincipal}/>
      </Router>
    </React.StrictMode>
  );
// }
// init();