document.addEventListener("DOMContentLoaded", () => {
  const navToggle = document.querySelector(".nav-toggle");
  const nav = document.querySelector(".site-nav");
  const yearEl = document.querySelector("#year");
  const animated = document.querySelectorAll(".animate");

  if (yearEl) {
    yearEl.textContent = new Date().getFullYear();
  }

  if (navToggle && nav) {
    navToggle.addEventListener("click", () => {
      const expanded = navToggle.getAttribute("aria-expanded") === "true";
      navToggle.setAttribute("aria-expanded", String(!expanded));
      nav.classList.toggle("is-open");
    });

    nav.querySelectorAll('a[href^="#"]').forEach((link) => {
      link.addEventListener("click", () => {
        nav.classList.remove("is-open");
        navToggle.setAttribute("aria-expanded", "false");
      });
    });
  }

  // IntersectionObserver adds animation classes when sections enter viewport
  if (animated.length) {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add("is-visible");
            observer.unobserve(entry.target);
          }
        });
      },
      { root: null, rootMargin: "0px 0px -10% 0px", threshold: 0.2 }
    );

    animated.forEach((el) => observer.observe(el));
  }

  // Weather and Environment Data Integration
  async function fetchWeather() {
    const weatherTemp = document.getElementById("weather-temp");
    const weatherIcon = document.getElementById("weather-icon");
    const windSpeed = document.getElementById("wind-speed");
    const uvIndex = document.getElementById("uv-index");
    const airQuality = document.getElementById("air-quality");
    const roadCondition = document.getElementById("road-condition");
    const roadIcon = document.getElementById("road-icon");
    const clothingAdvice = document.getElementById("clothing-advice");
    const sunscreenAdvice = document.getElementById("sunscreen-advice");

    if (!weatherTemp || !weatherIcon) return;

    try {
      // 使用 wttr.in API 获取新都桥天气（康定市）
      const response = await fetch("https://wttr.in/Kangding?format=j1");
      const data = await response.json();

      const current = data.current_condition[0];
      const temp = parseInt(current.temp_C);
      const weatherCode = current.weatherCode;
      const wind = parseInt(current.windspeedKmph);
      const uv = parseInt(current.uvIndex);
      const feelsLike = parseInt(current.FeelsLikeC);

      // 更新天气图标和温度
      const weatherEmoji = getWeatherEmoji(weatherCode);
      weatherTemp.textContent = `${temp}°C`;
      weatherIcon.textContent = weatherEmoji;

      // 更新风力
      if (windSpeed) {
        const windLevel = getWindLevel(wind);
        windSpeed.textContent = `${wind}km/h ${windLevel}`;
      }

      // 更新紫外线
      if (uvIndex) {
        const uvLevel = getUVLevel(uv);
        uvIndex.textContent = `${uv} ${uvLevel}`;
      }

      // 空气质量（高原地区通常优秀）
      if (airQuality) {
        airQuality.textContent = "优";
      }

      // 折多山路况（基于天气判断）
      if (roadCondition && roadIcon) {
        const roadInfo = getRoadCondition(weatherCode, temp);
        roadCondition.textContent = roadInfo.condition;
        roadIcon.textContent = roadInfo.icon;
      }

      // 穿着建议
      if (clothingAdvice) {
        clothingAdvice.textContent = getClothingAdvice(temp, feelsLike);
      }

      // 防晒建议
      if (sunscreenAdvice) {
        sunscreenAdvice.textContent = getSunscreenAdvice(uv);
      }

    } catch (error) {
      console.error("获取天气失败:", error);
      // 显示默认值
      weatherTemp.textContent = "15°C";
      weatherIcon.textContent = "☀️";
      if (windSpeed) windSpeed.textContent = "15km/h 轻风";
      if (uvIndex) uvIndex.textContent = "8 强";
      if (airQuality) airQuality.textContent = "优";
      if (roadCondition) roadCondition.textContent = "畅通";
      if (roadIcon) roadIcon.textContent = "🚗";
      if (clothingAdvice) clothingAdvice.textContent = "冲锋衣+抓绒";
      if (sunscreenAdvice) sunscreenAdvice.textContent = "SPF50+";
    }
  }

  function getWindLevel(speed) {
    if (speed < 12) return "微风";
    if (speed < 20) return "轻风";
    if (speed < 29) return "和风";
    if (speed < 39) return "清风";
    return "强风";
  }

  function getUVLevel(uv) {
    if (uv <= 2) return "弱";
    if (uv <= 5) return "中等";
    if (uv <= 7) return "强";
    if (uv <= 10) return "很强";
    return "极强";
  }

  function getRoadCondition(weatherCode, temp) {
    // 雪天或冰冻天气
    if ([179, 227, 230, 323, 326, 329, 332, 335, 338, 368, 371].includes(parseInt(weatherCode)) || temp < -5) {
      return { condition: "谨慎慢行", icon: "⚠️" };
    }
    // 雨天
    if ([176, 263, 266, 293, 296, 299, 302, 305, 308, 353].includes(parseInt(weatherCode))) {
      return { condition: "注意安全", icon: "🌧️" };
    }
    // 雾天
    if ([143, 248, 260].includes(parseInt(weatherCode))) {
      return { condition: "能见度低", icon: "🌫️" };
    }
    // 晴好天气
    return { condition: "路况良好", icon: "✅" };
  }

  function getClothingAdvice(temp, feelsLike) {
    const effectiveTemp = feelsLike || temp;
    if (effectiveTemp < 0) return "羽绒服+手套";
    if (effectiveTemp < 10) return "冲锋衣+抓绒";
    if (effectiveTemp < 18) return "轻羽绒+长袖";
    if (effectiveTemp < 25) return "长袖+薄外套";
    return "短袖+防晒衣";
  }

  function getSunscreenAdvice(uv) {
    if (uv <= 2) return "SPF30";
    if (uv <= 5) return "SPF30+ 常补";
    if (uv <= 7) return "SPF50+";
    if (uv <= 10) return "SPF50+ 戴帽";
    return "SPF50+ 全防护";
  }

  function getWeatherEmoji(code) {
    const weatherMap = {
      113: "☀️", // 晴天
      116: "⛅", // 多云
      119: "☁️", // 阴天
      122: "☁️", // 阴天
      143: "🌫️", // 雾
      176: "🌧️", // 小雨
      263: "🌦️", // 阵雨
      266: "🌦️", // 阵雨
      293: "🌧️", // 小雨
      296: "🌧️", // 小雨
      299: "🌧️", // 中雨
      302: "🌧️", // 中雨
      305: "🌧️", // 大雨
      308: "⛈️", // 暴雨
      179: "🌨️", // 小雪
      227: "🌨️", // 小雪
      230: "❄️", // 中雪
      323: "🌨️", // 小雪
      326: "🌨️", // 小雪
      329: "❄️", // 中雪
      332: "❄️", // 大雪
      335: "❄️", // 大雪
      338: "❄️", // 暴雪
      386: "⛈️", // 雷暴
      389: "⛈️", // 雷暴
    };
    return weatherMap[code] || "🌤️";
  }

  // 加载天气
  fetchWeather();

  // 初始化图片轮播
  function initGallerySlider() {
    const slider = document.getElementById('gallery-slider');
    if (!slider) return;

    const track = slider.querySelector('.gallery-track');
    const slides = slider.querySelectorAll('.gallery-slide');
    const dots = slider.querySelectorAll('.gallery-dot');
    const prevBtn = slider.querySelector('.gallery-nav--prev');
    const nextBtn = slider.querySelector('.gallery-nav--next');
    
    let currentIndex = 0;
    let autoplayInterval;

    function goToSlide(index) {
      // 更新transform位置
      const offset = -index * 100;
      track.style.transform = `translateX(${offset}%)`;
      
      // 更新圆点active状态
      dots.forEach(dot => dot.classList.remove('active'));
      dots[index].classList.add('active');
      
      currentIndex = index;
    }

    function nextSlide() {
      const next = (currentIndex + 1) % slides.length;
      goToSlide(next);
    }

    function prevSlide() {
      const prev = (currentIndex - 1 + slides.length) % slides.length;
      goToSlide(prev);
    }

    function startAutoplay() {
      autoplayInterval = setInterval(nextSlide, 4000);
    }

    function stopAutoplay() {
      if (autoplayInterval) {
        clearInterval(autoplayInterval);
      }
    }

    // 导航按钮事件
    if (prevBtn) {
      prevBtn.addEventListener('click', () => {
        prevSlide();
        stopAutoplay();
        startAutoplay();
      });
    }

    if (nextBtn) {
      nextBtn.addEventListener('click', () => {
        nextSlide();
        stopAutoplay();
        startAutoplay();
      });
    }

    // 圆点导航事件
    dots.forEach((dot, index) => {
      dot.addEventListener('click', () => {
        goToSlide(index);
        stopAutoplay();
        startAutoplay();
      });
    });

    // 鼠标悬停暂停自动播放
    slider.addEventListener('mouseenter', stopAutoplay);
    slider.addEventListener('mouseleave', startAutoplay);

    // 键盘导航
    document.addEventListener('keydown', (e) => {
      if (e.key === 'ArrowLeft') {
        prevSlide();
        stopAutoplay();
        startAutoplay();
      } else if (e.key === 'ArrowRight') {
        nextSlide();
        stopAutoplay();
        startAutoplay();
      }
    });

    // 添加触摸滑动支持
    let touchStartX = 0;
    let touchEndX = 0;

    slider.addEventListener('touchstart', (e) => {
      touchStartX = e.changedTouches[0].screenX;
    });

    slider.addEventListener('touchend', (e) => {
      touchEndX = e.changedTouches[0].screenX;
      handleSwipe();
    });

    function handleSwipe() {
      if (touchEndX < touchStartX - 50) {
        // 向左滑动
        nextSlide();
        stopAutoplay();
        startAutoplay();
      }
      if (touchEndX > touchStartX + 50) {
        // 向右滑动
        prevSlide();
        stopAutoplay();
        startAutoplay();
      }
    }

    // 启动自动播放
    startAutoplay();
  }

  // 初始化轮播
  initGallerySlider();

  // 初始化图片灯箱
  function initLightbox() {
    const lightbox = document.getElementById('lightbox');
    const lightboxImage = document.getElementById('lightbox-image');
    const lightboxCaption = document.getElementById('lightbox-caption');
    const closeBtn = lightbox?.querySelector('.lightbox__close');
    const galleryImages = document.querySelectorAll('.gallery-slide img');

    if (!lightbox || !lightboxImage) return;

    // 点击图片打开灯箱
    galleryImages.forEach((img) => {
      img.addEventListener('click', (e) => {
        e.stopPropagation(); // 防止触发轮播切换
        const caption = img.nextElementSibling?.textContent || img.alt;
        
        lightboxImage.src = img.src;
        lightboxImage.alt = img.alt;
        lightboxCaption.textContent = caption;
        
        // 添加active类触发显示
        lightbox.classList.add('active');
        document.body.style.overflow = 'hidden'; // 禁止页面滚动
      });
    });

    // 关闭灯箱的函数
    function closeLightbox() {
      lightbox.classList.remove('active');
      document.body.style.overflow = ''; // 恢复页面滚动
    }

    // 点击关闭按钮
    if (closeBtn) {
      closeBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        closeLightbox();
      });
    }

    // 点击背景关闭
    lightbox.addEventListener('click', closeLightbox);

    // 点击图片本身不关闭（避免误触）
    lightboxImage.addEventListener('click', (e) => {
      e.stopPropagation();
    });

    // ESC键关闭
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && lightbox.classList.contains('active')) {
        closeLightbox();
      }
    });
  }

  // 初始化灯箱
  initLightbox();

  // 初始化美食轮播
  function initFoodCarousel() {
    const foodTrack = document.getElementById('food-track');
    const prevBtn = document.querySelector('.food-carousel__nav--prev');
    const nextBtn = document.querySelector('.food-carousel__nav--next');
    
    if (!foodTrack || !prevBtn || !nextBtn) return;

    const cards = foodTrack.querySelectorAll('.food-card');
    const cardWidth = 280; // 卡片宽度 + gap
    const gap = 16; // gap大小
    let currentIndex = 0;
    const maxIndex = Math.max(0, cards.length - 3); // 最多显示3张卡片

    function updateCarousel() {
      const offset = -currentIndex * (cardWidth + gap);
      foodTrack.style.transform = `translateX(${offset}px)`;
      
      // 更新按钮状态
      prevBtn.style.opacity = currentIndex === 0 ? '0.5' : '1';
      nextBtn.style.opacity = currentIndex >= maxIndex ? '0.5' : '1';
      prevBtn.style.pointerEvents = currentIndex === 0 ? 'none' : 'auto';
      nextBtn.style.pointerEvents = currentIndex >= maxIndex ? 'none' : 'auto';
    }

    function nextSlide() {
      if (currentIndex < maxIndex) {
        currentIndex++;
        updateCarousel();
      }
    }

    function prevSlide() {
      if (currentIndex > 0) {
        currentIndex--;
        updateCarousel();
      }
    }

    // 按钮事件
    prevBtn.addEventListener('click', prevSlide);
    nextBtn.addEventListener('click', nextSlide);

    // 键盘导航
    document.addEventListener('keydown', (e) => {
      if (e.key === 'ArrowLeft') {
        prevSlide();
      } else if (e.key === 'ArrowRight') {
        nextSlide();
      }
    });

    // 触摸滑动支持
    let touchStartX = 0;
    let touchEndX = 0;

    foodTrack.addEventListener('touchstart', (e) => {
      touchStartX = e.changedTouches[0].screenX;
    });

    foodTrack.addEventListener('touchend', (e) => {
      touchEndX = e.changedTouches[0].screenX;
      handleSwipe();
    });

    function handleSwipe() {
      if (touchEndX < touchStartX - 50) {
        nextSlide();
      }
      if (touchEndX > touchStartX + 50) {
        prevSlide();
      }
    }

    // 初始化
    updateCarousel();
  }

  // 初始化美食轮播
  initFoodCarousel();

  // 初始化二维码功能
  function initQRCode() {
    const qrTrigger = document.querySelector('.qr-trigger');
    const qrPopup = document.querySelector('.qr-popup');
    
    if (!qrTrigger || !qrPopup) return;

    // 点击触发二维码显示/隐藏
    qrTrigger.addEventListener('click', (e) => {
      e.stopPropagation();
      const isVisible = qrPopup.style.opacity === '1';
      
      if (isVisible) {
        hideQRPopup();
      } else {
        showQRPopup();
      }
    });

    // 点击页面其他地方隐藏二维码
    document.addEventListener('click', (e) => {
      if (!qrTrigger.contains(e.target) && !qrPopup.contains(e.target)) {
        hideQRPopup();
      }
    });

    // ESC键隐藏二维码
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') {
        hideQRPopup();
      }
    });

    function showQRPopup() {
      qrPopup.style.opacity = '1';
      qrPopup.style.visibility = 'visible';
      qrPopup.style.transform = 'translateY(0) scale(1)';
      qrPopup.style.pointerEvents = 'auto';
      
      // 添加动画类
      qrPopup.classList.add('qr-popup--active');
    }

    function hideQRPopup() {
      qrPopup.style.opacity = '0';
      qrPopup.style.visibility = 'hidden';
      qrPopup.style.transform = 'translateY(-10px) scale(0.95)';
      qrPopup.style.pointerEvents = 'none';
      
      // 移除动画类
      qrPopup.classList.remove('qr-popup--active');
    }

    // 移动端触摸支持
    let touchStartTime = 0;
    qrTrigger.addEventListener('touchstart', (e) => {
      touchStartTime = Date.now();
    });

    qrTrigger.addEventListener('touchend', (e) => {
      const touchDuration = Date.now() - touchStartTime;
      if (touchDuration < 500) { // 短按视为点击
        e.preventDefault();
        const isVisible = qrPopup.style.opacity === '1';
        if (isVisible) {
          hideQRPopup();
        } else {
          showQRPopup();
        }
      }
    });
  }

  // 初始化二维码功能
  initQRCode();
});
