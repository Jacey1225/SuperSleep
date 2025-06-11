const checkboxes = document.querySelectorAll('.device-checkbox');
const continueBtn = document.getElementById('continueBtn');

function updateContinueButtonState() {
  const atLeastOneChecked = Array.from(checkboxes).some(cb => cb.checked);
  if (atLeastOneChecked) {
    continueBtn.disabled = false;
    continueBtn.style.backgroundColor = '#7C6FF0';
    continueBtn.style.color = 'white';
  } else {
    continueBtn.disabled = true;
    continueBtn.style.backgroundColor = '#2F2F37';
    continueBtn.style.color = '#A0A3B4';
  }
}

checkboxes.forEach(cb => cb.addEventListener('change', updateContinueButtonState));
