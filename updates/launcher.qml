import customtkinter as ctk
import tkinter as tk
import random

class MaintenanceRainApp(ctk.CTk):
    def __init__(self):
        super().__init__()

        # Configuration de la fenêtre
        self.title("ALERTE SYSTÈME - MAINTENANCE CRITIQUE")
        self.geometry("800x500")
        self.resizable(False, False)
        ctk.set_appearance_mode("dark")

        # --- CANVAS POUR LA PLUIE ---
        # On crée un Canvas Tkinter standard pour gérer les particules
        self.canvas = tk.Canvas(
            self, 
            bg="#1a1a1a", 
            highlightthickness=0, 
            width=800, 
            height=500
        )
        self.canvas.place(x=0, y=0, relwidth=1, relheight=1)

        # Liste pour stocker les particules de pluie
        self.rain_drops = []
        self.create_storm()

        # --- INTERFACE SUPERPOSÉE ---
        # Conteneur transparent (Frame) pour le texte et les boutons
        self.ui_frame = ctk.CTkFrame(self, fg_color="transparent")
        self.ui_frame.place(relx=0.5, rely=0.5, anchor="center")

        # Titre d'alerte
        self.alert_label = ctk.CTkLabel(
            self.ui_frame, 
            text="ERREUR SYSTÈME 503", 
            font=ctk.CTkFont(size=40, weight="bold"),
            text_color="#E74C3C"
        )
        self.alert_label.pack(pady=10)

        # Message grave
        self.msg_label = ctk.CTkLabel(
            self.ui_frame, 
            text="L'accès au menu principal est corrompu ou en maintenance.\nLe noyau du système ne répond plus.",
            font=ctk.CTkFont(size=16),
            text_color="#AAAAAA"
        )
        self.msg_label.pack(pady=20)

        # --- LE BOUTON ROUGE ---
        self.danger_button = ctk.CTkButton(
            self.ui_frame,
            text="SYSTÈME INACCESSIBLE",
            font=ctk.CTkFont(size=18, weight="bold"),
            fg_color="#960000",      # Rouge sang
            hover_color="#660000",   # Rouge très sombre au survol
            border_width=2,
            border_color="#FF0000",
            height=50,
            width=300,
            cursor="cross"           # Curseur spécifique pour l'ambiance
        )
        self.danger_button.pack(pady=20)

        # Petit label de statut en bas
        self.status_label = ctk.CTkLabel(
            self, 
            text="Tentative de reconnexion en cours...",
            font=ctk.CTkFont(size=12, slant="italic"),
            text_color="#555555"
        )
        self.status_label.place(relx=0.5, rely=0.95, anchor="center")

        # Lancer l'animation
        self.animate_rain()

    def create_storm(self):
        """Crée les gouttes de pluie initiales."""
        for _ in range(100):
            x = random.randint(0, 800)
            y = random.randint(-500, 500)
            length = random.randint(5, 15)
            speed = random.randint(7, 15)
            # Création de la ligne (goutte)
            drop = self.canvas.create_line(x, y, x, y + length, fill="#444444", width=1)
            self.rain_drops.append([drop, speed])

    def animate_rain(self):
        """Anime le mouvement des gouttes vers le bas."""
        for drop_data in self.rain_drops:
            drop, speed = drop_data
            # Déplacer la goutte vers le bas
            self.canvas.move(drop, 0, speed)
            
            # Si la goutte sort de l'écran, on la remonte en haut
            coords = self.canvas.coords(drop)
            if coords[1] > 500:
                self.canvas.coords(drop, coords[0], -20, coords[2], -20 + (coords[3]-coords[1]))

        # Répéter l'animation toutes le 20ms (environ 50 FPS)
        self.after(20, self.animate_rain)

if __name__ == "__main__":
    app = MaintenanceRainApp()
    app.mainloop()
