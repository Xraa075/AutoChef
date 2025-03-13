import React from "react";
import Header from "./components/Header";
import HeroSection from "./components/HeroSection";
import Features from "./components/Features";
import "./index.css";
import AppScreenshots from "./components/AppScreenshots";
import WhyAreWeUnique from "./components/WhyAreWeUnique";


function App() {
  return (
    <div>
      <Header />
      <HeroSection />
      <Features />
      <AppScreenshots />
      <WhyAreWeUnique />
    </div>
  );
}


export default App;
