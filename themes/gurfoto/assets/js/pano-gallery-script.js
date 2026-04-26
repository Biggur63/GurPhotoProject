console.log("pano-gallery-script.js loaded");

const galleries = document.querySelectorAll(".sc-gallery");
const dialog = document.querySelector(".gallery-dialog");
const dialogCloseBtn = dialog.querySelector(".gallery-dialog__close");
const iframe = dialog.querySelector("iframe");
let scrollPosition = 0;

galleries.forEach((gallery) => {
	gallery.addEventListener("click", (e) => {
		if (e.target.tagName === "IMG") {
			const src = e.target.dataset.iframesrc;
			console.log(e.target.dataset.iframesrc);
			iframe.src = src;
			openDialog();
		}
	});
});

dialogCloseBtn.addEventListener("click", () => {
	closeDialog();
});

dialog.addEventListener("click", (e) => {
	const dialogDimensions = dialog.getBoundingClientRect();
	if (
		e.clientX < dialogDimensions.left ||
		e.clientX > dialogDimensions.right ||
		e.clientY < dialogDimensions.top ||
		e.clientY > dialogDimensions.bottom
	) {
		closeDialog();
	}
});

dialog.addEventListener("cancel", (e) => {
	closeDialog();
	e.preventDefault();
});

// Prevent touchmove events on iOS when dialog is open
document.addEventListener(
	"touchmove",
	(e) => {
		if (dialog.open && !dialog.contains(e.target)) {
			e.preventDefault();
		}
	},
	{ passive: false },
);

function openDialog() {
	scrollPosition = window.scrollY;
	document.body.classList.add("dialog-open");
	document.body.style.top = `-${scrollPosition}px`;
	dialog.showModal();
}

function closeDialog() {
	document.body.classList.remove("dialog-open");
	document.body.style.top = "";
	window.scrollTo({
		left: 0,
		top: scrollPosition,
		behavior: "instant",
	});
	dialog.close();
}
