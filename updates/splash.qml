import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    id: window
    visible: true
    width: 1136
    height: 678
    color: "#0f1828"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    property real progressValue: backend.loadProgress / 100

    Rectangle {
        anchors.fill: parent
        color: "#0f1828"

        Canvas {
            id: loaderRing
            width: 54
            height: 54
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -42

            property real angle: 0

            onAngleChanged: requestPaint()

            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)

                ctx.beginPath()
                ctx.lineWidth = 5
                ctx.strokeStyle = "#2a3448"
                ctx.arc(width / 2, height / 2, 20, 0, Math.PI * 2)
                ctx.stroke()

                ctx.beginPath()
                ctx.lineWidth = 5
                ctx.strokeStyle = "#6f6bff"
                ctx.lineCap = "round"

                var start = (angle - 90) * Math.PI / 180
                var end = (angle + 105) * Math.PI / 180

                ctx.arc(width / 2, height / 2, 20, start, end)
                ctx.stroke()
            }

            NumberAnimation on angle {
                from: 0
                to: 360
                duration: 900
                loops: Animation.Infinite
                running: true
            }
        }

        Text {
            id: statusText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: loaderRing.bottom
            anchors.topMargin: 14
            text: backend.loadProgress < 20 ? "Checking for updates" :
                  backend.loadProgress < 55 ? "Preparing launcher" :
                  backend.loadProgress < 90 ? "Loading files" :
                  "Starting Robnite"
            color: "white"
            font.family: "Segoe UI"
            font.pixelSize: 15
            font.bold: true
        }

        Text {
            id: versionText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: statusText.bottom
            anchors.topMargin: 8
            text: "v" + backend.launcherVersion
            color: "#5f6f8f"
            font.family: "Segoe UI"
            font.pixelSize: 12
        }

        Rectangle {
            width: 150
            height: 3
            radius: 2
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: versionText.bottom
            anchors.topMargin: 16
            color: "#1a2537"
            clip: true

            Rectangle {
                height: parent.height
                width: parent.width * progressValue
                radius: 2
                color: "#6f6bff"

                Behavior on width {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutQuad
                    }
                }
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
            statusText.text = "Authentication successful"
        }
    }
}
