import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: window
    visible: true
    width: 1100
    height: 700
    color: "#0b0d13"
    title: "Robnite Launcher V6"

    // --- PROPRIÉTÉS DU LAUNCHER (CORRIGÉES) ---
    property bool isLaunching: false
    property bool isInstalling: false
    property bool showDownloadPopup: false
    property bool showProfileMenu: false
    
    // CORRECTION : "backend.isGameInstalled" enlevé provisoirement pour éviter le crash.
    property bool gameInstalledLocal: false 
    
    property int installProgress: 0
    property real downloadedGB: 0.0
    property int downloadedFiles: 0

    property string downloadName: "Fortnite 3.0"
    property string downloadSeason: "Saison 3"
    property string downloadBuild: "3.0-CL-3901517"
    property string downloadSize: "35 GB"

    property string selectedBuild: window.isInstalling ? downloadName : (gameInstalledLocal ? downloadName : "Fortnite 1.11")
    property string buildStatus: window.isInstalling ? ("Downloading... " + installProgress + "%") : (gameInstalledLocal ? "Installed" : "Not installed")

    property int elapsedSeconds: 0
    property string sessionTimer: "00:00:00"
    property string selectedTheme: "Default"

    // --- SYSTÈME DE PARTICULES (PLUIE + POUSSIÈRE FLOTTANTE) ---
    Canvas {
        id: effectCanvas
        anchors.fill: parent
        z: 0
        opacity: 0.4
        
        property var raindrops: []
        property var particles: []

        Component.onCompleted: {
            // Création de la pluie
            for (var i = 0; i < 100; i++) {
                raindrops.push({
                    x: Math.random() * window.width,
                    y: Math.random() * window.height,
                    len: Math.random() * 15 + 5,
                    speed: Math.random() * 10 + 5
                })
            }
            // Création des particules (orbites)
            for (var j = 0; j < 40; j++) {
                particles.push({
                    x: Math.random() * window.width,
                    y: Math.random() * window.height,
                    r: Math.random() * 2.5 + 0.5,
                    speedX: (Math.random() - 0.5) * 1.5,
                    speedY: (Math.random() - 0.5) * 1.5,
                    alpha: Math.random() * 0.8 + 0.2
                })
            }
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            
            // Dessin de la pluie
            ctx.strokeStyle = "#4a5b7d"
            ctx.lineWidth = 1
            ctx.beginPath()
            for (var i = 0; i < raindrops.length; i++) {
                var d = raindrops[i]
                ctx.moveTo(d.x, d.y)
                ctx.lineTo(d.x, d.y + d.len)
            }
            ctx.stroke()

            // Dessin des particules
            for (var j = 0; j < particles.length; j++) {
                var p = particles[j]
                ctx.beginPath()
                ctx.fillStyle = "rgba(255, 255, 255, " + p.alpha + ")"
                ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2)
                ctx.fill()
            }
        }

        Timer {
            interval: 16; running: true; repeat: true
            onTriggered: {
                // Mouvement de la pluie
                for (var i = 0; i < effectCanvas.raindrops.length; i++) {
                    var d = effectCanvas.raindrops[i]
                    d.y += d.speed
                    if (d.y > window.height) { d.y = -20; d.x = Math.random() * window.width }
                }
                // Mouvement des particules
                for (var j = 0; j < effectCanvas.particles.length; j++) {
                    var p = effectCanvas.particles[j]
                    p.x += p.speedX
                    p.y += p.speedY
                    // Rebond sur les bords
                    if (p.x < 0 || p.x > window.width) p.speedX *= -1
                    if (p.y < 0 || p.y > window.height) p.speedY *= -1
                }
                effectCanvas.requestPaint()
            }
        }
    }

    // --- FONCTIONS LOGIQUES ---
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

    // --- TIMERS D'INSTALLATION ---
    Timer {
        id: installTimer
        interval: 650; repeat: true; running: false
        onTriggered: {
            if (window.isInstalling) {
                installProgress += 2
                if (installProgress >= 100) window.finishInstall()
            }
        }
    }

    // --- BACKGROUND GRADIENT ---
    Rectangle {
        anchors.fill: parent
        z: -1
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0b0d13" }
            GradientStop { position: 1.0; color: selectedTheme === "Ocean" ? "#06233a" : "#1a0b2e" }
        }
    }

    // --- LAYOUT PRINCIPAL (BARRE LATÉRALE + CONTENU) ---
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
                        { icon: "⚙️", index: 2 }
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
                
                // PAGE 1: ACCUEIL
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

                // PAGE 2: LIBRARIE (INSTALLATION)
                ColumnLayout {
                    Text { text: "Votre Bibliothèque"; color: "white"; font.pixelSize: 24 }
                    ProgressBar {
                        Layout.fillWidth: true
                        value: window.installProgress / 100
                        visible: window.isInstalling
                    }
                    Item { Layout.fillHeight: true }
                }
                
                // PAGE 3: PARAMÈTRES
                ColumnLayout {
                    Text { text: "Paramètres"; color: "white"; font.pixelSize: 24 }
                    Item { Layout.fillHeight: true }
                }
            }
        }
    }

    // --- OVERLAY DE MAINTENANCE (LE BOUTON ROND HORS LIGNE) ---
    // Changez 'visible: true' en 'false' pour tester le launcher
    Rectangle {
        id: maintenanceOverlay
        anchors.fill: parent
        color: "#d9000000" // Fond noir semi-transparent (85%)
        z: 1000
        visible: true // <--- METTRE A FALSE POUR UTILISER LE LAUNCHER

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 30

            // BOUTON ROND
            Rectangle {
                id: offlineCircle
                width: 140; height: 140; radius: 70
                color: "#1a0505"
                border.color: "#ff3333"
                border.width: 3
                Layout.alignment: Qt.AlignHCenter

                // Correction de la secousse avec un Translate
                transform: Translate { id: shakeTranslate }

                // GLOW ANIMÉ
                Rectangle {
                    anchors.centerIn: parent
                    width: 120; height: 120; radius: 60
                    color: "#ff0000"
                    
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { from: 0.05; to: 0.3; duration: 1200; easing.type: Easing.InOutQuad }
                        NumberAnimation { from: 0.3; to: 0.05; duration: 1200; easing.type: Easing.InOutQuad }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "OFFLINE"
                    color: "#ff3333"
                    font.bold: true; font.pixelSize: 18
                    letterSpacing: 2
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: shakeAnim.start()
                }

                // Animation de secousse (corrigée)
                SequentialAnimation {
                    id: shakeAnim
                    NumberAnimation { target: shakeTranslate; property: "x"; to: 10; duration: 40 }
                    NumberAnimation { target: shakeTranslate; property: "x"; to: -10; duration: 40 }
                    NumberAnimation { target: shakeTranslate; property: "x"; to: 5; duration: 40 }
                    NumberAnimation { target: shakeTranslate; property: "x"; to: -5; duration: 40 }
                    NumberAnimation { target: shakeTranslate; property: "x"; to: 0; duration: 40 }
                }
            }

            Text {
                text: "LES SERVEURS SONT ACTUELLEMENT EN MAINTENANCE"
                color: "white"
                font.pixelSize: 14
                font.letterSpacing: 1
                opacity: 0.7
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
