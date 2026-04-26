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

    // --- VARIABLES D'ÉTAT ---
    property bool isInstalling: false
    property bool gameInstalledLocal: false
    property int installProgress: 0
    property string selectedBuild: "Fortnite 3.0"
    
    // État du serveur (Mettre à false pour activer le launcher)
    property bool isMaintenance: true 

    // --- SYSTÈME DE PLUIE ---
    Canvas {
        id: rainCanvas
        anchors.fill: parent
        z: 0
        opacity: 0.25
        property var drops: []

        Component.onCompleted: {
            for (var i = 0; i < 100; i++) {
                drops.push({
                    x: Math.random() * window.width,
                    y: Math.random() * window.height,
                    len: Math.random() * 15 + 5,
                    speed: Math.random() * 10 + 7
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
            interval: 16; running: true; repeat: true
            onTriggered: {
                for (var i = 0; i < rainCanvas.drops.length; i++) {
                    var d = rainCanvas.drops[i]
                    d.y += d.speed
                    if (d.y > window.height) { d.y = -20; d.x = Math.random() * window.width }
                }
                rainCanvas.requestPaint()
            }
        }
    }

    // --- ARRIÈRE-PLAN ---
    Rectangle {
        anchors.fill: parent
        z: -1
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0b0d13" }
            GradientStop { position: 1.0; color: "#1a0b2e" }
        }
    }

    // --- CONTENU DU LAUNCHER ---
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Sidebar
        Rectangle {
            width: 70; Layout.fillHeight: true
            color: "#0e1017"
            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 30; spacing: 25
                Text { text: "R"; color: "white"; font.bold: true; font.pixelSize: 24 }
                Text { text: "🏠"; color: "white"; font.pixelSize: 20 }
                Text { text: "⚙️"; color: "gray"; font.pixelSize: 20 }
            }
        }

        // Main View
        ColumnLayout {
            Layout.fillWidth: true; Layout.margins: 40; spacing: 30
            
            Text { 
                text: "Bienvenue sur Robnite"; 
                color: "white"; font.pixelSize: 32; font.bold: true 
            }

            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 300; radius: 15
                color: "#161923"
                border.color: "#2c3040"
                
                ColumnLayout {
                    anchors.centerIn: parent; spacing: 15
                    Text { text: "SAISON 3 DISPONIBLE"; color: "white"; font.bold: true; font.pixelSize: 24 }
                    Button {
                        text: isInstalling ? "INSTALLATION..." : "JOUER"
                        onClicked: isInstalling = true
                    }
                }
            }
            Item { Layout.fillHeight: true }
        }
    }

    // --- OVERLAY DE MAINTENANCE (BOUTON ROND) ---
    Rectangle {
        id: maintenanceOverlay
        anchors.fill: parent
        color: "#f2000000" // Noir très opaque
        visible: window.isMaintenance
        z: 9999

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 30

            // Le Bouton Rond Hors Ligne
            Item {
                width: 150; height: 150
                Layout.alignment: Qt.AlignHCenter

                // Effet de halo (Glow) qui pulse
                Rectangle {
                    id: glowEffect
                    anchors.fill: parent
                    radius: 75
                    color: "#ff0000"
                    opacity: 0.2

                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { from: 0.05; to: 0.4; duration: 1500; easing.type: Easing.InOutSine }
                        NumberAnimation { from: 0.4; to: 0.05; duration: 1500; easing.type: Easing.InOutSine }
                    }

                    PropertyAnimation on scale {
                        loops: Animation.Infinite
                        from: 0.9; to: 1.2; duration: 1500; easing.type: Easing.InOutSine
                    }
                }

                // Cercle Principal
                Rectangle {
                    id: offlineCircle
                    anchors.centerIn: parent
                    width: 100; height: 100
                    radius: 50
                    color: "#0b0d13"
                    border.color: "#ff3333"
                    border.width: 3

                    Column {
                        anchors.centerIn: parent
                        spacing: 2
                        Text { 
                            text: "STATUS"; color: "#666"; 
                            font.pixelSize: 10; font.bold: true; 
                            anchors.horizontalCenter: parent.horizontalCenter 
                        }
                        Text { 
                            text: "OFFLINE"; color: "#ff3333"; 
                            font.pixelSize: 14; font.bold: true; 
                            anchors.horizontalCenter: parent.horizontalCenter 
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: shakeAnim.start()
                    }
                }
            }

            Text {
                text: "LES SERVEURS SONT ACTUELLEMENT EN MAINTENANCE"
                color: "#888"
                font.pixelSize: 12
                font.letterSpacing: 1
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    // Animation de secousse pour le bouton
    SequentialAnimation {
        id: shakeAnim
        target: offlineCircle
        property: "anchors.horizontalCenterOffset"
        NumberAnimation { to: 10; duration: 40 }
        NumberAnimation { to: -10; duration: 40 }
        NumberAnimation { to: 5; duration: 40 }
        NumberAnimation { to: -5; duration: 40 }
        NumberAnimation { to: 0; duration: 40 }
    }
}
