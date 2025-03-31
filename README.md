# Analyse du Réseau de Transport Ferroviaire en France
<div align="center">
  <img src="https://github.com/user-attachments/assets/fb0fd7d8-5538-4ca6-abd7-2ad781d83776" width="50%">
</div>

## Membres 
- VIGNERON Marian 
- BRANCHUT Corentin
- XX
- VELIC Ajna

## Contexte du jeu de données

<p align="justify">
Nous sommes un groupe de 4 étudiants de l'Université de Technologie de Troyes et dans le cadre de nos études, nous effectuons un projet durant l'enseignement "IF36" (Visualisation de données) : nous devons analyser un jeu de donnée de notre choix.

Nous avons choisi de travailler sur un jeu de données provenant de plusieurs sources ouvertes françaises (SNCF, Île-de-France Mobilités), car il offre une vue détaillée du réseau de transport ferroviaire en France, incluant la ponctualité, les validations de titres de transport et la géolocalisation des arrêts.

Ce dataset nous permet de mieux comprendre les dynamiques du réseau ferré, tant en termes de régularité que de fréquentation, et de poser des questions d’analyse pertinentes. Il constitue une base solide pour explorer les performances du système de transport public français, tant au niveau national que régional (notamment en Île-de-France).

Avant de pouvoir réellement effectuer les différentes visualisations permettant de mieux comprendre et traiter les données, nous allons devoir les nettoyer : 
- renommage des colonnes
- traitement des valeurs manquantes
- traitement des valeurs aberrantes
- uniformisation des types
</p>

---

## Données

Ce dataset est composé de **7 fichiers** issus de différentes sources publiques françaises.

---
1. **`Regularities_by_liaisons_Trains_France.csv`**  
   ➤ Données sur la ponctualité des trains par liaison (retards, annulations, régularité, etc.)

2. **`Travel_titles_validations_in_Paris_and_suburbs.csv`**  
   ➤ Nombre quotidien de validations de titres de transport (navigo, ticket) en Île-de-France

3. **Shapefile des arrêts de transport (`Station_shapefiles.*`)**  
   Ensemble de 5 fichiers SIG permettant de visualiser les stations géolocalisées sur une carte :
   - `Station_shapefiles.shp` : géométrie des arrêts
   - `Station_shapefiles.dbf` : attributs (noms, codes, types)
   - `Station_shapefiles.shx`, `.prj`, `.cpg` : métadonnées, projection, encodage

---

### Résumé global

- **Total de fichiers :** 7
- **Colonnes cumulées :** 37
- **Types de données :**
  - Données **temporelles** : périodes, dates de validation
  - Données **quantitatives** : nombre de retards, taux de régularité, validations
  - Données **catégorielles** : causes de retards, type de titre, nom de liaison
  - Données **géographiques** : coordonnées des stations, noms des gares

---

*Un nettoyage des données est nécessaire* :
- Harmonisation des noms de colonnes
  - gestion des espaces, et simplification des noms de colonnes pour les rendre plus compréhensibles et accessibles 
- Gestion des valeurs manquantes / aberrantes
  - NA et valeur nulles
- Uniformisation des types de données (date, float, int…)

---

## Objectifs & pistes d’analyse

Nous avons identifié plusieurs axes d’analyse possibles autour de la ponctualité, la fréquentation et les causes des retards. Nous pourrons évidemment en rajouter ou modifier par la suite, à mesure que nous utilisons le jeu de données. 
Dans un premier temps nous allons faire une analyse exploratoire des données assez large, afin de mieux connaître les données que nous manipulons, puis nous entrerons dans le détail, afin de corréler les données et leur donner du sens. 

### 0. **Analyse globale des données**
- Durée moyenne des trajets en france, ou par région si besoin
- Nombre de trajet par gares
- Fréquentation des différentes gares...

### 1. **Évolution des retards dans le temps**

- **Question** : Comment la ponctualité évolue-t-elle au fil des mois ?
  - *Courbe de tendance* : % de trains en retard par mois
- **Question** : Y a-t-il des saisons où les retards sont plus fréquents (été, hiver, etc.) ?
  - *Boxplot par mois* : pour visualiser les variations saisonnières

---

### 2. **Analyse des retards par liaison et par gare**

- **Question** : Quelles sont les liaisons les plus touchées par les retards ?
  - *Barplot ou heatmap*
- **Question** : Quelles gares ont le plus de trains en retard ?
  - *Barplot départ/arrivée*

---

### 3. **Analyse des causes des retards**

- **Question** : Quelles sont les principales causes de retard ?
- **Question** : Certaines causes sont-elles plus fréquentes selon les mois ou les lignes ?
  - *Stacked bar chart* par mois ou par liaison

---

### 4. **Durée du trajet vs retards**

- **Question** : Les longs trajets sont-ils plus souvent en retard ?
  - *Scatterplot* : durée du trajet (X) vs retard moyen (Y)
- **Question** : Retard moyen selon la durée ?
  - *Boxplot* : retard moyen par tranche de durée

---

### 5. **Comparaison annulations vs retards**

- **Question** : Quelles lignes sont le plus annulées ?
  - *Carte ou barplot*
- **Question** : Existe-t-il un lien entre annulations et retards ?
  - *Scatterplot* : % annulations vs % retards

---

### 6. **Retards extrêmes (>15min, >30min, >60min)**

- **Question** : Quelle proportion des trains ont de très gros retards ?
  - *Barplot empilé*
- **Question** : Sur quelles lignes ces retards extrêmes sont-ils fréquents ?
  - *Heatmap* ou *carte*

---

### 7. **Cartographie & météo**

- **Idée** : Carte de France avec les retards par région (Nord/Sud)
- **Extension** : Comparaison entre été et hiver pour voir l’impact des conditions climatiques sur les retards

---

## Visualisations prévues

- Heatmaps des retards par liaison
- Cartes interactives
- Courbes temporelles, boxplots, scatterplots, barplots empilés
- Représentations par saisons ou types de lignes

---

## Prochaines étapes

1. Nettoyage des données : renommage des colonnes, traitement des valeurs nulles
2. Exploration rapide pour identifier les variables clés
3. Construction d’un pipeline d’analyse et de visualisation
4. Réalisation d’analyses plus poussées autour des causes, de la saisonnalité, etc.

---

## Limites anticipées

1. Limitation géographique : Paris et sa proche banlieue
2. Faire attention au détail des métadonnées, notamment pour les causes d'incident
3. Validations sur une periodicité plus courte que le premier dataset, uniquement 2019
4. Faire attention à l'agrégat qui pourrait masquer des variations intra-quotidiennes

---
## Conclusion
<p align="justify">
Ce projet vise à combiner rigueur analytique et visualisation claire pour mieux comprendre les problématiques de ponctualité et de fréquentation dans le transport ferroviaire français. Il pourrait servir de base à des réflexions pour améliorer le service public ou optimiser la gestion du réseau.
</p>

---
