import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Item {
    id: root
    property bool isOpen: false
    signal closeRequested()
    signal runCommand(string cmd)
    function forceSearch(q) { searchValue = q; textInput.text = q; }

    property bool hovered: false
    property int hoveredShortcut: -1
    property int hoveredResult: -1
    property string searchValue: ""
    property var searchResults: []

    property string activeFilter: ""
    property var shortcuts: [
        { id: "apps", icon: "󰕰", label: "Apps" },
        { id: "files", icon: "󰉋", label: "Files" },
        { id: "clipboard", icon: "󰈔", label: "Clipboard" },
        { id: "web", icon: "󰖟", label: "Web" }
    ]
    readonly property var springCurve: [0.25, 0.80, 0.35, 1.015, 0.55, 1.015, 0.70, 1.015, 0.80, 1.000, 1.00, 1.000]
    readonly property bool showShortcuts: root.hovered && root.searchValue === "" && root.activeFilter === ""


    readonly property int activeMenuHeight: {
        if (activeFilter === "Apps") return appGrid.contentHeight;
        if (activeFilter === "Clipboard") return clipboardView.contentHeight;
        if (searchValue !== "") return resultsContainer.contentHeightPixels;
        return 0;
    }

    property int contentWidth: 768
    width: contentWidth + (padding * 2)
    property int padding: 40
    height: searchBarContainer.height + (padding * 2)

    opacity: isOpen ? 1.0 : 0.0
    property bool wasOpen: false

    transform: [
        Scale {
            origin.x: root.width / 2
            origin.y: root.height / 2
            xScale: root.isOpen ? 1.0 : 0.90
            yScale: root.isOpen ? 1.0 : 0.90
            Behavior on xScale { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
            Behavior on yScale { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        },
        Translate {
            y: root.isOpen ? 0 : -16
            Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        }
    ]

    Behavior on opacity { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }

    Timer {
        id: focusTimer
        interval: 100
        onTriggered: textInput.forceActiveFocus()
    }

    Timer {
        id: resetStateTimer
        interval: 270
        repeat: false
        onTriggered: {
            root.activeFilter = "";
            root.searchValue = "";
            textInput.text = "";
            root.hoveredShortcut = -1;
            root.hoveredResult = -1;
            root.searchResults = [];
        }
    }

    onIsOpenChanged: {
        if (isOpen) {
            resetStateTimer.stop();
            wasOpen = true;
            focusTimer.start();
        } else {
            resetStateTimer.restart();
        }
    }

    onSearchValueChanged: {
        if (activeFilter === "Apps" || activeFilter === "Clipboard") {
            return;
        }
        if (!searchValue || searchValue.trim() === "") {
            searchResults = [];
            filesProcess.running = false;
            clipboardProcess.running = false;
            return;
        }
        searchDebounce.restart();
    }

    Timer {
        id: searchDebounce
        interval: 150
        onTriggered: root.doSearch()
    }
    
    Process {
        id: filesProcess
        stdout: SplitParser {
            onRead: function(line) {
                if (line.trim() !== "") {
                    let tmp = root.searchResults.slice();
                    let filename = line.split('/').pop();
                    tmp.push({ action: "command", id: "file_"+line, label: filename, description: line, icon: "󰈔", command: "xdg-open '" + line + "'" });
                    root.searchResults = tmp;
                }
            }
        }
    }
    
    Process {
        id: clipboardProcess
        stdout: SplitParser {
            onRead: function(line) {
                if (line.trim() !== "") {
                    let tmp = root.searchResults.slice();
                    let decoded = line.substring(line.indexOf('\t') + 1);
                    tmp.push({ action: "command", id: "clip_"+line, label: decoded, description: "Clipboard", icon: "󰅌", command: "echo -n '" + line.split('\t')[0] + "' | cliphist decode | wl-copy" });
                    root.searchResults = tmp;
                }
            }
        }
    }

    function doSearch() {
        let q = searchValue.trim();
        if (q === "") return;
        let res = [];
        if (q.startsWith(">")) {
            let cmd = q.substring(1).trim();
            if (cmd.length > 0) res.push({ action: "command", id: "cmd", label: cmd, description: "Run Command", icon: "󰆍", command: cmd });
            searchResults = res; return;
        }
        try {
            if (/^[\d\s\+\-\*\/\(\)\.]+$/.test(q) && q.match(/[\+\-\*\/]/)) {
                let result = eval(q);
                if (result !== undefined && !isNaN(result)) res.push({ action: "none", id: "math", label: String(result), description: "Calculator", icon: "󰪚" });
            }
        } catch(e) {}
        
        let lowerQ = q.toLowerCase();
        let filter = root.activeFilter;
        
        if (filter === "Apps" || filter === "") {
            let apps = DesktopEntries.applications.values;
            let matchedApps = [];
            for (let i = 0; i < apps.length; i++) {
                let app = apps[i];
                if (app.name.toLowerCase().indexOf(lowerQ) !== -1) {
                    matchedApps.push(app);
                }
            }
            matchedApps.sort((a, b) => {
                let aScore = a.name.toLowerCase().startsWith(lowerQ) ? 1 : 0;
                let bScore = b.name.toLowerCase().startsWith(lowerQ) ? 1 : 0;
                if (aScore !== bScore) return bScore - aScore;
                return a.name.localeCompare(b.name);
            });
            for (let i = 0; i < Math.min(matchedApps.length, 10); i++) {
                let app = matchedApps[i];
                res.push({ action: "app", id: app.id, label: app.name, description: app.comment || "Application", iconPath: Quickshell.iconPath(app.icon, true) || "", appRef: app });
            }
        }
        
        if (filter === "Web" || (filter === "" && res.length === 0)) {
            res.push({ action: "web", id: "web", label: `Search Web for "${q}"`, description: "Browser", icon: "󰖟", query: q });
        }
        searchResults = res;
        
        if (filter === "Files" || filter === "") {
            filesProcess.running = false;
            let safeQ = q.replace(/"/g, '\\"');
            filesProcess.command = ["sh", "-c", 'fd -i "' + safeQ + '" /home/banana -m 10'];
            filesProcess.running = true;
        }
        
        if (filter === "Clipboard" || filter === "") {
            clipboardProcess.running = false;
            let safeQ = q.replace(/"/g, '\\"');
            clipboardProcess.command = ["sh", "-c", 'cliphist list | grep -i "' + safeQ + '" | head -n 10'];
            clipboardProcess.running = true;
        }
    }


    Item {
        id: gooeyContainer
        width: parent.width
        height: parent.height
        x: 0
        y: 0

        // === LAYER 1: GOOEY BACKGROUND ===
        Item {
            id: gooeySource
            anchors.fill: parent
            
            Row {
                width: root.contentWidth
                height: searchBarContainer.height
                anchors.centerIn: parent
                layoutDirection: Qt.LeftToRight
                spacing: 16

                Rectangle {
                    width: root.contentWidth - (root.showShortcuts ? (root.shortcuts.length * 80) : 0)
                    height: 64 + root.activeMenuHeight
                    radius: 30
                    color: "#f5f5f5"
                    Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                    Behavior on height { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                }

                Repeater {
                    model: root.shortcuts
                    Item {
                        width: root.showShortcuts ? 64 : 0
                        height: 64
                        visible: root.showShortcuts || dummyBubble.opacity > 0.01
                        Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }

                        Rectangle {
                            id: dummyBubble
                            width: 64
                            height: 64
                            radius: 32
                            color: "#f5f5f5"
                            property real startX: -64 * (index + 1)
                            property real exitX: (16 + 64) * (root.shortcuts.length - index - 1)
                            
                            x: startX
                            scale: 0.7
                            opacity: 0.0

                            state: root.showShortcuts ? "hovered" : "unhovered"
                            states: [
                                State { name: "hovered"; PropertyChanges { target: dummyBubble; x: 0; scale: 1.0; opacity: 1.0 } },
                                State { name: "unhovered"; PropertyChanges { target: dummyBubble; x: dummyBubble.exitX; scale: 0.7; opacity: 0.0 } }
                            ]
                            transitions: [
                                Transition {
                                    from: "unhovered"; to: "hovered"
                                    SequentialAnimation {
                                        PropertyAction { target: dummyBubble; property: "x"; value: dummyBubble.startX }
                                        PropertyAction { target: dummyBubble; property: "scale"; value: 0.7 }
                                        PropertyAction { target: dummyBubble; property: "opacity"; value: 1.0 }
                                        PauseAnimation { duration: index * 45 }
                                        ParallelAnimation {
                                            NumberAnimation { target: dummyBubble; property: "x"; duration: 720; easing.type: Easing.BezierSpline; easing.bezierCurve: root.springCurve }
                                            NumberAnimation { target: dummyBubble; property: "scale"; duration: 720; easing.type: Easing.BezierSpline; easing.bezierCurve: root.springCurve }
                                        }
                                    }
                                },
                                Transition {
                                    from: "hovered"; to: "unhovered"
                                    SequentialAnimation {
                                        PauseAnimation { duration: index * 50 }
                                        ParallelAnimation {
                                            NumberAnimation { target: dummyBubble; property: "x"; duration: 800; easing.type: Easing.BezierSpline; easing.bezierCurve: root.springCurve }
                                            NumberAnimation { target: dummyBubble; property: "scale"; duration: 800; easing.type: Easing.BezierSpline; easing.bezierCurve: root.springCurve }
                                            SequentialAnimation {
                                                PauseAnimation { duration: 250 }
                                                NumberAnimation { target: dummyBubble; property: "opacity"; to: 0.0; duration: 350; easing.type: Easing.OutQuad }
                                            }
                                        }
                                        PropertyAction { target: dummyBubble; property: "x"; value: dummyBubble.startX }
                                    }
                                }
                            ]
                        }
                    }
                }
            }
        }

        ShaderEffectSource {
            id: gooeyTex
            sourceItem: gooeySource
            hideSource: true
            anchors.fill: parent
        }

        FastBlur {
            id: blurredGooey
            source: gooeyTex
            anchors.fill: parent
            radius: 25
            transparentBorder: true
            visible: false
        }

        ShaderEffect {
            anchors.fill: parent
            property var source: blurredGooey
            fragmentShader: "shaders/threshold.frag.qsb"
            visible: root.activeFilter === "" || root.showShortcuts
        }

        // === LAYER 2: FOREGROUND CONTENT ===
        Row {
            id: foregroundRow
            width: root.contentWidth
            height: searchBarContainer.height
            anchors.centerIn: parent
            layoutDirection: Qt.LeftToRight
            spacing: 16

            Rectangle {
                id: searchBarContainer
                z: 2
                width: root.contentWidth - (root.showShortcuts ? (root.shortcuts.length * 80) : 0)
                height: 64 + root.activeMenuHeight
                radius: 30
                color: "#f5f5f5"
                border.width: 1
                border.color: "#e5e5e5"

                Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                Behavior on height { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }

                clip: true
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton
                    onEntered: root.hovered = true
                }

                Item {
                    id: searchInput
                    width: parent.width
                    height: 64
                    
                    Text {
                        id: searchIcon
                        anchors.left: parent.left
                        anchors.leftMargin: 24
                        anchors.verticalCenter: parent.verticalCenter
                        text: {
                            if (root.activeFilter === "Apps") return "󰕰";
                            if (root.activeFilter === "Clipboard") return "󰈔";
                            return "󰍉";
                        }
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 24
                        color: root.activeFilter !== "" ? "#000000" : "#6b7280"
                    }

                    Rectangle {
                        id: clearFilterBtn
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        width: 28
                        height: 28
                        radius: 14
                        color: clearFilterMouse.containsMouse ? "#e5e7eb" : "#f3f4f6"
                        visible: root.activeFilter !== ""

                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            text: "󰅖"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 15
                            color: clearFilterMouse.containsMouse ? "#1f2937" : "#6b7280"
                        }

                        MouseArea {
                            id: clearFilterMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.activeFilter = "";
                                root.searchValue = "";
                                textInput.text = "";
                            }
                        }
                    }

                    Item {
                        anchors.left: searchIcon.right
                        anchors.leftMargin: 8
                        anchors.right: root.activeFilter !== "" ? clearFilterBtn.left : parent.right
                        anchors.rightMargin: root.activeFilter !== "" ? 8 : 24
                        height: parent.height
                        
                        Text {
                            id: placeholderText
                            anchors.verticalCenter: parent.verticalCenter
                            
                            text: {
                                if (root.hoveredShortcut >= 0) return "Search " + root.shortcuts[root.hoveredShortcut].label;
                                if (root.activeFilter === "Apps") return "Search applications...";
                                if (root.activeFilter === "Clipboard") return "Search clipboard history...";
                                if (root.hoveredResult >= 0 && root.searchValue !== "") return "Open " + resultsContainer.results[root.hoveredResult].label;
                                return "Search";
                            }
                            
                            color: (root.hoveredResult >= 0 && root.searchValue !== "") ? "#000000" : "#6b7280"
                            font.family: "SF Pro Text"
                            font.pixelSize: 24
                            
                            opacity: (root.searchValue.length === 0 || root.hoveredResult >= 0 || root.hoveredShortcut >= 0) ? 1.0 : 0.0
                            
                            layer.enabled: true
                            layer.effect: Component {
                                FastBlur {
                                    radius: placeholderText.opacity < 1.0 ? 5 : 0
                                    transparentBorder: true
                                }
                            }

                            Behavior on text {
                                SequentialAnimation {
                                    ParallelAnimation {
                                        NumberAnimation { target: placeholderText; property: "y"; to: -10; duration: 200; easing.type: Easing.OutQuad }
                                        NumberAnimation { target: placeholderText; property: "opacity"; to: 0; duration: 200; easing.type: Easing.OutQuad }
                                    }
                                    PropertyAction { target: placeholderText; property: "y"; value: 10 }
                                    PropertyAction { target: placeholderText; property: "text" }
                                    ParallelAnimation {
                                        NumberAnimation { target: placeholderText; property: "y"; to: (searchInput.height - placeholderText.height)/2; duration: 200; easing.type: Easing.OutQuad }
                                        NumberAnimation { target: placeholderText; property: "opacity"; to: 1; duration: 200; easing.type: Easing.OutQuad }
                                    }
                                }
                            }
                        }

                        TextInput {
                            id: textInput
                            anchors.fill: parent
                            verticalAlignment: TextInput.AlignVCenter
                            font.family: "SF Pro Text"
                            font.pixelSize: 24
                            color: "#000000"
                            opacity: text.length > 0 && root.hoveredResult < 0 ? 1.0 : 0.0
                            onTextChanged: root.searchValue = text
                            Keys.onEscapePressed: {
                                if (root.activeFilter !== "") {
                                    root.activeFilter = "";
                                    root.searchValue = "";
                                    textInput.text = "";
                                } else {
                                    root.closeRequested();
                                }
                            }
                            Keys.onUpPressed: {
                                if (root.activeFilter === "Apps") {
                                    appGrid.moveSelection(0, -1);
                                } else if (root.activeFilter === "Clipboard") {
                                    clipboardView.moveSelection(-1);
                                } else if (root.searchResults.length > 0) {
                                    root.hoveredResult = root.hoveredResult <= 0 ? root.searchResults.length - 1 : root.hoveredResult - 1;
                                }
                            }
                            Keys.onDownPressed: {
                                if (root.activeFilter === "Apps") {
                                    appGrid.moveSelection(0, 1);
                                } else if (root.activeFilter === "Clipboard") {
                                    clipboardView.moveSelection(1);
                                } else if (root.searchResults.length > 0) {
                                    root.hoveredResult = root.hoveredResult >= root.searchResults.length - 1 ? 0 : root.hoveredResult + 1;
                                }
                            }
                            Keys.onLeftPressed: {
                                if (root.activeFilter === "Apps" && textInput.cursorPosition === 0) {
                                    appGrid.moveSelection(-1, 0);
                                }
                            }
                            Keys.onRightPressed: {
                                if (root.activeFilter === "Apps" && textInput.cursorPosition === textInput.text.length) {
                                    appGrid.moveSelection(1, 0);
                                }
                            }
                            Keys.onReturnPressed: {
                                if (root.activeFilter === "Apps") {
                                    appGrid.launchSelected();
                                } else if (root.activeFilter === "Clipboard") {
                                    clipboardView.copySelected();
                                } else if (root.hoveredResult >= 0 && root.hoveredResult < root.searchResults.length) {
                                    resultsContainer.resultClicked(root.searchResults[root.hoveredResult]);
                                } else if (root.searchResults.length > 0) {
                                    resultsContainer.resultClicked(root.searchResults[0]);
                                }
                            }
                        }
                    }
                }

                SpotlightAppGrid {
                    id: appGrid
                    anchors.top: searchInput.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    opacity: root.activeFilter === "Apps" ? 1.0 : 0.0
                    visible: root.activeFilter === "Apps" || opacity > 0.01
                    Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }
                    filterQuery: root.searchValue
                    onAppLaunched: root.closeRequested()
                }

                SpotlightClipboard {
                    id: clipboardView
                    anchors.top: searchInput.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    opacity: root.activeFilter === "Clipboard" ? 1.0 : 0.0
                    visible: root.activeFilter === "Clipboard" || opacity > 0.01
                    Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }
                    filterQuery: root.searchValue
                    onItemCopied: root.closeRequested()
                }

                SpotlightResults {
                    id: resultsContainer
                    anchors.top: searchInput.bottom
                    visible: root.activeFilter === "" && root.searchValue !== ""
                    results: root.searchResults
                    selectedIndex: root.hoveredResult
                    onResultHovered: function(idx) { root.hoveredResult = idx; }
                    onResultUnhovered: function() { }
                    onResultClicked: function(result) {
                        if (result.action === "app") {
                            result.appRef.execute();
                        } else if (result.action === "command") {
                            root.runCommand(result.command);
                        } else if (result.action === "web") {
                            root.runCommand("xdg-open 'https://duckduckgo.com/?q=" + encodeURIComponent(result.query) + "'");
                        }
                        root.closeRequested();
                    }
                }

            }

            Repeater {
                model: root.shortcuts

                Item {
                    z: 1
                    width: root.showShortcuts ? 64 : 0
                    height: 64
                    visible: root.showShortcuts || realBubble.opacity > 0.01
                    Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }

                    Rectangle {
                        id: realBubble
                        width: 64
                        height: 64
                        radius: 32
                        color: root.activeFilter === modelData.label ? "#e5e5e5" : "transparent"
                        
                        property real startX: -64 * (index + 1)
                        property real exitX: (16 + 64) * (root.shortcuts.length - index - 1)
                        
                        x: startX
                        scale: 0.7
                        opacity: 0.0

                        state: root.showShortcuts ? "hovered" : "unhovered"
                        states: [
                            State { name: "hovered"; PropertyChanges { target: realBubble; x: 0; scale: 1.0; opacity: 1.0 } },
                            State { name: "unhovered"; PropertyChanges { target: realBubble; x: realBubble.exitX; scale: 0.7; opacity: 0.0 } }
                        ]
                        transitions: [
                            Transition {
                                from: "unhovered"; to: "hovered"
                                SequentialAnimation {
                                    PropertyAction { target: realBubble; property: "x"; value: realBubble.startX }
                                    PropertyAction { target: realBubble; property: "scale"; value: 0.7 }
                                    PropertyAction { target: realBubble; property: "opacity"; value: 1.0 }
                                    PauseAnimation { duration: index * 45 }
                                    ParallelAnimation {
                                        NumberAnimation { target: realBubble; property: "x"; duration: 720; easing.type: Easing.BezierSpline; easing.bezierCurve: root.springCurve }
                                        NumberAnimation { target: realBubble; property: "scale"; duration: 720; easing.type: Easing.BezierSpline; easing.bezierCurve: root.springCurve }
                                    }
                                }
                            },
                            Transition {
                                from: "hovered"; to: "unhovered"
                                SequentialAnimation {
                                    PauseAnimation { duration: index * 50 }
                                    ParallelAnimation {
                                        NumberAnimation { target: realBubble; property: "x"; duration: 800; easing.type: Easing.BezierSpline; easing.bezierCurve: root.springCurve }
                                        NumberAnimation { target: realBubble; property: "scale"; duration: 800; easing.type: Easing.BezierSpline; easing.bezierCurve: root.springCurve }
                                        SequentialAnimation {
                                            PauseAnimation { duration: 250 }
                                            NumberAnimation { target: realBubble; property: "opacity"; to: 0.0; duration: 350; easing.type: Easing.OutQuad }
                                        }
                                    }
                                    PropertyAction { target: realBubble; property: "x"; value: realBubble.startX }
                                }
                            }
                        ]

                        Text {
                            anchors.centerIn: parent
                            text: modelData.icon
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 28
                            color: "#000000"
                            opacity: shortcutMouse.containsMouse || root.activeFilter === modelData.label ? 1.0 : 0.4
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                        }

                        MouseArea {
                            id: shortcutMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: root.hoveredShortcut = index
                            onExited: {
                                if (root.hoveredShortcut === index)
                                    root.hoveredShortcut = -1
                            }
                            onClicked: {
                                if (root.activeFilter === modelData.label) {
                                    root.activeFilter = "";
                                } else {
                                    root.activeFilter = modelData.label;
                                }
                                root.hoveredShortcut = -1;
                                root.searchValue = "";
                                textInput.text = "";
                                if (root.activeFilter === "Clipboard") {
                                    clipboardView.reload();
                                }
                                focusTimer.start();
                            }
                        }
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: gooeyContainer
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onEntered: root.hovered = true
        onExited: {
            root.hovered = false
            root.hoveredShortcut = -1
        }
    }
}
