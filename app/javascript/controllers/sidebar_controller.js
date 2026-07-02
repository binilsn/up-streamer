import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["sidebar", "label", "userInfo", "logoText", "navText"];

    connect() {
        this.collapsed = false;
    }

    toggle() {
        this.collapsed = !this.collapsed;

        if (this.collapsed) {
            this.sidebarTarget.style.width = "72px";
        } else {
            this.sidebarTarget.style.width = "260px";
        }

        this.logoTextTargets.forEach((el) =>
            el.classList.toggle("hidden", this.collapsed),
        );
        this.labelTargets.forEach((el) =>
            el.classList.toggle("hidden", this.collapsed),
        );
        this.navTextTargets.forEach((el) =>
            el.classList.toggle("hidden", this.collapsed),
        );
        this.userInfoTargets.forEach((el) =>
            el.classList.toggle("hidden", this.collapsed),
        );
    }
}
