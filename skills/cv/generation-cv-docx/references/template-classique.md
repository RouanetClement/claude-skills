# Template Classique Corporate — CV DOCX

## Caractéristiques
- Mise en page : colonne unique · Police : Georgia (serif)
- Couleur principale : bleu ardoise `#2c3e50` · Photo : non supportée
- Cible : corporate, finance, conseil traditionnel

## Preamble

```python
from docx import Document
from docx.shared import Pt, Cm, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

BLEU = RGBColor(0x2C, 0x3E, 0x50)
doc = Document()
for s in doc.sections:
    s.top_margin = Cm(2); s.bottom_margin = Cm(2)
    s.left_margin = Cm(2.5); s.right_margin = Cm(2.5)
```

## En-tête

```python
def entete(doc, identite, linkedin_url=None, site_web=None):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = p.add_run(f"{identite['prenom']} {identite['nom']}")
    r.bold = True; r.font.size = Pt(18); r.font.name = 'Georgia'
    r.font.color.rgb = BLEU
    if identite.get('titre'):
        p2 = doc.add_paragraph()
        p2.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p2.add_run(identite['titre']).font.size = Pt(11)
    coords = [x for x in [
        identite.get('email'), identite.get('telephone'),
        identite.get('localisation'), linkedin_url, site_web
    ] if x]
    if coords:
        p3 = doc.add_paragraph(' | '.join(coords))
        p3.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p3.runs[0].font.size = Pt(9)
        pBdr = OxmlElement('w:pBdr')
        bottom = OxmlElement('w:bottom')
        bottom.set(qn('w:val'), 'single'); bottom.set(qn('w:sz'), '6')
        bottom.set(qn('w:color'), '2C3E50')
        pBdr.append(bottom)
        p3._p.get_or_add_pPr().append(pBdr)
```

## Titre de section

```python
def titre_section(doc, texte):
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(10)
    p.paragraph_format.space_after = Pt(4)
    r = p.add_run(texte.upper())
    r.bold = True; r.font.size = Pt(11); r.font.name = 'Georgia'
    r.font.color.rgb = BLEU
    pBdr = OxmlElement('w:pBdr')
    bottom = OxmlElement('w:bottom')
    bottom.set(qn('w:val'), 'single'); bottom.set(qn('w:sz'), '4')
    bottom.set(qn('w:color'), '2C3E50')
    pBdr.append(bottom)
    p._p.get_or_add_pPr().append(pBdr)
```

## Expériences (pattern appliqué à toutes les sections similaires)

```python
def experiences(doc, exps):
    if not exps: return
    titre_section(doc, 'Expériences professionnelles')
    for e in exps:
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(6)
        r = p.add_run(f"{e.get('poste','')} — {e.get('entreprise','')}")
        r.bold = True; r.font.size = Pt(11); r.font.name = 'Georgia'
        dates = f"{e.get('date_debut','')}–{e.get('date_fin','présent')}"
        if e.get('localisation'):
            dates += f" · {e['localisation']}"
        p.add_run(f"  |  {dates}").italic = True
        if e.get('description'):
            doc.add_paragraph(e['description']).paragraph_format.space_after = Pt(2)
        for real in e.get('realisations', []):
            p_b = doc.add_paragraph(style='List Bullet')
            p_b.paragraph_format.space_after = Pt(2)
            p_b.add_run(real.get('texte', ''))
```

## Appel final

```python
entete(doc, profil['identite'], linkedin_url=linkedin_url, site_web=site_web)
if profil.get('resume'):
    titre_section(doc, 'Résumé professionnel')
    doc.add_paragraph(profil['resume'])
experiences(doc, profil.get('experiences', []))
# formations, compétences, langues, certifications — même pattern que experiences()
doc.save('cv-classique.docx')
print('cv-classique.docx généré.')
```
