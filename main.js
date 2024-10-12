import "./src/style.css";

import {Elm} from "./src/Main.elm";
import {convertItems} from "./src/filereader.js";

Elm.Main.init({
    node: document.getElementById("root"),
    flags: "Initial Message",
});

// 1) creates a new field in a 'drop' event
Object.defineProperty(Event.prototype, 'fileTree', {
    configurable: false,
    enumerable: true,
    get() {
        this.preventDefault()
        if (this.type === "drop" && this.dataTransfer) {
            convertItems(this.dataTransfer.items).then(res => {
                // 2) creates a new "fileTree" event
                let detail = res.flat()
                let evt = new CustomEvent("fileTree", {detail})
                this.target.dispatchEvent(evt)
            });
        }
    }
})
