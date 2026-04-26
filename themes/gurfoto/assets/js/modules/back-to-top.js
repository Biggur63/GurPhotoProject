const btnBTT = document.querySelector('.back-to-top');

window.addEventListener('scroll', () => {
    const isBtnVisible = window.scrollY > window.innerHeight * 0.5;
    btnBTT.style.visibility = isBtnVisible ? 'visible' : 'hidden';
});
