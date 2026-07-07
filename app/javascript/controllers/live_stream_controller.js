import { Controller } from "@hotwired/stimulus";
import consumer from "channels/consumer";

const BUFFER_LIMIT = 500;
const HOT_DURATION = 2000;
const ROW_HEIGHT = 48;
const OVERSCAN = 10;

const LEVEL_COLORS = {
    debug: "bg-gray-50 text-gray-600",
    info: "bg-blue-50 text-secondary",
    warn: "bg-amber-50 text-amber-700",
    error: "bg-error/10 text-error",
    critical: "bg-red-100 text-red-800",
};

export default class extends Controller {
    static targets = [
        "container",
        "count",
        "pauseIcon",
        "indicator",
        "pausedIndicator",
        "filters",
    ];
    static values = {
        maxEntries: { type: Number, default: 500 },
        selectedService: { type: String, default: "all" },
    };

    connect() {
        this.logs = [];
        this.buffer = [];
        this.paused = false;
        this._removedPlaceholder = false;
        this._rafId = null;

        this.subscription = consumer.subscriptions.create("LiveStreamChannel", {
            connected: () => this._setStreamStatus(false),
            disconnected: () => this._setStreamStatus(true),
            received: (data) => this._received(data),
        });

        this.containerTarget.addEventListener(
            "scroll",
            () => this._scheduleRender(),
            { passive: true },
        );
        this._onFilterClick = (e) => this._handleFilterClick(e);
        if (this.hasFiltersTarget) {
            this.filtersTarget.addEventListener("click", this._onFilterClick);
        }
    }

    disconnect() {
        this.subscription?.unsubscribe();
        if (this._rafId) cancelAnimationFrame(this._rafId);
        if (this.hasFiltersTarget) {
            this.filtersTarget.removeEventListener(
                "click",
                this._onFilterClick,
            );
        }
    }

    togglePause() {
        this.paused = !this.paused;
        this._setStreamStatus(this.paused);
        if (this.hasPauseIconTarget) {
            this.pauseIconTarget.textContent = this.paused
                ? "play_arrow"
                : "pause";
        }
        if (!this.paused) this._flushBuffer();
    }

    changeMaxEntries(event) {
        this.maxEntriesValue = parseInt(event.target.value, 10);
        this._trimLogs();
        this._scheduleRender();
    }

    // -------- Filter handling --------

    _handleFilterClick(e) {
        const btn = e.target.closest("[data-level-filter]");
        if (!btn) return;
        this.filtersTarget
            .querySelectorAll("[data-level-filter]")
            .forEach((b) => {
                b.classList.remove(
                    "bg-white",
                    "shadow-sm",
                    "text-on-surface",
                    "active",
                );
                b.classList.add("text-on-surface-variant");
            });
        btn.classList.add("bg-white", "shadow-sm", "text-on-surface", "active");
        btn.classList.remove("text-on-surface-variant");
        // Re-render with new filter applied
        this._scheduleRender();
    }

    _activeLevel() {
        if (!this.hasFiltersTarget) return "all";
        const active = this.filtersTarget.querySelector(
            "[data-level-filter].active",
        );
        return active ? active.dataset.levelFilter : "all";
    }

    // -------- Data ingestion --------

    _received(data) {
        if (this.paused) {
            this.buffer.push(data);
            if (this.buffer.length > BUFFER_LIMIT) this.buffer.shift();
            return;
        }
        this._appendLog(data);
    }

    _appendLog(data) {
        this._removePlaceholder();
        this.logs.push(data);
        this._trimLogs();
        this._updateCount(1);
        this._scheduleRender();
        this._scrollToBottom();
    }

    _flushBuffer() {
        if (this.buffer.length === 0) return;
        this._removePlaceholder();

        this.logs.push(...this.buffer);
        this._trimLogs();
        this._updateCount(this.buffer.length);
        this.buffer = [];
        this._scheduleRender();
        this._scrollToBottom();
    }

    _trimLogs() {
        const max = this.maxEntriesValue;
        if (max > 0 && this.logs.length > max) {
            this.logs.splice(0, this.logs.length - max);
        }
    }

    // -------- Virtual render --------

