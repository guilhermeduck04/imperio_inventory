const NotifysType = {
    "error": "linear-gradient(to right, #ff3737c7, #b02020c7)",
    "success": "linear-gradient(to right, #56ab2f, #a8e063)",
}
function Notify(text, type){
    Client("PLAY_SOUND",{sound: type})
    Toastify({
        text: text,
        className: type,
        duration: 3000,
        style: {
            "font-family": 'Roboto Condensed',
            "font-weight": '350',
            background: NotifysType[type] || "linear-gradient(to right, #414d0b, #727a17)",
        },
    }).showToast();
}


globalThis.InternetStatus = true
window.addEventListener("online",function(){
    if(!globalThis.InternetStatus){
        globalThis.InternetStatus = true
        $("#inventory").css("pointer-events","all")
        // Notify("Conexão re-estabelecida!","success");
    }
})

window.addEventListener("offline",function(){
    if(globalThis.InternetStatus){
        globalThis.InternetStatus = false
        $("#inventory").css("pointer-events","none")
    }
})