import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets

// ─────────────────────────────────────────────────────────────────────────────
// NotificationGroupCard — Frosted Liquid Glass Stacking & Kinetic Physics
//
// Features:
//   - Fast 30% Snappier Hover Spring: 195ms response time with spring overshoot.
//   - Kinetic Wipe-out Animation on Clear All: Multi-axis aerodynamic slide,
//     tilt rotation (4.5deg), and scale compression squish into vanishing point.
//   - Liquid Glass Aesthetics: Top tile dense/opaque; underlying tiles frosted & translucent.
//   - Large High-Contrast Typography: Easily readable across all lighting conditions.
//   - Zero Overlapping Glitch: Deeper cards cleanly hide text when collapsed.
// ─────────────────────────────────────────────────────────────────────────────

Item {
    id: root

    property string groupKey: ""
    property string appName: "Notification"
    property string iconSource: ""
    property string appIcon: "󰂞"
    property string iconBg: "#2563eb"
    property var notifs: []
    property int count: getSafeCount()
    property bool isClearingAll: false

    property string sfFont: "SF Pro Rounded"
    property string sfFontMedium: "SF Pro Rounded"
    property string sfFontSemibold: "SF Pro Rounded"
    property string sfFontBold: "SF Pro Rounded"
    property string iconFont: "JetBrainsMono NFP"

    signal dismissNotification(int notifId)
    signal dismissGroup(string groupKey)

    function getSafeCount() {
        if (!root.notifs) return 0
        if (typeof root.notifs.length === "number") return root.notifs.length
        if (typeof root.notifs.count === "number") return root.notifs.count
        return 0
    }

    function getSafeItem(idx) {
        if (!root.notifs) return null
        if (Array.isArray(root.notifs) && idx >= 0 && idx < root.notifs.length) return root.notifs[idx]
        if (typeof root.notifs.get === "function" && idx >= 0 && idx < root.notifs.count) return root.notifs.get(idx)
        if (root.notifs[idx] !== undefined) return root.notifs[idx]
        return null
    }

    // ── Dedicated Non-Blocking HoverHandler ──────────────────────────
    HoverHandler {
        id: groupHover
    }

    property bool isHovered: groupHover.hovered
    property bool isPinnedOpen: false
    property bool isExpanded: root.count > 1 && (isHovered || isPinnedOpen)

    // Standard card dimensions
    readonly property real cardHeight: 82
    readonly property real cardGap: 10

    // Stacking geometry calculations
    function getCardY(i, exp, total) {
        if (!exp) {
            if (i === 0) return 0
            if (i === 1) return 16
            if (i === 2) return 32
            return 32
        }
        return i * (root.cardHeight + root.cardGap)
    }

    function getCardScale(i, exp, total) {
        if (exp) return 1.0
        if (i === 0) return 1.0
        if (i === 1) return 0.95
        if (i === 2) return 0.90
        return 0.85
    }

    function getCardOpacity(i, exp, total) {
        if (exp) return 1.0
        if (i === 0) return 1.0
        if (i === 1) return 0.92
        if (i === 2) return 0.80
        return 0.0
    }

    function getStackHeight(exp, total) {
        if (total <= 1) return root.cardHeight
        if (!exp) {
            if (total === 2) return root.cardHeight + 16
            return root.cardHeight + 32
        }
        return total * root.cardHeight + (total - 1) * root.cardGap
    }

    width: parent ? parent.width : 376
    implicitHeight: count <= 1 ? singleCardItem.implicitHeight : groupContainer.implicitHeight
    height: implicitHeight

    // ══════════════════════════════════════════════════════════════════
    // VARIANT A: SINGLE NOTIFICATION (Count === 1)
    // ══════════════════════════════════════════════════════════════════
    Item {
        id: singleCardItem
        visible: root.count === 1
        anchors.left: parent.left
        anchors.right: parent.right
        implicitHeight: sContentRow.implicitHeight + 24
        height: implicitHeight

        property var singleData: root.getSafeItem(0)
        property bool dismissing: false

        function dismiss() {
            if (!dismissing && singleData) {
                dismissing = true
                sExitAnim.restart()
            }
        }

        ParallelAnimation {
            id: sExitAnim
            NumberAnimation {
                target: singleCardRect
                property: "x"
                to: 120
                duration: 140
                easing.type: Easing.InQuad
            }
            NumberAnimation {
                target: singleCardRect
                property: "opacity"
                to: 0.0
                duration: 125
                easing.type: Easing.InQuad
            }
            onFinished: {
                if (singleCardItem.singleData) {
                    root.dismissNotification(singleCardItem.singleData.notifId)
                }
            }
        }

        LiquidGlassCard {
            id: singleCardRect
            anchors.fill: parent
            cardRadius: 26
            isHovered: sCardMouse.containsMouse
            idleColor: Theme.darkMode ? "#f0131c28" : "#f2ffffff"

            // Kinetic Wind-Sweep Wipe Out on Clear All
            transform: [
                Translate {
                    x: root.isClearingAll ? 160 : 0
                    Behavior on x {
                        NumberAnimation {
                            duration: 310
                            easing.type: Easing.InBack
                            easing.overshoot: 1.15
                        }
                    }
                },
                Rotation {
                    origin.x: singleCardRect.width / 2
                    origin.y: singleCardRect.height / 2
                    angle: root.isClearingAll ? 4.5 : 0
                    Behavior on angle {
                        NumberAnimation {
                            duration: 310
                            easing.type: Easing.InBack
                            easing.overshoot: 1.15
                        }
                    }
                },
                Scale {
                    origin.x: singleCardRect.width / 2
                    origin.y: singleCardRect.height / 2
                    xScale: root.isClearingAll ? 0.85 : 1.0
                    yScale: root.isClearingAll ? 0.85 : 1.0
                    Behavior on xScale { NumberAnimation { duration: 280; easing.type: Easing.InCubic } }
                    Behavior on yScale { NumberAnimation { duration: 280; easing.type: Easing.InCubic } }
                }
            ]

            opacity: root.isClearingAll ? 0.0 : 1.0
            Behavior on opacity { NumberAnimation { duration: 260; easing.type: Easing.InCubic } }

            MouseArea {
                id: sCardMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: singleCardItem.dismiss()
            }

            RowLayout {
                id: sContentRow
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                // Left App Squircle Badge (44x44)
                Rectangle {
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredWidth: 44
                    Layout.preferredHeight: 44
                    radius: 12
                    color: (sIconImg.status === Image.Ready && ((singleCardItem.singleData && singleCardItem.singleData.iconSource) || root.iconSource))
                        ? "transparent"
                        : ((singleCardItem.singleData && singleCardItem.singleData.iconBg) ? singleCardItem.singleData.iconBg : (root.iconBg || "#2563eb"))
                    clip: true

                    IconImage {
                        id: sIconImg
                        anchors.fill: parent
                        source: (singleCardItem.singleData && singleCardItem.singleData.iconSource) ? singleCardItem.singleData.iconSource : (root.iconSource || "")
                        visible: source !== "" && status === Image.Ready
                    }

                    Text {
                        anchors.centerIn: parent
                        font.family: root.iconFont
                        font.pixelSize: 22
                        color: "#ffffff"
                        text: (singleCardItem.singleData && singleCardItem.singleData.appIcon) ? singleCardItem.singleData.appIcon : (root.appIcon || "󰂞")
                        visible: !sIconImg.visible
                        renderType: Text.NativeRendering
                    }
                }

                // Right Text Column (Large Typography)
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
                            text: (singleCardItem.singleData && singleCardItem.singleData.app) ? singleCardItem.singleData.app : (root.appName !== "" ? root.appName : "NOTIFICATION")
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            renderType: Text.NativeRendering
                        }

                        Text {
                            font.family: root.sfFontSemibold
                            font.pixelSize: 13
                            font.bold: true
                            color: "#cbd5e1"
                            text: (singleCardItem.singleData && singleCardItem.singleData.timeStr) ? singleCardItem.singleData.timeStr : ""
                            renderType: Text.NativeRendering
                        }

                        Rectangle {
                            implicitWidth: 24
                            implicitHeight: 24
                            radius: 12
                            color: sCloseMouse.containsMouse ? (Theme.darkMode ? "#33ffffff" : "#20000000") : "transparent"

                            Text {
                                anchors.centerIn: parent
                                font.family: root.iconFont
                                font.pixelSize: 14
                                color: sCloseMouse.containsMouse ? "#f87171" : "#94a3b8"
                                text: "󰅖"
                                renderType: Text.NativeRendering
                            }

                            MouseArea {
                                id: sCloseMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: singleCardItem.dismiss()
                            }
                        }
                    }

                    // Title
                    Text {
                        Layout.fillWidth: true
                        font.family: root.sfFontBold
                        font.pixelSize: 18
                        font.bold: true
                        color: "#ffffff"
                        text: (singleCardItem.singleData && singleCardItem.singleData.title) ? singleCardItem.singleData.title : ""
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        visible: text !== ""
                        renderType: Text.NativeRendering
                    }

                    // Body
                    Text {
                        Layout.fillWidth: true
                        font.family: root.sfFont
                        font.pixelSize: 15
                        color: "#cbd5e1"
                        text: (singleCardItem.singleData && singleCardItem.singleData.body) ? singleCardItem.singleData.body : ""
                        wrapMode: Text.WordWrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                        visible: text !== ""
                        renderType: Text.NativeRendering
                    }
                }
            }
        }
    }

    // ══════════════════════════════════════════════════════════════════
    // VARIANT B: MULTI-NOTIFICATION STACK (Count > 1)
    // ══════════════════════════════════════════════════════════════════
    LiquidGlassCard {
        id: groupContainer
        visible: root.count > 1
        anchors.left: parent.left
        anchors.right: parent.right
        cardRadius: 28
        idleColor: Theme.darkMode ? "#55101622" : "#18ffffff"
        implicitHeight: groupLayout.implicitHeight + 20
        height: implicitHeight

        // Kinetic Wind-Sweep Wipe Out on Clear All
        transform: [
            Translate {
                x: root.isClearingAll ? 160 : 0
                Behavior on x {
                    NumberAnimation {
                        duration: 310
                        easing.type: Easing.InBack
                        easing.overshoot: 1.15
                    }
                }
            },
            Rotation {
                origin.x: groupContainer.width / 2
                origin.y: groupContainer.height / 2
                angle: root.isClearingAll ? 4.5 : 0
                Behavior on angle {
                    NumberAnimation {
                        duration: 310
                        easing.type: Easing.InBack
                        easing.overshoot: 1.15
                    }
                }
            },
            Scale {
                origin.x: groupContainer.width / 2
                origin.y: groupContainer.height / 2
                xScale: root.isClearingAll ? 0.85 : 1.0
                yScale: root.isClearingAll ? 0.85 : 1.0
                Behavior on xScale { NumberAnimation { duration: 280; easing.type: Easing.InCubic } }
                Behavior on yScale { NumberAnimation { duration: 280; easing.type: Easing.InCubic } }
            }
        ]

        opacity: root.isClearingAll ? 0.0 : 1.0
        Behavior on opacity { NumberAnimation { duration: 260; easing.type: Easing.InCubic } }

        Behavior on implicitHeight {
            NumberAnimation {
                duration: root.isExpanded ? 270 : 200
                easing.type: root.isExpanded ? Easing.OutBack : Easing.OutCubic
                easing.overshoot: root.isExpanded ? 1.08 : 1.0
            }
        }

        ColumnLayout {
            id: groupLayout
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 10
            spacing: 10

            // ── 1. Interactive Stacked Cards Area ─────────────────────
            Item {
                id: stackContainer
                Layout.fillWidth: true
                implicitHeight: root.getStackHeight(root.isExpanded, root.count)
                height: implicitHeight

                Behavior on implicitHeight {
                    NumberAnimation {
                        duration: root.isExpanded ? 270 : 200
                        easing.type: root.isExpanded ? Easing.OutBack : Easing.OutCubic
                        easing.overshoot: root.isExpanded ? 1.08 : 1.0
                    }
                }

                Repeater {
                    model: root.notifs

                    delegate: Item {
                        id: cardItem
                        width: stackContainer.width
                        implicitHeight: root.cardHeight
                        height: implicitHeight

                        property int cardIndex: index
                        property var itemData: modelData ? modelData : root.getSafeItem(index)
                        property bool isTop: index === 0
                        property bool closing: false

                        z: root.count - index
                        visible: opacity > 0.01

                        // Spatial spring animation (Expand: 270ms, Collapse: 200ms)
                        y: root.getCardY(index, root.isExpanded, root.count)
                        scale: root.getCardScale(index, root.isExpanded, root.count)
                        opacity: closing ? 0.0 : root.getCardOpacity(index, root.isExpanded, root.count)
                        x: closing ? 100 : 0

                        Behavior on y {
                            NumberAnimation {
                                duration: root.isExpanded ? 270 : 200
                                easing.type: root.isExpanded ? Easing.OutBack : Easing.OutCubic
                                easing.overshoot: root.isExpanded ? 1.18 : 1.0
                            }
                        }
                        Behavior on scale {
                            NumberAnimation {
                                duration: root.isExpanded ? 270 : 200
                                easing.type: root.isExpanded ? Easing.OutBack : Easing.OutCubic
                                easing.overshoot: root.isExpanded ? 1.18 : 1.0
                            }
                        }
                        Behavior on opacity {
                            NumberAnimation {
                                duration: root.isExpanded ? 180 : 130
                                easing.type: Easing.OutCubic
                            }
                        }
                        Behavior on x {
                            NumberAnimation {
                                duration: 125
                                easing.type: Easing.InQuad
                            }
                        }

                        function dismiss() {
                            if (!closing) {
                                closing = true
                                dismissTimer.restart()
                            }
                        }

                        Timer {
                            id: dismissTimer
                            interval: 130
                            repeat: false
                            onTriggered: {
                                if (cardItem.itemData) {
                                    root.dismissNotification(cardItem.itemData.notifId)
                                }
                            }
                        }

                        // Frosted Liquid Glass Card (Top tile is dense and opaque; deeper tiles are translucent)
                        LiquidGlassCard {
                            id: innerCardRect
                            anchors.fill: parent
                            cardRadius: 20
                            isHovered: innerMouse.containsMouse
                            idleColor: (cardItem.isTop || root.isExpanded)
                                ? (Theme.darkMode ? "#f0131c28" : "#f2ffffff")
                                : (Theme.darkMode ? "#60111822" : "#20ffffff")

                            MouseArea {
                                id: innerMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (!root.isExpanded) {
                                        root.isPinnedOpen = true
                                    }
                                }
                            }

                            // Content Row with intelligent fade
                            // (When collapsed, deeper cards hide their text to eliminate ghost overlapping)
                            RowLayout {
                                id: cardContentRow
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 10

                                opacity: (cardItem.isTop || root.isExpanded) ? 1.0 : 0.0
                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: root.isExpanded ? 180 : 130
                                        easing.type: Easing.OutCubic
                                    }
                                }

                                // App Squircle Badge (40x40)
                                Rectangle {
                                    Layout.alignment: Qt.AlignTop
                                    Layout.preferredWidth: 40
                                    Layout.preferredHeight: 40
                                    radius: 10
                                    color: (cIconImg.status === Image.Ready && (cardItem.itemData && cardItem.itemData.iconSource))
                                        ? "transparent"
                                        : (cardItem.itemData && cardItem.itemData.iconBg ? cardItem.itemData.iconBg : (root.iconBg || "#2563eb"))
                                    clip: true

                                    IconImage {
                                        id: cIconImg
                                        anchors.fill: parent
                                        source: (cardItem.itemData && cardItem.itemData.iconSource) ? cardItem.itemData.iconSource : (root.iconSource || "")
                                        visible: source !== "" && status === Image.Ready
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        font.family: root.iconFont
                                        font.pixelSize: 20
                                        color: "#ffffff"
                                        text: (cardItem.itemData && cardItem.itemData.appIcon) ? cardItem.itemData.appIcon : (root.appIcon || "󰂞")
                                        visible: !cIconImg.visible
                                        renderType: Text.NativeRendering
                                    }
                                }

                                // Text Content (Large Typography)
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    // Header: App name + Counter Pill (if collapsed top) + Time + Close
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 6

                                        Text {
                                            font.family: root.sfFontSemibold
                                            font.pixelSize: 14
                                            font.capitalization: Font.AllUppercase
                                            color: "#93c5fd"
                                            text: (cardItem.itemData && cardItem.itemData.app) ? cardItem.itemData.app : (root.appName || "NOTIFICATION")
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                            renderType: Text.NativeRendering
                                        }

                                        // RotateCcw Count Badge Pill (matches React demo top card counter)
                                        Rectangle {
                                            visible: cardItem.isTop && !root.isExpanded && root.count > 1
                                            implicitWidth: cntRow.implicitWidth + 10
                                            implicitHeight: 22
                                            radius: 11
                                            color: "#353b82f6"
                                            border.width: 1
                                            border.color: "#6060a5fa"

                                            RowLayout {
                                                id: cntRow
                                                anchors.centerIn: parent
                                                spacing: 3

                                                Text {
                                                    text: "󰑖"
                                                    font.family: root.iconFont
                                                    font.pixelSize: 12
                                                    color: "#93c5fd"
                                                    renderType: Text.NativeRendering
                                                }

                                                Text {
                                                    text: String(root.count)
                                                    font.family: root.sfFontBold
                                                    font.pixelSize: 13
                                                    color: "#ffffff"
                                                    renderType: Text.NativeRendering
                                                }
                                            }
                                        }

                                        Text {
                                            font.family: root.sfFontSemibold
                                            font.pixelSize: 13
                                            font.bold: true
                                            color: "#cbd5e1"
                                            text: (cardItem.itemData && cardItem.itemData.timeStr) ? cardItem.itemData.timeStr : ""
                                            renderType: Text.NativeRendering
                                        }

                                        // Individual Card Close Button
                                        Rectangle {
                                            visible: root.isExpanded || cardItem.isTop
                                            implicitWidth: 24
                                            implicitHeight: 24
                                            radius: 12
                                            color: cCloseMouse.containsMouse ? (Theme.darkMode ? "#33ffffff" : "#20000000") : "transparent"

                                            Text {
                                                anchors.centerIn: parent
                                                font.family: root.iconFont
                                                font.pixelSize: 14
                                                color: cCloseMouse.containsMouse ? "#f87171" : "#94a3b8"
                                                text: "󰅖"
                                                renderType: Text.NativeRendering
                                            }

                                            MouseArea {
                                                id: cCloseMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: cardItem.dismiss()
                                            }
                                        }
                                    }

                                    // Title
                                    Text {
                                        Layout.fillWidth: true
                                        font.family: root.sfFontBold
                                        font.pixelSize: 18
                                        font.bold: true
                                        color: "#ffffff"
                                        text: (cardItem.itemData && cardItem.itemData.title) ? cardItem.itemData.title : ""
                                        elide: Text.ElideRight
                                        visible: text !== ""
                                        renderType: Text.NativeRendering
                                    }

                                    // Body
                                    Text {
                                        Layout.fillWidth: true
                                        font.family: root.sfFont
                                        font.pixelSize: 15
                                        color: "#cbd5e1"
                                        text: (cardItem.itemData && cardItem.itemData.body) ? cardItem.itemData.body : ""
                                        wrapMode: Text.WordWrap
                                        maximumLineCount: root.isExpanded ? 3 : 1
                                        elide: Text.ElideRight
                                        visible: text !== ""
                                        renderType: Text.NativeRendering
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ── 2. Animated Footer Bar (React Component Exact Replica) ──
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 4
                Layout.rightMargin: 4
                Layout.topMargin: 2
                spacing: 8

                // Total Count Circle Pill Badge
                Rectangle {
                    implicitWidth: 24
                    implicitHeight: 24
                    radius: 12
                    color: Theme.darkMode ? "#334155" : "#cbd5e1"
                    border.width: 1
                    border.color: Theme.darkMode ? "#475569" : "#94a3b8"

                    Text {
                        anchors.centerIn: parent
                        text: String(root.count)
                        font.family: root.sfFontBold
                        font.pixelSize: 13
                        color: Theme.darkMode ? "#ffffff" : "#0f172a"
                        renderType: Text.NativeRendering
                    }
                }

                // Vertical Text Switcher with Slide + Fade Transition
                Item {
                    Layout.fillWidth: true
                    implicitHeight: 24
                    clip: true

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.isPinnedOpen = !root.isPinnedOpen
                        }
                    }

                    // Collapsed Label: "{App} Notifications"
                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: (root.appName !== "" ? root.appName : "App") + " Notifications"
                        font.family: root.sfFontMedium
                        font.pixelSize: 15
                        color: Theme.darkMode ? "#94a3b8" : "#64748b"
                        renderType: Text.NativeRendering

                        y: root.isExpanded ? -18 : 0
                        opacity: root.isExpanded ? 0.0 : 1.0

                        Behavior on y {
                            NumberAnimation {
                                duration: root.isExpanded ? 190 : 140
                                easing.type: Easing.InOutCubic
                            }
                        }
                        Behavior on opacity {
                            NumberAnimation {
                                duration: root.isExpanded ? 190 : 140
                                easing.type: Easing.InOutCubic
                            }
                        }
                    }

                    // Expanded Action Label: "View all ↗" or "Collapse 󰅀"
                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4

                        y: root.isExpanded ? 0 : 18
                        opacity: root.isExpanded ? 1.0 : 0.0

                        Behavior on y {
                            NumberAnimation {
                                duration: root.isExpanded ? 190 : 140
                                easing.type: Easing.InOutCubic
                            }
                        }
                        Behavior on opacity {
                            NumberAnimation {
                                duration: root.isExpanded ? 190 : 140
                                easing.type: Easing.InOutCubic
                            }
                        }

                        Text {
                            text: root.isPinnedOpen ? "Collapse stack" : "View all"
                            font.family: root.sfFontMedium
                            font.pixelSize: 15
                            color: "#60a5fa"
                            renderType: Text.NativeRendering
                        }

                        Text {
                            text: root.isPinnedOpen ? "󰅀" : "󰁝"
                            font.family: root.iconFont
                            font.pixelSize: 14
                            color: "#60a5fa"
                            renderType: Text.NativeRendering
                        }
                    }
                }

                // Clear Group Pill Button
                Rectangle {
                    implicitWidth: clrGrpText.implicitWidth + 16
                    implicitHeight: 24
                    radius: 12
                    color: clrGrpMouse.containsMouse ? "#45ef4444" : "#20ef4444"
                    border.width: 1
                    border.color: clrGrpMouse.containsMouse ? "#ef4444" : "#40ef4444"

                    opacity: root.isExpanded ? 1.0 : 0.0
                    scale: root.isExpanded ? 1.0 : 0.85
                    visible: opacity > 0.01

                    Behavior on opacity { NumberAnimation { duration: root.isExpanded ? 190 : 140 } }
                    Behavior on scale { NumberAnimation { duration: root.isExpanded ? 190 : 140; easing.type: Easing.OutBack } }

                    Text {
                        id: clrGrpText
                        anchors.centerIn: parent
                        text: "Clear"
                        font.family: root.sfFontMedium
                        font.pixelSize: 13
                        color: "#fca5a5"
                        renderType: Text.NativeRendering
                    }

                    MouseArea {
                        id: clrGrpMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.dismissGroup(root.groupKey)
                    }
                }
            }
        }
    }
}
