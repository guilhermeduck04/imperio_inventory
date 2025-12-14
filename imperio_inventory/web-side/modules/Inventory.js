class Inventory {
    items;
    maxWeight = 0;
    currentWeight = 0;
    side;

    constructor(data, side = "left"){
        const {inventory, weight, max_weight} = data;
        this.items = this.parseItems(inventory)
        this.maxWeight = max_weight;
        this.currentWeight = weight;
        this.side = side;
        this.renderInfos(side);
        this.renderSlots(side);
    }

    findSlotByItem(name, ignoreSlot){
        let _slot
        (Object.keys(this.items)).forEach((slot)=>{
            if(this.items[slot].item == name && (!ignoreSlot || !ignoreSlot.includes(slot))){
                _slot = slot
            }
        })
        return _slot
    }

    refreshWeight(){
        if(this.side == "right" && window.classInstances[this.side]?.mode){
            $(".weight-right").html(`-`);
            $(`.inside-${this.side}`).css("width", `${(0 * 100) / 100}%`);
            return
        }
        
         this.currentWeight = Object.values(this.items).reduce((total, num)=>{
            if(num.weight){
                return (num.weight * num.amount) + total
            }else{
                return total
            }
        }, 0); 

        $(`.weight-${this.side}`).html(`${(this.currentWeight).toFixed(2)} / ${this.maxWeight} KG`);
        $(`.inside-${this.side}`).css("width", `${(this.currentWeight * 100) / this.maxWeight}%`);
    }

    parseItems(items){
        Object.keys(items).forEach(slot => {
            let itemName        = items[slot].item
            items[slot].name    = globalThis.Config[itemName]?.name
            if(!items[slot].name){
                delete items[slot]
            }else{
                items[slot].key     = itemName
                items[slot].slot    = slot
                items[slot].weight  = globalThis.Config[itemName]?.weight
            }
        });
        return items
    }

    renderSlots(target = "left"){
        if (target === "left") {
            $(".hotbar-slots").html('');
            $(".slots-left").html('');
            
            let hotbarHtml = '';
            let mainHtml = '';
    
            for (let i = 0; i < 50; i++) {
                let slot = i+1;
                let htmlSnippet = '';

                // Verifica se tem item configurado no slot
                if(!this.items[slot.toString()] || (this.items[slot.toString()] && globalThis.Config[this.items[slot.toString()].item])){
                    
                    if (this.items[slot.toString()]) {
                        const item = this.items[slot.toString()];
                        htmlSnippet = this.getItemHtml(item, target, slot, "allDiv", slot <= 5 ? slot : null);
                    } else {
                        let keyIndicator = slot <= 5 ? `<div class="key-indicator">${slot}</div>` : '';
                        htmlSnippet = `<div class="slot empty slot-${target}${slot}" data-side="${target}" data-id="${slot}">${keyIndicator}</div>`;
                    }
    
                    if (slot <= 5) {
                        hotbarHtml += htmlSnippet;
                    } else {
                        mainHtml += htmlSnippet;
                    }
                }
            }
            
            $(".hotbar-slots").html(hotbarHtml);
            $(".slots-left").html(mainHtml);
            
        } else {
            $(".slots-"+target).html('');
            let htmlContent = '';
            
            for (let i = 0; i < 50; i++) {
                let slot = i+1;
                if(!this.items[slot.toString()] || (this.items[slot.toString()] && globalThis.Config[this.items[slot.toString()].item])){
                    if (this.items[slot.toString()]) {
                        const item = this.items[slot.toString()];
                        htmlContent += this.getItemHtml(item, target, slot);
                    } else {
                        htmlContent += `<div class="slot empty slot-${target}${slot}" data-side="${target}" data-id="${slot}"></div>`;
                    }
                }
            }
            $(".slots-"+target).html(htmlContent);
        }

        this.refreshWeight()
        this.updateDrag(target);
    }

    removeItem(slot, amount){
        this.items[slot].amount -= amount;
        if(this.items[slot].item == "mochila"){
            if(this.maxWeight <= 25){
                this.maxWeight = 50
            }else if(this.maxWeight == 50){
                this.maxWeight = 75
            }else if(this.maxWeight == 75){
                this.maxWeight = 90
            }
        }
        if(this.items[slot].amount <= 0){
            delete this.items[slot];
        }
        this.renderSlots(this.side);
    }

    getItemHtml(item, target, slot, method = "allDiv", hotbarKey = null){
        const imgUrl = `http://127.0.0.1/conexao_imagens/${item.item}.png`;
        const totalWeight = ((item.weight || 0) * item.amount).toFixed(2);
        const amountText = (item.amount) ? `x${item.amount}` : "R$"+item.price;

        if(method == "onlyItems"){
            return `
                <div class="item-top-info">
                    <span class="item-weight">${totalWeight}kg</span>
                    <span class="item-amount">${amountText}</span>
                </div>
                <img src="${imgUrl}" onerror="this.src='../assets/images/no_image.png'"/>
                <p>${item.name}</p>
            `
        }

        let keyIndicatorHtml = hotbarKey ? `<div class="key-indicator">${hotbarKey}</div>` : '';

        return `
        <div class="slot slot-${target} slot-item slot-${target}${slot}" data-side="${target}" data-id="${slot}">
            ${keyIndicatorHtml}
            <div class="item-top-info">
                <span class="item-weight">${totalWeight}kg</span>
                <span class="item-amount">${amountText}</span>
            </div>
            <img src="${imgUrl}" onerror="this.src='../assets/images/no_image.png'"/>
            <p>${item.name}</p>      
        </div>
        `
    }

    renderInfos(side) {
        if(this.side == "right" && window.classInstances[this.side]?.mode){
            $(".weight-right").html(`-`);
            $(`.inside-${this.side}`).css("width", `${(0 * 100) / 100}%`);
            return
        }
        this.refreshWeight();
        if(side == "left"){
            $(".input-frame").val("");
            $(".weight-left").html(`${(this.currentWeight).toFixed(2)} / ${this.maxWeight} KG`);
            $(".inside-left").css("width", `${(this.currentWeight * 100) / this.maxWeight}%`);
        }else{
            $(".left-main").css("display", "none");
            $(".add-main").css("display","flex");
            $(".weight-right").html(`${(this.currentWeight).toFixed(2)} / ${this.maxWeight} KG`);
            $(".inside-right").css("width", `${(this.currentWeight * 100) / this.maxWeight}%`);
        }
    }

    getItems(){
        return this.items
    }

    selectItem(side, itemId) {
        if(!this.items[itemId]) return
        const item = { ...this.items[itemId], id: itemId, side };
        $(".slot").removeClass('slot-active');

        globalThis.SelectedItem = item;
        $('.name-frame').html(globalThis.SelectedItem.name);
        $('.weight-frame').html(`${(globalThis.SelectedItem.weight || 0).toFixed(2)} kg`);
        $('.circle-quantity').html((globalThis.SelectedItem.amount) ? "x"+globalThis.SelectedItem.amount : "R$"+globalThis.SelectedItem.price);
        $('.inspector-image img').attr('src', `http://127.0.0.1/conexao_imagens/${globalThis.SelectedItem.item}.png`);
        
        $(`.slot-${side}${item.id}`).addClass('slot-active');
    }

    async changeItemPos(old, next, keyPressed) {
        if(old.side == next.side){
            old.item = this.items[(old.id).toString()]
            next.item = this.items[(next.id).toString()]
            let inputValue = parseInt($('.input-frame').val()) > 0 ? parseInt($('.input-frame').val()) : old.item.amount
            if(keyPressed == 'ctrl' && old.item.amount % 2 == 0){
                inputValue = old.item.amount/2
            }else if(keyPressed == 'shift'){
                inputValue = 1
            }
            if(inputValue > old.item.amount){ inputValue = old.item.amount}
            if(old.side == "right" && window.classInstances[old.side]?.mode) return false
            const response = old.side == "right" || await Client("SWAP_SLOT", { from_slot: old.id, from_amount: inputValue, to_slot: next.id });
            
            if(!response || response.error){
                return false
            }

            // ATUALIZAÇÃO LOCAL DOS DADOS
            if(!next.item){
                // Move para slot vazio
                if(old.item.amount <= inputValue){
                    this.items[(next.id).toString()] = this.items[(old.id).toString()]
                    this.items[(next.id).toString()].amount = inputValue
                    
                    if(old.item.amount <= inputValue) {
                        delete this.items[(old.id).toString()]
                    } else {
                        this.items[(old.id).toString()].amount -= inputValue
                    }
                }else{
                    this.items[(old.id).toString()].amount -= inputValue
                    this.items[(next.id).toString()] = {}
                    Object.assign(this.items[(next.id).toString()],this.items[(old.id).toString()], {amount: inputValue}) 
                }
            }else if(old.item.item == next.item.item){
                // Stack
                if(old.item.amount <= inputValue){
                     this.items[(next.id).toString()].amount += inputValue
                     delete this.items[(old.id).toString()]
                }else{
                     this.items[(old.id).toString()].amount -= inputValue
                     this.items[(next.id).toString()].amount += inputValue
                }
            }else if(old.item.item !== next.item.item){
                // Swap
                let oldObj = JSON.parse(JSON.stringify(this.items[(old.id).toString()]))
                let nextObj = JSON.parse(JSON.stringify(this.items[(next.id).toString()]))
                nextObj.slot    = next.id
                oldObj.slot     = old.id
                this.items[(next.id).toString()] = oldObj
                this.items[(old.id).toString()] = nextObj
            }

            // CORREÇÃO CRÍTICA: Use setTimeout para re-renderizar
            // Isso evita conflitos com o ciclo de vida do Drag & Drop do jQuery UI
            setTimeout(() => {
                this.renderSlots(old.side);
            }, 10);
        }

        // Lógica entre inventários (Mochila <-> Baú)
        if(old.side == "left" && next.side == "right"){
            old.item = this.items[(old.id).toString()]
            let inputValue = parseInt($('.input-frame').val()) > 0 ? parseInt($('.input-frame').val()) : old.item.amount
            if(keyPressed == 'ctrl' && old.item.amount % 2 == 0){
                inputValue = old.item.amount/2
            }else if(keyPressed == 'shift'){
                inputValue = 1
            }
            if(inputValue > old.item.amount){
                inputValue = old.item.amount
            }
            await window.classInstances["right"].putItem(old.id, inputValue, next.id)
        }

        if(old.side == "right" && next.side == "left"){
            if(window.classInstances["right"].mode){
                let inputValue = parseInt($('.input-frame').val()) > 0 ? parseInt($('.input-frame').val()) : 1
                if(keyPressed == 'ctrl' && old.item.amount % 2 == 0){
                    inputValue = old.item.amount/2
                }else if(keyPressed == 'shift'){
                    inputValue = 1
                }
                await window.classInstances["right"].takeItem(old.id, inputValue, next.id)
            }else{
                old.item = window.classInstances["right"].items[(old.id).toString()]
                let inputValue = parseInt($('.input-frame').val()) > 0 ? parseInt($('.input-frame').val()) : old.item.amount
                if(keyPressed == 'ctrl' && old.item.amount % 2 == 0){
                    inputValue = old.item.amount/2
                }else if(keyPressed == 'shift'){
                    inputValue = 1
                }
                await window.classInstances["right"].takeItem(old.id, inputValue, next.id)
            }
        }
    }

    updateDrag(target) {
        $(`.slot-${target}`).draggable({
            disabled: false,
            appendTo: 'body',
            zIndex: 99999,
            revertDuration: 0,
            // refreshPositions: false é bom para performance, mas removi para testar precisão se necessário
            start: (event, ui) => {
                this.selectItem(event.currentTarget.dataset.side, event.currentTarget.dataset.id)
                $(ui.helper).css({
                    width: $(event.target).width(),
                    height: $(event.target).height(),
                    backgroundColor: 'rgba(30,30,30,0.85)',
                    border: '1px solid #f0ad4e',
                    zIndex: 99999
                });
            },
            cursor: 'grabbing',
            helper: 'clone', 
            revert: 'invalid',
        });

        $(`.slot`).droppable({
            accept: ".slot-item, .slot-weapon",
            hoverClass: "slot-active",
            tolerance: "pointer", // CORREÇÃO: Melhora muito a precisão do drop
            drop: async (event, ui) => {
                if (ui.draggable.hasClass("slot-weapon")) {
                    const weaponName = ui.draggable.data("weapon");
                    if(window.classInstances["weapons"]){
                        await window.classInstances["weapons"].manageWeapons("selected", weaponName);
                    }
                    return;
                }

                const self = window.classInstances[ui.draggable.data('side')]
                if(!self) return 
                const id = ui.draggable.data('id');
                await self.changeItemPos({side: ui.draggable.data('side'), id}, {side: event.target.dataset.side, id: event.target.dataset.id}, (event.ctrlKey ? 'ctrl' : event.ctrlKey || event.shiftKey ? 'shift' : event.shiftKey));
                
                if(ui.draggable.data('side') !== event.target.dataset.side){
                    window.classInstances[event.target.dataset.side].selectItem(event.target.dataset.side, event.target.dataset.id);
                }else{
                    self.selectItem(event.target.dataset.side, event.target.dataset.id);
                }
            },
        });

        // Área de armas aceita drops
        $(".left-content").droppable({
            accept: ".slot-left",
            hoverClass: "hover-highlight", 
            tolerance: "pointer",
            drop: async (event, ui) =>{
                const self = window.classInstances[ui.draggable.data('side')]
                if(!self || ui.draggable.data('side') !== "left") return 
                
                let id = ui.draggable.data('id');
                let itemData = window.classInstances["left"].items[id];
                if(!itemData) return;
                
                let item = itemData.key || itemData.item;
                let inputValue = itemData.amount || 1; 

                const configItem = globalThis.Config[item];

                if(configItem?.tipo === "recarregar" || item.includes("AMMO_")) {
                    const response = await Client("USE_ITEM", {slot: id, item: item, amount: inputValue})
                    if(response && !response.error){
                        window.classInstances["left"].removeItem(id, response?.used_amount || inputValue)
                        window.classInstances["weapons"] = new Weapons(await Client("GET_WEAPONS"))
                        Notify("Arma recarregada!", "success");
                    } else if (response?.error) {
                        Notify(response.error, "error");
                    }
                    return;
                }

                if(configItem?.tipo !== "equipar"){
                    Notify("Este item não pode ser equipado ou usado aqui!", "error");
                    return;
                }

                const response = await Client("USE_ITEM", {slot: id, item: item, amount: 1}) 
                if(response && !response.error){
                    window.classInstances["left"].removeItem(id, response?.used_amount || 1)
                    if((configItem?.tipo == "equipar")){
                        window.classInstances["weapons"] = new Weapons(await Client("GET_WEAPONS"))
                    }
                } else if (response?.error) {
                    Notify(response.error, "error");
                }
            }
        });

        // Drop específico na arma
        $(".slot-weapon").droppable({
            accept: ".slot-item",
            greedy: true, 
            tolerance: "pointer",
            drop: async (event, ui) => {
                const id = ui.draggable.data('id');
                const self = window.classInstances["left"];
                if(!self.items[id]) return;
                
                const item = self.items[id].item;
                const amount = self.items[id].amount || 1; 
                const configItem = globalThis.Config[item];

                if(configItem?.tipo === "recarregar" || item.includes("AMMO_")) {
                    const response = await Client("USE_ITEM", {slot: id, item: item, amount: amount});
                    
                    if(response && !response.error){
                         window.classInstances["left"].removeItem(id, response?.used_amount || amount)
                         window.classInstances["weapons"] = new Weapons(await Client("GET_WEAPONS"))
                    } else if (response?.error) {
                         Notify(response.error, "error");
                    }
                }
            }
        });

        // Clique direito
        $(`.slot-${target}`).off('contextmenu').on('contextmenu', async function(event) {
            event.preventDefault(); 
            const id = $(this).data('id');
            const side = $(this).data('side');
            if (side !== 'left') return; 

            const self = window.classInstances[side];
            if (!self.items[id]) return;

            const item = self.items[id].key || self.items[id].item;
            let inputValue = 1;
            const configItem = globalThis.Config[item];
            
            if(configItem?.tipo === "recarregar" || item.includes("AMMO_")) {
                 inputValue = self.items[id].amount || 1;
            }

            const response = await Client("USE_ITEM", {slot: id, item: item, amount: inputValue});
            if(response && !response.error){
                self.removeItem(id, response?.used_amount || inputValue);
                if((configItem?.tipo == "equipar" || configItem?.tipo == "recarregar")){
                    window.classInstances["weapons"] = new Weapons(await Client("GET_WEAPONS"));
                }
            } else if (response?.error) {
                Notify(response.error, "error");
            }
        });

        $(`.slot-${target}`).off('dblclick').on('dblclick', async function() {
            $(this).trigger('contextmenu');
        });

        $(`.action-button`).droppable({
            accept: ".slot-left",
            tolerance: "pointer",
            drop: async (event, ui) => {
                const self = window.classInstances[ui.draggable.data('side')]
                if(!self || ui.draggable.data('side') !== "left") return 
                self.selectItem("left", ui.draggable.data('id'));

                if(!globalThis.SelectedItem || globalThis.SelectedItem.side !== "left") return Notify("Selecione um item!", "error");
                let {item, id} = globalThis.SelectedItem;
                
                if(!window.classInstances["left"].items[id]) {
                    id = window.classInstances["left"].findSlotByItem(item)
                    if(!id) return Notify("Erro ao localizar item.", "error");
                };

                let inputValue = parseInt($('.input-frame').val()) > 0 ? parseInt($('.input-frame').val()) : globalThis.SelectedItem.amount
                inputValue = inputValue > globalThis.SelectedItem.amount ? globalThis.SelectedItem.amount : inputValue
            
                const action = event.target.dataset.route;
            
                const response = await Client(action, {slot: id, item: item, amount: inputValue})
                
                if(response && !response.error){
                    window.classInstances["left"].removeItem(id, response?.used_amount || inputValue)
                    if(action == "USE_ITEM" && (globalThis.Config[item]?.tipo == "equipar" || globalThis.Config[item]?.tipo == "recarregar")){
                        window.classInstances["weapons"] = new Weapons(await Client("GET_WEAPONS"))
                    }
                } else if (response?.error) {
                    Notify(response.error, "error");
                }
            },
        });

        $('.slot-item').on('contextmenu', function(event) {
            event.preventDefault();
            const side = $(this).data('side');
            const itemId = $(this).data('id');
            const invInstance = window.classInstances[side];
            if (invInstance) {
                invInstance.selectItem(side, itemId);
                const contextMenu = $('#context-menu');
                contextMenu.css({ top: event.pageY + 'px', left: event.pageX + 'px' }).show();
                $(document).one('click', function() {
                    contextMenu.hide();
                });
            }
        });

        $(`.empty`).draggable({ disabled: true });
    }
}