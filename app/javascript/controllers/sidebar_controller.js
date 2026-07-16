import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["sidebar", "label", "userInfo", "logoText", "navText"];

    connect() {
        const stored = localStorage.getItem("sidebar-collapsed");
        this.collapsed = stored === "true";
        this._applyState();
    }

    toggle() {
        this.collapsed = !this.collapsed;
        localStorage.setItem("sidebar-collapsed", this.collapsed);
        this._applyState();
    }

    _applyState() {
        if (!this.hasSidebarTarget) return;

        this.sidebarTarget.style.width = this.collapsed ? "72px" : "260px";
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
