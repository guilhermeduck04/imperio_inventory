window.classInstances = {};
globalThis.SelectedItem = {}

// Variáveis do Sistema de Attachs
let isAttachMode = false;
let isDraggingRotate = false;
let lastMouseX = 0;

const Routes = {
    "OPEN_INVENTORY": async function(payload){
        const userInventory = await Client("GET_INVENTORY")
        $(".left-main").css("display", "flex");
        
        // Identidade
        if(userInventory.user_name && userInventory.user_id){
            $("#player-identity-card").fadeIn();
            $("#id-card-name").text(userInventory.user_name);
            $("#id-card-number").text(`PASSAPORTE: ${userInventory.user_id}`);
        }

        // Foto (Mugshot)
        if(payload && payload.mugshot){
            $("#id-card-mugshot").attr("src", `https://nui-img/${payload.mugshot}/${payload.mugshot}`);
        } else {
            $("#id-card-mugshot").attr("src", "assets/images/no_image.png");
        }
        
        // Reseta visuais
        $(".inventory-right-type").html("ARREDORES");
        $(".right-weight-container").hide();
        $(".add-main.right").hide(); 

        window.classInstances["weapons"] = new Weapons(await Client("GET_WEAPONS"))
        window.classInstances["left"] = new Inventory(userInventory)
        
        $("#inventory").fadeIn(150);
    },
    "OPEN_CHEST": async function(payload){
        $(".left-main").css("display", "none");
        $(".add-main.right").show();
        
        $(".inventory-right-type").html("BAÚ / MALA"); 
        
        let userInventory = await Client("GET_INVENTORY")
        window.classInstances["left"] = new Inventory(userInventory)
        window.classInstances["right"] = new Chest(payload)
        $("#inventory").fadeIn(150);
    }, 
    "OPEN_SHOP": async function(payload){
        $(".left-main").css("display", "none");
        $(".add-main.right").show();

        $(".inventory-right-type").html(payload.mode || "LOJA"); 

        let userInventory = await Client("GET_INVENTORY")
        window.classInstances["left"] = new Inventory(userInventory)
        window.classInstances["right"] = new Shop(payload)
        $("#inventory").fadeIn(150);
    },   
    "CLOSE_INVENTORY": async function(payload){
        $('#context-menu').hide();
        
        // Se estiver no modo attachs, garante que saia dele visualmente
        if(isAttachMode) {
            $("#attachs-container").hide();
            $("main").show();
            isAttachMode = false;
        }

        $("#player-identity-card").hide();
        
        const ignoreRight = payload.ignoreRight || false
        Client("CLOSE_INVENTORY",{
            right: ignoreRight || window.classInstances.hasOwnProperty("right")
        })
        window.classInstances = {}
        $("#inventory").fadeOut(150);
    },
    "OPEN_INSPECT": async function(payload){
        window.classInstances["left"] = new Inventory(payload.source)
        window.classInstances["right"] = new Inspect(payload.target)
        $("#inventory").fadeIn(150);
    },
    "FORCE_UPDATE_INVENTORY": async function(payload){
        if(window.classInstances["left"] && $("#inventory").is(":visible")){
            let userInventory = await Client("GET_INVENTORY")
            window.classInstances["left"] = new Inventory(userInventory)
            
            // Se estiver no menu de attachs, atualiza a lista de lá também
            if(isAttachMode){
                RenderAttachInventory();
            }
        }
    }
}

$(() => {
    window.addEventListener('message', async ({ data }) => {
        const {route, payload = {}} = data;
        if(!globalThis.Config){
            globalThis.Config = await Client("REQUEST_ITEMS_CONFIG")
        }
        if(Routes[route]){
            try{
                await Routes[route](payload)
            }catch(err){
                console.log(err)
            }
        }
    })
    document.addEventListener('keydown', ({key}) => {
        if (key === 'Escape') Close()
    })

    // --- EVENTOS DO SISTEMA DE ATTACHS ---

    // Soltar item na área da arma
    $(".weapon-viewport").droppable({
        accept: ".slot-attach-source",
        hoverClass: "drag-hover-attach", // Você pode estilizar essa classe no CSS se quiser um brilho extra
        drop: function(event, ui) {
            let slotId = ui.draggable.data("id");
            let itemData = window.classInstances["left"].items[slotId];
            
            if (itemData) {
                Client("APPLY_ATTACHMENT", {
                    item: itemData.item,
                    weapon: window.classInstances["weapons"].selected
                });
                Notify("Equipando " + itemData.name + "...", "success");
            }
        }
    });

    // Rotação da arma (Mouse Down)
    $(".rotate-area").on("mousedown", function(e) {
        isDraggingRotate = true;
        lastMouseX = e.clientX;
    });
});

