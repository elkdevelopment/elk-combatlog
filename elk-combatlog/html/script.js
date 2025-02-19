window.addEventListener('message', function(event) {
    let data = event.data;

    if (data.action === 'copy') {
        let textArea = document.createElement('textarea');
        textArea.value = data.text;
        document.body.appendChild(textArea);
        textArea.select();
        document.execCommand('copy');
        document.body.removeChild(textArea);
    }
});
