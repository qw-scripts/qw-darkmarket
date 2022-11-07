$(function () {
  function display(bool) {
    if (bool) {
      $("#container").show();
    } else {
      $("#container").hide();
    }
  }

  display(false);

  window.addEventListener("message", async function (event) {
    var item = event.data;
    if (item.type === "ui") {
      if (item.status == true) {
        display(true);
        loadDarkMarket();
      } else {
        display(false);
      }
    }
  });
  // if the person uses the escape key, it will exit the resource
  document.onkeyup = function (data) {
    if (data.which == 27) {
      $.post("https://qw-darkmarket/exit", JSON.stringify({}));
      return;
    }
  };
});

function buyItem(event) {
  const buttonClicked = event.target;
  const parent = buttonClicked.parentElement.parentElement;
  const item = parent.querySelector("#buy-item").dataset.item;
  const price = parent.querySelector("#buy-item").dataset.price;

  $.post(
    "https://qw-darkmarket/buyitems",
    JSON.stringify({
      item: item,
      price: price,
    })
  );
}

async function loadDarkMarket() {
  const response = await fetch("https://qw-darkmarket/items", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({}),
  });

  const data = await response.json();

  const itemsContainer = document.getElementById("items");
  itemsContainer.innerHTML = "";
  data.forEach((item) => {
    const itemElement = document.createElement("div");
    const classList = [
      "p-3",
      "border",
      "border-gray-600",
      "rounded-xl",
      "bg-gray-800",
      "w-full",
    ];
    itemElement.classList.add(...classList);
    itemElement.innerHTML = `
                      <div class="flex items-center justify-between"> 
                        <div class="w-32 h-32 bg-gray-900 border border-slate-700 flex items-center justify-center rounded-xl">
                            <img class="w-16 h-16" src='nui://${
                              item.image
                            }' alt="">
                        </div>
                        <div class="flex flex-col w-full gap-2 flex-1 pl-4">
                            <div class="text-xl font-bold text-white">${
                              item.name
                            }</div>
                            <div class="text-sm text-gray-400">${
                              item.description
                            }</div>
                        </div>
                        <div class="flex flex-col items-center gap-2">
                            <div class="text-xl font-bold text-white">$${item.price.toString()}</div>
                            <button id="buy-item" class="transition ease-in-out delay-150 px-4 py-2 hover:bg-gray-900 border border-slate-600 rounded-lg text-sm" data-item="${
                              item.item
                            }" data-price="${item.price}">Buy Now</button>
                        </div>
                      </div>
                    `;
    let buyItemButton = itemElement.querySelector("#buy-item");
    buyItemButton.addEventListener("click", buyItem);
    itemsContainer.appendChild(itemElement);
  });
}
