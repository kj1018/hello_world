import React from "react";
import { Routes, Route } from "react-router-dom";
import Home from "./Home";


const App = ({loggedInPrincipal}) => {
  return (
    <Routes>
      {/* <Route path="/profile" element={<Profile userAddress={loggedInPrincipal}/>} />
      <Route path="/explore" element={<Explore userAddress={loggedInPrincipal}/>} />
      <Route path="/alert" element={<Alert userAddress={loggedInPrincipal}/>} /> */}
      <Route path="/" element={<Home userAddress={loggedInPrincipal}/>} />
    </Routes>
  );
};

export default App;