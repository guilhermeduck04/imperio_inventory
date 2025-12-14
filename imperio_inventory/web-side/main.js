window.classInstances = {};
globalThis.SelectedItem = {}

const Routes = {
"OPEN_INVENTORY": async function(payload){
    const userInventory = await Client("GET_INVENTORY")
    $(".left-main").css("display", "flex");
    
    // Mostra a seção de chão
    $(".ground-items-section").show();
    
    // Renderiza os drops se houver, senão limpa
    if(payload.drops && payload.drops.length > 0){
        renderGroundItems(payload.drops);
    } else {
        $(".ground-content").html('<div style="width:100%; text-align:center; color:#555; margin-top:10px; font-style:italic;">Nenhum item próximo</div>');
    }

    window.classInstances["weapons"] = new Weapons(await Client("GET_WEAPONS"))
    window.classInstances["left"] = new Inventory(userInventory)
    $("#inventory").show()
},
    "OPEN_CHEST": async function(payload){
        $(".left-main").css("display", "none");
        // Oculta itens do chão ao abrir baú para focar no baú
        $(".ground-items-section").hide();
        
        let userInventory = await Client("GET_INVENTORY")
        window.classInstances["left"] = new Inventory(userInventory)
        window.classInstances["right"] = new Chest(payload)
        $("#inventory").show()
    },    
    "CLOSE_INVENTORY": async function(payload){
        $('#context-menu').hide();

        const ignoreRight = payload.ignoreRight || false
        Client("CLOSE_INVENTORY",{
            right: ignoreRight || window.classInstances.hasOwnProperty("right")
        })
        window.classInstances = {}
        $(".left-main").css("display", "none");
        $(".add-main").css("display","none");
        // Não precisamos esconder explicitamente aqui pois o #inventory inteiro some
        
        $("#inventory").hide()
    },
    "OPEN_INSPECT": async function(payload){
        $(".left-main").css("display", "none");
        $(".ground-items-section").hide();
        
        window.classInstances["left"] = new Inventory(payload.source)
        window.classInstances["right"] = new Inspect(payload.target)
        $("#inventory").show()
    },
    "OPEN_SHOP": async function(payload){
        $(".left-main").css("display", "none");
        $(".ground-items-section").hide();
        
        let userInventory = await Client("GET_INVENTORY")
        window.classInstances["left"] = new Inventory(userInventory)
        window.classInstances["right"] = new Shop(payload)
        $("#inventory").show()
    },
    "FORCE_UPDATE_INVENTORY": async function(payload){
        if(window.classInstances["left"] && $("#inventory").is(":visible")){
            let userInventory = await Client("GET_INVENTORY")
            window.classInstances["left"] = new Inventory(userInventory)
        }
    }
}

// Handler do Menu de Contexto
$(document).on('click', '.context-menu-option', async function() {
    if(!globalThis.InternetStatus){
        Notify("Sem conexão com a internet!","error")
        return
    }

    if(!globalThis.SelectedItem || globalThis.SelectedItem.side !== "left") return Notify("Selecione um item do seu inventário primeiro!", "error");
    let {item, id} = globalThis.SelectedItem;
    
    if(!window.classInstances["left"].items[id]) {
        id = window.classInstances["left"].findSlotByItem(item)
        if(!id) return Notify("Selecione um item do seu inventário primeiro!", "error");
    };
    
    let inputValue = parseInt($('.input-frame').val()) > 0 ? parseInt($('.input-frame').val()) : globalThis.SelectedItem.amount
    inputValue = inputValue > globalThis.SelectedItem.amount ? globalThis.SelectedItem.amount : inputValue

    const action = $(this).data("action");

    const response = await Client(action, {slot: id, item: item, amount: inputValue})
    
    if(typeof response !== "boolean" && response?.error){
        Notify(response.error,"error");
        return
    }
    
    if(response && !response.error){
        window.classInstances["left"].removeItem(id, response?.used_amount || inputValue)
        if(action == "USE_ITEM" && (globalThis.Config[item]?.tipo == "equipar" || globalThis.Config[item]?.tipo == "recarregar")){
            window.classInstances["weapons"] = new Weapons(await Client("GET_WEAPONS"))
        }
    }
    $('#context-menu').hide();
});

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
                console.log("Um erro foi detectado na rota: " + route)
                console.log(err)
            }
        }
    })

    document.addEventListener('keydown', ({key}) => {
        if (key === 'Escape') {
            Close()
        }
    })
});

