% Rapport de stage de fin d'études
% Corentin Gay
  GISTRE 2018
% Du 19/02/2018 au 24/08/2018

---
fontsize: 11pt
fontfamily: utopia
glossary: true
graphics: true
biblatex: true
header-includes:
    - \usepackage{hyperref}
    - \usepackage[toc,section=section]{glossaries}
    - \makeglossaries
    - \newglossaryentry{bare-metal}{name=bare-metal,
       description={Un programme dit `bare-metal` (métal nu) est un programme
       qui tourne sur du matériel sans système d'exploitation}}
    - \newglossaryentry{IDE}{name=IDE,
       description={(Integrated Development Environment) Programme qui facilite
       le développement informatique en intégrant plusieurs outils dans le même
       environnement}}
    - \newglossaryentry{GPS}{name=GPS,
       description={GNAT Programming Studio, l'IDE phare d'AdaCore}}
    - \newglossaryentry{runtime}{name=runtime,
       description={Bibliothèque nécessaire pour faire tourner du code Ada sur
       une cible, elle fournit certaines fonctionnalitées du langage}}
    - \newglossaryentry{GNATCOLL}{name=GNATCOLL,
       description={(GNAT Components Collection) Bibliothèque Ada fournissant
       du code permettant d'utiliser des bibliothèques externes. Par
       exemple, GNATCOLL fournit une API pour interragir avec une base de
       données.}}
    - \newglossaryentry{linker script}{name=linker script,
       description={Fichier décrivant à l'éditeur de lien comment arranger la
       cartographie mémoire dans l'exécutable final.}}
    - \newglossaryentry{startup code}{name=startup code,
       description={Aussi appellé 'crt0', c'est le bout de code qui initialise
	   la mémoire et qui appelle le point d'entrée du programme}}
    - \newglossaryentry{plugin}{name=plugin,
       description={Logiciel qui se greffe à un logiciel hôte et qui permet
       d'étendre les fonctionnalités de ce dernier}}
    - \newglossaryentry{boilerplate}{name=boilerplate,
       description={Se dit d'une fonctionnalité ou d'un programme dont le code
       source est quasiment le même quel que soit le programme}}
    - \newglossaryentry{generator functions}{name=fonctions génératrices,
       description={Fonction qui sauvegarde son état interne pour pouvoir
       reprendre l'execution lors d'un prochain appel}}
    - \newglossaryentry{pull-request}{name=pull-request,
       description={Requète pour qu'un projet incorpore des modifications
       tierces dans le code}}
    - \newglossaryentry{DoD}{name=DoD,
       description={'Department of Defense' Département de la Défense des États-Unis}}
    - \newglossaryentry{DAL}{name=DAL,
       description={Niveau d'Assurance de Développement, c'est le niveau de
	   criticité d'un sous-système allant de A (le plus critique) à E (le moins
	   critique). Par exemple, le système de pilotage d'un avion serait DAL A
	   tandis que le système de divertissement des passagers serait DAL E}}
    - \newglossaryentry{ISS}{name=ISS,
       description={Station Spatiale Internationale}}
    - \newglossaryentry{RAM}{name=RAM,
       description={(Random Access Memory) mémoire vive accessible en écriture
	   et en lecture}}
    - \newglossaryentry{ROM}{name=ROM,
       description={(Read Only Memory) mémoire accessible uniquement en lecture}}
---
# Résumé

J'ai découvert Ada lors des cours à EPITA donnés par Raphaël Amiard. J'ai
trouvé le langage très intéressant car les concepts (notamment l'orienté objet)
étaient assez différents de leurs équivalents en C++. De plus, grâce à la
programmation par contrat, Ada simplifie la vérification de l'exactitude d'un programme.

Plusieurs facteurs ont affectés mon choix pour ce stage. Le premier est
l'opportunité d'intégrer mon travail dans un outil pré-éxistant. Ce point me
semble important car il permet de comprendre le contexte technique dans lequel
sera utilisé mon travail. Le second point est le sujet qui me permet de toucher
a plusieurs technologies tout en restant dans mon domaine de prédilection, le
développement embarqué. Par exemple, en apprendre plus sur les différents
processeurs ARM et leurs assembleurs me paraissait être une bonne
expérience à avoir.

C'est donc pour ces différentes raisons que j'ai candidaté chez AdaCore.

J'ai commencé mon stage le 19 février, j'ai d'abord été accueilli par mes
collègues et ma première tâche a été d'écrire un plugin Python pour l'\gls{IDE}
d'AdaCore, \gls{GPS}. Le but de cette tâche était de me familiariser avec le système
de revue de code ainsi qu'avec le code de \gls{GPS}. J'ai ensuite commencé à étudier
mon sujet de stage et comment pouvions nous améliorer le support du
\gls{bare-metal} dans \gls{GPS}.

Après deux prototypes explorant le sujet, nous avons fait une réunion avec
mes encadrants afin de décider de la suite du stage et nous avons ainsi
décidé d'une architecture pour les outils que j'allais développer.

# Introduction

## Rappel du sujet de stage

Mon sujet de stage s'intitulait 'Improve baremetal support in \gls{GPS}' et
comportait les axes suivants:

- améliorer la `stack view`
- développer une `register view`
- explorer comment utiliser les CMSIS-Packs dans \gls{GPS}

J'ai choisi de m'attaquer à ce dernier sujet. L'idée était d'investiguer ce
qu'il était de faire grâce aux CMSIS-Packs pour rendre la programmation
embarquée en Ada plus simple.

Pour pouvoir exécuter du code Ada sur une cible donnée, il faut
avoir un logiciel appellé une `runtime`. Ce logiciel implémente des
fonctionnalités du langage qui sont utilisée par le programme comme le support
multi-tâches, la propagation des exceptions ou un allocateur mémoire.

Etant donné que le code étant dans la runtime doit tourner sur la cible, il
faut adapter la runtime à chaque cible. Actuellement, c'est une étape qui est
faite manuellement. Il faut également savoir qu'il y a plusieurs types de
runtime qui ne fournissent pas toutes les mêmes fonctionnatlités. Dans le cas
de mon stage je me suis attaqué à la question des `runtimes` dites `\gls{ZFP}`.
Ce type de runtime est le minimum pour pouvoir faire tourner
du code Ada. Par exemple, elle n'a pas de propagation d'exception, pas de
support multi-tâches et ne possède qu'un allocateur mémoire naif.

Dans le cas décrit ci-dessus, les modifications à effectuer dans le code de la
runtime elle-même sont nulles. Cependant, il faut tout de même modifier le
`startup-code`. Ce bout de code permet d'initialiser la mémoire et se charge
d'appeller le point d'entrée du programme. Il faut également modifier le
`linker script`. Ce fichier permet de spécifier les zones mémoires et quelles
portions du code y mettre.

Ces modifications dépendent de la cible et nécessite actuellement de lire la
documentation afin de récupérer les informations nécessaires. Dans le cas où on travaille
avec un processeur cortex-m, ARM a créé un standard qui permet de décrire
le matériel d'une `board` ou d'un `device`. Ces infos dans une
archive zip. On appelle ces archives des CMSIS-Packs.

La solution est donc d'utiliser les CMSIS-Packs pour automatiser le processus de
modification du `startup code` et du `linker script`. Cette automatisation
permet a l'utilisateur de choisir sa `board` de dévelopement lors de la
création d'un projet.

## Présentation de l'entreprise
### Historique

En 1975, le \gls{DoD} commence à rédiger un standard décrivant un langage visant à
remplacer les 450 langages utilisés à l'époque à l'intérieur de l'organisation.
En 1978, le dernier standard appellé 'Steelman' est finalisé. Le \gls{DoD} organise
ensuite un concours visant à trouver le langage remplaçant avec le standard
comme modêle à respecter. Quatres équipes sont crées et parmis ces quatres, c'est l'équipe
'Green' qui remporte le concours et qui devient le nouveau langage de
programmation Ada, nommé en hommage à Ada Lovelace, mathématicienne anglaise du
19ème siècle.

En 1992, l'université de New York conclut un contrat avec l'`US Air Force` afin
de créer un compilateur libre afin d'aider à la diffusion du
nouveau standard Ada 9X (qui deviendra Ada 95).
Suite a ce projet, la société Ada Core Technologies est créée à New York et la
sociétée sœur ACT-Europe est créée deux années plus tard. Ce n'est qu'en 2012
que les deux sociétés sont unifiées.

AdaCore fournit un compilateur Ada appellé GNAT. Ce compilateur est distribué
en plusieurs versions, chaqune visant un public différent.
Par exemple la version `Community` ne supporte que la dernière version du
standard Ada, Ada 2012, et vise principalement les développeurs amateurs.

La version `Assurance` destinée aux projets de certifications ou à des
projets de longues durées supporte jusqu'à Ada 83. Elle permet aussi de ne pas
avoir à soumettre le code produit à la license GPL, qui obligerait
l'utilisateur à rendre le code public.

Pour aller avec le compilateur, AdaCore peut également aider les clients avec
des projets de certifications. En effet,
une partie des outils fournis par AdaCore, comme GNATcoverage, est qualifié
pour le développement d'outil en DO-178B en \gls{DAL} A. C'est à dire le niveau de
criticité le plus élevé pour le standard avionique. GNATcoverage aide à
l'analyse de couverture de code ce qui permet de garantir qu'il n'y a pas de
code qui n'est jamais exécuté.

AdaCore a beaucoup de clients dans des domaines ou la présence d'erreurs dans
un logiciel n'est pas acceptable, comme l'avionique ou le secteur de la
défense.

Cependant AdaCore n'est pas présente que dans ces domaines, voici deux exemples
de projets menés par des clients d'AdaCore dans des domaines très distincts.

- MDA, une division de Maxar Technologies, va utiliser Ada ainsi que le produit
  GNAT Pro Assurance afin de remplacer le logiciel en charge de la
  communication espace-terre à bord de l'\gls{ISS}.

- Real Heart AB est une entreprise suédoise qui travaille sur un coeur totalement
  artificiel. Afin de garantir le bon fonctionnement du logiciel qui pilote le
  moteur de la pompe du coeur, elle a choisi d'utiliser Ada ainsi
  que le compilateur GNAT Pro fourni par AdaCore.

### Contexte concurentiel

AdaCore n'est pas la seule entreprise  dans le domaine des compilateurs Ada.
Voici un rapide aperçu des principaux compilateurs concurrents.

                          Green Hills Ada Compilers
---------------------     -----------------------------------------------------
Entreprise                Greens Hills Software
Standards                 Ada95
Plates-formes cibles      Power, ARM/Thumb, 68k, MIPS, x86, SPARC
Runtime                   Ravenscar (non multitâche)
---------------------     -----------------------------------------------------

                          ObjectAda
---------------------     -----------------------------------------------------
Entreprise                PTC
Standards                 Ada95 Ada2012 (seulement windows 10 natif)
Plates-formes cibles      PPC, x86
Runtime                   Ravenscar
---------------------     -----------------------------------------------------

Par rapport a ses concurrents, GNAT Pro a l'avantage de supporter la dernière
version du standard Ada (Ada2012) ainsi que toutes les versions antérieures, et
ce tout aussi bien sur des plate-formes natives qu'en compilation croisée.
GNAT Pro supporte également bien plus de plate-formes 64bits et supporte
également plus d'OS temps-réels comme PikeOS ou LynxOS. On peut donc en
conclure que même si AdaCore a de la compétition, elle reste première dans
son domaine.

### Organisation

AdaCore est organisée en cercles. Chaque cercle a une responsabilité bien
particulière. Dans mon cas, j'ai intégré le cercle PE (Product Engineering).
Ce cercle est responsable de créer, de faire évoluer et de maintenir les
produits d'AdaCore. Il est également responsable du support client pour les outils qu'il
maintient. C'est la force du support offert d'AdaCore, de pouvoir contacter
directement les personnes qui ont une expertise forte sur les produits qu'ils
maintiennent. Ce cercle s'occupe aussi
de la QA (Quality Assurance) et des partenariats de contrats de recherche.

Au sein de ce cercle j'ai intégrer le sous-cercle \gls{IDE}. Son rôle est de s'occuper de
l'\gls{IDE} (\gls{GPS}) ainsi que des bibliothèques périphériques. Par exemple, cette
équipe s'occupe de l'intégration de GNAT dans l'\gls{IDE} de WindRiver (Workbench)
afin de pouvoir facilement faire tourner des applications en Ada sur les
différentes versions de VxWorks, un OS propriétaire très utilisé dans le
domaine du temps-réel embarqué. J'ai également beaucoup interragi avec l'équipe
CROSS. Cette équipe s'occupe de porter la suite d'outils GNAT vers de nouvelles
plate-formes et de régler les problêmes trouvés dans ces produits.

Dans ce contexte j'ai surtout interagi avec l'équipe \gls{GPS} dont mon maître de
stage fait partie. Comme je devait intégrer mon travail dans \gls{GPS}, cela a été
très utile de pouvoir communiquer facilement avec les personnes qui
travaillent sur l'outil. J'ai également beaucoup avec un membre de l'équipe
CROSS qui a été à l'origine de mon sujet de stage. Il a pu me guider lorsque
j'avais des questions techniques vis-a-vis des `runtimes` Ada.

## État des connaissances sur le sujet

J'avais déjà utilisé les runtimes Ada pour un projet embarqué sur une STM32F729
dont le but était d'interfacer du code C++ avec du code Ada. Mon expérience
avec l'Ada était donc plutôt limitée et je voulais profiter de ce stage pour en
apprendre plus sur ce langage.

Au cours de mon cursus, je n'ai pas beaucoup utilisé Python. Cependant, je
l'utilise sur mon temps libre pour personnaliser certains aspects de ma
distribution Linux, je n'étais donc pas complètement novice sur ce sujet.

J'ai l'expérience de plusieurs projets à l'EPITA concernant l'assembleur, mon
premier projet ayant été le projet assembleur en ING1 qui touchait surtout
l'assembleur x86. En GISTRE, j'ai fait un peu d'assembleur ARM grâce au
projet ARM. Enfin, lors de mon projet de fin d'études, j'ai dû lire de
l'assembleur 8080 afin de déboguer notre émulateur Gameboy. Je voulais
profiter de mon stage pour en apprendre plus sur les différentes architectures
ARM et leurs différents assembleurs.

## Maturité et intérêt du stage pour l'entreprise

Côté embarqué, AdaCore possède beaucoup de ports différents. GNAT Pro
supporte des OS dits temps-réels comme VxWorks ou LynxOS et supporte
également des cibles \gls{bare-metal}, c'est à dire des cibles sans OS.

L'\gls{IDE} d'AdaCore (\gls{GPS}) permet de faciliter le développement embarqué en
fournissant une interface de connection à la `board` facile d'utilisation.
Cependant, \gls{GPS} ne supporte pas les CMSIS-Packs dans son état actuel, ce qui
rend difficile le développement embarqué sur une carte non supportée.
L'intérêt du stage est donc clair pour AdaCore : la simplification du processus
de développement permet d'enlever une barrière à l'adoption de l'\gls{IDE} \gls{GPS}.

Aucun outil Ada ne possède actuellement d'intégration des CMSIS-Packs,
contrairement aux outils pour le C où il y a déjà un écosystème bien installé.
Cette intégration permettrait donc de faciliter la diffusion du langage en
levant une autre barrière au développement.

## Contexte de travail

J'ai pu rapidement me mettre à travailler efficacement grâce à la
documentation interne. De plus, la disposition physique des locaux m'a permis,
lorsque j'avais des questions complexes, d'aller voir directement la personne
concernée afin d'obtenir une réponse claire.

J'était encadré par deux anciens épitéens, Anthony Leonardo Gracio et Fabien
Chouteau. Anthony fait partie de l'équipe \gls{GPS} et m'a
aidé à intégrer mon code dans \gls{GPS} et à écrire du meilleur code en faisant les
revues sur le code que j'écrivais. Fabien fait partie de l'équipe Bare-Board et
c'est lui qui est à l'origine de mon sujet de stage. Il m'a aidé lorsque
j'avais des questions vis à vis de certaines technologies ou du
fonctionnement d'Ada dans le domaine de l'embarqué.

Concernant le sujet du stage, un collègue avait déjà réalisé un prototype
utilisant les CMSIS-Packs, j'ai pu m'en inspirer afin d'avancer plus vite
dans mon travail. De plus, la haute disponibilité de mes deux encadrants m'a permis
d'avancer vite et de ne pas rester bloqué sur des problèmes qu'ils pouvaient
m'aider a resoudre.

Pour comprendre comment fonctionnaient les runtimes j'ai utilisé les papiers
suivants (Papers related to runtimes HERE). + DETAILS
LINK TO DESCRIPTION of those boards in the appendix

Lorsque j'ai commencé à tester mon travail, j'avais trois cartes
différentes à ma disposition. Une STM32F429 et deux cartes Atmel, une SAMD20
et une SAM4E. Toutes ces cartes avaient des moyens de communication ou des
CPUS différents afin de me permettre de tester le code que je produisais sur le
plus de cibles variées.

En termes de logiciels utilisés, j'ai principalement utilisé la bibliothèque
standard Python 2.7, ainsi qu'une bibliothèque Ada nommée \gls{GNATCOLL}.
Cette bibliothèque fournit beaucoup de
fonctionnalités, mais je l'ai principalement utilisée pour modifier et lire les
fichiers dits `projets`. Ces fichiers servent à décrire la structure d'un
projet Ada et j'ai utilisé le même formalisme afin de décrire les informations
nécessaires pour décrire une `board`.

# Aspects organisationnels
## Découpage du stage
Périodes:

- plugin \gls{GPS} au début
- fais 2-3 scripts pour explorer les possibilités des packs
- phase principale
    - point sur le stage
    - architecture des outils
    - travail sur les differents outils
        - gpr2ld
	- database
	- json2gpr
	- integration dans \gls{GPS}
	- tests
Livrables:

- différents outils

## Diagramme de Gantt, Kanban ??

- schéma des tâches successives a réaliser

## Points de contrôle

- Parler des monthly internship commits
- points réguliers avec mon maître de stage
- pull requests sur github

## Gestion des problèmes
Liste:

- mauvais analyseur syntaxique pour le python XML
    - problèmes d'efficacité (malloc tout le fichier en memoire)

- problème du schéma de la base de donnée
    - refait le schéma en simplifiant les données (no more héritage)

- intégration a pris plus de temps que prévu, j'ai du ajouter une
  fonctionnalité à \gls{GPS} afin de pouvoir y intégrer mon travail.

# Aspects techniques

expliquer le concept de runtime dans un des outils

Liste:

- schéma de l'architecture du code
- géneration du startup code et du linker script
- base de données représentant les packs
- intégration dans \gls{GPS}
- fix des bugs

## Faire fonctionner les harnais de test avec GNATemu
### Objectifs

GPS possède un outil appellé GNATtest. Cet outil permet de générer un projet
qui va se charger de tester les fonctions d'un autre projet, ce sont les
harnais de test.

Dans GPS, pour un projet embarqué, il est possible de lancer
le projet sur un émulateur : GNATemu. Il se repose sur l'émulateur libre QEMU.
GNATemu est utilisé pour tester des projets plus facilement que sur une carte
physique. Il permet également d'émuler des devices sur un bus (AMBA ou PCI)
via l'outil GNATbus.

L'objectif de cette tâche étaient de pouvoir exécuter le harnais de test sur
l'émulateur dans le cas d'un projet embarqué.

GNATtest était déjà intégré dans GPS avec un \gls{plugin}. Il fallait modifier
ce dernier afin de prendre en compte le cas où la cible de compilation était
non-native.

### Cadre de la tâche

GPS utilise des \gls{plugin}s en Python, ce \gls{plugin} doit donc être développé en
Python. Nous avons utiliser Gerrit pour faire les revues de code.

### Résultats obtenus et impact sur l'avancement du stage

Le plugin GPS a été modifié pour tenir compte de la cible et permet de lancer
la suite de test sur l'émulateur. J'ai utilisé les bibliothèques de workflows
python pour rendre mon code asynchrone. J'ai également utilisé les
\gls{generator functions} pour rendre mon code plus efficace.

J'ai refactorer le code qui servait à lancer l'émulateur afin de permettre
l'appel des fonctions depuis d'autre modules python.

Ce \gls{plugin} possède néanmoins une limitation.
Normalement, lorsque des tests échouent, GPS peut afficher directement quel test
échoue et à quelle ligne il se situe. Nous avons ce comportement lorsque l'on lance
l'émulateur sur un harnais de test. Cependant, lorsque l'on lance l'émulateur
sur une liste de harnais de test, \gls{GPS} ne peut pas récupérer les différentes
sorties et ne peut donc pas les afficher correctement. Nous avons
donc decider de les afficher dans une console, une par harnais de test.

Ce projet m'a permis de me familiariser avec l'API des \gls{plugin}s Python
dans GPS. J'ai pu également aussi prendre en main le système de revue de code.

## Prototypes de générations de runtimes
### Objectifs

L'objectif principal était de me familiariser avec le comportement des runtimes
Ada et comment elle fonctionnaient. Je devais également explorer ce qu'il était
possible de faire avec les CMSIS-Packs et comment nous pouvions les utiliser
dans le contexte de la programmation embarqué Ada.

Le rôle du script est de générer une runtime ZFP pour une board spécifique.
Le script doit pouvoir analyser le contenu du fichier et proposer à
l'utilisateur quelle board choisir.

### Cadre de la tâche

Le cadre de cette tâche était plutôt libre, j'ai utilisé Python pour parcourir
le contenu des paquets et générer les fichiers nécessaires.

### Propositions retenues ou pas

En découvrant qu'ARM avait son propre compilateur, assembleur et syntaxe de
linker script (appellés `scatter file` par le l'éditeur de liens ARM), j'ai pensé qu'un
outil transformant la syntaxe ARM en son équivalent GCC pouvait être
réalisable. Cependant, après en avoir discuter avec mon maître de stage il
s'avère que générer les fichiers serait plus simple que les traduire, nous
n'avont donc pas continué avec cette idée. La difficultée principale venait de
la transformation du startup code qui demandait une interprétation de certains
éléments du code assembleur car certaines directives ARM n'avaient pas leur
équivalent en assembleur GCC et vice-versa.

### Difficultés éventuelles

Je n'était pas très familier du parsing XML en Python. J'ai donc passé un
peu de temps à comprendre comment récupérer les informations intéressantes dans
le fichier XML.

J'ai également passé du temps à comprendre la structure des CMSIS-Packs.
Le ficher XML peut associer certains fichiers à des conditions. Par exemple, le
pack peut faire la distinction entre le compilateur GCC et le compilateur ARM
et peut spécifier quels fichiers utiliser pour un compilateur donné. GNAT est
basé sur GCC, il était donc nécessaire dans notre cas de ne récupérer que les
informations utilisables avec GCC.

### Résultats obtenus et impact sur l'avancement du stage

À la fin de cette tâche, j'avais réaliser deux outils. Le premier outil
sert à générer les fichiers utilisés lors de la compilation comme le
\gls{linker script} ou le \gls{startup code}.

Le second outil générait la structure d'une runtime prête à compiler. C'est à
dire les fichiers projets qui décrivaient à GPRbuild comment compiler la
runtime.

Cette tâche m'a permis de comprendre comment étaient agencés les packs et
quelles fonctionnalitées pouvaient être utiliser depuis le contenu des packs.
Certains packs possèdent un \gls{linker script} et un \gls{startup code}
compatible avec GCC mais ce n'est pas le cas de tout les packs. Il fallait dont
générer ces fichiers à partir des informations contenus dans les packs.

## Architecture de la chaîne d'outils
### Objectifs

Suite à l'accomplissement de la tâche précédente, j'ai organisé une réunion
avec mes encadrants afin de décider de la prochaine étape à suivre lors du
stage. Nous avons donc décider d'une architecture décrivant les outils que
j'allait écrire et leurs responsabilités.

### Cadre de la tâche

Le cadre de la tâche était de créer des outils le plus portable possible. Il
fallait donc complêtement décorréler l'intégration dans \gls{GPS} et le
fonctionnnement des outils. Il fallait pouvoir utiliser ces outils depuis un
terminal ou bien depuis un script Python. Ces outils devaient utiliser les
langages Python et/ou Ada.

### Propositions retenues ou pas

Nous avons décidé de laisser tomber la génération de runtime. En effet, il
existe un projet d'AdaCore appellé \href{https://github.com/AdaCore/bb-runtimes}{`bb-runtimes`}.

Le but de ce projet est de
fournir des `runtime`s spécifiques à un CPU et non à une `board`. Le support de
la board est dans le BSP à la place. Le but de ce projet est de réduire le
nombre de `runtime`s à supporter et de simplifier le processus de création de
`runtime`s. J'allais donc me reposer sur les runtimes de ce projet.

Une partie importante de l'organisation était la séparation du pilotage de la
chaîne d'outils et de l'intégration dans GPS. En effet, on devait pouvoir
intégrer facilement mon travail dans d'autres IDE où AdaCore s'occupe du
support du langage Ada.

### Résultats obtenus et impact sur l'avancement du stage

![Architecture des outils](newplan.png)

Pour que la chaîne d'outils soit extensible il fallait que chaque outil soit
clairement défini et qu'il n'accomplisse qu'un rôle, le plus simple possible et
le plus simplement possible.

Il fallait ensuite écrire un script qui allait piloter la chaîne d'outils et
enfin intégrer ce script dans GPS. Il fallait que les outils soient utilisables
depuis la ligne de commande ou importable comme un module Python.

Une fois cette architecture définie j'ai pu commencer à travailler sur le
programme qui allait générer le \gls{startup code} et le \gls{linker script}.
Cependant, il est plus pertinent de commencer par expliquer le fonctionnement de
la base de données.

## Base de données
### Objectifs

La base de données doit pouvoir représenter toutes les informations nécessaires
à la génération du \gls{linker script} et du \gls{startup code}. C'est à dire à la fois les
informations liées au CPU et les informations liées à la `board`. Il faut
également stocker la description des interruptions, c'est à dire l'index dans
le tableau d'interruptions ainsi que son nom (pour que l'utilisateur puisse
savoir quelle est la fonction de cet interruption).

Elle doit également contenir l'URL à laquelle un pack peut être téléchargé et
mis à jour. Il est également intéressant de stocker la hiérachie de famille et
de sous-familles afin de permettre, lors de l'intégration, à l'utilisateur de
filtrer les résultats de recherche à la sous-famille de son choix.

![Architecture de la base de données](database.png)

Un `device` représente la puce sur une carte. Par exemple, la carte
STM32F429-Discovery possède un `device` STM32F429IG. Il est important de
représenter les deux. En effet, deux `boards` peuvent avoir le même device et
nous ne voulons pas de dupplicata d'information.

Certains paquets ne respectent pas la hiérarchie famille/sous-famille et
possèdent uniquement des familles de board. C'est pour cela qu'un device peut
être lié à une famille ou à une sous-famille elle-même liée à une famille.

### Cadre de la tâche

La base de données sera développée en python en utilisant le module `sqlite3`
de la bibliothèque standard

### Difficultés éventuelles

Lors de la conception de la base de données, j'ai rencontré plusieurs obstacles.

SQLite3 ne possède que les types INTEGER, TEXT,
BLOB, REAL et NUMERIC. Elle convertit les types utilisés vers le type interne
utilisé (par exemple un champ VARCHAR(10) devient un champ TEXT). Dans le cas
précédent, cela ralentit la vitesse des requêtes qui récupèrent la valeur
du champ.

Certains paquets ne respectaient pas la syntaxe XML et j'ai du modifier
certains paquets afin de les rendre conforme à la syntaxe XML.

### Propositions retenues ou pas

Mon premier schéma de la base de données copiait la façon dont était
structuré le fichier XML et comportait une table avec des éléments qui
référençaient le contenu de leurs parents. Par exemple, pour récupérer toutes
les informations pertinentes à un `device` donné, il fallait récupérer les
informations du device mais aussi celles de la sous-famille et de la famille
associée.

Après relecture du code, j'ai décidé de remplacer cette table par 3 tables
distincts qui représentaient une famille, une sous-famille et un device.
Toutes les informations nécessaires sont maintenant dans la table représentant
les devices. En effet, la hiérarchie d'information ne change que lors de
l'ajout ou le retrait d'un paquet, il n'était donc pas utile de pouvoir
changer ces information en cours d'éxécution

### Résultats obtenus et impact sur l'avancement du stage

À la fin de cette tâche, j'avais un design de base de données fonctionnel.
Une fois tous les paquets ajoutés à la base de données, ell faisait une taille
d'à peu près 3 Mo.

## Outil d'interrogation de la base de données
### Objectifs

Le but de cet outil est de fournir une API de communication avec la base de
données. Elle doit permettre de récupérer tous les paquets ainsi que leurs
contenu. Elle doit également permettre de récupérer toutes les informations
concernant un device donné.

### Cadre de la tâche

Il faut que cet outil soit utilisable depuis un module python ou depuis la
ligne de commande. Cela permet d'utiliser l'outil depuis un script ou
depuis le code Python. Les informations concernant un device donné sont
affichées dans le format JSON, pour permettre facilement leur interprétation.
Cet outil ne doit pas avoir à gérer la base de données.

### Difficultés éventuelles

En testant cet outil, il est apparu clair que les performances n'étaient pas
suffisantes, en effet, l'outil mettait à peu près trente minutes à rajouter le
contenu de tous les paquets dans la base de données ce qui était beaucoup trop
long.

Il y a plusieurs types d'analyseur syntaxique pour le XML dans la bibliothèque
standard Python. Celui utilisé par l'outil jusqu'a présent par l'outil
fonctionne en alouant tout le fichier en mémoire pour ensuite pouvoir le
parcourir via des fonctions associées. Dans le cas de l'ajout des
interruptions, le fichier XML les décrivant faisant soixante-quinze mille
lignes, beaucoup de temps était perdu à cause de cette allocation mémoire.
En changeant de méthode pour le parcours des éléments, on peut utiliser un
analyseur différent qui permet de n'allouer que le minimum d'espace mémoire
nécessaire. En spécifiant précisément les éléments de début et de fin de la
partie du fichier qui nous intéresse, cet analyseur nous permet d'analyser les
éléments du fichier pendant son parcours et ainsi d'être beaucoup plus
efficace. En changeant d'analyseur, on passe de trente minutes à un peu en
dessous de trois minutes pour l'ajout du contenu de tous les paquets.

### Propositions retenues ou pas

J'ai réécris la façon dont les requêtes étaient faites. Dans la première
version de l'outil, un objet Python faisait des requêtes au fur et à mesure
pour aggréger les résultats.

Cette méthode posait des problêmes de performances. En effet, récupérer les
informations de tous les `devices` de la base de données prennait quelques
secondes. En modifiant le code pour générer des requêtes à la place de les
faire au fur et à mesure, le code a gagné en efficacité, passant de quelques
secondes à un résultat quasiment instantané.

Pour pouvoir implémenter la suppression de paquets efficacement, il fallait
introduire des `triggers` dans la base de données. En effet la structure
non-triviale des différentes tables rendaient la suppression en cascade
inefficace.

### Résultats obtenus et impact sur l'avancement du stage

Une fois cet outil écrit, il a permis de tester la base de données.
Il a notamment permis de déceler les problêmes de performances liés à l'ajout
des paquets.

## Transformation du JSON en fichiers projets
### Objectifs

Le but de cet outil est de traduire le JSON en syntaxe de fichier projet. Cela
permet de transformer la sortie de l'outil précédent en fichiers projet
représentant le matériel sélectionné.

### Alternatives

Il y avait une alternative qui consistait à ne pas utiliser du tout les
fichiers projet et de passer uniquement par du JSON. Cependant, cette
alternative n'a pas été retenue car cela ne permettait pas la modification des
fichiers projets simplement depuis GPS.

### Cadre de la tâche

Comme les autres outils, ce programme doit pouvoir être appellé depuis la ligne
de commande ou depuis un script Python.

### Résultats obtenus et impact sur l'avancement du stage

Une fois cet outil terminé, j'ai pu tester que la chaîne d'outils fonctionnait
correctement.

Voici un exemple de fichier projet décrivant la carte SAMD20 Xplained Pro:

```Ada
project Spec is

   package CPU is
      for Name use "cortex-m0plus";
      for Float_Handling use "soft";
      for Number_Of_Interrupts use "15";
   end CPU;

   package Memory_Map is

      --  MEMORY MAP
      for Memories use ("ROM", "RAM");

      for Boot_Memory use "ROM";

      for Mem_Kind("ROM") use "ROM";
      for Mem_Kind("RAM") use "RAM";

      --  ROM
      for Address("ROM") use "0x0";
      for Size("ROM") use "256K";

      -- RAM
      for Address("RAM") use "16#20000000#";
      for Size("RAM")    use "16#8000#";

   end Memory_Map;

end Spec;
```

Sur l'exemple ci-dessus on peut voir que le CPU gère les nombres à virgules
flottantes avec du software (certaines plate-formes ont des co-processeurs
spécifiques à ce genre d'opérations). Dans l'exemple ci-dessus, la carte
possède deux régions mémoires une \gls{ROM} et une \gls{RAM}. La mémoire de
démarage sélectionnée est la mémoire \gls{ROM}. Le mémoire ROM commence à
l'addresse `0` (en hexadécimal) et a 256 kilo octets de capacité.
La mémoire RAM commence à l'addresse `16#20000000#` (syntaxe Ada pour 20000000
en hexadécimal) et a une taille de 8000 (en hexadécimal) octets.

Le formalisme précédent permet de gagner fortement en clarté par rapport à un
\gls{linker script}. L'utilisation de la syntaxe des fichiers projets permet
également de profiter des outils utilisant ce format. Par exemple, cela rend la
modification dans \gls{GPS} plus aisée et permettrait de représenter
graphiquement les différentes mémoires.

## Génération du startup code et du linker script
### Objectifs

Le but de cet outil est de générer un \gls{linker script} et un \gls{startup code}
depuis un fichier projet utilisant le formalisme de la section précédente.
On doit pouvoir rajouter des architectures supportées juste en ajoutant des
fichiers de configuration.

Cet outil doit également s'assurer que le fichier projet est correct. Par
exemple, l'outil doit pouvoir détecter et refuser le fichier projet dans le cas
ou deux sections mémoires sont supperposées.

Dans le \gls{linker script}, chaque section de l'exécutable doit être
mise dans une section mémoire spécifique. Par exemple, la section `.text`
contenant le code doit être mise dans la région mémoire de démarrage afin
d'être exécuté.

### Cadre de la tâche

Cet outil doit être un exécutable indépendant écrit en Ada. Il doit se reposer
sur deux fichiers distincts: un fichier décrivant la mémoire et le CPU et un
autre décrivant le vecteur d'interruptions.

L'outil utilise des patrons de code assembleur afin de générer le code associé
à chaque section. Il doit être possible de rajouter des patrons de code avec
des architectures différentes sans avoir à recompiler l'outil.

### Propositions retenues ou pas

Actuellement, l'outil utilise des patrons de code assembleur afin de générer du
code. Une proposition qui n'a pas été retenue était d'écrire un langage de
description d'assembleur qui serait ensuite traduits dans l'assembleur cible.

Cette idée n'a pas été retenue car beaucoup trop complexe à mettre en place, à
la place on utilise des patrons de code assembleurs.

### Difficultés éventuelles

Avant ce projet, j'avais écris un court projet en Ada. J'ai donc passé un peu
de temps au début du développement à apprendre le langage. J'ai du utiliser des
bibliothèques Ada pour lire les fichiers projets. La bibliothèque
\gls{GNATCOLL} fourni une interface pour lire des projets et les valider. J'ai
passé du temps à comprendre comment utiliser l'API fournie car elle est très
peu documentée. De plus, les noms de fonction du code étaient mal choisis, ce
qui a ralenti mon travail.
J'ai demandé de l'aide au mainteneur du projet qui
m'a aiguillé sur les bonnes fonctions et qui m'a expliqué certains concepts de
l'API que j'avais mal compris. J'ai pu avancer dans mon travail et j'ai rajouté
un exemple dans la documentation expliquant comment faire ce que je voulais.

Pendant le développement, nous avons d'essayer un développement en utilisant
le site GitHub. Mon maître de stage devait revoir mes modifications et
les incorporer au dépôt Git. Git est un outil qui permet de versionner le
code afin de garder une trace des changements effectués. Cependant, après avoir
essayé, nous avons décidé de ne pas utiliser le système de \gls{pull-request}
de GitHub. En effet, lorsqu'un projet n'est pas encore stable et est en
développement constant, les \gls{pull-request}s ajoutent un coût en temps au
développement. Combiné au fait qu'il n'est pas possible de soumettre des
changements dépendant d'autres changement sur GitHub, cela rendait le travail
de revues très lourd pour mon maître de stage. Nous avons donc décidé de mettre
en pause les revues de code et d'attendre d'avoir un projet stable pour revoir
le code.

Nous n'avions pas de tests pour ce projet ce qui a posé problême quand un
collègue à rajouter des fonctionnalités au projet. Grâce à son aide pour créer
la testsuite, j'ai pu rajouter des tests basiques mais qui permettent de
vérifier que les modification n'ont pas de problêmes graves.

Enfin, lorsque je testais les linkerscript qui étaient générés, j'ai passé du
temps à trouver d'oû venaient certains problêmes car les message d'erreurs de
l'éditeur de liens n'étaient pas explicites ce qui compliquait le déboguage.

### Résultats obtenus et impact sur l'avancement du stage

Une fois cet outil terminé j'ai pu tester les fichiers générés. J'ai trouvé
quelques problèmes dans la création du \gls{linker script} liés à l'allocation
de certains symboles (stack and heap). Une fois cet outil terminé j'ai pu
commencé à travailler sur l'intégration des outils dans \gls{GPS}.

## Intégration dans GPS
### Objectifs

Le but de cette tâche est d'intégrer les outils que j'ai développés dans \gls{GPS}.
Il faut que lors de la création d'un projet embarqué, l'utilisateur puisse
choisir la carte sur laquelle il va développer pour que GPS puisse générer les
fichiers. L'utilisateur doit pouvoir relancer la génération si les fichiers décrivant
la carte ont été modifiés. L'utilisateur doit pouvoir interagir avec la base de
données depuis \gls{GPS}. Il doit pouvoir la mettre à jour et y rajouter des paquets
manuellement depuis \gls{GPS}. L'utilisateur doit également pouvoir consulter
toute la documentation liée à la carte sélectionnée. Cette documentation doit
cependant être téléchargée ne sera donc consultable que si l'utilisateur veut
télécharger le paquet associé à la carte sélectionnée.

Dans les CMSIS-Packs se trouvent des fichiers .svd. Ces fichiers décrivent
comment les périphériques de la carte sont représentées en mémoire.
C'est à dire à quelles addresses et comment sont arrangés les périphériques.
Un outil existe pour générer des en-têtes Ada depuis ces fichiers. Cela permet
de simplifier le code et de pouvoir utiliser les périphériques sans
avoir à écrire son propre code décrivant le périphérique. Le typage fort d'Ada
permet de contrôler comment les champs sont utilisés. Par exemple, il permet
d'utiliser un entier comme un tableau de bits et vice-versa tout en vérifiant les
bornes du tableau et la valeur de l'entier. Ada permet également de créer un
objet de ce type tout en spécifiant son addresse mémoire. Cela permet
d'utiliser l'objet pour interragir avec le périphérique sans avoir à passer par
des macros faisant des conversions de type (comme en C).

### Cadre de la tâche

Le plugin \gls{GPS} sera développé en Python tandis que les éventuelles modifications
à \gls{GPS} seront faites en Ada.

### Propositions retenues ou pas

Il serait très intéressant de pouvoir intégrer la génération des différents
fichiers à la plate-forme comme une étape de compilation supplémentaire.
Cela éviterait à l'utilisateur d'avoir à relancer l'outil lui-même lorsqu'il a
modifié la description du matériel.

Cependant, des limitations techniques ne permettent pas d'intégrer la
re-génération des fichiers de manière générique. L'outil utilisé pour piloter
les étapes de compilation ne permet pas de rajouter l'execution d'un outil
lors de la compilation.

### Difficultés éventuelles

GPS utilise un environnement Python spécifique et cet environnement ne
contenait pas le module sqlite3 nécessaire au foncionnement de mes outils.
Cet environnement utilise un outil appellé ANOD pour déployer des paquets
simplement, cependant le module dont j'avais besoins n'était pas déployé.
J'ai du créer un ticket pour résoudre ce problème, il fallait rajouter le
module sqlite3 dans la compilation de l'environnement.

J'ai dû modifier la façon dont les projets étaient créés. L'implémentation
actuelle ne permettait pas de créer une interface graphique pour un projet
spécifique. Elle permettait seulement d'exécuter du code après la création du
projet. J'ai donc dû rajouter une fonctionnalité pour pouvoir exécuter du code
pendant la création de projet et permettre de construire une interface
graphique personnalisable. Pour cela, \gls{GPS} va appeller une fonction du script
Python. Cette fonction peut renvoyer des éléments qui vont constituer les pages
successives correspondant au projet en question.

J'ai mis un peu de temps à implémenter cette fonctionalité. En effet, le code
que je devais modifier m'a pris un peu de temps à comprendre car le code
n'était pas très clair. Le code fait un usage intensif des variables globales,
ce qui rend le flux d'exécution compliquer à suivre car on ne sait pas à
l'avance si on modifie une variable globale ou non.

J'ai également eu des problèmes liés à des fichiers de configuration. L'outil
de génération de \gls{linker script} à besoin de fichier de configuration qui
décrivent les architectures supportées en fournissant les patrons d'assembleur
correspondants. Il fallait donc trouver une solution pour installer ces
fichiers de configuration.

[//]: # (TODO: Come back when it is fixed)

### Résultats obtenus et impact sur l'avancement du stage

L'intégration a bien avancée, je suis en train de travailler dessus.
Il reste plusieurs problèmes à régler, notamment regardant les fichiers de
configuration et l'installation de la base de données.

Avoir une interface graphique m'a permis de faire une démo et de mettre les
outils bout à bout afin de tester la chaîne d'outils.

# Premier bilan

## État de l'art sur l'intégration des CMSIS-Packs

Eclipse est l'\gls{IDE} le plus populaire pour écrire du code Java. Il possède un système
de plugins (écrits en Java) et supporte beaucoup de langages allant du Fortran
au Scala.

ARM a réalisé un plugin permettant de sélectionner quel pack utiliser et de
sélectionner précisément quels éléments (pilotes, exemples) du pack l'utilisateur
veut utiliser dans son projet. Le plugin permet également à l'utilisateur
d'accéder à toute la documentation concernant les éléments qu'il a choisi.

Le plugin est également capable de générer des \gls{linker script}s.
Cependant, le plugin génère un type de \gls{linker script} spécifique à l'éditeur de
liens ARM qui est incompatible avec l'outil LD que GNAT utilise. De plus, le \gls{plugin}
est réalisé en Java, ce qui rend l'intégration dans d'autres outils quasi-impossible.

## Intérêt du stage pour l'entreprise

Mon stage est surtout un avantage à long terme pour AdaCore. En effet, en
réduisant la barrière à l'entrée de la programmation embarquée en Ada, mon
stage permet de faciliter la transition du C vers l'Ada.
Il permet d'aider au support des runtimes ZFP et pourrait même être utiliser en
interne pour générer les futures runtimes distribuées aux clients.

Enfin, il est possible d'utiliser la chaîne d'outils actuelle pour d'autres
architectures qu'ARM et il serait très intéressant à long terme de supporter
les architectures LEON et PowerPC de cette manière.

## Perspectives d'amélioration

Toutes les fonctionnalitées que fournit Eclipse sont très intéressantes pour
l'utilisateur et seraient un atout pour AdaCore si elles étaient intégrées dans GPS.
Elles pourraient vraiment améliorer le développement en C dans GPS. On pourrait
également imaginer le cas où l'utilisateur pourrait utiliser certains pilotes du
paquet depuis le code Ada, il pourrait être intéressant de fournir cette
fonctionnalité 'out-of-the-box'. On pourrait utiliser l'option '-fdump-ada-spec'
du compilateur qui génére des fichiers .ads qui permettent au code Ada
d'appeller le code C.

La dernière étape de l'intégration dans GPS serait la re-génération du
\gls{linker script} et du \gls{startup code} dans le cas où l'utilisateur
changerait la description du matériel ou dans le cas où
l'utilisateur voudrait changer la mémoire de démarage.
Actuellement, il faut relancer l'outil qui génère ces fichiers.

Concernant la base de données stockant le contenu des packs, il serait
intéressant de pouvoir la synchroniser avec une version distante.
En effet, certains CMSIS-Packs, sont non-fonctionnels ou mal formatés et il
pourrait être intéressant pour AdaCore de fournir des versions corrigées de ces
packs. Cela permet également à AdaCore de corriger des bogues trouvés dans le
contenu des packs et de propager rapidement le patch.

Certaines architectures possèdent une cartographie mémoire particulière (deux
sections de RAM et pas de ROM par exemple). Il serait intéressant de pouvoir
gérer ces cas en permettant à l'utilisateur de choisir précisément où il va
mettre une section de l'executable.

Il serait intéressant de se pencher sur la question de génération de runtimes
plus complexes, comme les runtimes Ravenscar. Ces runtimes implémentent toutes
les fonctionnalitées du langage.

## Expérience personnelle acquise pendant le stage

### Intérêt technique

J'avais seulement fait un projet en Ada lors de mon cursus à l'EPITA et je
voulais profiter de mon expérience à AdaCore pour en apprendre plus. En
travaillant sur un des outils que j'ai fait en Ada j'ai beaucoup appris sur la
manière de travailler avec ce langage. Ada est un langage où la phase de
design est particulièrement importante car ce langage se veut résilient au
changement. J'ai pu donc m'améliorer sur ce que je considère être une de mes
faiblesses, la propention à commencer à coder sans avoir une vision claire de
l'architecture du code. Les diverses revues de code m'ont permis également de
rendre mon code plus clair notamment en limitant la taille des fonctions et en
choisissant des noms de fonction appropriées.

J'ai également beaucoup progressé dans mon apprentissage du Python. Beaucoup de
mes outils était développé sont en Python, ce qui m'a permis de mieux
comprendre certains idiomes du langage et d'avoir appris à mieux utiliser la
bibliothèque standard du langage.

En arrivant à AdaCore j'ai du configurer mon éditeur (Vim) afin de pouvoir
écrire du code Ada efficacement. J'ai écris plusieurs scripts qui me permettent
de générer du code \gls{boilerplate} et d'appliquer la coding-style
automatiquement en tappant du code. J'ai également écrit des scripts me
permettant d'écrire ce rapport en français de manière plus efficace, notamment
pour ce qui touche aux caractères accentués.

Lors de mon stage j'ai dû écrire des patrons de générations de code assembleur
pour plusieurs architectures différentes (ARMV6 et ARMV7). J'ai dû traduire du
code tournant sur ARMV7 vers l'architecture ARMV6. Comme j'ai dû écrire un
patron de linker script à générer, j'ai également approfondi ma connaissance des
différentes sections du linker et de leurs rôles.

A certains moments de mon stage, j'ai dû aller lire du code, soit parce que
j'avais des interrogations et que personne ne connaissait le réponse, soit
parceque j'avais un doute sur la façon dont certaines fonctions étaient
implémentées. Notamment, je n'ai pas trouvé de documentation qui expliquait
clairement quelles unitées de mesure de mémoire utilisait l'éditeur de liens,
j'ai dû donc aller lire le code.

AdaCore organise des `Monthly Interns Commits`. Ce sont des séances d'une heure
ou chacun des stagiaires d'AdaCore présente son travail, son avancement et les
problèmes qu'il a rencontrés. Les retours suite aux présentations m'ont vraiment
aidé à rendre mes diapositives plus claires et plus synthétiques.
J'ai passé un peu de temps à améliorer ma présentation et j'ai
rendant l'explication de mon sujet de stage beaucoup plus abordable,
notamment en situant mieux le contexte des runtimes qui est particulier à Ada.
Anthony a également revu certaines de mes présentations et m'a aidé à les
améliorer en les rendants plus pertinentes et plus claires, notamment en
expliquant le contenu de slides par un schéma.

### Intérêt organisationnel

J'ai appliqué ce que j'avais appris lors de mon stage précédent, c'est-à-dire
ne pas hésiter à demander des éclaircissements quand les spécifications de
ce que je devais développer n'étaient pas claires. Dans le cas où je suis
bloqué à cause d'un problème technique je n'ai pas hésité à aller poser des
questions aux personnes qui m'encadraient.

Je pense également avoir été plus consciencieux que pendant mon stage précédent. Lorsque
je trouvais un problème dans les outils que j'utilisais, je créais au minumum
un ticket et dans certains cas je cherchais un peu pour essayer de trouver d'où
venait le bug et j'ai même soumis quelques patchs de cette façon.

Je me suis également beaucoup mieux organisé puisque je gardais une trace de
mes tâches à réaliser dans mon cahier. Cela m'a permis de prioriser mon travail
et de me donner des buts à accomplir chaque jour. Si j'avais quelquechose à
changer dans cette organisation ce serait d'utiliser un programme plutôt qu'un
cahier pour organiser mes tâches.

## Retours sur le stage et pertinence de la formation

En ce qui concerne les points perfectibles du stage, je pense que j'aurais dû
commencer à penser au design des outils depuis le début du stage. En effet,
j'ai commencé par faire plusieurs scripts prototypes. Cependant, n'ayant pas
encore très bien cerné mon sujet de stage, ces script n'ont finalement pas été
utilisés car le problème qu'ils resolvaient était déjà résolu par d'autres
outils d'AdaCore.

La formation généraliste d'EPITA, notamment le projet TIGER en ING1, m'a permis
d'appréhender le fonctionnement des compilateurs et me sera très utile dans
mon futur emploi. Le projet ASM (aussi en ING1) m'a permis de me familiariser
avec l'assembleur de manière générale, ce qui m'a été très utile pour lire le
\gls{startup code} de référence et pouvoir l'adapter à de nouvelles plate-formes.

La formation Ada de GISTRE m'a aider à me familiariser avec le langage et m'a
permis d'avancer plus vite sur l'outil écrit en Ada. Le projet accompli dans le
contexte de cette matière m'a permis d'étudier comment interfacer de l'Ada et
du C++ sur une plate-forme embarqué et les difficultés qui s'ensuivaient, par
exemple lié à l'usage d'intialisation statique.

Grâce à cette formation, j'ai pu me renseigner en cherchant et en lisant des
papiers de recherche que j'ai pu lire et appréhender moi-même. Notamment des
articles qui m'ont permis de mieux comprendre le rôle et le fonctionnement de
la runtime Ada.

Les aspects temps-réels de la formation de GISTRE m'ont été à comprendre les
enjeux des clients d'AdaCore. Par exemple, le cours d'architecture distribuée
de Christian Garnier m'a permis de comprendre quels étaient les enjeux et les
garanties que devaient apporté un système temps réel. Le cours de freeRTOS de
Thierry Joubert m'a permis de comprendre comment fonctionnait un OS temps réel,
et les problèmes que le système résolvait. Enfin le cours de José Ruiz sur la
norme DO-178 était très intéressant car il permettait de comprendre comment le
processus de certifaction fonctionnait et comment on pouvait tracer les
exigences de haut-niveau jusqu'au code source.

[@gnatada9x].

[@bareboardkernelada2005].

[@adarealtimeclock].

[@ptcobjectada].

[@adacompetition].

- papiers de recherche
     - real time features on a bare board kernel
     - implementing Ada real time clock and absolute delays in real time kernels
     - ORK: An open source real-time kernel for on-board software systems.

# Bibliographie