// Eventos Globais de Mouse (para garantir que soltar o mouse fora da div pare a rotação)
$(document).on("mouseup", function() {
    isDraggingRotate = false;
});

$(document).on("mousemove", function(e) {
    if (isDraggingRotate && isAttachMode) {
        let deltaX = e.clientX - lastMouseX;
        lastMouseX = e.clientX;
        
        // Envia a rotação para o Client Lua
        // Dica: Se ficar muito pesado, pode usar um throttle aqui
        Client("ROTATE_WEAPON", { x: deltaX });
    }
});

function Close(){
    if(isAttachMode) {
        CloseAttachs();
        // Não retorna, continua para fechar o inventário todo
    }
    $('#context-menu').hide();
    Client("CLOSE_INVENTORY",{
        right: window.classInstances.hasOwnProperty("right")
    })
    window.classInstances = {}
    $("#inventory").fadeOut(150);
}

// --- FUNÇÕES DE ATTACHS ---

function OpenAttachs() {
    if (!window.classInstances["weapons"] || !window.classInstances["weapons"].selected) {
        Notify("Selecione uma arma primeiro!", "error");
        return;
    }
    
    let weaponName = window.classInstances["weapons"].selected;

    // Troca a UI
    $("main").fadeOut(100, function(){
        $("#attachs-container").fadeIn(200);
    });
    
    // Esconde identidade para limpar a tela
    $("#player-identity-card").fadeOut();

    isAttachMode = true;
    $("#attach-weapon-name").text(weaponName);

    // Manda cliente entrar no modo 3D
    Client("ENTER_ATTACH_MODE", { weapon: weaponName });

    // Renderiza o inventário na coluna da direita
    RenderAttachInventory();
}

function CloseAttachs() {
    $("#attachs-container").fadeOut(100, function(){
        $("main").fadeIn(200);
        $("#player-identity-card").fadeIn();
    });
    
    isAttachMode = false;
    Client("EXIT_ATTACH_MODE");
}

function RenderAttachInventory() {
    if(!window.classInstances["left"]) return;

    let items = window.classInstances["left"].items;
    $(".slots-attach-source").html('');
    
    Object.values(items).forEach(item => {
        // Gera o HTML do item usando o método da classe Inventory
        // Usamos um 'target' diferente ("attach-source") para diferenciar no CSS/Drag
        let html = window.classInstances["left"].getItemHtml(item, "attach-source", item.slot);
        $(".slots-attach-source").append(html);
    });

    // Torna os itens arrastáveis
    $(".slot-attach-source").draggable({
        helper: 'clone',
        appendTo: 'body',
        zIndex: 99999,
        start: function(e, ui) {
            $(ui.helper).addClass("ui-draggable-dragging");
        }
    });
}

// --- LÓGICA PADRÃO ---

$(".action-button").click(async function(){
    if(!globalThis.InternetStatus){ return Notify("Sem internet!","error") }
    if(!globalThis.SelectedItem || globalThis.SelectedItem.side !== "left") return Notify("Selecione um item!", "error");
    let {item, id} = globalThis.SelectedItem;
    if(!window.classInstances["left"].items[id]) {
        id = window.classInstances["left"].findSlotByItem(item)
        if(!id) return Notify("Erro item!", "error");
    };
    let inputValue = parseInt($('.input-frame').val()) > 0 ? parseInt($('.input-frame').val()) : globalThis.SelectedItem.amount
    inputValue = inputValue > globalThis.SelectedItem.amount ? globalThis.SelectedItem.amount : inputValue
    const action = $(this).data("route");
    const response = await Client(action, {slot: id, item: item, amount: inputValue})
    if(response && !response.error){
        window.classInstances["left"].removeItem(id, response?.used_amount || inputValue)
        if(action == "USE_ITEM" && (globalThis.Config[item]?.tipo == "equipar" || globalThis.Config[item]?.tipo == "recarregar")){
            window.classInstances["weapons"] = new Weapons(await Client("GET_WEAPONS"))
        }
    }
})

$(document).on("click", ".slot-left" , function() {
    if(window.classInstances["left"]) window.classInstances["left"].selectItem("left",$(this).data("id"))
})
$(document).on("click", ".slot-right" , function() {
    if(window.classInstances["right"]) window.classInstances["right"].selectItem("right",$(this).data("id"))
})

async function Client(route, body = {}){
    const res = await fetch(`http://${window.GetParentResourceName()}/${route}`,{
        method: 'POST',
        headers: {'Content-type': 'application/json; charset=UTF-8'},
        body: JSON.stringify(body)
    })
    const response = await res.json()
    if(route == "USE_ITEM" && !window.classInstances["left"]) return false
    return response
}