import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property var results: [
        { id: "1", icon: "󰕋", label: "Twitter", description: "Social Media", shortcut: "T" },
        { id: "2", icon: "󰖟", label: "Browser", description: "Web", shortcut: "B" },
        { id: "3", icon: "󰇮", label: "Mail", description: "Communication", shortcut: "M" },
        { id: "4", icon: "󰃭", label: "Calendar", description: "Schedule", shortcut: "C" },
        { id: "5", icon: "󰎚", label: "Notes", description: "Text", shortcut: "N" },
        { id: "6", icon: "󰋩", label: "Photos", description: "Gallery", shortcut: "P" },
        { id: "7", icon: "󰒓", label: "Settings", description: "System", shortcut: "S" },
        { id: "8", icon: "󰆍", label: "Terminal", description: "Command Line", shortcut: "Cmd" },
        { id: "9", icon: "󰉋", label: "Files", description: "Storage", shortcut: "F" },
        { id: "10", icon: "󰍡", label: "Messages", description: "Chat", shortcut: "Msg" },
        { id: "11", icon: "󰎆", label: "Music", description: "Audio", shortcut: "Audio" }
    ]

    signal resultHovered(int index)
    signal resultUnhovered()
    signal resultClicked(var result)
    
    property int selectedIndex: -1
    property real targetContentY: 0

    function smoothScrollBy(deltaY) {
        let step = -(deltaY / 120.0) * 110;
        let maxScroll = Math.max(0, resultsColumn.height - flickable.height);
        if (!scrollAnim.running) {
            targetContentY = flickable.contentY;
        }
        targetContentY = Math.max(0, Math.min(maxScroll, targetContentY + step));
        scrollAnim.to = targetContentY;
        scrollAnim.restart();
    }

    WheelHandler {
        id: wheelHandler
        target: null
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: function(event) {
            if (event.pixelDelta.y !== 0) {
                let maxScroll = Math.max(0, resultsColumn.height - flickable.height);
                let target = Math.max(0, Math.min(maxScroll, flickable.contentY - event.pixelDelta.y));
                flickable.contentY = target;
                root.targetContentY = target;
            } else if (event.angleDelta.y !== 0) {
                root.smoothScrollBy(event.angleDelta.y);
            }
        }
    }

    onSelectedIndexChanged: {
        if (selectedIndex >= 0 && selectedIndex < root.results.length) {
            let itemTop = resultsColumn.topPadding + (selectedIndex * 66);
            let itemBottom = itemTop + 66;
            if (itemTop < flickable.contentY) {
                targetContentY = Math.max(0, itemTop - 8);
                scrollAnim.to = targetContentY;
                scrollAnim.restart();
            } else if (itemBottom > flickable.contentY + flickable.height) {
                let maxScroll = Math.max(0, resultsColumn.height - flickable.height);
                targetContentY = Math.min(maxScroll, itemBottom - flickable.height + 8);
                scrollAnim.to = targetContentY;
                scrollAnim.restart();
            }
        }
    }

    NumberAnimation {
        id: scrollAnim
        target: flickable
        property: "contentY"
        duration: 220
        easing.type: Easing.OutCubic
    }

    // Auto-calculate height based on content or max 384px (h-96)
    property real contentHeightPixels: Math.min(resultsColumn.height, 384)
    width: parent.width
    height: contentHeightPixels
    clip: true

    Rectangle {
        width: parent.width
        height: 1
        color: "#1a000000" // border-t equivalent
        anchors.top: parent.top
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        anchors.topMargin: 1 // space for border
        contentHeight: resultsColumn.height
        contentWidth: width
        clip: true

        Column {
            id: resultsColumn
            width: parent.width
            topPadding: 8
            bottomPadding: 8
            leftPadding: 8
            rightPadding: 8
            spacing: 0

            Rectangle {
                id: liquidHighlight
                z: 0
                visible: root.results.length > 0 && root.selectedIndex >= 0 && root.selectedIndex < root.results.length
                width: resultsColumn.width - 16
                x: 8
                height: 66
                radius: 14
                color: "#ffffff"
                border.width: 1
                border.color: "#e5e7eb"

                y: resultsColumn.topPadding + (root.selectedIndex * 66)

                Behavior on y {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                }
            }

            Repeater {
                model: root.results

                Item {
                    id: resultCard
                    required property int index
                    required property var modelData
                    z: 1

                    width: parent.width - 16
                    height: 66

                    // Hover transition for shadow/color
                    // Staggered fade-in logic
                    opacity: 0
                    Component.onCompleted: {
                        staggerTimer.interval = 100 + (index * 100)
                        staggerTimer.start()
                    }
                    Timer {
                        id: staggerTimer
                        onTriggered: resultCard.opacity = 1.0
                    }
                    Behavior on opacity {
                        NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 14

                        // Icon container
                        Rectangle {
                            Layout.preferredWidth: 48
                            Layout.preferredHeight: 48
                            radius: 12
                            color: "#f5f5f5"
                            scale: root.selectedIndex === index ? 1.08 : 1.0
                            Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }
                            
                            Image {
                                anchors.fill: parent
                                anchors.margins: 4
                                visible: modelData.iconPath !== undefined
                                source: modelData.iconPath ? modelData.iconPath : ""
                                fillMode: Image.PreserveAspectFit
                                mipmap: true
                            }

                            Text {
                                anchors.centerIn: parent
                                text: modelData.icon ? modelData.icon : ""
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 20
                                color: "#000000"
                                visible: modelData.iconPath === undefined
                            }
                        }

                        // Text Content
                        Column {
                            Layout.fillWidth: true
                            spacing: 3
                            
                            Text {
                                text: modelData.label
                                font.family: "SF Pro Text"
                                font.bold: true
                                font.pixelSize: 17
                                color: "#000000"
                            }
                            Text {
                                text: modelData.description
                                font.family: "SF Pro Text"
                                font.pixelSize: 14
                                color: "#000000"
                                opacity: 0.6
                            }
                        }

                        // Chevron (visible on hover)
                        Text {
                            text: "󰅂"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 22
                            color: "#000000"
                            opacity: cardMouse.containsMouse || root.selectedIndex === index ? 1.0 : 0.0
                            Behavior on opacity {
                                NumberAnimation { duration: 200 }
                            }
                        }
                    }

                    MouseArea {
                        id: cardMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: {
                            root.selectedIndex = index
                            root.resultHovered(index)
                        }
                        onExited: root.resultUnhovered()
                        onClicked: root.resultClicked(modelData)
                    }
                }
            }
        }
    }
}
