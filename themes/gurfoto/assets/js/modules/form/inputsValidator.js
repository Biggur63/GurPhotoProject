import validators from "./validators";
import { setInputInvalid, setInputValid } from "./setInputValidInvalid";

export const inputsValidator = (inputs) => {
    inputs.forEach(input => {
        input.addEventListener('input', () => {
            if (validators(input)) {
                input.setAttribute('aria-invalid', 'false');
            } else {
                input.removeAttribute('aria-invalid');
            }
        })
        
        input.addEventListener('change', () => {
            if (validators(input)) {
                setInputValid(input)
            } else {
                setInputInvalid(input);
            }
        })
    })
}