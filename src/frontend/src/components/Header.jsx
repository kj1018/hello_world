import React, { useState } from "react";
import BrandLogo from "../../assets/Brand.png"
function Header() {
  const [hovered, setHovered] = useState(false);
  const handleHover = () => {
    setHovered(true);
  };
  const handleLeave = () => {
    setHovered(false);
  };

  return (
    <div className="header">
      <nav className="nav">
        <img
          onClick={() => {
            window.location.reload();
          }}
          className="brand-logo"
          src={BrandLogo}
          alt="Brand Logo"
          onMouseOver={handleHover}
          onMouseLeave={handleLeave}
          style={{
            cursor: hovered ? "pointer" : null,
          }}
        />
      </nav>
    </div>
  );
}
export default Header;
