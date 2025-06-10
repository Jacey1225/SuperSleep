// const choiceButtons = document.querySelectorAll('.selectable');
// const continueBtn = document.getElementById('continueBtn');

// choiceButtons.forEach(button => {
// button.addEventListener('click', () => {
//     button.classList.toggle('active');

//     // Enable "Continue" if at least one choice is active
//     const oneSelected = document.querySelectorAll('.choices.active').length > 0;
//     continueBtn.disabled = !oneSelected;

//     // Optional: Add hover/active color change
//     continueBtn.style.backgroundColor = oneSelected ? '#463f88' : '#2F2F37';
//     continueBtn.style.color = oneSelected ? '#fff' : '#ffffff';
// });
// });




const choiceButtons = document.querySelectorAll('.selectable');
const continueBtn = document.getElementById('continueBtn');
const whiteBox = document.getElementById('whiteBox');

choiceButtons.forEach(button => {
  button.addEventListener('click', () => {
    // Remove 'active' from all buttons
    choiceButtons.forEach(btn => btn.classList.remove('active'));

    // Add 'active' to the clicked one
    button.classList.add('active');

    // Enable continue button and show white box
    continueBtn.disabled = false;
    continueBtn.style.backgroundColor = '#463f88';
    continueBtn.style.color = '#fff';

    // Show the white box
    whiteBox.style.display = 'block';
  });
});
