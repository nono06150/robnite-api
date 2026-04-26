import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: window
    visible: true
    width: 1100
    height: 700
    color: "#0b0d13"
    title: "Robnite Launcher V3"

    property bool isLaunching: false
    property bool isInstalling: false
    property bool showDownloadPopup: false
    property bool showProfileMenu: false
    property bool gameInstalledLocal: backend.isGameInstalled
    property int installProgress: 0
    property real downloadedGB: 0.0
    property int downloadedFiles: 0

    property int unreadNews: 10
    property int newsPage: 1
    property int playerCount: 0
    property string pingStatus: "Low"

    property string downloadName: "Fortnite 3.0"
    property string downloadSeason: "Saison 3"
    property string downloadBuild: "3.0-CL-3901517"
    property string downloadSize: "35 GB"
    property string installLocation: "Documents\\Robnite\\builds\\Fortnite 3.0"

    property string selectedBuild: window.isInstalling ? downloadName : (gameInstalledLocal ? downloadName : "Fortnite 1.11")
    property string buildStatus: window.isInstalling ? ("Downloading... " + installProgress + "%") : (gameInstalledLocal ? "Installed" : "Not installed")

    property int elapsedSeconds: 0
    property string sessionTimer: "00:00:00"
    property int settingsIndex: 0
    property string selectedTheme: "Default"

    function formatSessionTime(seconds) {
        var h = Math.floor(seconds / 3600)
        var m = Math.floor((seconds % 3600) / 60)
        var s = seconds % 60
        return String(h).padStart(2, "0") + ":" +
               String(m).padStart(2, "0") + ":" +
               String(s).padStart(2, "0")
    }

    function chooseInstallLocation() {
        if (backend.chooseInstallFolder) {
            var path = backend.chooseInstallFolder()
            if (path !== "") {
                installLocation = path
                if (backend.saveLauncherSettings)
                    backend.saveLauncherSettings(installLocation, selectedBuild, elapsedSeconds)
            }
        }
    }

    function importBuild() {
        if (backend.chooseImportFolder) {
            var path = backend.chooseImportFolder()
            if (path !== "") {
                selectedBuild = "Imported Build"
                if (backend.importBuildFromPath)
                    backend.importBuildFromPath(path)
                if (backend.saveLauncherSettings)
                    backend.saveLauncherSettings(installLocation, selectedBuild, elapsedSeconds)
            }
        } else {
            backend.importBuild()
        }
    }

    function startInstall() {
        showDownloadPopup = false
        isInstalling = true
        installProgress = 0
        downloadedGB = 0.0
        downloadedFiles = 0
        mainStack.currentIndex = 1
        installTimer.restart()

        if (backend.startInstallToPath)
            backend.startInstallToPath(downloadName, installLocation)
        else
            backend.installGameExe("D:/1.11/1.11/FortniteGame/Binaries/Win64/FortniteClient-Win64-Shipping.exe")
    }

    function finishInstall() {
    isInstalling = false
    gameInstalledLocal = true
    installProgress = 100
    downloadedGB = 35.0
    downloadedFiles = 417
    installTimer.stop()
    selectedBuild = downloadName

    if (backend.saveLauncherSettings)
        backend.saveLauncherSettings(installLocation, downloadName, elapsedSeconds)
}

    function cancelInstall() {
        isInstalling = false
        installProgress = 0
        downloadedGB = 0.0
        downloadedFiles = 0
        installTimer.stop()
        if (backend.cancelInstall)
            backend.cancelInstall()
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            elapsedSeconds += 1
            sessionTimer = formatSessionTime(elapsedSeconds)
        }
    }

    Timer {
        id: installTimer
        interval: 650
        repeat: true
        running: false
        onTriggered: {
            if (window.isInstalling) {
                installProgress += 2
                if (installProgress > 100)
                    installProgress = 100

                downloadedGB = Math.round((35 * installProgress / 100) * 100) / 100
                downloadedFiles = Math.floor(417 * installProgress / 100)

                if (installProgress >= 100) {
                    window.finishInstall()
               }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        z: -1

        gradient: Gradient {
            GradientStop { id: gradStop1; position: 0.0; color: "#0b0d13" }
            GradientStop { id: gradStop2; position: 1.0; color: selectedTheme === "Ocean" ? "#06233a" : "#1a0b2e" }
        }

        SequentialAnimation {
            running: true
            loops: Animation.Infinite

            ParallelAnimation {
                ColorAnimation { target: gradStop1; property: "color"; to: "#12141d"; duration: 5000; easing.type: Easing.InOutQuad }
                ColorAnimation { target: gradStop2; property: "color"; to: selectedTheme === "Ocean" ? "#0a3554" : "#250d42"; duration: 5000; easing.type: Easing.InOutQuad }
            }
            ParallelAnimation {
                ColorAnimation { target: gradStop1; property: "color"; to: "#1a0b2e"; duration: 5000; easing.type: Easing.InOutQuad }
                ColorAnimation { target: gradStop2; property: "color"; to: "#0b0d13"; duration: 5000; easing.type: Easing.InOutQuad }
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            width: 75
            Layout.fillHeight: true
            color: "#0e1017"
            border.color: "#1e212d"
            opacity: 0.98

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 22
                y: 25

                Text {
                    text: "Era"
                    color: "white"
                    font.bold: true
                    font.pixelSize: 18
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Rectangle { width: 45; height: 1; color: "#1e212d" }

                Repeater {
                    model: [
                        { icon: "⚠️", index: 0 },
                        { icon: "👤", index: 0 },
                        { icon: "🏠", index: 0 },
                        { icon: "🎮", index: 1 },
                        { icon: "📁", index: 2 },
                        { icon: "🛒", index: 3 },
                        { icon: "📜", index: 4 },
                        { icon: "", index: 5 }
                    ]

                    Rectangle {
                        width: 45
                        height: 45
                        radius: 12
                        color: mainStack.currentIndex === modelData.index ? "#25245c" : "transparent"
                        border.color: mainStack.currentIndex === modelData.index ? "#7045ff" : "transparent"
                        scale: navMouse.containsMouse ? 1.05 : 1.0

                        Text {
                            text: modelData.icon
                            anchors.centerIn: parent
                            font.pixelSize: 20
                            color: "white"
                        }

                        MouseArea {
                            id: navMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: mainStack.currentIndex = modelData.index
                        }
                    }
                }

                Item { height: 45 }

                Rectangle {
                    width: 45
                    height: 45
                    radius: 12
                    visible: window.isInstalling
                    color: "#25245c"
                    border.color: "#7045ff"

                    Text {
                        anchors.centerIn: parent
                        text: "⇩"
                        color: "#7d7cff"
                        font.pixelSize: 24
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mainStack.currentIndex = 1
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 32
            spacing: 20

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Text {
                    id: headerTitle
                    text:
                        mainStack.currentIndex === 0 ? "Home" :
                        mainStack.currentIndex === 1 ? "Library" :
                        mainStack.currentIndex === 2 ? "Build Manager" :
                        mainStack.currentIndex === 3 ? "Shop" :
                        mainStack.currentIndex === 4 ? "Logs" :
                        "Settings"
                    color: "white"
                    font.pixelSize: 32
                    font.bold: true
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    width: 150
                    height: 48
                    radius: 12
                    color: "#161923"
                    border.color: "#2c3040"

                    Row {
                        anchors.centerIn: parent
                        spacing: 10

                        Text {
                            text: window.isInstalling ? "◌" : "▶"
                            color: "white"
                            font.pixelSize: 18

                            RotationAnimation on rotation {
                                running: window.isInstalling
                                from: 0
                                to: 360
                                loops: Animation.Infinite
                                duration: 900
                            }
                        }

                        Column {
                            spacing: 1
                            Text { text: selectedBuild; color: "white"; font.bold: true; font.pixelSize: 12 }
                            Text { text: "● " + buildStatus; color: window.isInstalling ? "#ffffff" : (window.gameInstalledLocal ? "#42ff8a" : "#ff5f6d"); font.pixelSize: 11 }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (window.gameInstalledLocal) {
                                window.isLaunching = true
                                backend.launchGame()
                            } else if (!window.isInstalling) {
                                window.showDownloadPopup = true
                            }
                        }
                    }
                }

                Rectangle {
                    width: 95
                    height: 48
                    radius: 12
                    color: "#161923"
                    border.color: "#2c3040"

                    Text {
                        anchors.centerIn: parent
                        text: "👥  " + playerCount + " / 0"
                        color: "white"
                        font.bold: true
                    }
                }

                Rectangle {
                    width: 160
                    height: 48
                    radius: 12
                    color: "#161923"
                    border.color: "#2c3040"

                    Text {
                        anchors.centerIn: parent
                        text: "🟢 " + pingStatus + "   ◷ " + sessionTimer
                        color: "white"
                        font.bold: true
                        font.pixelSize: 12
                    }
                }

                Rectangle {
                    id: profileBox
                    width: 170
                    height: 48
                    radius: 18
                    color: "#161923"
                    border.color: window.showProfileMenu ? "#ffb02e" : (profileMouse.containsMouse ? "#7045ff" : "#2c3040")

                    Row {
                        anchors.centerIn: parent
                        spacing: 10

                        Rectangle {
                            width: 32
                            height: 32
                            radius: 16
                            clip: true
                            color: "#0b0d13"

                            Image {
                                anchors.fill: parent
                                source: backend.userAvatar
                                fillMode: Image.PreserveAspectCrop
                            }
                        }

                        Column {
                            Text { text: backend.userName; color: "white"; font.bold: true; font.pixelSize: 13 }
                            Text { text: "Member"; color: "#a0a3ae"; font.pixelSize: 11 }
                        }

                        Text { text: window.showProfileMenu ? "⌃" : "⌄"; color: "#a0a3ae"; font.pixelSize: 14 }
                    }

                    MouseArea {
                        id: profileMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: window.showProfileMenu = !window.showProfileMenu
                    }
                }
            }

            StackLayout {
                id: mainStack
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: 0

                ColumnLayout {
                    spacing: 22

                    Text {
                        text: "Play now, " + backend.userName + "!"
                        color: "white"
                        font.pixelSize: 22
                        font.bold: true
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 280
                        radius: 20
                        color: "#ff7418"
                        clip: true

                        Image {
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: parent.width * 0.52
                            source: "https://static1.millenium.org/articles/2/40/13/22/@/1680037-fortnite-hype-atlas-20-og-ou-article_cover_bd-2.jpg"
                            fillMode: Image.PreserveAspectCrop
                            opacity: 0.75
                        }

                        Column {
                            anchors.left: parent.left
                            anchors.leftMargin: 35
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 14

                            Text { text: "Project Robnite"; color: "#fff36a"; font.bold: true; font.pixelSize: 18 }
                            Text { text: "Fortnite 3.0 - Saison 3"; color: "#fff36a"; font.bold: true; font.pixelSize: 38 }

                            Text {
                                width: 440
                                text: "Launcher avec téléchargement, importation, sauvegarde automatique et gestion de builds."
                                color: "#4a3414"
                                font.bold: true
                                font.pixelSize: 15
                                wrapMode: Text.WordWrap
                            }

                            Button {
                                width: 150
                                height: 46
                                contentItem: Text {
                                    text: window.isInstalling ? "INSTALL..." : (window.gameInstalledLocal ? "▶ Play" : "⬇ Install")
                                    color: "#ff7418"
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                background: Rectangle {
                                    color: "white"
                                    radius: 10
                                }
                                onClicked: {
                                    if (window.gameInstalledLocal) {
                                        window.isLaunching = true
                                        backend.launchGame()
                                    } else if (!window.isInstalling) {
                                        window.showDownloadPopup = true
                                    }
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Text { text: "What's new"; color: "white"; font.pixelSize: 22; font.bold: true }
                        Item { Layout.fillWidth: true }
                        Text { text: newsPage + " / 3"; color: "#a0a3ae"; font.pixelSize: 14 }

                        Button {
                            width: 90
                            height: 36
                            contentItem: Text {
                                text: unreadNews + " unread"
                                color: "white"
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle { color: "#25245c"; radius: 12; border.color: "#7045ff" }
                            onClicked: unreadNews = 0
                        }
                    }

                    RowLayout {
                        spacing: 18

                        Repeater {
                            model: [
                                { title: "CONTENT UPDATE #4", date: "13/04/2026", img: "https://static1.millenium.org/articles/2/40/13/22/@/1680037-fortnite-hype-atlas-20-og-ou-article_cover_bd-2.jpg" },
                                { title: "CONTENT UPDATE #3", date: "21/03/2026", img: "https://static1.millenium.org/articles/2/40/13/22/@/1680037-fortnite-hype-atlas-20-og-ou-article_cover_bd-2.jpg" }
                            ]

                            Rectangle {
                                width: 430
                                height: 125
                                radius: 12
                                color: "#161923"
                                clip: true
                                border.color: "#1e212d"

                                Row {
                                    anchors.fill: parent

                                    Image {
                                        width: 180
                                        height: parent.height
                                        source: modelData.img
                                        fillMode: Image.PreserveAspectCrop
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 10
                                        width: 220
                                        leftPadding: 14

                                        Text { text: modelData.title; color: "white"; font.bold: true; font.pixelSize: 16 }
                                        Text { text: "Challenges and launcher features added."; color: "#a0a3ae"; wrapMode: Text.WordWrap; width: 210; font.pixelSize: 12 }
                                        Text { text: modelData.date; color: "white"; font.bold: true; font.pixelSize: 11 }
                                    }
                                }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                }

                Flickable {
                    contentHeight: libraryContent.height
                    clip: true

                    Column {
                        id: libraryContent
                        width: parent.width
                        spacing: 35

                        RowLayout {
                            width: parent.width
                            Text { text: "Manage your game builds"; color: "#a0a3ae"; font.pixelSize: 15 }
                            Item { Layout.fillWidth: true }
                            Button {
                                width: 120
                                height: 34
                                contentItem: Text { text: "Open Logs"; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                background: Rectangle { color: "#161923"; radius: 10; border.color: "#2c3040" }
                                onClicked: mainStack.currentIndex = 4
                            }
                        }

                        RowLayout {
                            width: parent.width
                            Text { text: "Installed"; color: "white"; font.bold: true; font.pixelSize: 22 }
                            Item { Layout.fillWidth: true }
                            Rectangle {
                                width: 70
                                height: 26
                                radius: 13
                                color: "#161923"
                                border.color: "#2c3040"
                                Text { anchors.centerIn: parent; text: window.isInstalling ? "2 builds" : "1 build"; color: "#8a8d98"; font.pixelSize: 12 }
                            }
                        }

                        Row {
                            spacing: 14

                            Rectangle {
                                width: 180
                                height: 245
                                radius: 4
                                color: "#161923"
                                border.color: "#7045ff"
                                clip: true

                                Image {
                                    anchors.fill: parent
                                    source: "https://static1.millenium.org/articles/2/40/13/22/@/1680037-fortnite-hype-atlas-20-og-ou-article_cover_bd-2.jpg"
                                    fillMode: Image.PreserveAspectCrop
                                    opacity: 0.55
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: "transparent" }
                                        GradientStop { position: 1.0; color: "#000000" }
                                    }
                                }

                                Text { anchors.left: parent.left; anchors.bottom: parent.bottom; anchors.leftMargin: 12; anchors.bottomMargin: 35; text: "Fortnite 1.11"; color: "white"; font.bold: true; font.pixelSize: 15 }
                                Text { anchors.left: parent.left; anchors.bottom: parent.bottom; anchors.leftMargin: 12; anchors.bottomMargin: 18; text: "1.11-CL-3807424"; color: "white"; font.pixelSize: 11 }
                            }

                            Rectangle {
                                width: 380
                                height: 245
                                radius: 4
                                color: "#252638"
                                border.color: "#7045ff"
                                visible: window.isInstalling
                                clip: true

                                Row {
                                    anchors.fill: parent

                                    Rectangle {
                                        width: 230
                                        height: parent.height
                                        color: "#a56100"
                                        clip: true

                                        Image {
                                            anchors.fill: parent
                                            source: "https://static1.millenium.org/articles/2/40/13/22/@/1680037-fortnite-hype-atlas-20-og-ou-article_cover_bd-2.jpg"
                                            fillMode: Image.PreserveAspectCrop
                                            opacity: 0.8
                                        }

                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: 70
                                            height: 70
                                            radius: 35
                                            color: "#00000066"
                                            border.color: "white"
                                            border.width: 2

                                            Text {
                                                anchors.centerIn: parent
                                                text: installProgress + "%"
                                                color: "white"
                                                font.bold: true
                                                font.pixelSize: 18
                                            }

                                            RotationAnimation on rotation {
                                                running: window.isInstalling
                                                from: 0
                                                to: 360
                                                loops: Animation.Infinite
                                                duration: 900
                                            }
                                        }
                                    }

                                    Rectangle {
                                        width: 150
                                        height: parent.height
                                        color: "#252638"

                                        Column {
                                            anchors.fill: parent
                                            anchors.margins: 16
                                            spacing: 13

                                            Rectangle {
                                                width: 105
                                                height: 25
                                                radius: 7
                                                color: "#3a3d52"
                                                Text { anchors.centerIn: parent; text: "● DOWNLOADING"; color: "white"; font.bold: true; font.pixelSize: 10 }
                                            }

                                            Text { text: downloadName; color: "white"; font.bold: true; font.pixelSize: 18 }
                                            Text { text: downloadBuild; color: "#d0d2dc"; font.pixelSize: 13 }

                                            Text { text: "DL:              " + downloadedGB.toFixed(2) + " GB"; color: "white"; font.bold: true; font.pixelSize: 12 }
                                            Text { text: "Speed:     379.9 Mbps"; color: "#7d7cff"; font.pixelSize: 12 }

                                            Rectangle { width: parent.width; height: 1; color: "#3a3d52" }

                                            Text { text: "Files:          " + downloadedFiles + " / 417"; color: "#d0d2dc"; font.bold: true; font.pixelSize: 12 }
                                        }
                                    }
                                }

                                Rectangle {
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.margins: 14
                                    width: 34
                                    height: 34
                                    radius: 17
                                    color: "#ef5350"

                                    Text { anchors.centerIn: parent; text: "×"; color: "white"; font.pixelSize: 24 }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: window.cancelInstall()
                                    }
                                }
                            }

                            Rectangle {
                                id: importCard
                                width: 180
                                height: 245
                                radius: 4
                                color: "#161923"
                                border.color: importMouse.containsMouse ? "#7045ff" : "#2c3040"
                                border.width: 2

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 12

                                    Rectangle {
                                        width: 58
                                        height: 58
                                        radius: 29
                                        color: "#252b36"
                                        Text { anchors.centerIn: parent; text: "+"; color: "#b5b8c5"; font.bold: true; font.pixelSize: 34 }
                                    }

                                    Text { text: "Import from Disk"; color: "white"; font.bold: true; font.pixelSize: 15; anchors.horizontalCenter: parent.horizontalCenter }
                                    Text { text: "Add existing build"; color: "#d0d2dc"; font.pixelSize: 12; anchors.horizontalCenter: parent.horizontalCenter }
                                }

                                MouseArea {
                                    id: importMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: window.importBuild()
                                }
                            }
                        }

                        RowLayout {
                            width: parent.width
                            Text { text: "Available Downloads"; color: "white"; font.bold: true; font.pixelSize: 22 }
                            Item { Layout.fillWidth: true }
                            Rectangle {
                                width: 90
                                height: 26
                                radius: 13
                                color: "#161923"
                                border.color: "#2c3040"
                                Text { anchors.centerIn: parent; text: "1 available"; color: "#8a8d98"; font.pixelSize: 12 }
                            }
                        }

                        Rectangle {
                            width: 180
                            height: 245
                            radius: 4
                            color: "#ff8a00"
                            border.color: "#7045ff"
                            visible: !window.isInstalling
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: "https://static1.millenium.org/articles/2/40/13/22/@/1680037-fortnite-hype-atlas-20-og-ou-article_cover_bd-2.jpg"
                                fillMode: Image.PreserveAspectCrop
                            }

                            Rectangle {
                                anchors.fill: parent
                                color: downloadMouse.containsMouse ? "#00000066" : "transparent"
                            }

                            Rectangle {
                                anchors.centerIn: parent
                                width: 58
                                height: 58
                                radius: 29
                                color: "#ffffff66"
                                visible: downloadMouse.containsMouse

                                Text { anchors.centerIn: parent; text: "⇩"; color: "white"; font.pixelSize: 32; font.bold: true }
                            }

                            Text { anchors.left: parent.left; anchors.bottom: parent.bottom; anchors.leftMargin: 12; anchors.bottomMargin: 35; text: downloadName; color: "white"; font.bold: true; font.pixelSize: 15 }
                            Text { anchors.left: parent.left; anchors.bottom: parent.bottom; anchors.leftMargin: 12; anchors.bottomMargin: 18; text: downloadBuild; color: "white"; font.pixelSize: 11 }

                            MouseArea {
                                id: downloadMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: window.showDownloadPopup = true
                            }
                        }
                    }
                }

                ColumnLayout {
                    spacing: 18
                    Text { text: "Manage your game builds"; color: "#a0a3ae"; font.pixelSize: 15 }
                    Text { text: "Current Build"; color: "white"; font.pixelSize: 22; font.bold: true }
                    Text { text: "Status: " + buildStatus; color: window.isInstalling ? "#ffaa33" : "#a0a3ae"; font.pixelSize: 15 }
                    Text { text: "Install Location: " + installLocation; color: "#a0a3ae"; font.pixelSize: 15 }
                    Text { text: "Session time: " + sessionTimer; color: "#a0a3ae"; font.pixelSize: 15 }
                    Item { Layout.fillHeight: true }
                }

                ColumnLayout {
                    spacing: 24
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 360
                        radius: 22
                        color: "#8d63ff"
                        Text { anchors.centerIn: parent; text: "Founder"; color: "white"; font.bold: true; font.pixelSize: 54 }
                    }
                    Item { Layout.fillHeight: true }
                }

                ColumnLayout {
                    spacing: 16
                    Text { text: "Launcher Logs"; color: "white"; font.pixelSize: 22; font.bold: true }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 16
                        color: "#080a10"
                        border.color: "#1e212d"

                        Text {
                            anchors.fill: parent
                            anchors.margins: 18
                            color: "#a0ffb0"
                            font.family: "Consolas"
                            font.pixelSize: 13
                            text:
                                "[INFO] Robnite Launcher started\n" +
                                "[INFO] User loaded: " + backend.userName + "\n" +
                                "[INFO] Build selected: " + selectedBuild + "\n" +
                                "[INFO] Status: " + buildStatus + "\n" +
                                "[INFO] Install location: " + installLocation + "\n" +
                                "[INFO] Session time: " + sessionTimer + "\n" +
                                "[READY] Waiting for action..."
                        }
                    }
                }

                RowLayout {
                    spacing: 24

                    Rectangle {
                        width: 280
                        Layout.fillHeight: true
                        radius: 12
                        color: "#161923"
                        border.color: "#2c3040"

                        Column {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 14

                            Text { text: "PROFILE"; color: "#71788a"; font.bold: true; font.pixelSize: 11 }
                            SettingsMenuButton { textValue: "👤  Account"; selected: settingsIndex === 0; onClicked: settingsIndex = 0 }
                            SettingsMenuButton { textValue: "🛍  Purchases"; selected: settingsIndex === 1; onClicked: settingsIndex = 1 }
                            Text { text: "GAME"; color: "#71788a"; font.bold: true; font.pixelSize: 11; topPadding: 10 }
                            SettingsMenuButton { textValue: "💾  Builds"; selected: settingsIndex === 2; onClicked: settingsIndex = 2 }
                            Text { text: "PREFERENCES"; color: "#71788a"; font.bold: true; font.pixelSize: 11; topPadding: 10 }
                            SettingsMenuButton { textValue: "🎨  Appearance"; selected: settingsIndex === 3; onClicked: settingsIndex = 3 }
                            Rectangle { width: parent.width; height: 1; color: "#252b36" }
                            SettingsMenuButton { textValue: "🚪  Log out"; selected: false; onClicked: backend.logout() }
                            Text { text: "era-launcher/latest\nStable 3.0.9\nMade with ❤ by benjamin"; color: "#4f5668"; font.pixelSize: 12; lineHeight: 1.25 }
                        }
                    }

                    StackLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        currentIndex: settingsIndex

                        ColumnLayout {
                            spacing: 14
                            Text { text: "Account"; color: "white"; font.bold: true; font.pixelSize: 22 }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 78
                                radius: 8
                                color: "#161923"
                                border.color: "#2c3040"
                                Row {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin: 16
                                    spacing: 12
                                    Rectangle { width: 48; height: 48; radius: 24; clip: true; Image { anchors.fill: parent; source: backend.userAvatar; fillMode: Image.PreserveAspectCrop } }
                                    Column { anchors.verticalCenter: parent.verticalCenter; Text { text: backend.userName; color: "white"; font.bold: true; font.pixelSize: 16 } Text { text: "Member  • Online"; color: "#5ca8ff"; font.pixelSize: 12 } }
                                }
                            }
                            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 72; radius: 8; color: "#161923"; border.color: "#2c3040"; RowLayout { anchors.fill: parent; anchors.margins: 16; Column { Text { text: "ACCOUNT ID"; color: "#71788a"; font.pixelSize: 11; font.bold: true } Text { text: "5496fa30-f915-437f-8d80-00d61e5ec444"; color: "#bfc5d2"; font.pixelSize: 13 } } Item { Layout.fillWidth: true } Column { Text { text: "USERNAME"; color: "#71788a"; font.pixelSize: 11; font.bold: true } Text { text: backend.userName; color: "white"; font.pixelSize: 13; font.bold: true } } } }
                            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 64; radius: 8; color: "#161923"; border.color: "#2c3040"; Text { anchors.centerIn: parent; text: "Username changes require the Name Change perk"; color: "#71788a"; font.pixelSize: 12 } }
                            Item { Layout.fillHeight: true }
                        }

                        ColumnLayout {
                            spacing: 14
                            Text { text: "Purchases"; color: "white"; font.bold: true; font.pixelSize: 22 }
                            Text { text: "Owned Products"; color: "white"; font.bold: true; font.pixelSize: 16 }
                            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 170; radius: 8; color: "#161923"; border.color: "#2c3040"; Column { anchors.centerIn: parent; spacing: 10; Text { text: "🏷"; color: "#687083"; font.pixelSize: 36; anchors.horizontalCenter: parent.horizontalCenter } Text { text: "No products yet"; color: "#bfc5d2"; font.bold: true; font.pixelSize: 18; anchors.horizontalCenter: parent.horizontalCenter } Text { text: "Visit the store to browse available products"; color: "#71788a"; font.pixelSize: 13; anchors.horizontalCenter: parent.horizontalCenter } } }
                            Text { text: "Active Perks"; color: "white"; font.bold: true; font.pixelSize: 16 }
                            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 210; radius: 8; color: "#161923"; border.color: "#2c3040"; Column { anchors.centerIn: parent; spacing: 10; Text { text: "✿"; color: "#687083"; font.pixelSize: 36; anchors.horizontalCenter: parent.horizontalCenter } Text { text: "No active perks"; color: "#bfc5d2"; font.bold: true; font.pixelSize: 18; anchors.horizontalCenter: parent.horizontalCenter } Text { text: "Purchase products to unlock special perks and features"; color: "#71788a"; font.pixelSize: 13; anchors.horizontalCenter: parent.horizontalCenter } } }
                            Item { Layout.fillHeight: true }
                        }

                        ColumnLayout {
                            spacing: 14
                            Text { text: "Builds"; color: "white"; font.bold: true; font.pixelSize: 22 }
                            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 64; radius: 8; color: "#161923"; border.color: "#2c3040"; RowLayout { anchors.fill: parent; anchors.margins: 12; Text { text: window.gameInstalledLocal ? "💾  19.0 GB used\n1 build" : "💾  No builds installed"; color: "white"; font.bold: true; font.pixelSize: 13 } Item { Layout.fillWidth: true } Button { width: 135; height: 36; contentItem: Text { text: "🗑 Clear All Data"; color: "#ff7777"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter } background: Rectangle { color: "#5a2632"; radius: 7 } onClicked: if (backend.clearAllData) backend.clearAllData() } } }
                            Text { text: "Installed Builds"; color: "white"; font.bold: true; font.pixelSize: 16 }
                            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 145; radius: 8; color: "#161923"; border.color: "#2c3040"; visible: !window.gameInstalledLocal; Column { anchors.centerIn: parent; spacing: 10; Text { text: "💾"; color: "#687083"; font.pixelSize: 36; anchors.horizontalCenter: parent.horizontalCenter } Text { text: "No builds installed"; color: "#bfc5d2"; font.bold: true; font.pixelSize: 18; anchors.horizontalCenter: parent.horizontalCenter } Text { text: "Visit the library to download game builds"; color: "#71788a"; font.pixelSize: 13; anchors.horizontalCenter: parent.horizontalCenter } } }
                            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 70; radius: 8; color: "#161923"; border.color: "#2c3040"; visible: window.gameInstalledLocal; RowLayout { anchors.fill: parent; anchors.margins: 14; Column { Text { text: "Fortnite 1.11"; color: "white"; font.bold: true; font.pixelSize: 15 } Text { text: "Build 1.11-CL-3807424  •  19 GB"; color: "#a0a3ae"; font.pixelSize: 12 } } Item { Layout.fillWidth: true } Button { width: 70; height: 32; contentItem: Text { text: "📂 Open"; color: "white"; font.bold: true; font.pixelSize: 11; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter } background: Rectangle { color: "#25245c"; radius: 7 } onClicked: backend.openFolder() } Button { width: 80; height: 32; contentItem: Text { text: "🗑 Remove"; color: "#ff7777"; font.bold: true; font.pixelSize: 11; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter } background: Rectangle { color: "#5a2632"; radius: 7 } onClicked: if (backend.removeBuild) backend.removeBuild() } } }
                            Item { Layout.fillHeight: true }
                        }

                        Flickable {
                            contentHeight: appearanceContent.height
                            clip: true
                            Column {
                                id: appearanceContent
                                width: parent.width
                                spacing: 14
                                Text { text: "Appearance"; color: "white"; font.bold: true; font.pixelSize: 22 }
                                Rectangle {
                                    width: parent.width
                                    height: 560
                                    radius: 8
                                    color: "#160d2c"
                                    border.color: "#4c3578"
                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: 16
                                        spacing: 14
                                        Text { text: "Preset Themes"; color: "white"; font.bold: true; font.pixelSize: 20 }
                                        Text { text: "Choose from our collection of beautifully crafted themes to personalize your launcher."; color: "#a0a3ae"; font.pixelSize: 13 }
                                        Grid {
                                            columns: 3
                                            spacing: 14
                                            Repeater {
                                                model: ["Default", "Crimson Moon", "Forest", "Ocean", "Sunset", "Midnight", "Chroma Glow", "Neon City", "Toxic", "Amber Flame", "Arctic"]
                                                Rectangle {
                                                    width: 190
                                                    height: 105
                                                    radius: 8
                                                    color: index === 0 ? "#14142c" : "#1b1730"
                                                    border.color: selectedTheme === modelData ? "#ffb02e" : "#252b36"
                                                    Row { anchors.centerIn: parent; spacing: 15; Rectangle { width: 34; height: 34; radius: 17; color: index % 2 === 0 ? "#263078" : "#63222b" } Rectangle { width: 34; height: 34; radius: 17; color: "#7045ff"; opacity: index === 0 || modelData === "Ocean" ? 1 : 0.35; Text { anchors.centerIn: parent; text: index === 0 || modelData === "Ocean" ? "" : "🔒"; color: "white" } } Rectangle { width: 34; height: 34; radius: 17; color: index % 3 === 0 ? "#0b7285" : "#5f5f23" } }
                                                    Text { anchors.left: parent.left; anchors.bottom: parent.bottom; anchors.leftMargin: 10; anchors.bottomMargin: 8; text: modelData; color: "#d0d2dc"; font.bold: true; font.pixelSize: 12 }
                                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { if (index === 0 || modelData === "Ocean") selectedTheme = modelData } }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        visible: showProfileMenu
        z: 30
        width: 210
        height: 145
        radius: 8
        x: window.width - width - 40
        y: 88
        color: "#111827"
        border.color: "#3a455c"
        Column {
            anchors.fill: parent
            spacing: 0
            Row {
                width: parent.width
                height: 55
                leftPadding: 14
                spacing: 10
                Rectangle { width: 34; height: 34; radius: 17; anchors.verticalCenter: parent.verticalCenter; clip: true; Image { anchors.fill: parent; source: backend.userAvatar; fillMode: Image.PreserveAspectCrop } }
                Text { anchors.verticalCenter: parent.verticalCenter; text: backend.userName; color: "white"; font.bold: true; font.pixelSize: 13 }
            }
            Rectangle { width: parent.width; height: 1; color: "#2c3040" }
            Rectangle { width: parent.width; height: 36; color: menuMouse1.containsMouse ? "#1c2435" : "transparent"; Text { anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 16; text: "⚙  Settings"; color: "#d0d2dc"; font.pixelSize: 13; font.bold: true } MouseArea { id: menuMouse1; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { showProfileMenu = false; mainStack.currentIndex = 5; settingsIndex = 0 } } }
            Rectangle { width: parent.width; height: 36; color: menuMouse2.containsMouse ? "#1c2435" : "transparent"; Text { anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 16; text: "↪  Logout"; color: "#ff6b6b"; font.pixelSize: 13; font.bold: true } MouseArea { id: menuMouse2; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { showProfileMenu = false; backend.logout() } } }
        }
    }

    Rectangle {
        anchors.fill: parent
        visible: window.showDownloadPopup
        color: "#000000aa"
        z: 50

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        Rectangle {
            width: 460
            height: 310
            radius: 10
            color: "#111827"
            border.color: "#2c3750"
            anchors.centerIn: parent

            Column {
                anchors.fill: parent

                Row {
                    width: parent.width
                    height: 120
                    leftPadding: 20
                    spacing: 14

                    Rectangle {
                        width: 78
                        height: 78
                        radius: 8
                        anchors.verticalCenter: parent.verticalCenter
                        clip: true
                        Image {
                            anchors.fill: parent
                            source: "https://static1.millenium.org/articles/2/40/13/22/@/1680037-fortnite-hype-atlas-20-og-ou-article_cover_bd-2.jpg"
                            fillMode: Image.PreserveAspectCrop
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 7
                        Text { text: downloadName; color: "white"; font.bold: true; font.pixelSize: 20 }
                        Text { text: downloadSeason + " • " + downloadBuild; color: "#8a8d98"; font.pixelSize: 13 }
                        Rectangle {
                            width: 58
                            height: 28
                            radius: 6
                            color: "#25245c"
                            border.color: "#7045ff"
                            Text { anchors.centerIn: parent; text: downloadSize; color: "white"; font.bold: true; font.pixelSize: 12 }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: "#2c3750" }

                Column {
                    width: parent.width
                    spacing: 12
                    padding: 20

                    Text { text: "DOWNLOAD LOCATION"; color: "#cfd3df"; font.bold: true; font.pixelSize: 12 }

                    Rectangle {
                        width: parent.width - 40
                        height: 38
                        radius: 8
                        color: "#1b2435"
                        border.color: pathMouse.containsMouse ? "#8b5cf6" : "#3a455c"

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 14
                            anchors.right: changePath.left
                            anchors.rightMargin: 8
                            text: "📁  " + installLocation
                            color: "#aeb4c2"
                            font.pixelSize: 13
                            elide: Text.ElideMiddle
                        }

                        Text {
                            id: changePath
                            visible: pathMouse.containsMouse
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 14
                            text: "Change"
                            color: "#8b5cf6"
                            font.pixelSize: 12
                            font.bold: true
                        }

                        MouseArea {
                            id: pathMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: window.chooseInstallLocation()
                        }
                    }

                    Row {
                        spacing: 10

                        Button {
                            width: 90
                            height: 40
                            contentItem: Text { text: "Cancel"; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            background: Rectangle { color: "#1b2435"; radius: 8; border.color: "#3a455c" }
                            onClicked: window.showDownloadPopup = false
                        }

                        Button {
                            width: 320
                            height: 40
                            contentItem: Text { text: "Start Download"; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            background: Rectangle { color: "#6366f1"; radius: 8 }
                            onClicked: window.startInstall()
                        }
                    }
                }
            }
        }
    }

    component SettingsMenuButton: Rectangle {
        signal clicked()
        property string textValue: ""
        property bool selected: false
        width: parent.width
        height: 42
        radius: 7
        color: selected ? "#343a4b" : (btnMouse.containsMouse ? "#202839" : "transparent")
        border.color: selected ? "#ffb02e" : "transparent"
        Text { anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 14; text: textValue; color: "#d9dce8"; font.bold: true; font.pixelSize: 13 }
        MouseArea { id: btnMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: parent.clicked() }
    }
}
