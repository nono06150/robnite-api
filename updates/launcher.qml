import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: window
    visible: true
    width: 1100
    height: 700
    color: "#0b0d13"
    title: "Robnite Launcher"

    // --- PROPRIÉTÉS DU LAUNCHER ---
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

    // --- SYSTÈME DE PLUIE (ANIMATION CANVAS) ---
    Canvas {
        id: rainCanvas
        anchors.fill: parent
        z: 0
        opacity: 0.3
        property var drops: []

        Component.onCompleted: {
            for (var i = 0; i < 100; i++) {
                drops.push({
                    x: Math.random() * window.width,
                    y: Math.random() * window.height,
                    len: Math.random() * 15 + 5,
                    speed: Math.random() * 10 + 5
                })
            }
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.strokeStyle = "#4a5b7d"
            ctx.lineWidth = 1
            ctx.beginPath()
            for (var i = 0; i < drops.length; i++) {
                var d = drops[i]
                ctx.moveTo(d.x, d.y)
                ctx.lineTo(d.x, d.y + d.len)
            }
            ctx.stroke()
        }

        Timer {
            interval: 16
            running: true
            repeat: true
            onTriggered: {
                for (var i = 0; i < rainCanvas.drops.length; i++) {
                    var d = rainCanvas.drops[i]
                    d.y += d.speed
                    if (d.y > window.height) {
                        d.y = -20
                        d.x = Math.random() * window.width
                    }
                }
                rainCanvas.requestPaint()
            }
        }
    }

    // --- FONCTIONS LOGIQUES ---
    function formatSessionTime(seconds) {
        var h = Math.floor(seconds / 3600)
        var m = Math.floor((seconds % 3600) / 60)
        var s = seconds % 60
        return String(h).padStart(2, "0") + ":" +
               String(m).padStart(2, "0") + ":" +
               String(s).padStart(2, "0")
    }

    function startInstall() {
        showDownloadPopup = false
        isInstalling = true
        installProgress = 0
        mainStack.currentIndex = 1
        installTimer.restart()
    }

    function finishInstall() {
        isInstalling = false
        gameInstalledLocal = true
        installProgress = 100
        installTimer.stop()
    }

    // --- TIMERS ---
    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: {
            elapsedSeconds += 1
            sessionTimer = formatSessionTime(elapsedSeconds)
        }
    }

    Timer {
        id: installTimer
        interval: 650; repeat: true; running: false
        onTriggered: {
            if (window.isInstalling) {
                installProgress += 2
                downloadedGB = Math.round((35 * installProgress / 100) * 100) / 100
                downloadedFiles = Math.floor(417 * installProgress / 100)
                if (installProgress >= 100) window.finishInstall()
            }
        }
    }

    // --- BACKGROUND GRADIENT ---
    Rectangle {
        anchors.fill: parent
        z: -1
        gradient: Gradient {
            GradientStop { id: gradStop1; position: 0.0; color: "#0b0d13" }
            GradientStop { id: gradStop2; position: 1.0; color: selectedTheme === "Ocean" ? "#06233a" : "#1a0b2e" }
        }
    }

    // --- LAYOUT PRINCIPAL ---
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // BARRE LATÉRALE (NAVIGATION)
        Rectangle {
            width: 75
            Layout.fillHeight: true
            color: "#0e1017"
            opacity: 0.98

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 22
                y: 25

                Text { text: "Era"; color: "white"; font.bold: true; font.pixelSize: 18; anchors.horizontalCenter: parent.horizontalCenter }

                Repeater {
                    model: [
                        { icon: "🏠", index: 0 },
                        { icon: "🎮", index: 1 },
                        { icon: "⚙️", index: 5 }
                    ]
                    Rectangle {
                        width: 45; height: 45; radius: 12
                        color: mainStack.currentIndex === modelData.index ? "#25245c" : "transparent"
                        Text { text: modelData.icon; anchors.centerIn: parent; font.pixelSize: 20; color: "white" }
                        MouseArea { anchors.fill: parent; onClicked: mainStack.currentIndex = modelData.index; cursorShape: Qt.PointingHandCursor }
                    }
                }
            }
        }

        // CONTENU PRINCIPAL
        ColumnLayout {
            Layout.fillWidth: true; Layout.fillHeight: true
            Layout.margins: 32; spacing: 20

            // HEADER
            RowLayout {
                Layout.fillWidth: true
                Text { text: "Robnite Launcher"; color: "white"; font.pixelSize: 32; font.bold: true }
                Item { Layout.fillWidth: true }
                
                // BOUTON PLAY/INSTALL DANS LE HEADER
                Rectangle {
                    width: 150; height: 48; radius: 12; color: "#161923"
                    border.color: "#2c3040"
                    Row {
                        anchors.centerIn: parent; spacing: 10
                        Text { text: "▶"; color: "white" }
                        Column {
                            Text { text: selectedBuild; color: "white"; font.bold: true; font.pixelSize: 12 }
                            Text { text: buildStatus; color: "#42ff8a"; font.pixelSize: 11 }
                        }
                    }
                    MouseArea { 
                        anchors.fill: parent
                        onClicked: if(!window.gameInstalledLocal) window.startInstall()
                    }
                }
            }

            // PAGES (STACK)
            StackLayout {
                id: mainStack
                Layout.fillWidth: true; Layout.fillHeight: true
                
                // PAGE ACCUEIL
                ColumnLayout {
                    spacing: 20
                    Rectangle {
                        Layout.fillWidth: true; Layout.preferredHeight: 280; radius: 20
                        color: "#ff7418"; clip: true
                        Column {
                            anchors.left: parent.left; anchors.leftMargin: 35; anchors.verticalCenter: parent.verticalCenter; spacing: 15
                            Text { text: "Saison 3 Arrive"; color: "white"; font.bold: true; font.pixelSize: 38 }
                            Button {
                                text: "JOUER MAINTENANT"
                                onClicked: window.startInstall()
                            }
                        }
                    }
                    Item { Layout.fillHeight: true }
                }

                // PAGE LIBRARIE (INSTALLATION)
                ColumnLayout {
                    Text { text: "Votre Bibliothèque"; color: "white"; font.pixelSize: 24 }
                    ProgressBar {
                        Layout.fillWidth: true
                        value: window.installProgress / 100
                        visible: window.isInstalling
                    }
                    Item { Layout.fillHeight: true }
                }
            }
        }
    }

    // --- OVERLAY DE MAINTENANCE (LE BOUTON ROUGE) ---
    // Changez 'visible: true' en 'false' pour débloquer le launcher
    Rectangle {
        id: maintenanceOverlay
        anchors.fill: parent
        color: "#1a0000"
        z: 1000
        visible: true // <--- METTRE A FALSE POUR UTILISER LE LAUNCHER

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 30

            Text {
                text: "⚠️ ROBNITE EN MAINTENANCE"
                color: "#ff4444"
                font.pixelSize: 42
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            Rectangle {
                width: 300; height: 60; radius: 8
                color: "#960000"; border.color: "#ff0000"; border.width: 2
                Layout.alignment: Qt.AlignHCenter

                Text {
                    anchors.centerIn: parent
                    text: "ACCÈS REFUSÉ"
                    color: "white"
                    font.bold: true; font.pixelSize: 18
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: shakeAnim.start()
                }

                SequentialAnimation on x {
                    id: shakeAnim
                    running: false
                    NumberAnimation { to: maintenanceOverlay.width/2 - 160; duration: 50 }
                    NumberAnimation { to: maintenanceOverlay.width/2 - 140; duration: 50 }
                    NumberAnimation { to: maintenanceOverlay.width/2 - 150; duration: 50 }
                }
            }
        }
    }
}
