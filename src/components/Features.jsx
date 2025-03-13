import React from "react";
import "./Features.css";
import mockupImage from "../assets/features.png"; // Sesuaikan path dengan lokasi gambar

const Features = () => {
  return (
    <section id="Features" className="features-section">
      <h3 className="section-title">FEATURES</h3>
      <h2 className="features-heading">Awesome Features</h2>

      <div className="features-container">
        {/* List Fitur Kiri */}
        <div className="features-list">
          {["Near By Stores", "Near By Stores", "Near By Stores"].map((title, index) => (
            <div className="feature-item" key={index}>
              <span className="feature-dot"></span>
              <h4>{title}</h4>
              <p>Discover Local Stores Based On Your GPS Location</p>
            </div>
          ))}
        </div>

        {/* Gambar Mockup */}
        <div className="features-image">
          <img src={mockupImage} alt="Mockup" />
        </div>

        {/* List Fitur Kanan */}
        <div className="features-list">
          {["Near By Stores", "Near By Stores", "Near By Stores"].map((title, index) => (
            <div className="feature-item" key={index}>
              <span className="feature-dot"></span>
              <h4>{title}</h4>
              <p>Discover Local Stores Based On Your GPS Location</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default Features;
