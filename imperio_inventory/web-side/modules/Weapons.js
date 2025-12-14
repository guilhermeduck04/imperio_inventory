class Weapons {
    weapons;
    selected;
    constructor(weapons) {
        this.weapons = weapons
        this.renderWeapons()
    }

    async manageWeapons(type = "selected", weaponName = null){
        if(!globalThis.InternetStatus){
            Notify("Sem conexão com a internet!","error")
            return
        }

        let weaponsToManage = [];

        if(type == "selected"){
            if(weaponName){
                weaponsToManage = [weaponName];
            } else if(this.selected){
                weaponsToManage = [this.selected];
            } else {
                return; // Nenhuma arma selecionada
            }
        } else if(type == "all"){
            weaponsToManage = Object.keys(this.weapons);
        }

        const response = await Client("MANAGE_WEAPONS", {weapons: weaponsToManage})
        
        if(!response || response?.error){
            Notify(response?.error || "Erro","error");
            return
        }
        if(response.success){
            // Remove as armas processadas da lista local para atualizar a UI instantaneamente
            weaponsToManage.forEach(w => delete this.weapons[w]);
            this.renderWeapons()
            // Atualiza o inventário da esquerda (onde a arma vai parar)
            window.classInstances["left"] = new Inventory(await Client("GET_INVENTORY"))
        }
    }

    renderWeapons(){
        $(".left-content").html('')
        Object.keys(this.weapons).forEach(weapon => {
            if(!weapon.includes("PARACHUTE")){
                let weaponData = this.weapons[weapon]
                let weaponConfig = {}
                let weaponName = weapon.replace("WEAPON_","WEAPON_").toLowerCase()
                if(globalThis.Config[weapon]){
                    weaponConfig.name = globalThis.Config[weapon].name
                }
                
                // HTML Estruturado para Imagem Grande
                let weaponElement = $(`
                <div class="slot-weapon" data-weapon="${weapon}">
                    <div class="weapon-header">
                        <span class="weapon-name">${weaponConfig.name || weaponName}</span>
                        <span class="ammo-badge">${weaponData.ammo}</span>
                    </div>
                    <div class="weapon-image-container">
                        <img src="http://127.0.0.1/conexao_imagens/${weaponName}.png" onerror="this.src='../assets/images/no_image.png'"/>
                    </div>
                </div>
                `)
                $(".left-content").append(weaponElement)
            }
        })

        // Configuração Otimizada de Drag para as Armas
        $(".slot-weapon").draggable({
            helper: 'clone',
            appendTo: 'body',
            zIndex: 99999,
            revertDuration: 0,
            start: (event, ui) => {
                $(event.target).addClass("selected-weapon");
                this.selected = $(event.target).data("weapon");
                
                // Helper visual otimizado
                $(ui.helper).css({
                    width: $(event.target).width(),
                    height: $(event.target).height(),
                    backgroundColor: 'rgba(30,30,30,0.9)',
                    border: '1px solid #f0ad4e',
                    boxShadow: '0 10px 20px rgba(0,0,0,0.5)',
                    opacity: 0.9
                });
            }
        });
    }
}

$(document).on("click", ".slot-weapon" , function() {
    $(".selected-weapon").removeClass("selected-weapon")
    $(this).addClass("selected-weapon")
    window.classInstances["weapons"].selected = $(this).data("weapon")
})

$(".button-left-red").on("click", async () => window.classInstances["weapons"].manageWeapons("selected"))
$(".button-left-black").on("click", async () => window.classInstances["weapons"].manageWeapons("all"))