# Acquisition & extraction du transcript

## 1. Obtenir le transcript JSONL

- **Mode auto** : utiliser le chemin fourni dans le systemMessage (`Transcript path: <path>`).
- **Mode manuel** : localiser le transcript de la session courante :
  - Dossier projet = `~/.claude/projects/<cwd-sanitisé>`, où `<cwd-sanitisé>` = le cwd avec `:` `\` `/` `.` remplacés par `-` (ex. `C:\Program Files\cmder` → `C--Program-Files-cmder`).
  - Fallback si le dossier n'est pas trouvé : parcourir tous les sous-dossiers de `~/.claude/projects/`.
  - Prendre le fichier `.jsonl` au `LastWriteTime` le plus récent (= session courante).
  - PowerShell : `Get-ChildItem "<projet>\*.jsonl" | Sort-Object LastWriteTime -Descending | Select-Object -First 1`

## 2. Extraction CIBLÉE — jamais un `Read` intégral

Les transcripts contiennent de gros dumps (sorties de skills, schémas JSON) : une seule ligne peut dépasser 150 KB, et l'outil `Read` échoue dès quelques lignes (limites 256 KB / 25 000 tokens). **Ne jamais faire de `Read` sur tout le fichier.** Extraire ligne par ligne uniquement les champs utiles, avec `jq` (préféré, installé) ou PowerShell `ConvertFrom-Json` en fallback, en tronquant les gros champs.

Champs utiles par type d'entrée :

| type | champ à extraire |
|---|---|
| `last-prompt` | `.lastPrompt` — prompts réellement tapés par l'utilisateur |
| `user` | `.message.content` si string (ignorer les entrées `tool_result`) |
| `assistant` | `.message.content[].text` + les `tool_use` (`.name`, `.input` tronqué) |

Exemples `jq` :
- Prompts utilisateur : `jq -r 'select(.type=="last-prompt") | .lastPrompt' "<file>"`
- Outils appelés : `jq -r 'select(.type=="assistant") | .message.content[]? | select(.type=="tool_use") | .name' "<file>"`
- Cartographie taille/type des lignes (repérer les gros dumps à éviter) :
  `jq -rn 'input_line_number as $n | inputs | "\($n): \(.type)"' "<file>"` *(ou équivalent PowerShell)*

Fallback PowerShell (si `jq` indisponible) :
```
Get-Content "<file>" | ForEach-Object { try { $_ | ConvertFrom-Json } catch {} } |
  Where-Object type -eq 'last-prompt' | ForEach-Object lastPrompt
```

## 3. Sous-agents

Entrées `tool_use` avec `name == "Agent"` : `input.prompt` = tâche déléguée, la `tool_result` correspondante = résultat. Si `subagent_transcript_path` est disponible, l'extraire de la même façon (jamais de `Read` intégral).
