pragma Singleton

import QtQuick
import QtMultimedia
import Quickshell
import Quickshell.Io

// Interface sounds, shared with ~/.config/quickshell/extras (packs from DarkShadow's Shell, MIT).
// Settings in ~/.config/extras/settings.json -> sfx {enabled, volume, pack}; reloaded live.
// Sfx.play("click" | "switch-on" | "switch-off" | "select" | "done")
Singleton {
    id: sfx

    property bool enabled: false
    property int volume: 45
    property string pack: "pebble"
    readonly property string dir: Quickshell.env("HOME") + "/.local/share/extras/sounds/"
    function file(ev) { return dir + pack + "/" + ev + ".wav" }
    property var lastAt: ({})

    FileView {
        path: Quickshell.env("HOME") + "/.config/extras/settings.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                const s = JSON.parse(text()).sfx || {};
                sfx.enabled = s.enabled !== false;
                if (s.volume !== undefined) sfx.volume = Number(s.volume);
                if (s.pack) sfx.pack = s.pack;
            } catch (e) { sfx.enabled = false; }
        }
    }

    component Snd: SoundEffect {
        required property string ev
        property bool warming: false
        source: "file://" + sfx.file(ev)
        volume: warming ? 0 : sfx.volume / 100
        onStatusChanged: if (status === SoundEffect.Ready) { warming = true; play(); }
        onPlayingChanged: if (!playing) warming = false
    }
    Snd { id: sClick; ev: "click" }
    Snd { id: sSelect; ev: "select" }
    Snd { id: sDone; ev: "done" }
    Snd { id: sOn; ev: "switch-on" }
    Snd { id: sOff; ev: "switch-off" }
    readonly property var map: ({ "click": sClick, "select": sSelect, "done": sDone, "switch-on": sOn, "switch-off": sOff })

    function play(ev) {
        if (!enabled || volume <= 0) return;
        const now = Date.now();
        if (lastAt[ev] && now - lastAt[ev] < 35) return;
        lastAt[ev] = now;
        const s = map[ev];
        if (s && s.status === SoundEffect.Ready && !s.warming) { s.play(); return; }
        Quickshell.execDetached(["pw-play", "--media-role", "Event", "--volume", (volume / 100).toFixed(2), file(ev)]);
    }
}
