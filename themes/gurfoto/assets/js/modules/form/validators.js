export default (input) => {
    
    if (input.required) {
        if (input.type === 'checkbox' && !input.checked) return false;
        if (!input.value.trim()) return false;
    }

    if (input.type === 'email') {
        const re = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
        if (!re.test(input.value.trim())) {
            return false;
        }
    }

    if (input.hasAttribute('minlength')) {
        if (input.value.trim().length < +input.getAttribute('minlength')) {
            return false;
        }
    }
    
    if (input.hasAttribute('maxlength')) {
        if (input.value.length > +input.getAttribute('maxlength')) {
            return false;
        }
    }
    
    if (input.hasAttribute('pattern')) {
        const regex = new RegExp(`^${input.getAttribute('pattern')}$`);
        if (regex.test(input.value.trim()) === false) {
            return false;
        }
    }

    return true;
}   