    _scheduleRender() {
        if (this._rafId) return;
        this._rafId = requestAnimationFrame(() => {
            this._rafId = null;
            this._render();
        });
    }

    _render() {
        const el = this.containerTarget;
        const total = this.logs.length;
        if (total === 0) return;

        const level = this._activeLevel();
        const svc = this.selectedServiceValue;
        // Build filtered index list: positions in this.logs that pass the filter
        const filtered = [];
        for (let i = 0; i < total; i++) {
            const log = this.logs[i];
            const matchLevel = level === "all" || log.level === level;
            const matchService = svc === "all" || log.service === svc;
            if (matchLevel && matchService) {
                filtered.push(i);
            }
        }

        const filteredCount = filtered.length;
        if (filteredCount === 0) {
            el.textContent = "";
            return;
        }

        const scrollTop = el.scrollTop;
        const viewHeight = el.clientHeight;

        const startIdx = Math.max(
            0,
            Math.floor(scrollTop / ROW_HEIGHT) - OVERSCAN,
        );
        const endIdx = Math.min(
            filteredCount,
            Math.ceil((scrollTop + viewHeight) / ROW_HEIGHT) + OVERSCAN,
        );

        const topSpacer = document.createElement("div");
        topSpacer.style.height = startIdx * ROW_HEIGHT + "px";

        const visible = document.createDocumentFragment();
        for (let i = startIdx; i < endIdx; i++) {
            visible.appendChild(this._buildRow(this.logs[filtered[i]]));
        }

        const bottomSpacer = document.createElement("div");
        bottomSpacer.style.height =
            (filteredCount - endIdx) * ROW_HEIGHT + "px";

        el.textContent = "";
        el.appendChild(topSpacer);
        el.appendChild(visible);
        el.appendChild(bottomSpacer);
    }

    _buildRow(data) {
        const ts = this._formatTime(data.timestamp);
        const lc = LEVEL_COLORS[data.level] || LEVEL_COLORS.info;
        const src = data.service || data.hostname || "\u2014";
        const msg = this._escape(data.message || "");

        const row = document.createElement("div");
        row.className =
            "grid grid-cols-[120px_90px_1fr_2.5fr] gap-4 px-6 py-3 border-b border-[#F1F5F9] hover:bg-surface-container/30 transition-colors log-row";
        row.style.height = ROW_HEIGHT + "px";
        row.style.alignItems = "center";
        row.innerHTML = `
      <span class="font-code text-[13px] text-on-surface">${ts}</span>
      <span><span class="px-2.5 py-1 ${lc} font-body text-[12px] font-semibold rounded-full inline-block text-center w-fit">${data.level.toUpperCase()}</span></span>
      <span class="font-code text-[13px] text-[#6f3721] truncate">${this._escape(src)}</span>
      <span class="font-body text-[13px] text-on-surface truncate">${msg}</span>
    `;
        row.classList.add("log-row--hot");
        setTimeout(() => row.classList.remove("log-row--hot"), HOT_DURATION);
        return row;
    }

    // -------- Helpers --------

    _removePlaceholder() {
        if (this._removedPlaceholder) return;
        const ph = this.containerTarget.querySelector(".placeholder-text");
        if (ph) ph.remove();
        this._removedPlaceholder = true;
    }

    _scrollToBottom() {
        requestAnimationFrame(() => {
            this.containerTarget.scrollTop = this.containerTarget.scrollHeight;
        });
    }

    _updateCount(delta) {
        if (!this.hasCountTarget) return;
        this.countTarget.textContent =
            (parseInt(this.countTarget.textContent, 10) || 0) + delta;
    }

    _setStreamStatus(isPaused) {
        if (this.hasIndicatorTarget)
            this.indicatorTarget.classList.toggle("hidden", isPaused);
        if (this.hasPausedIndicatorTarget)
            this.pausedIndicatorTarget.classList.toggle("hidden", !isPaused);
    }

    _formatTime(iso) {
        const d = new Date(iso);
        return (
            d.toLocaleTimeString("en-US", { hour12: false }) +
            "." +
            String(d.getMilliseconds()).padStart(3, "0")
        );
    }

    _escape(str) {
        const d = document.createElement("div");
        d.textContent = str;
        return d.innerHTML;
    }
}
