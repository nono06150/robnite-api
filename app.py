import sys
import os
import subprocess
import threading
import webbrowser
import requests
import json
import logging
import shutil
import time
from datetime import datetime, timedelta
from flask import Flask, request

from PyQt6.QtWidgets import QApplication, QFileDialog, QWidget, QVBoxLayout, QLabel, QProgressBar
from PyQt6.QtQml import QQmlApplicationEngine
from PyQt6.QtCore import QObject, pyqtSlot, pyqtProperty, pyqtSignal, QTimer, QUrl, Qt

# --- CONFIGURATION ---
CLIENT_ID = "1497235795717783552"
CLIENT_SECRET = "J9QgHXC3u11qImE5ADW90zu-xWYmLc4-"
REDIRECT_URI = "http://localhost:5000"

API_BASE_URL = "https://robnite-api.onrender.com"
API_KEY = "ROBNITE_SECURE_KEY"

APP_NAME = "RobniteLauncher"
CONFIG_FILE = "user_data.json"
LOCAL_VERSION_FILE = "local_version.json"

API_UPDATES_FOLDER = r"C:\Users\Administrateur\Desktop\RobniteAPI\updates"

app_flask = Flask(__name__)
logging.getLogger("werkzeug").setLevel(logging.ERROR)


def exe_dir():
    if getattr(sys, "frozen", False):
        return os.path.dirname(sys.executable)
    return os.path.dirname(os.path.abspath(__file__))


def bundled_dir():
    if getattr(sys, "frozen", False) and hasattr(sys, "_MEIPASS"):
        return sys._MEIPASS
    return exe_dir()


def appdata_dir():
    base = os.getenv("APPDATA", exe_dir())
    path = os.path.join(base, APP_NAME)
    os.makedirs(path, exist_ok=True)
    return path


def bundled_path(name):
    return os.path.join(bundled_dir(), name)


def data_path(name):
    return os.path.join(appdata_dir(), name)


def api_update_path(name):
    return os.path.join(API_UPDATES_FOLDER, name)


def copy_to_appdata(name):
    target = data_path(name)

    source_api = api_update_path(name)
    if os.path.exists(source_api):
        shutil.copy2(source_api, target)
        print("Fichier copié depuis RobniteAPI updates:", name)
        return target

    source_bundled = bundled_path(name)
    if os.path.exists(source_bundled):
        shutil.copy2(source_bundled, target)
        print("Fichier copié depuis EXE:", name)
        return target

    source_local = os.path.join(exe_dir(), name)
    if os.path.exists(source_local):
        shutil.copy2(source_local, target)
        print("Fichier copié depuis dossier Robnite:", name)
        return target

    return target


def prepare_appdata_files():
    copy_to_appdata("launcher.qml")
    copy_to_appdata("splash.qml")


def cleanup_on_close():
    target = data_path("launcher.qml")

    if os.path.exists(target):
        try:
            os.remove(target)
            print("launcher.qml supprimé à la fermeture")
        except Exception as e:
            print("Impossible de supprimer launcher.qml:", e)


def runtime_file(name):
    updated = data_path(name)
    if os.path.exists(updated):
        return updated

    bundled = bundled_path(name)
    if os.path.exists(bundled):
        return bundled

    return os.path.join(exe_dir(), name)


def restart_app():
    if getattr(sys, "frozen", False):
        subprocess.Popen([sys.executable], cwd=exe_dir())
    else:
        subprocess.Popen([sys.executable, os.path.abspath(__file__)], cwd=exe_dir())
    sys.exit()


def load_local_version():
    path = data_path(LOCAL_VERSION_FILE)

    if not os.path.exists(path):
        with open(path, "w", encoding="utf-8") as f:
            json.dump({"version": "1.0.0", "exe_version": "1.0.0"}, f, indent=4)
        return {"version": "1.0.0", "exe_version": "1.0.0"}

    try:
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
            return {
                "version": data.get("version", "1.0.0"),
                "exe_version": data.get("exe_version", "1.0.0")
            }
    except Exception:
        return {"version": "1.0.0", "exe_version": "1.0.0"}


def save_local_version(version, exe_version=None):
    old = load_local_version()
    data = {
        "version": version,
        "exe_version": exe_version if exe_version else old.get("exe_version", "1.0.0")
    }

    with open(data_path(LOCAL_VERSION_FILE), "w", encoding="utf-8") as f:
        json.dump(data, f, indent=4)


def save_local_exe_version(exe_version):
    old = load_local_version()
    data = {
        "version": old.get("version", "1.0.0"),
        "exe_version": exe_version
    }

    with open(data_path(LOCAL_VERSION_FILE), "w", encoding="utf-8") as f:
        json.dump(data, f, indent=4)


