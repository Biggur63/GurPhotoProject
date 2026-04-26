export const showMsgDialog = (className, timer = 15000) => {
    const msgDialog = document.querySelector(className);
    const closeBtn = msgDialog.querySelector('.sdialog__close-btn');

    msgDialog.showModal();

    setTimeout(() => {
        msgDialog.close();
        return true;
    }, timer)
    
    closeBtn.addEventListener('click', () => {
        msgDialog.close();
        return true;
    },  { once: true })    
}

export const showFormLoader = (cForm, action = 'hide') => {
    const submitBtn = cForm.querySelector('[type=submit]');
    const label = submitBtn.querySelector('.label');
    const loader = submitBtn.querySelector('.loader');
    
    if (action === 'show') {
        submitBtn.disabled = true;
        label.hidden = true;
        loader.hidden = false;
    } else {
        submitBtn.disabled = false;
        loader.hidden = true;
        label.hidden = false;
    }
};