import pandas as pd
import requests
import json
import time
from shapely.geometry import LineString
import geopandas as gpd
from unidecode import unidecode
import re
import difflib
from tqdm import tqdm
from collections import defaultdict

# === Fonctions utilitaires ===
def normalize(text):
    if not isinstance(text, str):
        return ""
    text = unidecode(text.upper())
    text = re.sub(r"\\bSAINT\\b", "ST", text)
    text = re.sub(r"\\bSAINTE\\b", "STE", text)
    text = re.sub(r"[^A-Z0-9 ]", "", text)
    return text.strip()

# === Chargement du dataset de retards ===
df = pd.read_csv("Train_dataset.csv")
df = df[
    (df["Number of late trains > 15min"] > 0) |
    (df["Number of late trains > 30min"] > 0) |
    (df["Number of late trains > 60min"] > 0)
]
df["Departure station"] = df["Departure station"].apply(normalize)
df["Arrival station"] = df["Arrival station"].apply(normalize)

# Comptage des retards agrégés par trajet et par année
df_retards = df.groupby(["Year", "Departure station", "Arrival station"]).agg(
    retard_15min=("Number of late trains > 15min", "sum"),
    retard_30min=("Number of late trains > 30min", "sum"),
    retard_60min=("Number of late trains > 60min", "sum")
).reset_index()
df_retards["retard_total"] = df_retards[["retard_15min", "retard_30min", "retard_60min"]].sum(axis=1)

stations = set(df_retards["Departure station"]).union(df_retards["Arrival station"])
print(f"{len(stations)} gares uniques à traiter (départs + arrivées).")

# === Requête paginée à liste-des-gares ===
print("Chargement complet de la base 'liste-des-gares' via API...")
garess_api = []
offset = 0
while True:
    try:
        res = requests.get(
            "https://data.sncf.com/api/explore/v2.1/catalog/datasets/liste-des-gares/records",
            params={"limit": 100, "offset": offset},
            timeout=10
        )
        res.raise_for_status()
        data = res.json().get("results", [])
        if not data:
            break
        garess_api.extend(data)
        offset += 100
    except Exception as e:
        print(f"Erreur lors de la requête liste-des-gares : {e}")
        break

print(f"{len(garess_api)} gares récupérées.")

# === Matching des gares ===
station_to_code_ligne = {}
not_matched = []

for station in stations:
    best_score = 0
    best_match = None
    for g in garess_api:
        libelle = normalize(g.get("libelle", ""))
        commune = normalize(g.get("commune", ""))
        score = max(
            difflib.SequenceMatcher(None, station, libelle).ratio(),
            difflib.SequenceMatcher(None, station, commune).ratio()
        )
        if score > best_score:
            best_score = score
            best_match = g

    if best_score >= 0.7 and best_match:
        station_to_code_ligne[station] = best_match.get("code_ligne")
    else:
        not_matched.append(station)

print(f"{len(station_to_code_ligne)} gares matchées avec un code_ligne.")
print(f"{len(not_matched)} gares non matchées : {not_matched}")

# === Récupération des segments RFN enrichis ===
codes_ligne_utilises = {code for code in station_to_code_ligne.values() if code}
all_features = []
print(f"Recherche de segments RFN pour {len(codes_ligne_utilises)} codes_ligne...")

for _, row in tqdm(df_retards.iterrows(), total=len(df_retards)):
    dep = row["Departure station"]
    arr = row["Arrival station"]
    year = row["Year"]
    code_dep = station_to_code_ligne.get(dep)
    code_arr = station_to_code_ligne.get(arr)
    if code_dep is None or code_arr is None:
        continue

    for code in {code_dep, code_arr}:
        offset = 0
        while True:
            try:
                res = requests.get(
                    "https://data.sncf.com/api/explore/v2.1/catalog/datasets/formes-des-lignes-du-rfn/records",
                    params={"where": f"code_ligne='{code}'", "limit": 100, "offset": offset},
                    timeout=10
                )
                res.raise_for_status()
                data = res.json().get("results", [])
                if not data:
                    break
                for seg in data:
                    geometry = seg.get("geo_shape", {}).get("geometry", {})
                    coords = geometry.get("coordinates", [])
                    gtype = geometry.get("type", "")
                    if gtype == "LineString" and all(isinstance(p, (list, tuple)) and len(p) == 2 for p in coords):
                        all_features.append({
                            "type": "Feature",
                            "geometry": {
                                "type": "LineString",
                                "coordinates": coords
                            },
                            "properties": {
                                "year": year,
                                "from": dep,
                                "to": arr,
                                "retard_15min": int(row["retard_15min"]),
                                "retard_30min": int(row["retard_30min"]),
                                "retard_60min": int(row["retard_60min"]),
                                "retard_total": int(row["retard_total"]),
                                "code_ligne": code
                            }
                        })
                    elif gtype == "MultiLineString":
                        for line_coords in coords:
                            if all(isinstance(p, (list, tuple)) and len(p) == 2 for p in line_coords):
                                all_features.append({
                                    "type": "Feature",
                                    "geometry": {
                                        "type": "LineString",
                                        "coordinates": line_coords
                                    },
                                    "properties": {
                                        "year": year,
                                        "from": dep,
                                        "to": arr,
                                        "retard_15min": int(row["retard_15min"]),
                                        "retard_30min": int(row["retard_30min"]),
                                        "retard_60min": int(row["retard_60min"]),
                                        "retard_total": int(row["retard_total"]),
                                        "code_ligne": code
                                    }
                                })
                offset += 100
            except Exception as e:
                print(f"❌ Erreur avec code_ligne {code} (offset {offset}) : {e}")
                break

print(f"✅ {len(all_features)} segments RFN enrichis récupérés.")

# === Export GeoJSON enrichi ===
geojson_final = {
    "type": "FeatureCollection",
    "features": all_features
}

with open("trajets_retards.geojson", "w", encoding="utf-8") as f:
    json.dump(geojson_final, f, ensure_ascii=False)

print("🗺️ Fichier 'trajets_retards.geojson' généré.")

# === Export des gares non trouvées ===
with open("gares_non_trouvees.txt", "w", encoding="utf-8") as f:
    for s in not_matched:
        f.write(s + "\n")
print("Liste des gares non trouvées dans 'gares_non_trouvees.txt'")
