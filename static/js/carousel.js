// ABOUTME: Carousel card rotation with crossfade, auto-advance, hover pause, and arrow navigation.
// ABOUTME: Only activates when multiple carousel cards exist; single card is static.

(function () {
  var container = document.querySelector(".carousel-container");
  if (!container) return;

  var cards = container.querySelectorAll(".carousel-card");
  if (cards.length <= 1) return;

  var interval = (parseInt(container.dataset.interval, 10) || 6) * 1000;
  var current = 0;
  var timer = null;
  var paused = false;

  function showCard(index) {
    for (var i = 0; i < cards.length; i++) {
      cards[i].classList.remove("carousel-active");
    }
    cards[index].classList.add("carousel-active");
    current = index;
  }

  function next() {
    showCard((current + 1) % cards.length);
  }

  function prev() {
    showCard((current - 1 + cards.length) % cards.length);
  }

  function startTimer() {
    if (timer) clearInterval(timer);
    timer = setInterval(function () {
      if (!paused) next();
    }, interval);
  }

  // Pause on hover
  container.addEventListener("mouseenter", function () {
    paused = true;
  });
  container.addEventListener("mouseleave", function () {
    paused = false;
  });

  // Arrow buttons
  var leftArrow = container.querySelector(".carousel-arrow-left");
  var rightArrow = container.querySelector(".carousel-arrow-right");

  if (leftArrow) {
    leftArrow.addEventListener("click", function () {
      prev();
      startTimer();
    });
  }
  if (rightArrow) {
    rightArrow.addEventListener("click", function () {
      next();
      startTimer();
    });
  }

  // Keyboard navigation when carousel is focused/hovered
  container.setAttribute("tabindex", "0");
  container.addEventListener("keydown", function (e) {
    if (e.key === "ArrowLeft") {
      prev();
      startTimer();
    } else if (e.key === "ArrowRight") {
      next();
      startTimer();
    }
  });

  startTimer();
})();
