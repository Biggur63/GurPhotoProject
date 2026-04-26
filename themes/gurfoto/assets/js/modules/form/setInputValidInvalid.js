export const setInputInvalid = (input) => {
    const errorMsg = input.parentNode.querySelector('.form__err-msg');
    errorMsg.hidden = false;
    input.setAttribute('aria-invalid', 'true');
    input.setAttribute('aria-describedby', `form-${input.name}-err-msg`);
}   

export const setInputValid = (input) => {
    const errorMsg = input.parentNode.querySelector('.form__err-msg');
    errorMsg.hidden = true;
    input.setAttribute('aria-invalid', 'false');
    input.removeAttribute('aria-describedby');
}