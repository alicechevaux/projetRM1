# projetRM1
Voici une partie de mon code effectué pour un projet pour se familiariser avec R. Il a pour but d'être intégrer à une application shiny afin de créer un quizz/test 
qui ressortira des scores calculés par une certaine fonctions et qui enregistrera les réponses des participants.

Vous pouvez trouvé l'application Shiny qui en découle ici : https://alnack.shinyapps.io/newapp/
ou pour le même résultat executer le fichier app.R

Ce code fonctionne pour mettre en place un test/quizz qui contiennent des questions, récoltent les résultats, et calcule un ertain score basé sur certains paramètres sur 
lesquels les questions portent. 
Par exemple j'ai utilisé une base de données basées sur un test de personnalité dont chaque question influe selon une certaine constante sur les paramètres 
Ouverture d'esprit / Consciensiosité / Extraversion / Amabilité / Nevrosité.

Pour faire fonctionner ce code vous devez avez une dataframe questions.csv qui contiennent des colonnes:
id, q, 'nom du premier parametre',.... 'nom du dernier parametre'

De façon à ce que 
- id contienne un identifiant unique pour chaque question (qui ne peut pas être un simple entier)
- q contiennent l'intitulé de la question
- pour chaque colonne associée à un paramètre, chaque question doit comprendre une constante (réelle) qui indique l'impact de cette question sur ce paramètre

Ce code récoltera les réponses des participants de manière anonyme et ressortira un score en pourcentage pour chaque paramètre (simple combinaison linéaire des 
constantes précédentes et des réponses aux questions, le tout ramené sur 100).
Il rendra aussi l'histogramme des scores associé aux réponses déjà collectées.

Pour récolter les résultats il faudra une autre base de données nommée data.rda à ranger dans le dossier www afin de pouvoir la récupérer à tout moment sur shiny.

Si vous voulez simplement faire apparaitre un sondage et récupérer les réponses, vous pouvez supprimer les lignes de codes associées à la variable 'res' et 'score'.

J'ai ici séparé l'UI et le server afin de ne garder que la partie reproduciblede mon code, mais vous pouvez simplement éxécuter le fichier app après avoir télécharger
le dossier pour avoir un aperçu de l'application que j'ai rendu dans mon cas, sachant que le code UI et server de mon git ne concerne que l'onglet "votre test".