class UpdateWindow(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Robnite Launcher - Update")
        self.setFixedSize(520, 260)
        self.setStyleSheet("""
            QWidget {
                background-color: #0b0d13;
                color: white;
                font-family: Segoe UI;
            }
            QLabel {
                color: white;
            }
            QProgressBar {
                border: 1px solid #2c3040;
                border-radius: 8px;
                text-align: center;
                height: 24px;
                background-color: #161923;
                color: white;
            }
            QProgressBar::chunk {
                background-color: #7045ff;
                border-radius: 8px;
            }
        """)

        layout = QVBoxLayout()
        layout.setContentsMargins(28, 24, 28, 24)
        layout.setSpacing(14)

        self.title = QLabel("Recherche de mise à jour...")
        self.title.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.title.setStyleSheet("font-size: 22px; font-weight: bold;")

        self.status = QLabel("Connexion à l'API Robnite...")
        self.status.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.status.setStyleSheet("font-size: 14px; color: #a0a3ae;")

        self.progress = QProgressBar()
        self.progress.setValue(0)

        self.patch_title = QLabel("Patch notes")
        self.patch_title.setStyleSheet("font-size: 15px; font-weight: bold; color: #ffb02e;")

        self.patch_notes = QLabel("Aucune note pour le moment.")
        self.patch_notes.setWordWrap(True)
        self.patch_notes.setStyleSheet("font-size: 13px; color: #d0d2dc;")

        layout.addWidget(self.title)
        layout.addWidget(self.status)
        layout.addWidget(self.progress)
        layout.addWidget(self.patch_title)
        layout.addWidget(self.patch_notes)

        self.setLayout(layout)

    def set_status(self, text):
        self.status.setText(text)
        QApplication.processEvents()

    def set_progress(self, value):
        self.progress.setValue(value)
        QApplication.processEvents()

    def set_patch_notes(self, notes):
        if isinstance(notes, list):
            self.patch_notes.setText("\n".join(["• " + str(n) for n in notes]))
        elif isinstance(notes, str):
            self.patch_notes.setText(notes)
        else:
            self.patch_notes.setText("Aucune note pour cette version.")
        QApplication.processEvents()


def create_exe_update_bat(new_exe_path, current_exe_path):
    bat_path = data_path("update_launcher.bat")

    bat_content = f"""
@echo off
timeout /t 2 /nobreak > nul
taskkill /f /im "{os.path.basename(current_exe_path)}" > nul 2>&1
timeout /t 1 /nobreak > nul
copy /y "{new_exe_path}" "{current_exe_path}"
start "" "{current_exe_path}"
del "{new_exe_path}" > nul 2>&1
del "%~f0" > nul 2>&1
"""

    with open(bat_path, "w", encoding="utf-8") as f:
        f.write(bat_content)

    subprocess.Popen(
        ["cmd", "/c", bat_path],
        cwd=appdata_dir(),
        creationflags=subprocess.CREATE_NO_WINDOW if os.name == "nt" else 0
    )

    sys.exit()


def download_with_progress(url, target, headers=None, progress_callback=None, start_percent=0, end_percent=100):
    headers = headers or {}

    with requests.get(url, headers=headers, stream=True, timeout=60) as response:
        if response.status_code != 200:
            raise Exception(f"Erreur download {response.status_code}")

        total = int(response.headers.get("content-length", 0))
        downloaded = 0

        with open(target, "wb") as f:
            for chunk in response.iter_content(chunk_size=8192):
                if chunk:
                    f.write(chunk)
                    downloaded += len(chunk)

                    if total > 0 and progress_callback:
                        ratio = downloaded / total
                        percent = int(start_percent + (end_percent - start_percent) * ratio)
                        progress_callback(percent)

    if progress_callback:
        progress_callback(end_percent)


def check_for_updates(update_window=None):
    try:
        local_data = load_local_version()
        local_version = local_data.get("version", "1.0.0")
        local_exe_version = local_data.get("exe_version", "1.0.0")

        if update_window:
            update_window.title.setText("Recherche de mise à jour...")
            update_window.set_status("Connexion à l'API Robnite...")
            update_window.set_progress(5)

        r = requests.get(
            API_BASE_URL + "/version",
            headers={"X-API-KEY": API_KEY},
            timeout=15
        )

        if r.status_code != 200:
            print("Erreur API version:", r.status_code)
            if update_window:
                update_window.set_status("Impossible de contacter l'API. Lancement normal...")
                update_window.set_progress(100)
                time.sleep(1)
            return False

        data = r.json()

        online_version = data.get("version", local_version)
        files_data = data.get("files", {})
        patch_notes = data.get("patch_notes", [])
        exe_data = data.get("exe", {})

        if update_window:
            update_window.set_patch_notes(patch_notes)

        exe_updated = False

        if isinstance(exe_data, dict):
            online_exe_version = exe_data.get("version", local_exe_version)
            exe_url = exe_data.get("url", "")

            if online_exe_version != local_exe_version and exe_url:
                if getattr(sys, "frozen", False):
                    if update_window:
                        update_window.title.setText("Mise à jour du launcher...")
                        update_window.set_status("Téléchargement du nouveau .exe...")
                        update_window.set_progress(10)

                    new_exe_path = data_path("Robnite_new.exe")
                    current_exe_path = sys.executable

                    download_with_progress(
                        exe_url,
                        new_exe_path,
                        headers={"X-API-KEY": API_KEY},
                        progress_callback=lambda p: update_window.set_progress(p) if update_window else None,
                        start_percent=10,
                        end_percent=95
                    )

                    save_local_exe_version(online_exe_version)

                    if update_window:
                        update_window.set_status("Installation du nouveau launcher...")
                        update_window.set_progress(100)
                        time.sleep(1)

                    create_exe_update_bat(new_exe_path, current_exe_path)

                else:
                    print("Update .exe ignorée en mode Python.")
                    save_local_exe_version(online_exe_version)

        if online_version == local_version:
            if update_window:
                update_window.title.setText("Launcher à jour")
                update_window.set_status("Aucune mise à jour disponible.")
                update_window.set_progress(100)
                time.sleep(0.8)
            return False

        if update_window:
            update_window.title.setText("Mise à jour en cours...")
            update_window.set_status("Téléchargement des fichiers...")
            update_window.set_progress(10)

        if isinstance(files_data, dict):
            files = list(files_data.keys())
        else:
            files = files_data

        if not files:
            save_local_version(online_version)
            return False

        total_files = len(files)

        for index, filename in enumerate(files):
            if isinstance(files_data, dict):
                download_url = files_data[filename]
            else:
                download_url = API_BASE_URL + "/download/" + filename

            target = data_path(filename)

            if update_window:
                update_window.set_status(f"Téléchargement : {filename}")

            if os.path.exists(target):
                try:
                    os.remove(target)
                    print("Ancien fichier supprimé:", filename)
                except Exception as e:
                    print("Impossible de supprimer l'ancien fichier:", filename, e)

            start_p = 10 + int((index / total_files) * 80)
            end_p = 10 + int(((index + 1) / total_files) * 80)

            download_with_progress(
                download_url,
                target,
                headers={"X-API-KEY": API_KEY},
                progress_callback=lambda p: update_window.set_progress(p) if update_window else None,
                start_percent=start_p,
                end_percent=end_p
            )

            print("Fichier mis à jour:", filename)

        save_local_version(online_version)

        if update_window:
            update_window.set_status("Mise à jour terminée. Redémarrage...")
            update_window.set_progress(100)
            time.sleep(1)

        return True

    except Exception as e:
        print("Erreur update API:", e)
        if update_window:
            update_window.set_status("Erreur update. Lancement normal...")
            update_window.set_progress(100)
            time.sleep(1)
        return False


class Backend(QObject):
    progressChanged = pyqtSignal()
    loadingFinished = pyqtSignal()
    authDone = pyqtSignal()
    userNameChanged = pyqtSignal()
    userAvatarChanged = pyqtSignal()
    gameStateChanged = pyqtSignal()

    def __init__(self):
        super().__init__()
        self._progress = 0
        self._user_name = "Invité"
        self._user_avatar = ""
        self.game_path = r"D:\1.11\1.11\FortniteGame\Binaries\Win64\Launcher.bat"

        if not self.load_save_and_check():
            threading.Thread(target=self.run_auth_server, daemon=True).start()
            webbrowser.open(
                f"https://discord.com/api/oauth2/authorize?"
                f"client_id={CLIENT_ID}&redirect_uri={REDIRECT_URI}"
                f"&response_type=code&scope=identify"
            )
        else:
            QTimer.singleShot(1000, self.trigger_success_visuals)

    def load_save_and_check(self):
        path = data_path(CONFIG_FILE)

        if os.path.exists(path):
            try:
                with open(path, "r", encoding="utf-8") as f:
                    data = json.load(f)

                last_login = datetime.strptime(data["last_login"], "%Y-%m-%d %H:%M:%S")

                if datetime.now() - last_login > timedelta(days=5):
                    return False

                self._user_name = data["username"]
                self._user_avatar = data["avatar"]
                self.userNameChanged.emit()
                self.userAvatarChanged.emit()
                return True

            except Exception:
                return False

        return False

    def save_user(self, username, avatar):
        data = {
            "username": username,
            "avatar": avatar,
            "last_login": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }

        with open(data_path(CONFIG_FILE), "w", encoding="utf-8") as f:
            json.dump(data, f, indent=4)

    def run_auth_server(self):
        @app_flask.route("/")
        def callback():
            code = request.args.get("code")

            if code and self.fetch_discord_data(code):
                QTimer.singleShot(0, self.trigger_success_visuals)
                return "Authentification réussie ! Tu peux fermer cette page."

            return "Erreur d'authentification."

        app_flask.run(port=5000)

    def fetch_discord_data(self, code):
        try:
            data = {
                "client_id": CLIENT_ID,
                "client_secret": CLIENT_SECRET,
                "grant_type": "authorization_code",
                "code": code,
                "redirect_uri": REDIRECT_URI
            }

            r = requests.post("https://discord.com/api/oauth2/token", data=data).json()
            token = r.get("access_token")

            u = requests.get(
                "https://discord.com/api/users/@me",
                headers={"Authorization": f"Bearer {token}"}
            ).json()

            self._user_name = u.get("username", "Utilisateur")
            user_id = u.get("id")
            avatar = u.get("avatar")

            if user_id and avatar:
                self._user_avatar = f"https://cdn.discordapp.com/avatars/{user_id}/{avatar}.png"
            else:
                self._user_avatar = ""

            self.save_user(self._user_name, self._user_avatar)

            self.userNameChanged.emit()
            self.userAvatarChanged.emit()
            return True

        except Exception:
            return False

    @pyqtProperty(str, notify=userNameChanged)
    def userName(self):
        return self._user_name

    @pyqtProperty(str, notify=userAvatarChanged)
    def userAvatar(self):
        return self._user_avatar

    @pyqtProperty(bool, notify=gameStateChanged)
    def isGameInstalled(self):
        return os.path.exists(self.game_path)

    @pyqtProperty(float, notify=progressChanged)
    def loadProgress(self):
        return self._progress

    @pyqtSlot()
    def trigger_success_visuals(self):
        self.authDone.emit()
        QTimer.singleShot(2000, self.start_loading)

    def start_loading(self):
        self.timer = QTimer()
        self.timer.timeout.connect(self.advance_progress)
        self.timer.start(20)

    def advance_progress(self):
        if self._progress < 100:
            self._progress += 2
            self.progressChanged.emit()
        else:
            self.timer.stop()
            self.loadingFinished.emit()

    @pyqtSlot()
    def launchGame(self):
        if os.path.exists(self.game_path):
            subprocess.Popen([self.game_path], cwd=os.path.dirname(self.game_path), shell=True)

    @pyqtSlot()
    def downloadGame(self):
        webbrowser.open("TON_LIEN_DE_TELECHARGEMENT_ICI")

    @pyqtSlot()
    def openFolder(self):
        folder = os.path.dirname(self.game_path)
        if os.path.exists(folder):
            os.startfile(folder)

    @pyqtSlot(result=str)
    def chooseInstallFolder(self):
        folder = QFileDialog.getExistingDirectory(None, "Choisir le dossier d'installation")
        return folder.replace("/", "\\") if folder else ""

    @pyqtSlot(result=str)
    def chooseImportFolder(self):
        folder = QFileDialog.getExistingDirectory(None, "Importer une version")
        return folder.replace("/", "\\") if folder else ""

    @pyqtSlot(str)
    def importBuildFromPath(self, path):
        print("Build importé depuis:", path)

    @pyqtSlot(str, str)
    def startInstallToPath(self, build_name, install_path):
        print("Installation de", build_name, "dans", install_path)

    @pyqtSlot()
    def cancelInstall(self):
        print("Installation annulée")

    @pyqtSlot(str, str, int)
    def saveLauncherSettings(self, install_path, selected_build, elapsed_seconds):
        data = {
            "install_path": install_path,
            "selected_build": selected_build,
            "elapsed_seconds": elapsed_seconds
        }

        with open(data_path("launcher_settings.json"), "w", encoding="utf-8") as f:
            json.dump(data, f, indent=4)

    @pyqtSlot()
    def logout(self):
        path = data_path(CONFIG_FILE)

        if os.path.exists(path):
            os.remove(path)

        sys.exit()


def main():
    os.environ["QT_QUICK_CONTROLS_STYLE"] = "Basic"

    app = QApplication(sys.argv)

    prepare_appdata_files()

    update_window = UpdateWindow()
    update_window.show()
    QApplication.processEvents()

    updated = check_for_updates(update_window)

    update_window.close()

    if updated:
        restart_app()

    app.aboutToQuit.connect(cleanup_on_close)

    engine = QQmlApplicationEngine()
    backend = Backend()

    engine.rootContext().setContextProperty("backend", backend)

    splash_file = runtime_file("splash.qml")
    launcher_file = runtime_file("launcher.qml")

    engine.load(QUrl.fromLocalFile(splash_file))

    def show_main():
        if engine.rootObjects():
            engine.rootObjects()[0].close()

        engine.load(QUrl.fromLocalFile(launcher_file))

    backend.loadingFinished.connect(show_main)

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())


if __name__ == "__main__":
    main()
