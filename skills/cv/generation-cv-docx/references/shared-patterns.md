# Patterns python-docx partagés — tous templates CV DOCX

Utilitaires communs chargés par tous les templates.
Chaque fichier `template-<nom>.md` s'appuie sur ces helpers de base.

## Patterns python-docx — Génération CV DOCX

## Imports standard (tous templates)

```python
from docx import Document
from docx.shared import Pt, Cm, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml.ns import qn
from docx.oxml import OxmlElement
```

## Initialisation du document et marges

```python
doc = Document()
for s in doc.sections:
    s.top_margin    = Cm(2)
    s.bottom_margin = Cm(2)
    s.left_margin   = Cm(2.5)
    s.right_margin  = Cm(2.5)
# Ajuster les marges selon le template (ex: Cm(1.5) pour bicolonne)
```

## Pattern bordure basse (OxmlElement) — utilisé par tous les templates

```python
# Ajouter une bordure basse à un paragraphe p, avec une couleur hex (ex: '2C3E50')
def ajouter_bordure_basse(p, hex_color, sz='4'):
    pPr = p._p.get_or_add_pPr()
    pBdr = OxmlElement('w:pBdr')
    bottom = OxmlElement('w:bottom')
    bottom.set(qn('w:val'), 'single')
    bottom.set(qn('w:sz'), sz)
    bottom.set(qn('w:color'), hex_color)
    pBdr.append(bottom)
    pPr.append(pBdr)
# Appel : ajouter_bordure_basse(p, '2C3E50', sz='6')
```

## Règle des champs optionnels

Tout champ absent du profil YAML → valeur `None` dans le dictionnaire Python.
Ne jamais afficher un label sans valeur — utiliser `if valeur:` avant chaque bloc.

```python
# Exemple : coordonnées de contact
coords = [x for x in [
    identite.get('email'),
    identite.get('telephone'),
    identite.get('localisation'),
    linkedin_url,   # None si non fourni
    site_web,       # None si non fourni
] if x]
if coords:
    doc.add_paragraph(' | '.join(coords))
```

## Sauvegarde

```python
doc.save('cv-<template>.docx')
print('cv-<template>.docx généré.')
```
