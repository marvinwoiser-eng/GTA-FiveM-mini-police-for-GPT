window.addEventListener("message", function(event) {
    if (event.data.action === "copy") {

        const text = event.data.text;

        const tempInput = document.createElement("textarea");
        tempInput.value = text;
        document.body.appendChild(tempInput);

        tempInput.select();
        document.execCommand("copy");

        document.body.removeChild(tempInput);
    }
});