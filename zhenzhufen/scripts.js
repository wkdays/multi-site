(function () {
  const header = document.querySelector('.site-header');
  const navToggle = document.querySelector('.main-nav__toggle');
  const navList = document.querySelector('.main-nav__list');

  function updateHeaderState() {
    if (!header) return;
    header.classList.toggle('is-scrolled', window.scrollY > 12);
  }

  window.addEventListener('scroll', updateHeaderState, { passive: true });
  updateHeaderState();

  if (navToggle && navList) {
    navToggle.addEventListener('click', () => {
      const expanded = navToggle.getAttribute('aria-expanded') === 'true';
      navToggle.setAttribute('aria-expanded', String(!expanded));
    });

    navList.addEventListener('click', (event) => {
      if (event.target instanceof HTMLAnchorElement) {
        navToggle.setAttribute('aria-expanded', 'false');
      }
    });
  }

  const revealElements = document.querySelectorAll('.reveal');
  if ('IntersectionObserver' in window && revealElements.length) {
    const observer = new IntersectionObserver(
      (entries, obs) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add('is-visible');
            obs.unobserve(entry.target);
          }
        });
      },
      {
        threshold: 0.15,
        rootMargin: '0px 0px -10% 0px',
      }
    );

    revealElements.forEach((el) => observer.observe(el));
  } else {
    revealElements.forEach((el) => el.classList.add('is-visible'));
  }

  const stats = document.querySelectorAll('[data-count]');
  if (stats.length) {
    const formatNumber = (value) => {
      if (value >= 10000) {
        return `${Math.round(value / 100) / 100}万+`;
      }
      return value.toString();
    };

    const animateCount = (el) => {
      const target = Number(el.dataset.count);
      if (!Number.isFinite(target)) return;
      const duration = 1200;
      const start = performance.now();

      const step = (time) => {
        const progress = Math.min((time - start) / duration, 1);
        const eased = progress < 0.5 ? 2 * progress * progress : -1 + (4 - 2 * progress) * progress;
        const current = Math.floor(eased * target);
        el.textContent = formatNumber(progress === 1 ? target : current);
        if (progress < 1) {
          requestAnimationFrame(step);
        }
      };

      requestAnimationFrame(step);
    };

    if ('IntersectionObserver' in window) {
      const statObserver = new IntersectionObserver(
        (entries, obs) => {
          entries.forEach((entry) => {
            if (entry.isIntersecting) {
              animateCount(entry.target);
              obs.unobserve(entry.target);
            }
          });
        },
        {
          threshold: 0.4,
        }
      );

      stats.forEach((el) => statObserver.observe(el));
    } else {
      stats.forEach((el) => animateCount(el));
    }
  }

  const slider = document.querySelector('[data-slider]');
  if (slider) {
    const track = slider.querySelector('.product-slider__track');
    const slides = Array.from(slider.querySelectorAll('.product-slider__slide'));
    const prev = slider.querySelector('[data-slider-prev]');
    const next = slider.querySelector('[data-slider-next]');
    let currentIndex = 0;
    let autoTimer;

    const getSlideWidth = () => {
      if (!slides.length) return 0;
      const style = window.getComputedStyle(slides[0]);
      const margin = parseFloat(style.marginLeft) + parseFloat(style.marginRight);
      return slides[0].offsetWidth + margin;
    };

    const updateSlider = () => {
      const slideWidth = getSlideWidth();
      if (!slideWidth) return;
      const offset = currentIndex * slideWidth;
      track.style.transform = `translateX(-${offset}px)`;
    };

    const goTo = (index) => {
      if (!slides.length) return;
      const total = slides.length;
      currentIndex = (index + total) % total;
      updateSlider();
    };

    const goNext = () => goTo(currentIndex + 1);
    const goPrev = () => goTo(currentIndex - 1);

    const startAutoPlay = () => {
      stopAutoPlay();
      autoTimer = window.setInterval(goNext, 6000);
    };

    const stopAutoPlay = () => {
      if (autoTimer) {
        window.clearInterval(autoTimer);
        autoTimer = undefined;
      }
    };

    next?.addEventListener('click', () => {
      goNext();
      startAutoPlay();
    });
    prev?.addEventListener('click', () => {
      goPrev();
      startAutoPlay();
    });

    slider.addEventListener('mouseenter', stopAutoPlay);
    slider.addEventListener('mouseleave', startAutoPlay);

    window.addEventListener('resize', () => {
      updateSlider();
    });

    startAutoPlay();
    updateSlider();
  }

  const form = document.getElementById('contact-form');
  if (form) {
    const successMessage = form.querySelector('.form-success');

    const validators = {
      name: (value) => (value.trim() ? '' : '请填写您的姓名'),
      phone: (value) => (value.trim() ? '' : '请填写联系电话'),
      email: (value) => {
        if (!value) return '';
        return /\S+@\S+\.\S+/.test(value) ? '' : '请输入有效的邮箱地址';
      },
      type: (value) => (value ? '' : '请选择需求类型'),
      message: (value) => (value.trim().length >= 6 ? '' : '请至少输入 6 个字描述您的需求'),
    };

    const showError = (field, message) => {
      const errorEl = form.querySelector(`[data-error-for="${field.name}"]`);
      if (errorEl) errorEl.textContent = message;
    };

    form.addEventListener('submit', (event) => {
      event.preventDefault();
      let hasError = false;

      Object.entries(validators).forEach(([key, validate]) => {
        const field = form.elements.namedItem(key);
        if (field instanceof HTMLInputElement || field instanceof HTMLTextAreaElement || field instanceof HTMLSelectElement) {
          const message = validate(field.value);
          showError(field, message);
          if (message) {
            hasError = true;
          }
        }
      });

      if (!hasError) {
        successMessage.textContent = '提交成功！我们将尽快与您联系。';
        form.reset();
        window.setTimeout(() => {
          successMessage.textContent = '';
        }, 6000);
      } else {
        successMessage.textContent = '';
      }
    });

    form.addEventListener('input', (event) => {
      const target = event.target;
      if (!(target instanceof HTMLInputElement || target instanceof HTMLTextAreaElement || target instanceof HTMLSelectElement)) return;
      const validate = validators[target.name];
      if (!validate) return;
      const message = validate(target.value);
      showError(target, message);
    });
  }

  const anchorLinks = document.querySelectorAll('a[href^="#"]');
  anchorLinks.forEach((link) => {
    link.addEventListener('click', (event) => {
      const href = link.getAttribute('href');
      if (!href || href.length <= 1) return;
      const target = document.querySelector(href);
      if (!target) return;
      event.preventDefault();
      target.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });
  });

  // 滚动提示框功能
  const scrollingTip = document.querySelector('.scrolling-tip__title');
  const tooltipContent = document.querySelector('.tooltip-content');
  
  if (scrollingTip && tooltipContent) {
    let hoverTimeout;
    
    scrollingTip.addEventListener('mouseenter', () => {
      clearTimeout(hoverTimeout);
      tooltipContent.setAttribute('aria-hidden', 'false');
    });
    
    scrollingTip.addEventListener('mouseleave', () => {
      hoverTimeout = setTimeout(() => {
        tooltipContent.setAttribute('aria-hidden', 'true');
      }, 100);
    });
    
    // 防止鼠标移到提示框时消失
    tooltipContent.addEventListener('mouseenter', () => {
      clearTimeout(hoverTimeout);
    });
    
    tooltipContent.addEventListener('mouseleave', () => {
      tooltipContent.setAttribute('aria-hidden', 'true');
    });
  }

  // 功能横条展开/收起功能
  const moreButtons = document.querySelectorAll('.feature-more-btn');
  
  moreButtons.forEach(button => {
    button.addEventListener('click', () => {
      const content = button.parentElement.querySelector('.feature-text[data-expandable="true"]');
      const moreText = button.querySelector('.more-text');
      const lessText = button.querySelector('.less-text');
      
      if (content) {
        const isExpanded = content.classList.contains('expanded');
        
        if (isExpanded) {
          // 收起
          content.classList.remove('expanded');
          moreText.style.display = 'inline';
          lessText.style.display = 'none';
          button.setAttribute('aria-label', '展开查看完整内容');
        } else {
          // 展开
          content.classList.add('expanded');
          moreText.style.display = 'none';
          lessText.style.display = 'inline';
          button.setAttribute('aria-label', '收起内容');
        }
      }
    });
  });
})();
