// Inventory System using localStorage
const form = document.getElementById('product-form');
const nameInput = document.getElementById('product-name');
const priceInput = document.getElementById('product-price');
const quantityInput = document.getElementById('product-quantity');
const idInput = document.getElementById('product-id');
const tableBody = document.querySelector('#inventory-table tbody');

function getInventory() {
    return JSON.parse(localStorage.getItem('inventory') || '[]');
}

function setInventory(inventory) {
    localStorage.setItem('inventory', JSON.stringify(inventory));
}

function renderInventory() {
    const inventory = getInventory();
    tableBody.innerHTML = '';
    inventory.forEach((product, idx) => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${product.name}</td>
            <td>$${parseFloat(product.price).toFixed(2)}</td>
            <td>${product.quantity}</td>
            <td>
                <button class="action-btn sell-btn" onclick="sellProduct(${idx})">Sell</button>
                <button class="action-btn edit-btn" onclick="editProduct(${idx})">Edit</button>
                <button class="action-btn delete-btn" onclick="deleteProduct(${idx})">Delete</button>
            </td>
        `;
        tableBody.appendChild(row);
    });
}

window.editProduct = function(idx) {
    const inventory = getInventory();
    const product = inventory[idx];
    nameInput.value = product.name;
    priceInput.value = product.price;
    quantityInput.value = product.quantity;
    idInput.value = idx;
    form.querySelector('button[type="submit"]').textContent = 'Update Product';
}

window.deleteProduct = function(idx) {
    if (confirm('Are you sure you want to delete this product?')) {
        const inventory = getInventory();
        inventory.splice(idx, 1);
        setInventory(inventory);
        renderInventory();
    }
}

window.sellProduct = function(idx) {
    const inventory = getInventory();
    const product = inventory[idx];
    let maxQty = product.quantity;
    if (maxQty === 0) {
        alert('No stock available to sell.');
        return;
    }
    let qty = prompt(`Enter quantity to sell (Available: ${maxQty}):`, '1');
    qty = parseInt(qty);
    if (isNaN(qty) || qty <= 0) {
        alert('Invalid quantity.');
        return;
    }
    if (qty > maxQty) {
        alert('Not enough stock.');
        return;
    }
    product.quantity -= qty;
    setInventory(inventory);
    renderInventory();
}

form.addEventListener('submit', function(e) {
    e.preventDefault();
    const name = nameInput.value.trim();
    const price = parseFloat(priceInput.value);
    const quantity = parseInt(quantityInput.value);
    const id = idInput.value;
    if (!name || isNaN(price) || isNaN(quantity)) return;
    let inventory = getInventory();
    if (id === '') {
        // Add new product
        inventory.push({ name, price, quantity });
    } else {
        // Update existing product
        inventory[id] = { name, price, quantity };
        idInput.value = '';
        form.querySelector('button[type="submit"]').textContent = 'Add Product';
    }
    setInventory(inventory);
    form.reset();
    renderInventory();
});

// Initial render
renderInventory();
