import React from "react";
import "./AppScreenshots.css";
import { Swiper, SwiperSlide } from "swiper/react";
import "swiper/css";
import "swiper/css/navigation";
import "swiper/css/pagination";
import { Navigation, Pagination, Autoplay, EffectCoverflow } from "swiper/modules";

// Import gambar
import waveBackground from "../assets/wave-background.png";
import screenshot1 from "../assets/screenshot1.png";
import screenshot2 from "../assets/screenshot2.png";
import screenshot3 from "../assets/screenshot3.png";
import screenshot4 from "../assets/screenshot4.png";
import screenshot5 from "../assets/screenshot5.png";

const AppScreenshots = () => {
  const screenshots = [screenshot1, screenshot2, screenshot3, screenshot4, screenshot5];

  return (
    <section
      className="app-screenshots"
      style={{
        backgroundImage: `url(${waveBackground})`,
      }}
    >
      <h3 className="screenshots-heading">SCREENSHOTS</h3>
      <h2 className="sub-heading">App Screenshots</h2>

      <Swiper
        modules={[Navigation, Pagination, Autoplay, EffectCoverflow]}
        effect="coverflow"
        spaceBetween={20}
        slidesPerView={3}
        navigation
        pagination={{ clickable: true }}
        autoplay={{ delay: 3000, disableOnInteraction: false }}
        grabCursor={true}
        centeredSlides={true}
        loop={true}
        coverflowEffect={{
          rotate: 10,
          stretch: 0,
          depth: 100,
          modifier: 2.5,
          slideShadows: false,
        }}
        breakpoints={{
          640: { slidesPerView: 1 },
          768: { slidesPerView: 2 },
          1024: { slidesPerView: 3 },
        }}
      >
        {screenshots.map((src, index) => (
          <SwiperSlide key={index} className="screenshot-slide">
            <img src={src} alt={`Screenshot ${index + 1}`} className="screenshot-image" />
          </SwiperSlide>
        ))}
      </Swiper>
    </section>
  );
};

export default AppScreenshots;
