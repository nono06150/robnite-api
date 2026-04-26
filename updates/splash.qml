import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    id: window
    visible: true
    width: 600
    height: 400
    color: "transparent" // Permet d'utiliser le radius du Rectangle
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    Rectangle {
        id: bgRect
        anchors.fill: parent
        color: "#0b0d13"
        radius: 15
        border.color: "#1e212d"
        border.width: 1

        // Animation de changement de couleur du fond en boucle
        SequentialAnimation on color {
            id: bgAnim
            running: false // Ne démarre que quand l'auth est réussie
            loops: Animation.Infinite
            ColorAnimation { from: "#0b0d13"; to: "#1a0b2e"; duration: 2000 }
            ColorAnimation { from: "#1a0b2e"; to: "#0b1a2e"; duration: 2000 }
            ColorAnimation { from: "#0b1a2e"; to: "#0b0d13"; duration: 2000 }
        }

        Column {
            anchors.centerIn: parent
            spacing: 30
            width: parent.width

            // Message "AUTHENTIFICATION RÉUSSIE"
            Text {
                id: successText
                text: "AUTHENTIFICATION RÉUSSIE"
                font.pixelSize: 22
                font.bold: true
                font.family: "Segoe UI"
                color: "#7045ff"
                visible: false // Caché au début
                anchors.horizontalCenter: parent.horizontalCenter

                // Animation de clignotement (opacité)
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { from: 1; to: 0.2; duration: 600; easing.type: Easing.InOutQuad }
                    NumberAnimation { from: 0.2; to: 1; duration: 600; easing.type: Easing.InOutQuad }
                }
            }

            // Titre Principal
            Text {
                id: titleText
                text: "Robnite"
                font.pixelSize: 50
                font.bold: true
                font.family: "Segoe UI"
                color: "white"
                anchors.horizontalCenter: parent.horizontalCenter
                
                Behavior on font.pixelSize { NumberAnimation { duration: 500 } }
            }

            // Barre de progression personnalisée
            ProgressBar {
                id: pb
                value: backend.loadProgress
                from: 0
                to: 100
                implicitWidth: 450
                implicitHeight: 8
                anchors.horizontalCenter: parent.horizontalCenter

                background: Rectangle {
                    color: "#1e212d"
                    radius: 4
                }

                contentItem: Item {
                    Rectangle {
                        width: pb.visualPosition * parent.width
                        height: parent.height
                        color: "#7045ff"
                        radius: 4

                        // Petit éclat au bout de la barre
                        Rectangle {
                            width: 10; height: parent.height
                            color: "white"
                            opacity: 0.3
                            anchors.right: parent.right
                        }
                    }
                }
            }
            
            Text {
                text: Math.floor(backend.loadProgress) + "%"
                color: "#8a8d98"
                font.pixelSize: 14
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    // Gestion des signaux venant du Python (main.py)
    Connections {
        target: backend

        // Quand l'authentification Discord est reçue
        function onAuthDone() {
            successText.visible = true
            bgAnim.running = true
            titleText.text = "PRÉPARATION DES FICHIERS..."
            titleText.font.pixelSize = 24
        }
    }
}