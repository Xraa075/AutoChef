import React from "react";
import "./HeroSection.css";
import phoneImage from "../assets/phone.png"; // Sesuaikan path
import sushiImage from "../assets/sushi.png"; // Sesuaikan path

const HeroSection = () => {
  return (
    <section className="hero">
      <div className="hero-content">
        <h1 className="hero-title">AutoChef <br /> AutoChef</h1>
        <p className="hero-subtitle">
          To Stay Ahead Of The Curve, Serve Your Customers Through An
          On-Demand Food Delivery App.
        </p>
        <div className="hero-buttons">
          <button className="btn btn-primary">Get Started</button>
          <button className="btn btn-secondary">View More</button>
        </div>
      </div>
      <div className="hero-image">
        <img src={phoneImage} alt="Mobile App" className="phone" />
        <img src={sushiImage} alt="Sushi Dish" className="sushi" />
      </div>
    </section>
  );
};

export default HeroSection;