function Close(){
    $('#context-menu').hide();

    Client("CLOSE_INVENTORY",{
        right: window.classInstances.hasOwnProperty("right")
    })
    window.classInstances = {}
    $(".left-main").css("display", "none");
    $(".add-main").css("display","none");
    $("#inventory").hide()
}

// Botões de Ação
$(".action-button").click(async function(){
    if(!globalThis.InternetStatus){
        Notify("Sem conexão com a internet!","error")
        return
    }

    if(!globalThis.SelectedItem || globalThis.SelectedItem.side !== "left") return Notify("Selecione um item do seu inventário primeiro!", "error");
    let {item, id} = globalThis.SelectedItem;
    
    if(!window.classInstances["left"].items[id]) {
        id = window.classInstances["left"].findSlotByItem(item)
        if(!id) return Notify("Selecione um item do seu inventário primeiro!", "error");
    };
    
    let inputValue = parseInt($('.input-frame').val()) > 0 ? parseInt($('.input-frame').val()) : globalThis.SelectedItem.amount
    inputValue = inputValue > globalThis.SelectedItem.amount ? globalThis.SelectedItem.amount : inputValue

    const action = $(this).data("route");

    const response = await Client(action, {slot: id, item: item, amount: inputValue})
    
    if(typeof response !== "boolean" && response?.error){
        Notify(response.error,"error");
        return
    }
    
    if(response && !response.error){
        window.classInstances["left"].removeItem(id, response?.used_amount || inputValue)
        if(action == "USE_ITEM" && (globalThis.Config[item]?.tipo == "equipar" || globalThis.Config[item]?.tipo == "recarregar")){
            window.classInstances["weapons"] = new Weapons(await Client("GET_WEAPONS"))
        }
    }
})

$(document).on("click", ".slot-left" , function() {
    if(window.classInstances["left"])
        window.classInstances["left"].selectItem("left",$(this).data("id"))
})

$(document).on("click", ".slot-right" , function() {
    if(window.classInstances["right"])
        window.classInstances["right"].selectItem("right",$(this).data("id"))
})

async function Client(route, body = {}){
    if(!globalThis.InternetStatus){
        Notify("Sem conexão com a internet!","error")
        return
    }
    const res = await fetch(`http://${window.GetParentResourceName()}/${route}`,{
        method: 'POST',
        headers: {
            'Content-type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(body)
    })

    const response = await res.json()
    if(route == "USE_ITEM" && !window.classInstances["left"]) return false
    return response
}

function renderGroundItems(drops) {
    const container = $(".ground-content");
    container.html('');

    drops.forEach(drop => {
        const imgUrl = `http://127.0.0.1/conexao_imagens/${drop.item}.png`;
        
        const html = `
            <div class="ground-item-slot" data-id="${drop.id}" title="${drop.name}">
                <div class="ground-qty">x${drop.amount}</div>
                <img src="${imgUrl}" onerror="this.src='./assets/images/no_image.png'"/>
                <p>${drop.name}</p>
            </div>
        `;
        container.append(html);
    });

    $(".ground-item-slot").off('click').on('click', async function() {
        const id = $(this).data('id');
        const response = await Client("PICKUP_ITEM", { id: id });
        
        if (response && response.success) {
            $(this).fadeOut(200, function() { 
                $(this).remove();
                // Se ficar vazio, mostra mensagem de vazio, mas mantem a caixa
                if($(".ground-item-slot").length === 0) {
                     $(".ground-content").html('<div style="width:100%; text-align:center; color:#555; font-style:italic; grid-column: 1/-1; padding-top:20px;">Nenhum item próximo</div>');
                }
            });
            
            const updatedInventory = await Client("GET_INVENTORY");
            window.classInstances["left"] = new Inventory(updatedInventory);
            
            Notify("Item recolhido!", "success");
        } else if (response && response.error) {
            Notify(response.error, "error");
        }
    });
}