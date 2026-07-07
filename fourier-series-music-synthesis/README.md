# Développement en série de Fourier et synthèse musicale

Projet universitaire (UE IRP) visant à analyser et resynthétiser des notes de musique (guitare, piano, saxophone) à partir de leur développement en série de Fourier, en estimant la fréquence fondamentale, les coefficients harmoniques et l'enveloppe temporelle du signal.

## Auteurs
ALEGRE Elisa, TIRECHE Sofiane, VALVERDE Simon

Encadrant : Haï Meïr Alezra — Université de Toulouse, Mai 2026

## Contexte

À partir d'un enregistrement audio d'un instrument (guitare, piano ou saxophone), le projet cherche à :

1. **Estimer la fréquence fondamentale** de la note jouée, par recherche sur une grille de fréquences minimisant l'erreur quadratique de reconstruction
2. **Extraire les coefficients de Fourier** (amplitude et phase de chaque harmonique) à partir d'une zone stable ("maintien") du signal
3. **Extraire l'enveloppe temporelle** du son via la transformée de Hilbert, lissée par un filtre de Butterworth
4. **Resynthétiser la note** en combinant le timbre (harmoniques) et l'enveloppe
5. **Générer une gamme complète** en appliquant le processus à plusieurs fréquences
6. **Évaluer la qualité de la synthèse** via deux métriques : RMSE (écart d'amplitude) et corrélation de Pearson (comparaison des enveloppes)

## Structure du dépôt

```
.
├── README.md
├── .gitignore
├── docs/
│   └── ALEGRE_TIRECHE_VALVERDE_IRP.pdf   # rapport de présentation complet
├── audio/
│   ├── guitar.mp3                        # enregistrement source guitare
│   ├── piano.mp3                         # enregistrement source piano
│   └── saxo.mp3                          # enregistrement source saxophone
└── src/
    └── CODE_ALEGRE_TIRECHE_VALVERDE_FINAL.m   # script MATLAB complet
```

## Prérequis

- **MATLAB** (testé avec la version 2024/2025)
- **Signal Processing Toolbox** (fonctions `hilbert`, `butter`, `filtfilt`)
- Un lecteur audio capable de lire des fichiers `.mp3` via `audioread`

## Utilisation

1. Ouvrir `src/CODE_ALEGRE_TIRECHE_VALVERDE_FINAL.m` dans MATLAB
2. Placer les fichiers audio (`audio/guitar.mp3`, `audio/piano.mp3`, `audio/saxo.mp3`) dans le même dossier que le script, ou adapter les chemins dans le code
3. Choisir l'instrument à analyser en décommentant la ligne `audioread` correspondante (par défaut : piano)
4. Ajuster si besoin la zone de "maintien" (`t_debut`, `t_fin`) propre à chaque instrument
5. Exécuter le script section par section (`%%`) pour suivre les étapes : détection de f0, extraction des coefficients, extraction de l'enveloppe, synthèse, génération de gamme, métriques

Le script génère plusieurs fichiers `.wav` en sortie (son de synthèse brut, note synthétisée, gamme complète) ainsi que des figures illustrant chaque étape.

## Résultats

Métriques obtenues sur la synthèse d'une note pour chaque instrument :

| Instrument | RMSE | Pearson |
|---|---|---|
| Guitare | 7,16×10⁻³ | 0,9820 |
| Piano | 6,31×10⁻³ | 0,9952 |
| Saxophone | 8,36×10⁻² | 0,9734 |

Un score de Pearson proche de 1 et un RMSE faible indiquent une synthèse fidèle à l'enveloppe et à l'amplitude du signal original.

Pour le détail complet de la méthodologie et des visualisations, voir le rapport dans `docs/`.

## Bibliographie

Voir la dernière section du rapport PDF (`docs/ALEGRE_TIRECHE_VALVERDE_IRP.pdf`) pour les références complètes (Bello et al. 2005, cours H. Carfantan, TP J-F. Trouilhet).
