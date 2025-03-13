import React from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faTruck, faStore, faCog } from "@fortawesome/free-solid-svg-icons";
import "./WhyAreWeUnique.css"; // Import CSS

// Import gambar (pastikan path sesuai dengan struktur proyek)
import googlePlay from "../assets/google-play.png";
import appStore from "../assets/app-store.png";
import phoneMockup from "../assets/phone-mockup.png";
import burger from "../assets/burger.png";

const WhyAreWeUnique = () => {
  return (
    <section id="Download" className="unique-section fade-in">
      {/* Bagian Fitur Unik */}
      <p className="small-heading">LOREM IPSUM</p>
      <h2 className="section-title">Why Are We Unique?</h2>

      <div className="unique-features">
        <div className="feature hover-effect">
          <FontAwesomeIcon icon={faTruck} className="icon" />
          <h3>We've Upped The Game.</h3>
          <p>We carry a variety of products through our unique vendors that you can't typically get delivered.</p>
        </div>
        <div className="feature hover-effect">
          <FontAwesomeIcon icon={faStore} className="icon" />
          <h3>Order From Our Virtual Mall</h3>
          <p>Order from a large variety of local stores you like and trust for years. You can't typically get delivered.</p>
        </div>
        <div className="feature hover-effect">
          <FontAwesomeIcon icon={faCog} className="icon" />
          <h3>Easy Access To Local Services</h3>
          <p>Easy access to local services such as dry cleaning. We can pick it up and drop it off to make your life easier.</p>
        </div>
      </div>

      {/* Bagian Promosi Aplikasi */}
      <div className="promo-section">
        <div className="promo-text">
          <h2>The Innovative Way To Shop</h2>
          <p>Join us to enjoy a new and improved way of shopping through our virtual mall experience.</p>
          <div className="app-buttons">
            <a href="https://play.google.com/store" target="_blank" rel="noopener noreferrer">
              <img src={googlePlay} alt="Google Play" className="store-button scale-hover" />
            </a>
            <a href="https://www.apple.com/app-store/" target="_blank" rel="noopener noreferrer">
              <img src={appStore} alt="App Store" className="store-button scale-hover" />
            </a>
          </div>
        </div>
        <div className="promo-image">
          <img src={phoneMockup} alt="App Preview" className="phone-mockup" />
          <img src={burger} alt="Burger" className="floating-burger" />
        </div>
      </div>
    </section>
  );
};

export default WhyAreWeUnique;
