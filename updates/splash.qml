import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    id: window
    visible: true
    width: 680
    height: 430
    color: "transparent"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    property real progressValue: backend.loadProgress / 100

    Rectangle {
        id: bgRect
        anchors.fill: parent
        radius: 24
        color: "#090b12"
        border.color: "#272b3a"
        border.width: 1
        clip: true

        gradient: Gradient {
            GradientStop { position: 0.0; color: "#141633" }
            GradientStop { position: 0.5; color: "#0b0d13" }
            GradientStop { position: 1.0; color: "#1a0b2e" }
        }

        Rectangle {
            width: 360
            height: 360
            radius: 180
            color: "#7045ff"
            opacity: 0.16
            x: -120
            y: -120

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { from: 0.10; to: 0.24; duration: 1400; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 0.24; to: 0.10; duration: 1400; easing.type: Easing.InOutQuad }
            }
        }

        Rectangle {
            width: 300
            height: 300
            radius: 150
            color: "#00d4ff"
            opacity: 0.10
            x: parent.width - 130
            y: parent.height - 140

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { from: 0.06; to: 0.18; duration: 1800; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 0.18; to: 0.06; duration: 1800; easing.type: Easing.InOutQuad }
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.width: 2
            border.color: "#7045ff"
            radius: 24
            opacity: 0.35
        }

        Column {
            anchors.centerIn: parent
            spacing: 24
            width: parent.width

            Rectangle {
                width: 92
                height: 92
                radius: 26
                color: "#161923"
                border.color: "#7045ff"
                border.width: 2
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    anchors.centerIn: parent
                    text: "R"
                    color: "white"
                    font.pixelSize: 48
                    font.bold: true
                    font.family: "Segoe UI"
                }

                RotationAnimation on rotation {
                    running: backend.loadProgress < 100
                    from: 0
                    to: 360
                    duration: 4500
                    loops: Animation.Infinite
                }
            }

            Text {
                id: successText
                text: "AUTHENTIFICATION RÉUSSIE"
                color: "#42ff8a"
                visible: false
                font.pixelSize: 15
                font.bold: true
                font.family: "Segoe UI"
                anchors.horizontalCenter: parent.horizontalCenter

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { from: 1; to: 0.35; duration: 650; easing.type: Easing.InOutQuad }
                    NumberAnimation { from: 0.35; to: 1; duration: 650; easing.type: Easing.InOutQuad }
                }
            }

            Text {
                id: titleText
                text: "Robnite"
                color: "white"
                font.pixelSize: 54
                font.bold: true
                font.family: "Segoe UI"
                anchors.horizontalCenter: parent.horizontalCenter

                Behavior on font.pixelSize {
                    NumberAnimation { duration: 450; easing.type: Easing.OutBack }
                }
            }

            Text {
                id: subtitleText
                text: backend.loadProgress < 35 ? "Connexion aux services..." :
                      backend.loadProgress < 70 ? "Préparation du launcher..." :
                      backend.loadProgress < 100 ? "Chargement des fichiers..." :
                      "Lancement..."
                color: "#a0a3ae"
                font.pixelSize: 14
                font.family: "Segoe UI"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Rectangle {
                width: 470
                height: 14
                radius: 7
                color: "#161923"
                border.color: "#2c3040"
                anchors.horizontalCenter: parent.horizontalCenter
                clip: true

                Rectangle {
                    id: progressFill
                    width: parent.width * progressValue
                    height: parent.height
                    radius: 7
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#7045ff" }
                        GradientStop { position: 0.5; color: "#8b5cf6" }
                        GradientStop { position: 1.0; color: "#00d4ff" }
                    }

                    Behavior on width {
                        NumberAnimation { duration: 220; easing.type: Easing.OutQuad }
                    }

                    Rectangle {
                        width: 45
                        height: parent.height
                        radius: 7
                        color: "white"
                        opacity: 0.22
                        anchors.right: parent.right

                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation { from: 0.10; to: 0.35; duration: 500 }
                            NumberAnimation { from: 0.35; to: 0.10; duration: 500 }
                        }
                    }
                }
            }

            Row {
                spacing: 8
                anchors.horizontalCenter: parent.horizontalCenter

                Repeater {
                    model: 3

                    Rectangle {
                        width: 9
                        height: 9
                        radius: 5
                        color: "#7045ff"

                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            PauseAnimation { duration: index * 160 }
                            NumberAnimation { from: 0.25; to: 1; duration: 350 }
                            NumberAnimation { from: 1; to: 0.25; duration: 350 }
                            PauseAnimation { duration: 480 }
                        }
                    }
                }
            }

            Text {
                text: Math.floor(backend.loadProgress) + "%"
                color: "#d0d2dc"
                font.pixelSize: 16
                font.bold: true
                font.family: "Segoe UI"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        MouseArea {
            anchors.fill: parent
            property point clickPos

            onPressed: clickPos = Qt.point(mouse.x, mouse.y)

            onPositionChanged: {
                window.x += mouse.x - clickPos.x
                window.y += mouse.y - clickPos.y
            }
        }
    }

    Connections {
        target: backend

        function onAuthDone() {
            successText.visible = true
            titleText.text = "PRÉPARATION..."
            titleText.font.pixelSize = 32
        }
    }
}
