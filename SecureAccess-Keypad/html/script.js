const buttons = document.querySelectorAll('.button');
const passwordInput = document.getElementById('password-input');
const screen = document.getElementById('screen');
const screenContent = document.querySelector('.screen-content');
const onOffButton = document.getElementById('on-off-button');
const errorSound = document.getElementById('error-sound');
let password = '';
let isOn = false;

function resetScreen() {
    password = '';
    passwordInput.textContent = '';
    screen.style.backgroundColor = 'rgba(0, 255, 0, 0.178)';
    screenContent.style.color = '#0f0';
}

buttons.forEach(button => {
    button.addEventListener('click', () => {
        const value = button.textContent;
        if (isOn && value !== 'ON' && value !== 'OFF') {
            password += value;
            passwordInput.textContent = password;
        }
    });
});

document.querySelector('.button-red').addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/closeUI`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        }
    }).then(() => {
        document.body.style.display = 'none';
    });
});

document.querySelector('.button-green').addEventListener('click', () => {
    if (isOn) {
        fetch(`https://${GetParentResourceName()}/submitPassword`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({ password: password })
        }).then(resp => resp.json()).then(resp => {
            if (resp === 'ok') {
                password = '';
                passwordInput.textContent = '';
                fetch(`https://${GetParentResourceName()}/closeUI`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json; charset=UTF-8',
                    }
                }).then(() => {
                    document.body.style.display = 'none';
                });
            } else {
                screen.style.backgroundColor = 'rgba(255, 0, 0, 0.178)';
                screenContent.style.color = '#f00';
                passwordInput.textContent = 'ERROR';
                errorSound.play();
                setTimeout(() => {
                    fetch(`https://${GetParentResourceName()}/closeUI`, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json; charset=UTF-8',
                        }
                    }).then(() => {
                        document.body.style.display = 'none';
                        resetScreen();
                    });
                }, 2000); 
            }
        });
    }
});

document.querySelector('.button-yellow').addEventListener('click', () => {
    if (isOn) {
        password = password.slice(0, -1);
        passwordInput.textContent = password;
    }
});

onOffButton.addEventListener('click', () => {
    isOn = !isOn;
    onOffButton.textContent = 'OFF';
    if (isOn) {
        onOffButton.textContent = 'ON';
        screen.style.opacity = '1';
        screenContent.style.opacity = '1';
    } else {
        onOffButton.textContent = 'OFF';
        screen.style.opacity = '0.2';
        screenContent.style.opacity = '0.2';
    }
});

window.addEventListener('message', (event) => {
    if (event.data.action === 'openKeypad') {
        document.body.style.display = 'block';
        resetScreen();
    }
});
