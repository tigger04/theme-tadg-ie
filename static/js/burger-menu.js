// Burger menu functionality
document.addEventListener('DOMContentLoaded', function() {
    const burgerToggle = document.getElementById('burger-toggle');
    const mainNav = document.getElementById('main-nav');
    const dropdowns = document.querySelectorAll('.nav-dropdown');
    
    // Toggle burger menu
    burgerToggle.addEventListener('click', function() {
        burgerToggle.classList.toggle('open');
        mainNav.classList.toggle('open');
        
        // Prevent body scroll when menu is open
        if (mainNav.classList.contains('open')) {
            document.body.style.overflow = 'hidden';
        } else {
            document.body.style.overflow = '';
        }
    });
    
    // Close menu when clicking outside (mobile)
    document.addEventListener('click', function(event) {
        if (window.innerWidth <= 768) {
            const isClickInsideNav = mainNav.contains(event.target);
            const isClickOnBurger = burgerToggle.contains(event.target);
            
            if (!isClickInsideNav && !isClickOnBurger && mainNav.classList.contains('open')) {
                burgerToggle.classList.remove('open');
                mainNav.classList.remove('open');
                document.body.style.overflow = '';
            }
        }
    });
    
    // Handle dropdown behavior on mobile
    dropdowns.forEach(dropdown => {
        const dropdownBtn = dropdown.querySelector('.nav-dropdown-btn');
        
        dropdownBtn.addEventListener('click', function(event) {
            if (window.innerWidth <= 768) {
                event.preventDefault();
                dropdown.classList.toggle('open');
            }
        });
    });
    
    // Close menu on window resize if it gets larger
    window.addEventListener('resize', function() {
        if (window.innerWidth > 768) {
            burgerToggle.classList.remove('open');
            mainNav.classList.remove('open');
            document.body.style.overflow = '';
            
            // Close all dropdowns
            dropdowns.forEach(dropdown => {
                dropdown.classList.remove('open');
            });
        }
    });
    
    // Close menu when a link is clicked (mobile)
    const navLinks = mainNav.querySelectorAll('a:not(.nav-dropdown-btn)');
    navLinks.forEach(link => {
        link.addEventListener('click', function() {
            if (window.innerWidth <= 768 && mainNav.classList.contains('open')) {
                burgerToggle.classList.remove('open');
                mainNav.classList.remove('open');
                document.body.style.overflow = '';
            }
        });
    });
});
