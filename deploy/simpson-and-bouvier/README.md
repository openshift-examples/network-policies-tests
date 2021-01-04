# Simpson & Bouvier network policy demo env

## Deploy
```bash
oc new-project simpson
oc apply -k homer.simpson
oc apply -k marge.simpson
oc new-project bouvier
oc apply -k patty.bouvier
oc apply -k selma.bouvier
```