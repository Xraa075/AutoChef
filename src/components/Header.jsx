import React from "react";
import "../index.css"; // Import CSS

const Header = () => {
  return (
    <header className="header">
      <h1 className="logo">AutoChef</h1>
      <nav>
        <ul className="nav-links">
          <li><a href="#Home">Home</a></li>
          <li><a href="#Features">Features</a></li>
          <li><a href="#Download">Download</a></li>
        </ul>
      </nav>
    </header>
  );
};

export default Header;
