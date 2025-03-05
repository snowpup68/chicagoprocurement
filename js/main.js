/*
*    main.js
*    Mastering Data Visualization with D3.js
*    2.5 - Activity: Adding SVGs to the screen
*/
function dragstartHandler(ev) {
    // Add the target element's id to the data transfer object
    ev.dataTransfer.setData("text/plain", ev.target.id);
    ev.target.style.cursor = 'move';
}

function dropHandler(ev) {
    ev.preventDefault();

    const src = ev.dataTransfer.getData("text/plain");
    const dst = ev.target.id;
    const element = document.getElementById(src);
    const sibling = document.getElementById(dst);

    sibling.parentNode.insertBefore(element, sibling);
}

window.addEventListener("DOMContentLoaded", () => {
  // Get the element by id
  const items = document.getElementsByClassName("draggable");
  for (var i = 0; i < items.length; i++) {
    // Add the ondragstart event listener
    items[i].addEventListener("dragstart", dragstartHandler);
    items[i].addEventListener("dragover", (ev) => {
      // prevent default to allow drop
      ev.preventDefault();
    });
    items[i].addEventListener("drop", dropHandler);
  };
});
