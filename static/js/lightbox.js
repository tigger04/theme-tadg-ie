// ABOUTME: Simple lightbox for gallery images with keyboard navigation
// ABOUTME: Supports picture elements with WebP sources and EXIF-based captions
(function() {
  'use strict';

  let currentImageIndex = 0;
  let galleryImages = [];

  function initLightbox() {
    // Create lightbox element if it doesn't exist
    if (!document.getElementById('lightbox')) {
      const lightboxHTML = `
        <div id="lightbox" class="lightbox">
          <span class="lightbox-close">&times;</span>
          <span class="lightbox-nav lightbox-prev">&#8249;</span>
          <span class="lightbox-nav lightbox-next">&#8250;</span>
          <img id="lightbox-image" src="" alt="">
          <div id="lightbox-caption" class="lightbox-caption"></div>
        </div>
      `;
      document.body.insertAdjacentHTML('beforeend', lightboxHTML);
    }

    const lightbox = document.getElementById('lightbox');
    const lightboxImg = document.getElementById('lightbox-image');
    const lightboxCaption = document.getElementById('lightbox-caption');
    const closeBtn = document.querySelector('.lightbox-close');
    const prevBtn = document.querySelector('.lightbox-prev');
    const nextBtn = document.querySelector('.lightbox-next');

    // Collect all gallery images
    const galleryLinks = document.querySelectorAll('.gallery-image-link');
    galleryImages = Array.from(galleryLinks);

    // Add click handlers to gallery images
    galleryImages.forEach((link, index) => {
      link.addEventListener('click', function(e) {
        e.preventDefault();
        currentImageIndex = index;
        showImage(currentImageIndex);
      });
    });

    // Close lightbox
    function closeLightbox() {
      lightbox.classList.remove('active');
    }

    closeBtn.addEventListener('click', closeLightbox);

    lightbox.addEventListener('click', function(e) {
      if (e.target === lightbox) {
        closeLightbox();
      }
    });

    // Navigation
    prevBtn.addEventListener('click', function(e) {
      e.stopPropagation();
      currentImageIndex = (currentImageIndex - 1 + galleryImages.length) % galleryImages.length;
      showImage(currentImageIndex);
    });

    nextBtn.addEventListener('click', function(e) {
      e.stopPropagation();
      currentImageIndex = (currentImageIndex + 1) % galleryImages.length;
      showImage(currentImageIndex);
    });

    // Keyboard navigation
    document.addEventListener('keydown', function(e) {
      if (!lightbox.classList.contains('active')) return;

      if (e.key === 'Escape') {
        closeLightbox();
      } else if (e.key === 'ArrowLeft') {
        currentImageIndex = (currentImageIndex - 1 + galleryImages.length) % galleryImages.length;
        showImage(currentImageIndex);
      } else if (e.key === 'ArrowRight') {
        currentImageIndex = (currentImageIndex + 1) % galleryImages.length;
        showImage(currentImageIndex);
      }
    });

    function showImage(index) {
      const link = galleryImages[index];
      const picture = link.querySelector('picture');
      const img = link.querySelector('img');

      // Get full-size image URL
      let fullSrc = img.src;
      let srcsetToUse = img.srcset;

      // If picture element exists, check for WebP source first
      if (picture) {
        const webpSource = picture.querySelector('source[type="image/webp"]');
        if (webpSource && webpSource.srcset) {
          srcsetToUse = webpSource.srcset;
        }
      }

      // Try to get the largest srcset version
      if (srcsetToUse) {
        const sources = srcsetToUse.split(',').map(s => {
          const parts = s.trim().split(/\s+/);
          const url = parts[0];
          const descriptor = parts[1];
          // Parse width (e.g., "800w") or density (e.g., "2x")
          const width = descriptor && descriptor.endsWith('w')
            ? parseInt(descriptor)
            : 0;
          return { url, width };
        });

        // Get largest by width
        const largest = sources.reduce((max, curr) =>
          curr.width > max.width ? curr : max
        );
        if (largest.url) fullSrc = largest.url;
      }

      lightboxImg.src = fullSrc;
      lightboxImg.alt = img.alt;

      // Set caption (using textContent to prevent XSS)
      const captionDiv = link.parentElement.querySelector('.gallery-item-caption');
      if (captionDiv) {
        lightboxCaption.textContent = captionDiv.textContent;
        lightboxCaption.style.display = 'block';
      } else {
        lightboxCaption.style.display = 'none';
      }

      lightbox.classList.add('active');
    }
  }

  // Initialize when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initLightbox);
  } else {
    initLightbox();
  }
})();
