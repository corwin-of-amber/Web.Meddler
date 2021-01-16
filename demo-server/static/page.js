
function send_some_stuff() {
    $.ajax("/", {
        method: "POST",
        data: "buck",
        dataType: "text",
        contentType: "text/plain",
        mimeType: "text/plain"
    })
    .then((reply) => {
        console.log(reply);
        $('#resp').text(new Date() + " " + reply);
    })
    .catch((err) => console.error(err));
}

