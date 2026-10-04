import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications
import Quickshell.Widgets

// ─────────────────────────────────────────────────────────────────────────────
// NotificationWidget — macOS-Style Floating Notification Cards & History Center.
//
// Design:
//   - Individual standalone floating rounded glass boxes (no giant panel wrapper).
//   - Notification history has no "Notifications" title; shows floating "Clear All" pill.
//   - Highly curvy cards (cardRadius: 26) with authentic Apple macOS squircle badges.
//   - Full backdrop click-away dismiss.
//   - Ultra-smooth 60fps sliding transition from the right.
//   - Mutual exclusivity: opening notifications closes Control Center.
// ─────────────────────────────────────────────────────────────────────────────

PanelWindow {
    id: root

    // ── Apple SF Pro Rounded Typography ──────────────────────────────
    readonly property string sfFont: "SF Pro Rounded"
    readonly property string sfFontMedium: "SF Pro Rounded"
    readonly property string sfFontSemibold: "SF Pro Rounded"
    readonly property string sfFontBold: "SF Pro Rounded"
    readonly property string iconFont: "JetBrainsMono NFP"

    property int lastNotifId: 0
    property bool dndActive: false
    property bool panelOpen: false
    property var controlCenter: null

    // Grouped History List (Stores clubbed notifications by application)
    property var groupList: []

    // Transient Toast Model (Active popups)
    ListModel {
        id: toastModel
    }

    function addNotificationToHistory(notif) {
        let groups = []
        for (let i = 0; i < root.groupList.length; i++) {
            groups.push(root.groupList[i])
        }

        let foundIdx = -1
        for (let i = 0; i < groups.length; i++) {
            if (groups[i].groupKey === notif.app) {
                foundIdx = i
                break
            }
        }

        if (foundIdx >= 0) {
            let grp = groups[foundIdx]
            let oldItems = grp.items || []
            let newItems = [notif]
            for (let j = 0; j < oldItems.length; j++) {
                if (j < 14) newItems.push(oldItems[j])
            }
            let iSrc = notif.iconSource || grp.iconSource || ""
            let aIcn = notif.appIcon || grp.appIcon || "󰂞"
            let iBg = notif.iconBg || grp.iconBg || "#2563eb"

            groups.splice(foundIdx, 1)
            groups.unshift({
                groupKey:   notif.app,
                app:        notif.app,
                iconSource: iSrc,
                appIcon:    aIcn,
                iconBg:     iBg,
                count:      newItems.length,
                items:      newItems
            })
        } else {
            groups.unshift({
                groupKey:   notif.app,
                app:        notif.app,
                iconSource: notif.iconSource,
                appIcon:    notif.appIcon,
                iconBg:     notif.iconBg,
                count:      1,
                items:      [notif]
            })
        }

        if (groups.length > 25) {
            groups.pop()
        }
        root.groupList = groups
    }

    // Helper process runner
    Process { id: notifProc }
    function runShell(cmd) {
        notifProc.command = ["sh", "-c", cmd]
        notifProc.running = true
    }

    // Format local filesystem icon path to valid QML URL
    function formatIconUrl(p) {
        if (!p) return ""
        const s = String(p).trim()
        if (s === "") return ""
        if (s.startsWith("/") && !s.startsWith("//")) return "file://" + s
        return s
    }

    // Helper to resolve primary notification icon vs. sending app fallback icon
    function resolveNotificationIcon(notification, appName) {
        let iconSource = ""
        let appIcon = "󰂞"
        let iconBg = "#2563eb"

        // 1. PRIMARY: Check if the notification itself provided an icon or image
        if (notification.image && String(notification.image).trim() !== "") {
            iconSource = root.formatIconUrl(notification.image)
        } else if (notification.appIcon && String(notification.appIcon).trim() !== "") {
            const rawIcon = String(notification.appIcon).trim()
            if (rawIcon.startsWith("/") || rawIcon.startsWith("file://") || rawIcon.startsWith("image://")) {
                iconSource = root.formatIconUrl(rawIcon)
            } else {
                try {
                    const de = DesktopEntries.heuristicLookup(rawIcon)
                    if (de && de.icon) {
                        iconSource = Quickshell.iconPath(de.icon) || de.icon
                    } else {
                        iconSource = Quickshell.iconPath(rawIcon) || rawIcon
                    }
                } catch(e) {
                    try {
                        iconSource = Quickshell.iconPath(rawIcon) || rawIcon
                    } catch(e2) {
                        iconSource = rawIcon
                    }
                }
            }
        }

        // 2. FALLBACK: When no icon was received with the notification,
        // lookup the icon from the application that sent it!
        if (!iconSource || iconSource === "") {
            const desktopKey = (notification.desktopEntry || "").trim()
            if (desktopKey !== "") {
                try {
                    const de = DesktopEntries.heuristicLookup(desktopKey)
                    if (de && de.icon) {
                        iconSource = Quickshell.iconPath(de.icon) || de.icon
                    } else {
                        iconSource = Quickshell.iconPath(desktopKey) || desktopKey
                    }
                } catch(e) {}
            }
        }

        if (!iconSource || iconSource === "") {
            const appClean = (appName || "").trim()
            if (appClean !== "") {
                try {
                    const de = DesktopEntries.heuristicLookup(appClean)
                    if (de && de.icon) {
                        iconSource = Quickshell.iconPath(de.icon) || de.icon
                    }
                } catch(e) {}
                if (!iconSource || iconSource === "") {
                    try {
                        iconSource = Quickshell.iconPath(appClean.toLowerCase()) || Quickshell.iconPath(appClean)
                    } catch(e) {}
                }
            }
        }

        // 3. App-specific branded glyphs & signature background accents
        const appLower = (appName || "").toLowerCase()
        if (appLower.includes("spotify") || appLower.includes("music")) {
            appIcon = "󰝚"
            iconBg = "#10b981"
        } else if (appLower.includes("discord")) {
            appIcon = "󰙯"
            iconBg = "#5865f2"
        } else if (appLower.includes("github") || appLower.includes("git")) {
            appIcon = "󰊤"
            iconBg = "#2563eb"
        } else if (appLower.includes("code") || appLower.includes("vsc") || appLower.includes("nvim")) {
            appIcon = "󰨞"
            iconBg = "#0284c7"
        } else if (appLower.includes("telegram")) {
            appIcon = "󰈔"
            iconBg = "#0284c7"
        } else if (appLower.includes("steam")) {
            appIcon = "󰓓"
            iconBg = "#1e293b"
        } else if (appLower.includes("chrome") || appLower.includes("firefox") || appLower.includes("browser") || appLower.includes("brave") || appLower.includes("zen")) {
            appIcon = "󰇧"
            iconBg = "#f59e0b"
        } else if (appLower.includes("fitness") || appLower.includes("health")) {
            appIcon = "󰋉"
            iconBg = "#ef4444"
        } else if (appLower.includes("terminal") || appLower.includes("kitty") || appLower.includes("alacritty") || appLower.includes("foot") || appLower.includes("wezterm")) {
            appIcon = "󰆍"
            iconBg = "#334155"
        } else if (appLower.includes("mail") || appLower.includes("gmail") || appLower.includes("thunderbird")) {
            appIcon = "󰇮"
            iconBg = "#3b82f6"
        } else if (appLower.includes("settings") || appLower.includes("system") || appLower.includes("control")) {
            appIcon = "󰒓"
            iconBg = "#64748b"
        } else if (appLower.includes("file") || appLower.includes("folder") || appLower.includes("thunar") || appLower.includes("dolphin")) {
            appIcon = "󰉋"
            iconBg = "#0284c7"
        }

        return {
            iconSource: iconSource,
            appIcon: appIcon,
            iconBg: iconBg
        }
    }

    NotificationServer {
        id: notifServer
        keepOnReload: false

        onNotification: function(notification) {
            notification.tracked = false

            const id = ++root.lastNotifId
            const now = new Date()
            const hours = String(now.getHours()).padStart(2, "0")
            const mins = String(now.getMinutes()).padStart(2, "0")
            const timeStr = hours + ":" + mins
            const timeout = notification.expireTimeout > 0 ? notification.expireTimeout : 5000

            const appName = notification.appName && notification.appName.trim() !== "" 
                ? notification.appName.trim() 
                : "Notification"
            const summary = notification.summary ? notification.summary.trim() : ""
            const bodyText = notification.body ? notification.body.trim() : ""

            // Resolve primary icon with app fallback
            const iconInfo = root.resolveNotificationIcon(notification, appName)

            // 1. Store to Grouped History
            root.addNotificationToHistory({
                notifId:    id,
                title:      summary,
                body:       bodyText,
                app:        appName,
                timeStr:    timeStr,
                iconSource: iconInfo.iconSource,
                appIcon:    iconInfo.appIcon,
                iconBg:     iconInfo.iconBg,
                timestamp:  now.getTime()
            })

            // 2. If DND is active or Panel is open, don't show floating popup toast
            if (root.dndActive || root.panelOpen) return

            // 3. Show floating toast for ONLY this newly arrived notification
            toastModel.append({
                notifId:    id,
                title:      summary,
                body:       bodyText,
                app:        appName,
                timeStr:    timeStr,
                iconSource: iconInfo.iconSource,
                appIcon:    iconInfo.appIcon,
                iconBg:     iconInfo.iconBg,
                timeout:    timeout
            })
        }
    }

    property bool clearingAll: false
    property bool isPanelVisible: false

    function togglePanel() {
        if (panelOpen) closePanel()
        else openPanel()
    }

    function openPanel() {
        hidePanelTimer.stop()
        if (root.controlCenter) {
            root.controlCenter.close()
        }
        panelOpen = true
        isPanelVisible = true
        toastModel.clear()
    }

    function closePanel() {
        panelOpen = false
        hidePanelTimer.restart()
    }

    Timer {
        id: hidePanelTimer
        interval: (!root.groupList || root.groupList.length === 0) ? 440 : 180
        repeat: false
        onTriggered: {
            if (!root.panelOpen) {
                root.isPanelVisible = false
            }
        }
    }

    function clearAll() {
        if (!root.groupList || root.groupList.length === 0 || clearingAll) return
        clearingAll = true
        clearAnimTimer.restart()
    }

    Timer {
        id: clearAnimTimer
        interval: 330
        repeat: false
        onTriggered: {
            root.groupList = []
            root.clearingAll = false
            root.closePanel()
        }
    }

    function removeNotification(id) {
        let groups = []
        for (let i = 0; i < (root.groupList ? root.groupList.length : 0); i++) {
            let grp = root.groupList[i]
            let oldItems = grp.items || []
            let found = false
            let newItems = []
            for (let j = 0; j < oldItems.length; j++) {
                if (oldItems[j].notifId === id) {
                    found = true
                } else {
                    newItems.push(oldItems[j])
                }
            }
            if (found) {
                if (newItems.length > 0) {
                    groups.push({
                        groupKey:   grp.groupKey,
                        app:        grp.app,
                        iconSource: grp.iconSource,
                        appIcon:    grp.appIcon,
                        iconBg:     grp.iconBg,
                        count:      newItems.length,
                        items:      newItems
                    })
                }
            } else {
                groups.push(grp)
            }
        }
        root.groupList = groups
    }

    function removeGroup(groupKey) {
        if (!root.groupList) return
        root.groupList = root.groupList.filter(function(g) { return g.groupKey !== groupKey })
    }

    function removeToast(id) {
        for (let i = 0; i < toastModel.count; i++) {
            if (toastModel.get(i).notifId === id) {
                toastModel.remove(i)
                break
            }
        }
    }

    IpcHandler {
        target: "notifications"
        function toggle() { root.togglePanel() }
        function open() { root.openPanel() }
        function close() { root.closePanel() }
        function clearAll() { root.clearAll() }
    }

    // ── Full Window Layer for Reliable Backdrop Click-Away ────────────
    anchors {
        top: true
        left: true
        right: true
    }

    WlrLayershell.margins.top: 28
    implicitHeight: Screen.height - 28

    exclusiveZone: -1
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-notifications"
    WlrLayershell.keyboardFocus: root.panelOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    color: "transparent"
    visible: root.isPanelVisible || toastModel.count > 0

    mask: root.isPanelVisible ? fullRegion : toastRegion

    Region {
        id: fullRegion
        x: 0
        y: 0
        width: root.width
        height: root.height
    }

    Region {
        id: toastRegion
        x: root.width - 376 - 20
        y: 0
        width: 376 + 20
        height: (!root.panelOpen && toastModel.count > 0) ? (toastCol.implicitHeight + 20) : 0
    }

    // Backdrop Click-away: clicking anywhere outside history cards closes the panel
    MouseArea {
        anchors.fill: parent
        enabled: root.panelOpen
        hoverEnabled: false
        focus: root.panelOpen

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                root.closePanel()
                event.accepted = true
            }
        }
        onClicked: function(mouse) {
            const pad = 10
            const cardLeft = historyContainer.x + historyTrans.x
            const cardRight = cardLeft + historyContainer.width
            const cardTop = historyContainer.y
            const cardBottom = cardTop + historyContainer.height
            const inCard = (mouse.x >= cardLeft - pad && mouse.x <= cardRight + pad &&
                            mouse.y >= cardTop - pad && mouse.y <= cardBottom + pad)
            if (!inCard) {
                root.closePanel()
            }
        }
    }

    // ══════════════════════════════════════════════════════════════════
    // LAYER 1: NOTIFICATION CENTER HISTORY STACK (Curvy Floating Boxes)
    // ══════════════════════════════════════════════════════════════════
    Item {
        id: historyContainer
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 8
        anchors.rightMargin: 16
        width: 376
        implicitHeight: historyCol.implicitHeight
        height: Math.min(implicitHeight, Screen.height - 60)

        // Fluid liquid spring transform: coordinated scale and translation
        transform: [
            Translate {
                id: historyTrans
                x: root.panelOpen ? 0 : 28
                Behavior on x {
                    NumberAnimation {
                        duration: (!root.groupList || root.groupList.length === 0)
                            ? (root.panelOpen ? 600 : 400)
                            : (root.panelOpen ? 225 : 140)
                        easing.type: root.panelOpen ? Easing.OutBack : Easing.InCubic
                        easing.overshoot: 1.15
                    }
                }
            },
            Scale {
                id: historyScale
                origin.x: historyContainer.width
                origin.y: 0
                xScale: root.panelOpen ? 1.0 : 0.96
                yScale: root.panelOpen ? 1.0 : 0.96
                Behavior on xScale {
                    NumberAnimation {
                        duration: (!root.groupList || root.groupList.length === 0)
                            ? (root.panelOpen ? 600 : 400)
                            : (root.panelOpen ? 225 : 140)
                        easing.type: root.panelOpen ? Easing.OutBack : Easing.InCubic
                        easing.overshoot: 1.15
                    }
                }
                Behavior on yScale {
                    NumberAnimation {
                        duration: (!root.groupList || root.groupList.length === 0)
                            ? (root.panelOpen ? 600 : 400)
                            : (root.panelOpen ? 225 : 140)
                        easing.type: root.panelOpen ? Easing.OutBack : Easing.InCubic
                        easing.overshoot: 1.15
                    }
                }
            }
        ]

        opacity: root.panelOpen ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation {
                duration: (!root.groupList || root.groupList.length === 0)
                    ? (root.panelOpen ? 450 : 320)
                    : (root.panelOpen ? 168 : 125)
                easing.type: root.panelOpen ? Easing.OutCubic : Easing.InCubic
            }
        }

        visible: root.isPanelVisible

        ColumnLayout {
            id: historyCol
            width: parent.width
            spacing: 10

            // Floating Header: Only [ Clear All ] Button (No "Notifications" Title)
            RowLayout {
                Layout.fillWidth: true
                visible: root.groupList && root.groupList.length > 0

                Item { Layout.fillWidth: true }

                // Clear All Pill Button
                Rectangle {
                    implicitWidth: clearText.implicitWidth + 30
                    implicitHeight: 36
                    radius: 18
                    color: clearMouse.containsMouse ? "#45ffffff" : "#22ffffff"
                    border.width: 1
                    border.color: clearMouse.containsMouse ? "#90ffffff" : "#40ffffff"

                    scale: clearMouse.pressed ? 0.94 : (clearMouse.containsMouse ? 1.05 : 1.0)
                    Behavior on scale {
                        NumberAnimation {
                            duration: 125
                            easing.type: Easing.OutBack
                            easing.overshoot: 1.15
                        }
                    }
                    Behavior on color { ColorAnimation { duration: 105 } }
                    Behavior on border.color { ColorAnimation { duration: 105 } }

                    Text {
                        id: clearText
                        anchors.centerIn: parent
                        text: "Clear All"
                        font.family: root.sfFontMedium
                        font.pixelSize: 16
                        color: "#ffffff"
                        renderType: Text.NativeRendering
                    }

                    MouseArea {
                        id: clearMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.clearAll()
                    }
                }
            }

            // Empty State Card (With Smooth Opening and Closing Animations)
            LiquidGlassCard {
                id: emptyStateCard
                visible: (!root.groupList || root.groupList.length === 0) && !root.clearingAll && root.isPanelVisible
                Layout.fillWidth: true
                implicitHeight: 82
                cardRadius: 26

                transform: [
                    Translate {
                        id: emptyTrans
                        x: root.panelOpen ? 0 : 32
                        y: root.panelOpen ? 0 : 12
                        Behavior on x {
                            NumberAnimation {
                                duration: root.panelOpen ? 600 : 400
                                easing.type: root.panelOpen ? Easing.OutBack : Easing.InCubic
                                easing.overshoot: 1.15
                            }
                        }
                        Behavior on y {
                            NumberAnimation {
                                duration: root.panelOpen ? 600 : 400
                                easing.type: root.panelOpen ? Easing.OutBack : Easing.InCubic
                                easing.overshoot: 1.15
                            }
                        }
                    },
                    Scale {
                        id: emptyScale
                        origin.x: emptyStateCard.width / 2
                        origin.y: emptyStateCard.height / 2
                        xScale: root.panelOpen ? 1.0 : 0.90
                        yScale: root.panelOpen ? 1.0 : 0.90
                        Behavior on xScale {
                            NumberAnimation {
                                duration: root.panelOpen ? 600 : 400
                                easing.type: root.panelOpen ? Easing.OutBack : Easing.InCubic
                                easing.overshoot: 1.15
                            }
                        }
                        Behavior on yScale {
                            NumberAnimation {
                                duration: root.panelOpen ? 600 : 400
                                easing.type: root.panelOpen ? Easing.OutBack : Easing.InCubic
                                easing.overshoot: 1.15
                            }
                        }
                    }
                ]

                opacity: root.panelOpen ? 1.0 : 0.0
                Behavior on opacity {
                    NumberAnimation {
                        duration: root.panelOpen ? 450 : 320
                        easing.type: root.panelOpen ? Easing.OutCubic : Easing.InCubic
                    }
                }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 12

                    Text {
                        font.family: root.iconFont
                        font.pixelSize: 26
                        color: "#64748b"
                        text: "󰂚"
                        renderType: Text.NativeRendering
                    }

                    Text {
                        text: "No Notifications"
                        font.family: root.sfFontMedium
                        font.pixelSize: 18
                        color: "#94a3b8"
                        renderType: Text.NativeRendering
                    }
                }
            }

            // Scrollable History Cards List (Clubbed Group Stacks)
            ListView {
                id: historyListView
                Layout.fillWidth: true
                implicitHeight: Math.min(contentHeight, Screen.height - 130)
                Layout.preferredHeight: implicitHeight
                clip: true
                spacing: 12
                model: root.groupList
                boundsBehavior: Flickable.StopAtBounds

                delegate: NotificationGroupCard {
                    id: groupDelegate
                    width: historyListView.width
                    groupKey: modelData.groupKey || ""
                    appName: modelData.app || "Notification"
                    iconSource: modelData.iconSource || ""
                    appIcon: modelData.appIcon || "󰂞"
                    iconBg: modelData.iconBg || "#2563eb"
                    notifs: modelData.items || []
                    count: modelData.count || (modelData.items ? modelData.items.length : 0)
                    isClearingAll: root.clearingAll
                    sfFont: root.sfFont
                    sfFontMedium: root.sfFontMedium
                    sfFontSemibold: root.sfFontSemibold
                    sfFontBold: root.sfFontBold
                    iconFont: root.iconFont

                    onDismissNotification: function(notifId) {
                        root.removeNotification(notifId)
                    }
                    onDismissGroup: function(grpKey) {
                        root.removeGroup(grpKey)
                    }
                }
            }
        }
    }

    // ══════════════════════════════════════════════════════════════════
    // LAYER 2: TRANSIENT TOAST NOTIFICATIONS (Individual Floating Boxes)
    // ══════════════════════════════════════════════════════════════════
    ColumnLayout {
        id: toastCol
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 8
        anchors.rightMargin: 16
        width: 376
        spacing: 10
        visible: !root.panelOpen && toastModel.count > 0

        Repeater {
            model: toastModel

            delegate: Item {
                id: toastCardItem
                Layout.fillWidth: true
                implicitHeight: tContentRow.implicitHeight + 36
                height: implicitHeight

                property int currentId: model.notifId
                property bool closing: false

                function dismiss() {
                    if (!closing) {
                        closing = true
                        tAutoTimer.stop()
                        enterAnim.stop()
                        exitAnim.restart()
                    }
                }

                Timer {
                    id: tAutoTimer
                    interval: model.timeout > 0 ? model.timeout : 5000
                    running: true
                    repeat: false
                    onTriggered: toastCardItem.dismiss()
                }

                // Entrance animation: Liquid Slide (32px -> 0px)
                ParallelAnimation {
                    id: enterAnim
                    running: true
                    NumberAnimation {
                        target: toastCardRect
                        property: "x"
                        from: 32
                        to: 0
                        duration: 260
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.15
                    }
                    NumberAnimation {
                        target: toastCardRect
                        property: "opacity"
                        from: 0.0
                        to: 1.0
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }

                // Exit animation: Liquid Slide Out (0px -> 40px)
                ParallelAnimation {
                    id: exitAnim
                    NumberAnimation {
                        target: toastCardRect
                        property: "x"
                        to: 40
                        duration: 180
                        easing.type: Easing.InQuad
                    }
                    NumberAnimation {
                        target: toastCardRect
                        property: "opacity"
                        to: 0.0
                        duration: 180
                        easing.type: Easing.InQuad
                    }
                    onFinished: root.removeToast(toastCardItem.currentId)
                }

                LiquidGlassCard {
                    id: toastCardRect
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width
                    cardRadius: 26
                    isHovered: tCardMouse.containsMouse
                    x: 32
                    opacity: 0.0

                    MouseArea {
                        id: tCardMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: toastCardItem.dismiss()
                    }

                    RowLayout {
                        id: tContentRow
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        // Left App Squircle Badge (46x46) - Full Big Icon with 0 padding
                        Rectangle {
                            Layout.alignment: Qt.AlignTop
                            Layout.preferredWidth: 46
                            Layout.preferredHeight: 46
                            radius: 12
                            color: (tIconImg.status === Image.Ready && model.iconSource !== "")
                                ? "transparent"
                                : (model.iconBg || "#2563eb")
                            clip: true

                            IconImage {
                                id: tIconImg
                                anchors.fill: parent
                                anchors.margins: 0
                                source: model.iconSource || ""
                                visible: model.iconSource !== "" && status === Image.Ready
                            }

                            Text {
                                anchors.centerIn: parent
                                font.family: root.iconFont
                                font.pixelSize: 24
                                color: "#ffffff"
                                text: model.appIcon || "󰂞"
                                visible: !tIconImg.visible
                                renderType: Text.NativeRendering
                            }
                        }

                        // Right Text Content
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 3

                            // Header: App Name + Time + Dismiss
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                Text {
                                    font.family: root.sfFontSemibold
                                    font.pixelSize: 14
                                    font.capitalization: Font.AllUppercase
                                    color: "#93c5fd"
                                    text: model.app !== "" ? model.app : "NOTIFICATION"
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                    renderType: Text.NativeRendering
                                }

                                Text {
                                    font.family: root.sfFontSemibold
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#e2e8f0"
                                    text: model.timeStr || ""
                                    renderType: Text.NativeRendering
                                }

                                Rectangle {
                                    implicitWidth: 22
                                    implicitHeight: 22
                                    radius: 11
                                    color: tCloseMouse.containsMouse ? "#33ffffff" : "transparent"

                                    Text {
                                        anchors.centerIn: parent
                                        font.family: root.iconFont
                                        font.pixelSize: 14
                                        color: tCloseMouse.containsMouse ? "#f87171" : "#94a3b8"
                                        text: "󰅖"
                                        renderType: Text.NativeRendering
                                    }

                                    MouseArea {
                                        id: tCloseMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: toastCardItem.dismiss()
                                    }
                                }
                            }

                            // Title
                            Text {
                                Layout.fillWidth: true
                                font.family: root.sfFont
                                font.pixelSize: 18
                                color: "#ffffff"
                                text: model.title
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                                visible: model.title !== ""
                                renderType: Text.NativeRendering
                            }

                            // Body
                            Text {
                                Layout.fillWidth: true
                                font.family: root.sfFont
                                font.pixelSize: 15
                                color: "#cbd5e1"
                                text: model.body
                                wrapMode: Text.WordWrap
                                maximumLineCount: 3
                                elide: Text.ElideRight
                                visible: model.body !== ""
                                renderType: Text.NativeRendering
                            }
                        }
                    }
                }
            }
        }
    }
}