import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import "../../services"
import "../../theme"
import ".."

// App icons from the system tray (StatusNotifier). Click to activate,
// right-click for the app's own menu, middle-click for the secondary action.
Item {
    id: root

    // The same app can show up twice; keep the first entry per id.
    readonly property var uniqueItems: {
        const seen = {};
        return SystemTray.items.values.filter(it => {
            const key = it.id || it.title;
            if (seen[key]) return false;
            seen[key] = true;
            return true;
        });
    }

    Label {
        anchors.centerIn: parent
        visible: root.uniqueItems.length === 0
        text: "No tray apps running"
        color: Theme.textTertiary
        font.pixelSize: Theme.fontSmall
    }

    Row {
        anchors.centerIn: parent
        spacing: 12

        Repeater {
            model: root.uniqueItems
            delegate: Rectangle {
                id: cell
                required property var modelData
                width: 72
                height: 72
                radius: Theme.cardRadius
                color: hover.hovered ? Theme.surface : "transparent"
                border.color: Theme.border

                HoverHandler { id: hover }

                Image {
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: -8
                    width: 28
                    height: 28
                    sourceSize: Qt.size(56, 56)
                    source: cell.modelData.icon
                }
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 6
                    width: parent.width - 8
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    text: (cell.modelData.tooltipTitle || cell.modelData.title || cell.modelData.id || "").replace(/_client$/, "")
                    color: Theme.textSecondary
                    font.pixelSize: Theme.fontSmall
                }
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    onClicked: mouse => {
                        if (mouse.button === Qt.RightButton || cell.modelData.onlyMenu) {
                            const pos = cell.mapToItem(null, 0, cell.height);
                            cell.modelData.display(QsWindow.window, pos.x, pos.y);
                        } else if (mouse.button === Qt.MiddleButton) {
                            cell.modelData.secondaryActivate();
                        } else {
                            cell.modelData.activate();
                        }
                    }
                }
            }
        }
    }
}
