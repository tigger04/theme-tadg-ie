// ABOUTME: JavaScript masonry layout with CSS Grid fallback
// ABOUTME: Positions items absolutely using shortest-column algorithm

(function() {
  'use strict';

  var resizeTimeout = null;
  var GAP = 24; // Gap between items in pixels

  /**
   * Calculate number of columns based on viewport width in em units.
   * Uses the computed root font size to adapt layout when users change
   * their browser font size preferences (WCAG 2.1 compliance).
   * Breakpoints match CSS media queries in custom.css.
   *
   * Constraint: Min 2, max 5 columns total (including sidebar).
   * - Without sidebar: 2-5 content columns
   * - With sidebar: sidebar is ALWAYS visible, so 1-4 content columns
   */
  function getColumnCount() {
    // Get computed font size of root element (respects user preferences)
    var rootFontSize = parseFloat(
      getComputedStyle(document.documentElement).fontSize
    );
    // Convert viewport width to em units
    var widthInEm = window.innerWidth / rootFontSize;

    // Check if sidebar is present - sidebar is ALWAYS a column when present
    var hasSidebar = document.querySelector('.sidebar-layout') !== null;

    // Base column count (without sidebar consideration)
    // Min 2, max 5 columns total
    var columns;
    if (widthInEm < 48) {
      columns = 2; // Mobile/small tablet: 2 columns
    } else if (widthInEm < 64) {
      columns = 3; // Tablet: 3 columns
    } else if (widthInEm < 80) {
      columns = 4; // Desktop: 4 columns
    } else {
      columns = 5; // Large desktop: max 5 columns
    }

    // If sidebar exists, it ALWAYS takes one column, reduce content columns
    // (sidebar + content columns = total columns)
    if (hasSidebar) {
      columns = Math.max(1, columns - 1);
    }

    return columns;
  }

  /**
   * Apply masonry layout using absolute positioning
   */
  function layoutMasonry() {
    var grid = document.querySelector('.masonry-grid');
    if (!grid) return;

    var items = Array.from(grid.querySelectorAll('.masonry-item'));
    if (items.length === 0) return;

    var columnCount = getColumnCount();

    // Fallback: if somehow we get 1 or fewer columns, use natural flow
    if (columnCount <= 1) {
      grid.classList.remove('masonry-js-active');
      grid.style.position = '';
      grid.style.height = '';
      items.forEach(function(item) {
        item.style.position = '';
        item.style.left = '';
        item.style.top = '';
        item.style.width = '';
      });
      return;
    }

    // Set up grid for absolute positioning
    grid.classList.add('masonry-js-active');
    grid.style.position = 'relative';

    var gridWidth = grid.clientWidth;
    // Guard against zero width (hidden element or rendering issue)
    if (gridWidth <= 0) {
      setTimeout(layoutMasonry, 100);
      return;
    }

    var columnWidth = (gridWidth - (GAP * (columnCount - 1))) / columnCount;

    // Track height of each column
    var columnHeights = new Array(columnCount).fill(0);
    var positionedCount = 0;

    // Position each item with error handling
    items.forEach(function(item, index) {
      try {
        // Set item width first so we can measure height
        item.style.width = columnWidth + 'px';
        item.style.position = 'absolute';

        // Find shortest column
        var shortestColumn = 0;
        var shortestHeight = columnHeights[0];
        for (var i = 1; i < columnCount; i++) {
          if (columnHeights[i] < shortestHeight) {
            shortestColumn = i;
            shortestHeight = columnHeights[i];
          }
        }

        // Calculate position
        var left = shortestColumn * (columnWidth + GAP);
        var top = columnHeights[shortestColumn];

        // Apply position
        item.style.left = left + 'px';
        item.style.top = top + 'px';

        // Get actual rendered height and update column height
        var itemHeight = item.offsetHeight;
        // Guard against zero height items
        if (itemHeight <= 0) {
          itemHeight = 200; // Default minimum height
        }
        columnHeights[shortestColumn] = top + itemHeight + GAP;
        positionedCount++;
      } catch (e) {
        // Log error but continue positioning other items
        console.error('Masonry layout error for item ' + index + ':', e);
      }
    });

    // Set container height to tallest column
    var maxHeight = Math.max.apply(null, columnHeights);
    // Ensure minimum height if calculation failed
    if (maxHeight <= GAP) {
      maxHeight = items.length * 250; // Fallback estimate
    }
    grid.style.height = (maxHeight - GAP) + 'px';
  }

  /**
   * Wait for all images then layout
   */
  function initMasonry() {
    var grid = document.querySelector('.masonry-grid');
    if (!grid) return;

    var images = grid.querySelectorAll('img');
    var loadedCount = 0;
    var totalImages = images.length;

    function onImageReady() {
      loadedCount++;
      if (loadedCount >= totalImages) {
        // Small delay to ensure CSS is fully applied
        requestAnimationFrame(function() {
          requestAnimationFrame(layoutMasonry);
        });
      }
    }

    // Initial layout (before images load, to show something)
    requestAnimationFrame(layoutMasonry);

    if (totalImages === 0) {
      return;
    }

    // Re-layout after all images load
    images.forEach(function(img) {
      if (img.complete && img.naturalHeight !== 0) {
        onImageReady();
      } else {
        img.addEventListener('load', onImageReady);
        img.addEventListener('error', onImageReady);
      }
    });

    // Fallback: re-layout after timeout
    setTimeout(layoutMasonry, 3000);
  }

  /**
   * Debounced resize handler
   */
  function handleResize() {
    if (resizeTimeout) {
      clearTimeout(resizeTimeout);
    }
    resizeTimeout = setTimeout(layoutMasonry, 150);
  }

  // Initialise on DOM ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initMasonry);
  } else {
    initMasonry();
  }

  // Handle resize
  window.addEventListener('resize', handleResize);

  // Handle orientation change on mobile
  window.addEventListener('orientationchange', function() {
    setTimeout(layoutMasonry, 100);
  });

  // Expose for manual re-layout
  window.masonryLayout = layoutMasonry;
  window.masonryInit = initMasonry;
})();
