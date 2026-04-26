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

    // --- PROPRIÉTÉS (CORRIGÉES POUR ÉVITER LES CRASHS) ---
    property bool isInstalling: false
    property bool gameInstalledLocal: false // Changé pour éviter l'erreur backend
    property int installProgress: 0
    property string selectedTheme: "Default"
    property int mainIndex: 0

    // --- SYSTÈME DE PARTICULES ET PLUIE (CANVAS) ---
    Canvas {
        id: effectCanvas
        anchors.fill: parent
        z: 0
        opacity: 0.4
        
        property var raindrops: []
        property var particles: [] // Particules qui flottent

        Component.onCompleted: {
            // Initialisation Pluie
            for (var i = 0; i < 80; i++) {
                raindrops.push({
                    x: Math.random() * window.width,
                    y: Math.random() * window.height,
                    len: Math.random() * 20 + 10,
                    speed: Math.random() * 15 + 10
                })
            }
            // Initialisation Particules (Orbites)
            for (var j = 0; j < 40; j++) {
                particles.push({
                    x: Math.random() * window.width,
                    y: Math.random() * window.height,
                    r: Math.random() * 3 + 1,
                    speedX: (Math.random() - 0.5) * 1,
                    speedY: (Math.random() - 0.5) * 1,
                    alpha: Math.random()
                })
            }
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            
            // Dessiner la Pluie
            ctx.strokeStyle = "#4a5b7d"
            ctx.lineWidth = 1
            ctx.beginPath()
            for (var i = 0; i < raindrops.length; i++) {
                var d = raindrops[i]
                ctx.moveTo(d.x, d.y)
                ctx.lineTo(d.x, d.y + d.len)
            }
            ctx.stroke()

            // Dessiner les Particules
            for (var j = 0; j < particles.length; j++) {
                var p = particles[j]
                ctx.beginPath()
                ctx.fillStyle = "rgba(255, 255, 255, " + p.alpha + ")"
                ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2)
                ctx.fill()
            }
        }

        Timer {
            interval: 16
            running: true
            repeat: true
            onTriggered: {
                // Animation Pluie
                for (var i = 0; i < effectCanvas.raindrops.length; i++) {
                    var d = effectCanvas.raindrops[i]
                    d.y += d.speed
                    if (d.y > window.height) { d.y = -20; d.x = Math.random() * window.width }
                }
                // Animation Particules
                for (var j = 0; j < effectCanvas.particles.length; j++) {
                    var p = effectCanvas.particles[j]
                    p.x += p.speedX
                    p.y += p.speedY
                    if (p.x < 0 || p.x > window.width) p.speedX *= -1
                    if (p.y < 0 || p.y > window.height) p.speedY *= -1
                }
                effectCanvas.requestPaint()
            }
        }
    }

    // --- FOND DÉGRADÉ ---
    Rectangle {
        anchors.fill: parent
        z: -1
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0b0d13" }
            GradientStop { position: 1.0; color: "#1a0b2e" }
        }
    }

    // --- LAYOUT PRINCIPAL ---
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Sidebar
        Rectangle {
            width: 75; Layout.fillHeight: true; color: "#0e1017"
            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 25; y: 30
                Text { text: "Era"; color: "white"; font.bold: true; font.pixelSize: 20 }
                
                // Navigation simple
                Rectangle { width: 40; height: 40; radius: 10; color: "#25245c"
                    Text { text: "🏠"; anchors.centerIn: parent; font.pixelSize: 20 }
                }
            }
        }

        // Contenu
        ColumnLayout {
            Layout.fillWidth: true; Layout.margins: 40; spacing: 20
            
            Text { text: "Robnite Launcher"; color: "white"; font.pixelSize: 32; font.bold: true }

            Rectangle {
                id: heroBanner
                Layout.fillWidth: true; Layout.preferredHeight: 300; radius: 20
                color: "#ff7418"
                clip: true
                
                Column {
                    anchors.left: parent.left; anchors.leftMargin: 40; anchors.verticalCenter: parent.verticalCenter
                    spacing: 15
                    Text { text: "SAISON 3"; color: "white"; font.bold: true; font.pixelSize: 45 }
                    Button {
                        text: "INSTALLER MAINTENANT"
                        onClicked: isInstalling = true
                    }
                }
            }

            ProgressBar {
                Layout.fillWidth: true
                visible: isInstalling
                value: installProgress / 100
            }

            Item { Layout.fillHeight: true }
        }
    }

    // --- OVERLAY DE MAINTENANCE (BOUTON ROND) ---
    Rectangle {
        id: maintenanceOverlay
        anchors.fill: parent
        color: "#f2000000"
        z: 1000
        visible: true // <--- Change en 'false' pour tester le launcher

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 30

            // Bouton Rond Hors Ligne
            Rectangle {
                id: offlineButton
                width: 140; height: 140; radius: 70
                color: "#1a0505"
                border.color: "#ff3333"
                border.width: 3
                Layout.alignment: Qt.AlignHCenter

                // Pulsation Glow
                Rectangle {
                    anchors.fill: parent; radius: 70
                    color: "#ff0000"; opacity: 0.1
                    PropertyAnimation on scale { from: 0.9; to: 1.2; duration: 1000; loops: Animation.Infinite; easing.type: Easing.InOutSine }
                    PropertyAnimation on opacity { from: 0.1; to: 0.3; duration: 1000; loops: Animation.Infinite; easing.type: Easing.InOutSine }
                }

                Text {
                    anchors.centerIn: parent
                    text: "OFFLINE"
                    color: "#ff3333"; font.bold: true; font.pixelSize: 18
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: shakeAnim.start()
                }
            }

            Text {
                text: "LES SERVEURS SONT EN MAINTENANCE"
                color: "white"; font.pixelSize: 14; opacity: 0.6
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    // Animation de secousse
    SequentialAnimation {
        id: shakeAnim
        target: offlineButton
        property: "anchors.horizontalCenterOffset"
        NumberAnimation { to: 15; duration: 50 }
        NumberAnimation { to: -15; duration: 50 }
        NumberAnimation { to: 10; duration: 50 }
        NumberAnimation { to: -10; duration: 50 }
        NumberAnimation { to: 0; duration: 50 }
    }
}
