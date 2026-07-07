MarketPalce
Flutter:dart

<!DOCTYPE html><html class="light" lang="fr"><head>
<meta charset="utf-8">
<meta content="width=device-width, initial-scale=1.0" name="viewport">
<title>Publier un bien - RealEstate Pro</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet">
<script id="tailwind-config">
      tailwind.config = {
        darkMode: "class",
        theme: {
          extend: {
            "colors": {
                    "on-primary-fixed": "#001b3d",
                    "on-tertiary-fixed-variant": "#005138",
                    "on-error": "#ffffff",
                    "tertiary": "#004931",
                    "surface-container": "#eceef0",
                    "primary-fixed-dim": "#a9c7ff",
                    "primary": "#003e7e",
                    "surface-container-lowest": "#ffffff",
                    "on-primary-container": "#b3cdff",
                    "surface-container-high": "#e6e8ea",
                    "surface-container-highest": "#e0e3e5",
                    "background": "#f7f9fb",
                    "surface": "#f7f9fb",
                    "on-tertiary": "#ffffff",
                    "on-secondary": "#ffffff",
                    "on-background": "#191c1e",
                    "on-primary-fixed-variant": "#00468c",
                    "error-container": "#ffdad6",
                    "secondary-fixed-dim": "#bfc8ce",
                    "on-tertiary-container": "#6fe1af",
                    "on-secondary-container": "#5d666c",
                    "outline": "#737782",
                    "on-error-container": "#93000a",
                    "on-secondary-fixed-variant": "#3f484e",
                    "error": "#ba1a1a",
                    "secondary-fixed": "#dbe4eb",
                    "tertiary-fixed": "#86f8c5",
                    "secondary": "#576065",
                    "inverse-on-surface": "#eff1f3",
                    "surface-container-low": "#f2f4f6",
                    "on-secondary-fixed": "#141d22",
                    "on-primary": "#ffffff",
                    "on-surface": "#191c1e",
                    "surface-tint": "#265ea8",
                    "on-tertiary-fixed": "#002114",
                    "surface-dim": "#d8dadc",
                    "secondary-container": "#dbe4eb",
                    "on-surface-variant": "#424751",
                    "inverse-primary": "#a9c7ff",
                    "primary-container": "#1a56a0",
                    "tertiary-fixed-dim": "#69dbaa",
                    "tertiary-container": "#006344",
                    "inverse-surface": "#2d3133",
                    "surface-variant": "#e0e3e5",
                    "primary-fixed": "#d6e3ff",
                    "outline-variant": "#c2c6d3",
                    "surface-bright": "#f7f9fb"
            },
            "borderRadius": {
                    "DEFAULT": "0.25rem",
                    "lg": "0.5rem",
                    "xl": "0.75rem",
                    "full": "9999px"
            },
            "spacing": {
                    "xs": "4px",
                    "sm": "8px",
                    "md": "16px",
                    "base": "4px",
                    "xl": "32px",
                    "lg": "24px",
                    "gutter": "16px",
                    "container-max": "1280px"
            },
            "fontFamily": {
                    "display-lg-mobile": ["Inter"],
                    "label-md": ["Inter"],
                    "label-sm": ["Inter"],
                    "body-md": ["Inter"],
                    "body-lg": ["Inter"],
                    "headline-md": ["Inter"],
                    "display-lg": ["Inter"],
                    "title-lg": ["Inter"]
            },
            "fontSize": {
                    "display-lg-mobile": ["28px", {"lineHeight": "34px", "fontWeight": "700"}],
                    "label-md": ["12px", {"lineHeight": "16px", "letterSpacing": "0.01em", "fontWeight": "600"}],
                    "label-sm": ["11px", {"lineHeight": "14px", "fontWeight": "500"}],
                    "body-md": ["14px", {"lineHeight": "20px", "fontWeight": "400"}],
                    "body-lg": ["16px", {"lineHeight": "24px", "fontWeight": "400"}],
                    "headline-md": ["24px", {"lineHeight": "32px", "fontWeight": "600"}],
                    "display-lg": ["36px", {"lineHeight": "44px", "letterSpacing": "-0.02em", "fontWeight": "700"}],
                    "title-lg": ["20px", {"lineHeight": "28px", "fontWeight": "600"}]
            }
          },
        },
      }
    </script>
<style>
        body { font-family: 'Inter', sans-serif; }
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        .step-active { font-variation-settings: 'FILL' 1; }
        .hide-scrollbar::-webkit-scrollbar { display: none; }
        .hide-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }
    </style>
</head>
<body class="bg-background text-on-background min-h-screen pb-24">
<!-- TopAppBar -->
<header class="bg-primary-container text-on-primary w-full top-0 sticky shadow-md flex items-center justify-between px-md h-16 z-50">
<div class="flex items-center gap-md">
<button class="material-symbols-outlined active:scale-95 duration-150 p-sm hover:bg-primary-container/20 transition-colors rounded-full">arrow_back</button>
<h1 class="font-title-lg text-title-lg">Publier un bien</h1>
</div>
<div class="flex flex-col items-end">
<span class="font-label-md text-label-md opacity-80 uppercase tracking-wider">Étape</span>
<span class="font-title-lg text-title-lg font-bold">1 / 4</span>
</div>
</header>
<main class="max-w-container-max mx-auto px-md mt-md">
<!-- Info Banner -->
<section class="bg-primary-fixed text-on-primary-fixed p-md rounded-xl flex gap-md items-start mb-xl shadow-sm border border-primary-fixed-dim/30">
<div class="bg-primary-container/10 p-sm rounded-full">
<span class="material-symbols-outlined text-primary-container" style="font-variation-settings: &quot;FILL&quot; 1;">home_work</span>
</div>
<div class="flex flex-col">
<p class="font-body-md text-body-md leading-snug">
                    En publiant, vous devenez aussi <span class="font-bold">Propriétaire</span> sur ImmoPro. Profitez d'outils de gestion exclusifs.
                </p>
</div>
</section>
<!-- Form Canvas -->
<div class="grid grid-cols-1 md:grid-cols-12 gap-lg">
<!-- Left Side: Basic Info -->
<section class="md:col-span-7 flex flex-col gap-lg">
<!-- Type de Bien -->
<div class="flex flex-col gap-sm">
<label class="font-label-md text-on-surface-variant ml-xs">Type de bien</label>
<div class="relative">
<select class="w-full h-12 px-md bg-surface-container-lowest border-outline-variant rounded-xl focus:ring-2 focus:ring-primary focus:border-primary appearance-none text-body-lg font-body-lg">
<option>Appartement</option>
<option>Maison</option>
<option>Terrain</option>
<option>Bureau / Commerce</option>
<option>Villa</option>
</select>
<span class="material-symbols-outlined absolute right-md top-1/2 -translate-y-1/2 pointer-events-none text-on-surface-variant">expand_more</span>
</div>
</div>
<!-- Transaction Chips -->
<div class="flex flex-col gap-sm">

<div class="flex flex-wrap gap-sm">



</div>
</div>
<!-- Ad Title -->
<div class="flex flex-col gap-sm">
<label class="font-label-md text-on-surface-variant ml-xs">Titre de l'annonce</label>
<input class="w-full h-12 px-md bg-surface-container-lowest border-outline-variant rounded-xl focus:ring-2 focus:ring-primary focus:border-primary font-body-lg" placeholder="Ex: Bel appartement F4 à Cocody" type="text">
</div>
<!-- Price & Surface Grid -->
<div class="grid grid-cols-2 gap-md">
<div class="flex flex-col gap-sm">
<label class="font-label-md text-on-surface-variant ml-xs">Prix</label>
<div class="relative">
<input class="w-full h-12 pl-md pr-16 bg-surface-container-lowest border-outline-variant rounded-xl focus:ring-2 focus:ring-primary focus:border-primary font-body-lg" placeholder="0" type="number">
<span class="absolute right-md top-1/2 -translate-y-1/2 text-on-surface-variant font-label-md bg-surface-container-high px-xs py-0.5 rounded">FCFA</span>
</div>
</div>
<div class="flex flex-col gap-sm">
<label class="font-label-md text-on-surface-variant ml-xs">Surface</label>
<div class="relative">
<input class="w-full h-12 pl-md pr-12 bg-surface-container-lowest border-outline-variant rounded-xl focus:ring-2 focus:ring-primary focus:border-primary font-body-lg" placeholder="0" type="number">
<span class="absolute right-md top-1/2 -translate-y-1/2 text-on-surface-variant font-label-md">m²</span>
</div>
</div>
</div>
<!-- Steppers -->
<div class="grid grid-cols-2 gap-md">
<div class="flex flex-col gap-sm">
<label class="font-label-md text-on-surface-variant ml-xs">Pièces</label>
<div class="flex items-center bg-surface-container-lowest border border-outline-variant rounded-xl h-12 overflow-hidden shadow-sm">
<button class="flex-1 flex justify-center items-center hover:bg-surface-container-high active:bg-surface-container-highest transition-colors h-full" onclick="decrement('rooms')"><span class="material-symbols-outlined">remove</span></button>
<span class="flex-[2] text-center font-title-lg text-title-lg border-x border-outline-variant h-full flex items-center justify-center" id="rooms-val">1</span>
<button class="flex-1 flex justify-center items-center hover:bg-surface-container-high active:bg-surface-container-highest transition-colors h-full" onclick="increment('rooms')"><span class="material-symbols-outlined">add</span></button>
</div>
</div>
<div class="flex flex-col gap-sm">
<label class="font-label-md text-on-surface-variant ml-xs">Salles de bain</label>
<div class="flex items-center bg-surface-container-lowest border border-outline-variant rounded-xl h-12 overflow-hidden shadow-sm">
<button class="flex-1 flex justify-center items-center hover:bg-surface-container-high active:bg-surface-container-highest transition-colors h-full" onclick="decrement('baths')"><span class="material-symbols-outlined">remove</span></button>
<span class="flex-[2] text-center font-title-lg text-title-lg border-x border-outline-variant h-full flex items-center justify-center" id="baths-val">1</span>
<button class="flex-1 flex justify-center items-center hover:bg-surface-container-high active:bg-surface-container-highest transition-colors h-full" onclick="increment('baths')"><span class="material-symbols-outlined">add</span></button>
</div>
</div>
</div>
</section>
<!-- Right Side: Details & Location -->
<section class="md:col-span-5 flex flex-col gap-lg">
<!-- Description -->
<div class="flex flex-col gap-sm">
<div class="flex justify-between items-end ml-xs">
<label class="font-label-md text-on-surface-variant">Description</label>
<span class="font-label-sm text-on-surface-variant opacity-60" id="char-count">0 / 2000</span>
</div>
<textarea class="w-full min-h-[160px] p-md bg-surface-container-lowest border-outline-variant rounded-xl focus:ring-2 focus:ring-primary focus:border-primary font-body-md resize-none" id="desc-area" maxlength="2000" oninput="updateCharCount()" placeholder="Décrivez les atouts de votre bien (luminosité, calme, travaux récents...)"></textarea>
</div>
<!-- Address & Map -->
<div class="flex flex-col gap-sm">
<label class="font-label-md text-on-surface-variant ml-xs">Adresse</label>
<div class="relative">
<input class="w-full h-12 pl-12 pr-24 bg-surface-container-lowest border-outline-variant rounded-xl focus:ring-2 focus:ring-primary focus:border-primary font-body-lg" placeholder="Entrez le quartier ou la rue" type="text">
<span class="material-symbols-outlined absolute left-md top-1/2 -translate-y-1/2 text-primary">location_on</span>
<button class="absolute right-md top-1/2 -translate-y-1/2 text-primary font-label-md font-bold uppercase tracking-wide hover:underline">Localiser</button>
</div>
<!-- Mini Map Card -->
<div class="w-full h-48 rounded-xl overflow-hidden border border-outline-variant shadow-sm relative group">
<div class="absolute inset-0 bg-surface-container-low flex items-center justify-center">
<img class="w-full h-full object-cover grayscale opacity-60 group-hover:grayscale-0 group-hover:opacity-100 transition-all duration-500" data-alt="A clean, minimalist 2D vector style map showing a serene residential neighborhood with neatly lined streets, green parks, and modern building outlines in Abidjan, Côte d'Ivoire. The map is rendered with soft pastel blues and whites, echoing a professional real estate dashboard aesthetic. A prominent red location pin is placed in the center, casting a soft shadow." src="https://lh3.googleusercontent.com/aida-public/AB6AXuB2zkfCWLPyTE19dwlFjriU-Rqiyorqzui47MAogE2bJhhkSDh8i3QA4Cmv8YtODa2kmaU9pEcO5oTVeHIHKtqrR0VBfhd-gNTjeXxIoztltXyylANugSjLpSO_KGe-u1E0EEOFyiJTV0fSRY3DvwH4IAR8L4kqXSly4vO6LwQHucX09b2UUL3Lo1DBwyuRtT31hvGY9waawpyGTtNFsZe_T28LIVGjz63YIr5pFR705-YiYustgjAo798pyb0nGNooBUZ5d0m38x8">
</div>
<div class="absolute inset-0 bg-black/5 flex items-center justify-center group-hover:bg-transparent transition-colors">
<div class="bg-surface p-sm rounded-lg shadow-lg flex items-center gap-sm">
<span class="material-symbols-outlined text-primary" style="font-variation-settings: &quot;FILL&quot; 1;">explore</span>
<span class="font-label-md">Cliquez pour agrandir</span>
</div>
</div>
</div>
</div>
</section>
</div>
</main>
<!-- Bottom Action Bar -->
<footer class="fixed bottom-0 left-0 w-full bg-surface-container-lowest px-md h-20 flex items-center justify-center z-50 border-t border-outline-variant">
<div class="max-w-container-max w-full flex justify-between items-center">
<div class="hidden md:flex flex-col">
<span class="font-label-sm text-on-surface-variant">Auto-sauvegardé à 14:32</span>
<span class="font-body-md text-primary font-semibold">Brouillon conservé</span>
</div>
<button class="w-full md:w-auto min-w-[240px] h-12 bg-primary-container text-on-primary-container font-bold rounded-xl flex items-center justify-center gap-sm shadow-lg active:scale-95 transition-all duration-150 hover:bg-primary-container/90">
                Suivant 
                <span class="material-symbols-outlined">arrow_forward</span>
</button>
</div>
</footer>
<script>
        function toggleChip(btn) {
            const isActive = btn.dataset.active === "true";
            const siblings = btn.parentElement.querySelectorAll('button');
            
            siblings.forEach(s => {
                s.dataset.active = "false";
                s.classList.remove('bg-primary-container', 'text-on-primary-container', 'border-transparent');
                s.classList.add('bg-surface-container-lowest', 'text-on-surface-variant', 'border-outline-variant');
            });

            if (!isActive) {
                btn.dataset.active = "true";
                btn.classList.add('bg-primary-container', 'text-on-primary-container', 'border-transparent');
                btn.classList.remove('bg-surface-container-lowest', 'text-on-surface-variant', 'border-outline-variant');
            }
        }

        // Initialize active chip
        document.querySelectorAll('.chip-active').forEach(chip => {
            chip.classList.add('bg-primary-container', 'text-on-primary-container', 'border-transparent');
            chip.classList.remove('bg-surface-container-lowest', 'text-on-surface-variant', 'border-outline-variant');
        });

        function increment(id) {
            const el = document.getElementById(id + '-val');
            let val = parseInt(el.innerText);
            el.innerText = val + 1;
        }

        function decrement(id) {
            const el = document.getElementById(id + '-val');
            let val = parseInt(el.innerText);
            if (val > 1) el.innerText = val - 1;
        }

        function updateCharCount() {
            const area = document.getElementById('desc-area');
            const counter = document.getElementById('char-count');
            counter.innerText = `${area.value.length} / 2000`;
        }
    </script>


</body></html>






<!DOCTYPE html>

<html class="light" lang="fr"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
      tailwind.config = {
        darkMode: "class",
        theme: {
          extend: {
            "colors": {
                    "on-primary-fixed": "#001b3d",
                    "on-tertiary-fixed-variant": "#005138",
                    "on-error": "#ffffff",
                    "tertiary": "#004931",
                    "surface-container": "#eceef0",
                    "primary-fixed-dim": "#a9c7ff",
                    "primary": "#003e7e",
                    "surface-container-lowest": "#ffffff",
                    "on-primary-container": "#b3cdff",
                    "surface-container-high": "#e6e8ea",
                    "surface-container-highest": "#e0e3e5",
                    "background": "#f7f9fb",
                    "surface": "#f7f9fb",
                    "on-tertiary": "#ffffff",
                    "on-secondary": "#ffffff",
                    "on-background": "#191c1e",
                    "on-primary-fixed-variant": "#00468c",
                    "error-container": "#ffdad6",
                    "secondary-fixed-dim": "#bfc8ce",
                    "on-tertiary-container": "#6fe1af",
                    "on-secondary-container": "#5d666c",
                    "outline": "#737782",
                    "on-error-container": "#93000a",
                    "on-secondary-fixed-variant": "#3f484e",
                    "error": "#ba1a1a",
                    "secondary-fixed": "#dbe4eb",
                    "tertiary-fixed": "#86f8c5",
                    "secondary": "#576065",
                    "inverse-on-surface": "#eff1f3",
                    "surface-container-low": "#f2f4f6",
                    "on-secondary-fixed": "#141d22",
                    "on-primary": "#ffffff",
                    "on-surface": "#191c1e",
                    "surface-tint": "#265ea8",
                    "on-tertiary-fixed": "#002114",
                    "surface-dim": "#d8dadc",
                    "secondary-container": "#dbe4eb",
                    "on-surface-variant": "#424751",
                    "inverse-primary": "#a9c7ff",
                    "primary-container": "#1a56a0",
                    "tertiary-fixed-dim": "#69dbaa",
                    "tertiary-container": "#006344",
                    "inverse-surface": "#2d3133",
                    "surface-variant": "#e0e3e5",
                    "primary-fixed": "#d6e3ff",
                    "outline-variant": "#c2c6d3",
                    "surface-bright": "#f7f9fb"
            },
            "borderRadius": {
                    "DEFAULT": "0.25rem",
                    "lg": "0.5rem",
                    "xl": "0.75rem",
                    "full": "9999px"
            },
            "spacing": {
                    "xs": "4px",
                    "sm": "8px",
                    "md": "16px",
                    "base": "4px",
                    "xl": "32px",
                    "lg": "24px",
                    "gutter": "16px",
                    "container-max": "1280px"
            },
            "fontFamily": {
                    "display-lg-mobile": ["Inter"],
                    "label-md": ["Inter"],
                    "label-sm": ["Inter"],
                    "body-md": ["Inter"],
                    "body-lg": ["Inter"],
                    "headline-md": ["Inter"],
                    "display-lg": ["Inter"],
                    "title-lg": ["Inter"]
            },
            "fontSize": {
                    "display-lg-mobile": ["28px", {"lineHeight": "34px", "fontWeight": "700"}],
                    "label-md": ["12px", {"lineHeight": "16px", "letterSpacing": "0.01em", "fontWeight": "600"}],
                    "label-sm": ["11px", {"lineHeight": "14px", "fontWeight": "500"}],
                    "body-md": ["14px", {"lineHeight": "20px", "fontWeight": "400"}],
                    "body-lg": ["16px", {"lineHeight": "24px", "fontWeight": "400"}],
                    "headline-md": ["24px", {"lineHeight": "32px", "fontWeight": "600"}],
                    "display-lg": ["36px", {"lineHeight": "44px", "letterSpacing": "-0.02em", "fontWeight": "700"}],
                    "title-lg": ["20px", {"lineHeight": "28px", "fontWeight": "600"}]
            }
          },
        },
      }
    </script>
<style>
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        .step-progress-glow {
            box-shadow: 0 0 12px rgba(169, 199, 255, 0.4);
        }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-background text-on-surface font-body-md text-body-md antialiased min-h-screen pb-24">
<!-- TopAppBar -->
<header class="w-full top-0 sticky bg-primary shadow-md z-50 flex items-center justify-between px-md h-16 transition-all">
<div class="flex items-center gap-md">
<button class="hover:bg-primary-container/20 transition-colors p-2 rounded-full active:scale-95 duration-150">
<span class="material-symbols-outlined text-on-primary">arrow_back</span>
</button>
<div class="flex flex-col">
<span class="font-title-lg text-title-lg text-on-primary">Publier un bien</span>
<span class="font-label-sm text-label-sm text-primary-fixed-dim">Étape 2 sur 4</span>
</div>
</div>
<div class="flex items-center gap-xs">
<div class="flex gap-1">
<div class="w-2 h-2 rounded-full bg-primary-fixed"></div>
<div class="w-6 h-2 rounded-full bg-primary-fixed-dim step-progress-glow"></div>
<div class="w-2 h-2 rounded-full bg-primary-container"></div>
<div class="w-2 h-2 rounded-full bg-primary-container"></div>
</div>
</div>
</header>
<main class="max-w-container-max mx-auto px-md py-lg space-y-xl">
<!-- Upload Zone -->
<section class="space-y-md">
<div class="border-2 border-dashed border-primary-container bg-surface-container-low rounded-xl p-xl flex flex-col items-center justify-center text-center space-y-sm hover:bg-surface-container-high transition-colors cursor-pointer active:scale-98">
<div class="bg-primary-container text-on-primary-container p-lg rounded-full mb-xs">
<span class="material-symbols-outlined text-4xl">photo_camera</span>
</div>
<h3 class="font-title-lg text-title-lg text-primary">Ajouter des photos</h3>
<p class="text-on-surface-variant max-w-xs">
                    Importez entre 3 et 10 visuels. Les vidéos sont également les bienvenues pour booster votre annonce.
                </p>
<div class="mt-md px-lg py-sm bg-primary text-on-primary rounded-full font-label-md text-label-md">
                    Parcourir les fichiers
                </div>
</div>
</section>
<!-- Media Grid -->
<section class="space-y-md">
<div class="flex items-center justify-between">
<h4 class="font-title-lg text-title-lg text-on-surface">Vos médias (4)</h4>
<span class="text-on-surface-variant font-label-md">Maintenez pour réorganiser</span>
</div>
<div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-md">
<!-- Media Item 1 (Primary) -->
<div class="relative group aspect-square rounded-xl overflow-hidden shadow-sm hover:shadow-md transition-all duration-300 border-2 border-primary">
<div class="absolute inset-0 w-full h-full bg-cover bg-center" data-alt="A professional high-resolution architectural photograph of a spacious modern living room with floor-to-ceiling windows, soft morning light illuminating hardwood floors and minimalist furniture. The color palette is composed of soft whites, warm wood tones, and subtle blue accents, creating an inviting and premium real estate atmosphere." style="background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuC4GUUqoyEs_Mbe9yscwC1YqaIGYvAvLaSu3d1qykawaAJtXVVOT5oxe9saDeBHtf_uXEeY4aYb2WDr3VKZLVzSvp6mhTUXoqUz96BBLK3PvZZYfV_faEZwvirRkvXeKz9lsTqFgPVqODsmbdenYWenaz748n_u5DV2WdWC_GIocdrqEP73xVWcV4DkEbRZmQWiyBqSzzIkF2s__2degGAkHcrxY7ncHzUpoTCYW0lR7jF0NThq56yJN6RClIc2JgSlY34uDZ2c_X8')"></div>
<!-- Badges & Controls -->
<div class="absolute top-sm left-sm bg-tertiary text-on-tertiary px-sm py-1 rounded-full flex items-center gap-1 shadow-sm">
<span class="material-symbols-outlined text-[14px]" style="font-variation-settings: 'FILL' 1;">star</span>
<span class="text-[10px] font-bold uppercase tracking-wider">Photo principale</span>
</div>
<div class="absolute top-sm right-sm flex gap-1">
<div class="bg-primary text-on-primary w-6 h-6 rounded-full flex items-center justify-center shadow-md">
<span class="material-symbols-outlined text-[16px]" style="font-variation-settings: 'FILL' 1;">check_circle</span>
</div>
<button class="bg-error/90 hover:bg-error text-on-error w-6 h-6 rounded-full flex items-center justify-center shadow-md backdrop-blur-sm transition-transform active:scale-90">
<span class="material-symbols-outlined text-[16px]">close</span>
</button>
</div>
<div class="absolute inset-0 bg-primary/10 opacity-0 group-hover:opacity-100 transition-opacity flex items-end p-sm pointer-events-none">
<span class="text-white font-label-sm drop-shadow-md">IMG_001.jpg</span>
</div>
</div>
<!-- Media Item 2 -->
<div class="relative group aspect-square rounded-xl overflow-hidden shadow-sm hover:shadow-md transition-all duration-300">
<div class="absolute inset-0 w-full h-full bg-cover bg-center" data-alt="A detailed shot of a contemporary kitchen featuring marble countertops, high-end stainless steel appliances, and sleek charcoal cabinetry. The lighting is bright and natural, highlighting the premium finishes and clean design of this luxury property. The overall mood is sophisticated and clean, perfectly aligned with a professional corporate real estate aesthetic." style="background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuDkmoB7YS56cWcQhybwqKmu4ab530hXaeGWlH3J_4O_6DKZq5LRLgjg2OriwZtzyMjCp29KWSkU4HZGxsCO8sXjrv9gFfHfF2ShtRzUrBGFuhoqsSR-JWNGSuFGHVsVgF8yN4Vt2QwQnafEWqAVxDhdbFFGgHZ2Mlx1GrGbG-TqLAO6HXNVNBJt2m0PHov6ddH_eAOHN3toRJSs87lCWu8mDrhoEjzRMD-KldSJh9lAksLvRbBzChClaD_e7TGTZ01urAVKRBH3UiA')"></div>
<div class="absolute top-sm right-sm flex gap-1">
<div class="bg-primary text-on-primary w-6 h-6 rounded-full flex items-center justify-center shadow-md">
<span class="material-symbols-outlined text-[16px]" style="font-variation-settings: 'FILL' 1;">check_circle</span>
</div>
<button class="bg-error/90 hover:bg-error text-on-error w-6 h-6 rounded-full flex items-center justify-center shadow-md backdrop-blur-sm transition-transform active:scale-90">
<span class="material-symbols-outlined text-[16px]">close</span>
</button>
</div>
</div>
<!-- Media Item 3 -->
<div class="relative group aspect-square rounded-xl overflow-hidden shadow-sm hover:shadow-md transition-all duration-300">
<div class="absolute inset-0 w-full h-full bg-cover bg-center" data-alt="A wide-angle photograph of a master bedroom suite with a king-sized bed, plush neutral-toned bedding, and large windows offering a garden view. The atmosphere is serene and relaxing, captured in soft evening daylight that creates long, gentle shadows and emphasizes the room's airy layout." style="background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuAxAGFV0gyjcWgtOFQX8SknUrwX3Rgn0WYhpVGLdwsk69_wtK7KgKKYN-xz73jaZO6xFalK2S1gn7FvaI1qkLy4cUd-81bgbkMbatCgk77DhzDmDOFrQZCDGaG5RWWviLB1l7xkiRHfz3mIu5BO8s886316nluigfEsvchn03iRd2Ze9pBoF-kZrcSul1iEQpo9RErIvyWm7uKrtlxERNHny0iB_i-UpDu84YpklHlZGGGl3nVJ8lB5VjDzwrRzzTYIyJEqc4etXb0')"></div>
<div class="absolute top-sm right-sm flex gap-1">
<div class="bg-primary text-on-primary w-6 h-6 rounded-full flex items-center justify-center shadow-md">
<span class="material-symbols-outlined text-[16px]" style="font-variation-settings: 'FILL' 1;">check_circle</span>
</div>
<button class="bg-error/90 hover:bg-error text-on-error w-6 h-6 rounded-full flex items-center justify-center shadow-md backdrop-blur-sm transition-transform active:scale-90">
<span class="material-symbols-outlined text-[16px]">close</span>
</button>
</div>
</div>
<!-- Media Item 4 (Video Placeholder) -->
<div class="relative group aspect-square rounded-xl overflow-hidden shadow-sm hover:shadow-md transition-all duration-300">
<div class="absolute inset-0 w-full h-full bg-cover bg-center grayscale-[0.5]" data-alt="A cinematic outdoor shot of a modern villa exterior with a swimming pool and landscaped gardens during the golden hour. The sky is a gradient of deep orange and soft blue, casting a warm glow over the white facade of the house. This high-end real estate imagery conveys luxury and lifestyle." style="background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuBTVYgCWLjvg1BtmNnAfEm_cC6XiRshho6LpNe3-7ZvWEHixYdSQl434Umsqgv50107PYUld9KCv6v82zzFMOlMYDLKYt1KfgQbjj-1qf_do5soqD8RkCoOYlAAdA2q8RlrMsW3lagw9sRVdjaSj0EoK-nsHMSbjSpC5JzuCaJyeLOCZRs_XE0m-zL6DstFKp_32T1N0vlfedLfVkwmYiz708p8hAIMmudece7Aus-Enw79OviRHjnjaXZVJPkMwOZ8BoGwgGM7M5c')"></div>
<div class="absolute inset-0 flex items-center justify-center">
<div class="w-12 h-12 bg-white/30 backdrop-blur-md rounded-full flex items-center justify-center border border-white/50 text-white">
<span class="material-symbols-outlined text-3xl" style="font-variation-settings: 'FILL' 1;">play_arrow</span>
</div>
</div>
<div class="absolute bottom-sm left-sm bg-black/50 text-white px-2 py-0.5 rounded text-[10px] font-bold">0:15</div>
<div class="absolute top-sm right-sm flex gap-1">
<div class="bg-primary text-on-primary w-6 h-6 rounded-full flex items-center justify-center shadow-md">
<span class="material-symbols-outlined text-[16px]" style="font-variation-settings: 'FILL' 1;">check_circle</span>
</div>
<button class="bg-error/90 hover:bg-error text-on-error w-6 h-6 rounded-full flex items-center justify-center shadow-md backdrop-blur-sm transition-transform active:scale-90">
<span class="material-symbols-outlined text-[16px]">close</span>
</button>
</div>
</div>
</div>
</section>
<!-- Tip Box -->
<section>
<div class="bg-primary-fixed text-on-primary-fixed p-md rounded-xl flex gap-md items-start border border-primary-container/20">
<div class="bg-primary-container text-on-primary-container p-sm rounded-lg shrink-0">
<span class="material-symbols-outlined">lightbulb</span>
</div>
<div class="space-y-1">
<p class="font-bold text-on-primary-fixed">Le conseil de l'expert</p>
<p class="text-on-primary-fixed-variant leading-relaxed">
                        Photos en lumière naturelle = plus de visites. Essayez de prendre vos clichés en milieu de journée pour un rendu optimal et chaleureux.
                    </p>
</div>
</div>
</section>
</main>
<!-- Navigation Buttons Footer -->
<footer class="fixed bottom-0 left-0 w-full bg-surface h-20 px-md flex items-center justify-between border-t border-outline-variant shadow-lg z-50">
<button class="flex items-center justify-center gap-2 border-2 border-outline-variant text-on-surface-variant px-lg h-12 rounded-lg font-bold transition-all active:scale-95 hover:bg-surface-container-high">
<span class="material-symbols-outlined">chevron_left</span>
            Retour
        </button>
<button class="flex items-center justify-center gap-2 bg-primary text-on-primary px-xl h-12 rounded-lg font-bold shadow-md transition-all active:scale-95 hover:bg-primary-container">
            Suivant
            <span class="material-symbols-outlined">chevron_right</span>
</button>
</footer>
<script>
        // Simple micro-interaction for the upload zone
        const uploadZone = document.querySelector('.border-dashed');
        if (uploadZone) {
            uploadZone.addEventListener('dragover', (e) => {
                e.preventDefault();
                uploadZone.classList.add('bg-primary-container/10');
            });
            uploadZone.addEventListener('dragleave', () => {
                uploadZone.classList.remove('bg-primary-container/10');
            });
            uploadZone.addEventListener('drop', (e) => {
                e.preventDefault();
                uploadZone.classList.remove('bg-primary-container/10');
                // Interaction logic could go here
            });
        }

        // Handle delete buttons
        document.querySelectorAll('button.bg-error\\/90').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const card = e.currentTarget.closest('.relative.group');
                card.style.transform = 'scale(0.8)';
                card.style.opacity = '0';
                setTimeout(() => {
                    card.remove();
                }, 300);
            });
        });
    </script>
</body></html>


<!DOCTYPE html>

<html class="light" lang="fr"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    "colors": {
                        "on-primary-fixed": "#001b3d",
                        "on-tertiary-fixed-variant": "#005138",
                        "on-error": "#ffffff",
                        "tertiary": "#004931",
                        "surface-container": "#eceef0",
                        "primary-fixed-dim": "#a9c7ff",
                        "primary": "#003e7e",
                        "surface-container-lowest": "#ffffff",
                        "on-primary-container": "#b3cdff",
                        "surface-container-high": "#e6e8ea",
                        "surface-container-highest": "#e0e3e5",
                        "background": "#f7f9fb",
                        "surface": "#f7f9fb",
                        "on-tertiary": "#ffffff",
                        "on-secondary": "#ffffff",
                        "on-background": "#191c1e",
                        "on-primary-fixed-variant": "#00468c",
                        "error-container": "#ffdad6",
                        "secondary-fixed-dim": "#bfc8ce",
                        "on-tertiary-container": "#6fe1af",
                        "on-secondary-container": "#5d666c",
                        "outline": "#737782",
                        "on-error-container": "#93000a",
                        "on-secondary-fixed-variant": "#3f484e",
                        "error": "#ba1a1a",
                        "secondary-fixed": "#dbe4eb",
                        "tertiary-fixed": "#86f8c5",
                        "secondary": "#576065",
                        "inverse-on-surface": "#eff1f3",
                        "surface-container-low": "#f2f4f6",
                        "on-secondary-fixed": "#141d22",
                        "on-primary": "#ffffff",
                        "on-surface": "#191c1e",
                        "surface-tint": "#265ea8",
                        "on-tertiary-fixed": "#002114",
                        "surface-dim": "#d8dadc",
                        "secondary-container": "#dbe4eb",
                        "on-surface-variant": "#424751",
                        "inverse-primary": "#a9c7ff",
                        "primary-container": "#1a56a0",
                        "tertiary-fixed-dim": "#69dbaa",
                        "tertiary-container": "#006344",
                        "inverse-surface": "#2d3133",
                        "surface-variant": "#e0e3e5",
                        "primary-fixed": "#d6e3ff",
                        "outline-variant": "#c2c6d3",
                        "surface-bright": "#f7f9fb"
                    },
                    "borderRadius": {
                        "DEFAULT": "0.25rem",
                        "lg": "0.5rem",
                        "xl": "0.75rem",
                        "full": "9999px"
                    },
                    "spacing": {
                        "xs": "4px",
                        "sm": "8px",
                        "md": "16px",
                        "base": "4px",
                        "xl": "32px",
                        "lg": "24px",
                        "gutter": "16px",
                        "container-max": "1280px"
                    },
                    "fontFamily": {
                        "display-lg-mobile": ["Inter"],
                        "label-md": ["Inter"],
                        "label-sm": ["Inter"],
                        "body-md": ["Inter"],
                        "body-lg": ["Inter"],
                        "headline-md": ["Inter"],
                        "display-lg": ["Inter"],
                        "title-lg": ["Inter"]
                    },
                    "fontSize": {
                        "display-lg-mobile": ["28px", {"lineHeight": "34px", "fontWeight": "700"}],
                        "label-md": ["12px", {"lineHeight": "16px", "letterSpacing": "0.01em", "fontWeight": "600"}],
                        "label-sm": ["11px", {"lineHeight": "14px", "fontWeight": "500"}],
                        "body-md": ["14px", {"lineHeight": "20px", "fontWeight": "400"}],
                        "body-lg": ["16px", {"lineHeight": "24px", "fontWeight": "400"}],
                        "headline-md": ["24px", {"lineHeight": "32px", "fontWeight": "600"}],
                        "display-lg": ["36px", {"lineHeight": "44px", "letterSpacing": "-0.02em", "fontWeight": "700"}],
                        "title-lg": ["20px", {"lineHeight": "28px", "fontWeight": "600"}]
                    }
                },
            },
        }
    </script>
<style>
        body { font-family: 'Inter', sans-serif; background-color: #f7f9fb; }
        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
        .custom-shadow { box-shadow: 0 4px 12px rgba(26, 86, 160, 0.05); }
        .hide-scrollbar::-webkit-scrollbar { display: none; }
        .hide-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="text-on-surface">
<!-- Top Navigation Anchor -->
<header class="bg-primary dark:bg-primary-container text-on-primary dark:text-on-primary-container shadow-md w-full top-0 sticky z-50 flex items-center justify-between px-md h-16">
<div class="flex items-center gap-md">
<button class="material-symbols-outlined hover:bg-primary-container/20 transition-colors active:scale-95 duration-150 p-2 rounded-full">arrow_back</button>
<h1 class="font-title-lg text-title-lg">Récapitulatif</h1>
</div>
<div class="flex items-center gap-sm">
<span class="font-label-md text-label-md bg-white/20 px-3 py-1 rounded-full">Étape 4/4</span>
</div>
</header>
<main class="max-w-[1280px] mx-auto pb-32">
<!-- Hero Preview Section -->
<div class="relative w-full h-[280px] md:h-[450px] overflow-hidden mb-lg">
<div class="absolute inset-0 bg-cover bg-center" data-alt="High-end architectural photography of a luxury modern villa in Dakar. The exterior features clean white lines, large glass windows reflecting a sunset, and lush tropical greenery. The lighting is warm and golden, creating a premium real estate marketplace feel. Professional wide-angle shot, sharp detail, vibrant blue sky." style="background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuBJEX-CTgEgnOzbHWRYgJafh6troosxkpRrclID4ub1N43o2o5xT3j8GjK9Vod1GLL9XjpsDRMnU_r6MFA5gpazEXonMZmZkyr-3ItQhU_2JRwkvz45HzIakGQJ3-xLc591cx9X8HiO4J0NYUPtIrcEY3_GO5-8121DGFduF04alEd7BYXapKCF7xM8LHePIFl3oP56HaaSOdpiyh_gwwCuT7FoXb7nfijGdSYD5jI4vfk7BX887VrMwi_kIcmZf2cxS_BYIudIOb8')"></div>
<div class="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent"></div>
<div class="absolute bottom-md left-md text-white">
<span class="inline-block px-2 py-1 mb-2 bg-primary-container text-white text-[10px] font-bold uppercase tracking-wider rounded">Aperçu de la publication</span>
<h2 class="font-display-lg-mobile text-display-lg-mobile md:text-display-lg leading-tight">Villa de Luxe Plateau</h2>
<div class="flex items-center gap-xs mt-2">
<span class="material-symbols-outlined text-[18px]">location_on</span>
<span class="font-body-md text-body-md">Dakar, Sénégal</span>
</div>
</div>
<div class="absolute top-md right-md">
<div class="bg-white/90 backdrop-blur px-4 py-2 rounded-xl shadow-lg flex items-center gap-2">
<span class="material-symbols-outlined text-tertiary" style="font-variation-settings: 'FILL' 1;">verified</span>
<span class="text-primary font-bold text-title-lg">450.000.000 FCFA</span>
</div>
</div>
</div>
<div class="px-md grid grid-cols-1 lg:grid-cols-12 gap-lg">
<!-- Main Content Column -->
<div class="lg:col-span-8 space-y-lg">
<!-- Section: Informations -->
<section class="bg-white rounded-xl p-md custom-shadow">
<div class="flex justify-between items-center mb-md">
<h3 class="font-headline-md text-headline-md flex items-center gap-2">
<span class="material-symbols-outlined text-primary">info</span>
                            Informations
                        </h3>
<button class="text-primary font-bold hover:underline transition-all">Modifier</button>
</div>
<div class="grid grid-cols-2 md:grid-cols-4 gap-md border-b border-outline-variant pb-md mb-md">
<div>
<p class="text-on-surface-variant font-label-sm text-label-sm uppercase">Type</p>
<p class="font-body-lg text-body-lg text-on-surface font-semibold">Villa</p>
</div>
<div>
<p class="text-on-surface-variant font-label-sm text-label-sm uppercase">Surface</p>
<p class="font-body-lg text-body-lg text-on-surface font-semibold">450 m²</p>
</div>
<div>
<p class="text-on-surface-variant font-label-sm text-label-sm uppercase">Pièces</p>
<p class="font-body-lg text-body-lg text-on-surface font-semibold">6 pièces</p>
</div>
<div>
<p class="text-on-surface-variant font-label-sm text-label-sm uppercase">Chambres</p>
<p class="font-body-lg text-body-lg text-on-surface font-semibold">4 chambres</p>
</div>
</div>
<div class="space-y-md">
<div>
<p class="text-on-surface-variant font-label-sm text-label-sm uppercase mb-1">Description</p>
<p class="font-body-md text-body-md text-on-surface leading-relaxed">
                                Magnifique villa moderne située au cœur du Plateau. Architecture contemporaine avec des matériaux de haute qualité. Grand salon lumineux ouvrant sur une piscine privée, cuisine équipée de standard européen, et système de sécurité intelligent installé. Idéal pour une résidence de prestige.
                            </p>
</div>
<div>
<p class="text-on-surface-variant font-label-sm text-label-sm uppercase mb-1">Adresse complète</p>
<p class="font-body-md text-body-md text-on-surface">Rue 12, Quartier résidentiel du Plateau, Dakar - BP 1200</p>
</div>
</div>
</section>
<!-- Section: Médias -->
<section class="bg-white rounded-xl p-md custom-shadow">
<div class="flex justify-between items-center mb-md">
<h3 class="font-headline-md text-headline-md flex items-center gap-2">
<span class="material-symbols-outlined text-primary">image</span>
                            Médias
                        </h3>
<button class="text-primary font-bold hover:underline transition-all">Modifier</button>
</div>
<div class="grid grid-cols-2 md:grid-cols-4 gap-sm overflow-hidden rounded-xl">
<div class="aspect-square bg-cover bg-center rounded-lg" data-alt="Interior design of a luxury living room in a Dakar villa. Polished marble floors, floor-to-ceiling windows, designer minimalist furniture in neutral tones. Soft natural lighting from the morning sun. High-end lifestyle photography, clear, modern, and serene atmosphere." style="background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuDyHDjn11xMLEGdIh86Lkt0gVjEDzwO_uO2ZgwCBjVk7nz_6d_5_bsc9vClkJyrvOM-URuKWmAiBlka2MtzhX-uUJKZ9XXxNH2_CFGfO1IAOw1JeVGe1PRKXwMQ9wMTSZut8ibNKY6RwlbuwI6pOmt6BXZCaGvY271ASWTeQNKCURKdUR3ZnXwAStGnAsAh46torLMgLBx7t5bAtXPl8kGVIid101dhlasSHM3rKBQ4W-XrXcXYnSQC8VXTRLEGAH0JLxf6o-GreJg')"></div>
<div class="aspect-square bg-cover bg-center rounded-lg" data-alt="A modern professional kitchen with high-end stainless steel appliances, dark wood cabinets, and white quartz countertops. Elegant pendant lighting hangs over a central island. Clean, bright, and organized aesthetic for a premium real estate brochure." style="background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuDJ02WQtAPl0d9Krl9HMEyhroH_DyzkNA947rS0pxBdE7385deqpPDwjqSrk919YlOH-W_TXRWzeKLNzTADzXxExjTsQ3MJgvsAM9b3Lv7n5DmHxGQPDX95rE55QS8CUF6irSD0bOA3NqxU1jccmnJeiCQWnDWXkznadowNwUqAqBA8Zi2yj_leeOCDNV79Do3bmuldjnpsU_Ot7Z7aFYmUmd8PMD2W5WiP5cpuQCnu-4MxZm_n5wrDaikJHAqWebaAfiAFVLq62mU')"></div>
<div class="aspect-square bg-cover bg-center rounded-lg" data-alt="Outdoor swimming pool and patio area of a luxury residence at night. Strategic architectural lighting highlights the water and the surrounding palm trees. Soft blue glow from the pool creates a tranquil and expensive mood. High-contrast photography." style="background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuCNG_nlxAbaSCb45fFcRfBETCkoDPhgg13hrL4rzju0Vfs1rV20R0m7RNZuRzbZeBrLICefuoOHdmvUN7LjwjMoaIoLY8Cy1XRXyQ2Rfdw_ORQYHRmrYljSfdlicNki_K6g_5QcFZK25RIYemUAb5GMJbY3ylYZ9wp2K2fuc79V1__FZ4xge4pVyDwEhQNBdNPpHruUr3L2pgnbEKFkevGZILD9K0W8VR7Fk1lw1GpKoBB97rFwsGj8xy-Lr47EvyM4vhNdLdDH2Pw')"></div>
<div class="relative aspect-square bg-surface-container rounded-lg flex items-center justify-center">
<img class="absolute inset-0 w-full h-full object-cover rounded-lg" data-alt="The master bedroom of a luxury house with a large bed, plush white bedding, and a balcony view of the Dakar coastline. Minimalist decor with warm wooden accents and soft lighting. Cinematic atmosphere, focused on comfort and elegance." src="https://lh3.googleusercontent.com/aida-public/AB6AXuDqs_DKFXcMRfjHFQVDATHTjdZQxokx45iv4u9Q7drAt3X-mTkReWhkFbM5YUxfzVLhcQ-CVKWMlJi2RNvRfPdH2XE6VbX9SBl_JNUbs9KwhAPKreUpK3hLsQDekllNRrn2IQoPhWLN6oGKRBI4EesmRen2zyalsqYmd3MrNHTB5RfXusNdhvhvSAdUK64pHwSaYo-c5ENW-rzjK-59bbgbHMPK6j9PUNa32goka8HBj0KFofbq4gyoGweIBz0afQABB_ztmXTDOf4"/>
<div class="absolute inset-0 bg-black/40 flex items-center justify-center rounded-lg">
<span class="text-white font-bold">+8 photos</span>
</div>
</div>
</div>
</section>
<!-- Section: Documents -->
<section class="bg-white rounded-xl p-md custom-shadow">
<div class="flex justify-between items-center mb-md">
<h3 class="font-headline-md text-headline-md flex items-center gap-2">
<span class="material-symbols-outlined text-primary">description</span>
                            Documents joints
                        </h3>
<button class="text-primary font-bold hover:underline transition-all">Modifier</button>
</div>
<div class="space-y-sm">
<!-- Doc Item -->
<div class="flex items-center justify-between p-md border border-outline-variant rounded-xl bg-surface-container-low">
<div class="flex items-center gap-md">
<div class="w-10 h-10 bg-primary-container/10 flex items-center justify-center rounded-lg">
<span class="material-symbols-outlined text-primary">picture_as_pdf</span>
</div>
<div>
<p class="font-body-md text-body-md font-semibold">Titre_de_propriete_villa.pdf</p>
<p class="text-on-surface-variant text-[12px]">2.4 MB • Téléchargé le 12/05/2024</p>
</div>
</div>
<div class="flex items-center gap-1 text-tertiary">
<span class="material-symbols-outlined text-[18px]">check_circle</span>
<span class="font-label-sm text-label-sm">Prêt</span>
</div>
</div>
<!-- Doc Item -->
<div class="flex items-center justify-between p-md border border-outline-variant rounded-xl bg-surface-container-low">
<div class="flex items-center gap-md">
<div class="w-10 h-10 bg-primary-container/10 flex items-center justify-center rounded-lg">
<span class="material-symbols-outlined text-primary">badge</span>
</div>
<div>
<p class="font-body-md text-body-md font-semibold">CNI_Proprietaire_Recto.jpg</p>
<p class="text-on-surface-variant text-[12px]">1.1 MB • Téléchargé le 12/05/2024</p>
</div>
</div>
<div class="flex items-center gap-1 text-tertiary">
<span class="material-symbols-outlined text-[18px]">check_circle</span>
<span class="font-label-sm text-label-sm">Prêt</span>
</div>
</div>
<!-- Doc Item -->
<div class="flex items-center justify-between p-md border border-outline-variant rounded-xl bg-surface-container-low">
<div class="flex items-center gap-md">
<div class="w-10 h-10 bg-primary-container/10 flex items-center justify-center rounded-lg">
<span class="material-symbols-outlined text-primary">analytics</span>
</div>
<div>
<p class="font-body-md text-body-md font-semibold">Plan_Cadastral_Plateau.pdf</p>
<p class="text-on-surface-variant text-[12px]">4.8 MB • Téléchargé le 12/05/2024</p>
</div>
</div>
<div class="flex items-center gap-1 text-tertiary">
<span class="material-symbols-outlined text-[18px]">check_circle</span>
<span class="font-label-sm text-label-sm">Prêt</span>
</div>
</div>
</div>
</section>
</div>
<!-- Side Card: Information & Security -->
<div class="lg:col-span-4">
<div class="sticky top-24 space-y-md">
<div class="bg-primary-container text-white p-md rounded-xl custom-shadow">
<h4 class="font-title-lg text-title-lg mb-sm">Dernière vérification</h4>
<p class="text-body-md mb-md opacity-90">
                            Veuillez vous assurer que toutes les informations fournies sont exactes et conformes aux documents officiels. Toute fausse déclaration entraînera le rejet immédiat de l'annonce.
                        </p>
<div class="flex flex-col gap-2">
<div class="flex items-center gap-2">
<span class="material-symbols-outlined text-tertiary-fixed">lock</span>
<span class="text-sm">Données sécurisées SSL</span>
</div>
<div class="flex items-center gap-2">
<span class="material-symbols-outlined text-tertiary-fixed">visibility</span>
<span class="text-sm">Examen humain par nos agents</span>
</div>
</div>
</div>
<div class="bg-surface-container-high border border-outline-variant p-md rounded-xl">
<div class="flex items-center gap-md mb-2">
<span class="material-symbols-outlined text-primary text-[32px]">schedule</span>
<div>
<h4 class="font-semibold text-body-lg">Délai de traitement</h4>
<p class="text-body-md text-on-surface-variant">24h à 48h ouvrées</p>
</div>
</div>
<p class="text-[12px] text-on-surface-variant mt-2 border-t border-outline-variant pt-2">
                            Note : Vous recevrez une notification par email dès que votre annonce sera validée ou si des modifications sont nécessaires.
                        </p>
</div>
</div>
</div>
</div>
</main>
<!-- Bottom Action Bar -->
<footer class="fixed bottom-0 left-0 w-full bg-white border-t border-outline-variant p-md flex flex-col items-center gap-2 z-50">
<button class="w-full max-w-md h-14 bg-primary text-on-primary font-bold rounded-xl flex items-center justify-center gap-2 hover:bg-primary-container transition-all active:scale-95 shadow-lg">
<span>Soumettre pour vérification</span>
<span class="material-symbols-outlined">send</span>
</button>
<p class="text-[11px] text-on-surface-variant font-medium">En publiant, vous acceptez nos Conditions Générales de Vente.</p>
</footer>
<!-- Mobile Navigation Suppressed for Focus Journey as per instructions -->
<script>
        // Micro-interactions
        document.querySelectorAll('button').forEach(btn => {
            btn.addEventListener('click', function(e) {
                // Simple ripple effect visual feedback
                let ripple = document.createElement('span');
                ripple.classList.add('absolute', 'bg-white/30', 'rounded-full', 'animate-ping');
                ripple.style.width = '20px';
                ripple.style.height = '20px';
                this.appendChild(ripple);
                setTimeout(() => ripple.remove(), 400);
            });
        });
    </script>
</body></html>
  <!DOCTYPE html>

<html lang="fr"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>RealEstate Pro - Publication de Bien (Étape 3)</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
      tailwind.config = {
        darkMode: "class",
        theme: {
          extend: {
            "colors": {
                    "on-primary-fixed": "#001b3d",
                    "on-tertiary-fixed-variant": "#005138",
                    "on-error": "#ffffff",
                    "tertiary": "#004931",
                    "surface-container": "#eceef0",
                    "primary-fixed-dim": "#a9c7ff",
                    "primary": "#003e7e",
                    "surface-container-lowest": "#ffffff",
                    "on-primary-container": "#b3cdff",
                    "surface-container-high": "#e6e8ea",
                    "surface-container-highest": "#e0e3e5",
                    "background": "#f7f9fb",
                    "surface": "#f7f9fb",
                    "on-tertiary": "#ffffff",
                    "on-secondary": "#ffffff",
                    "on-background": "#191c1e",
                    "on-primary-fixed-variant": "#00468c",
                    "error-container": "#ffdad6",
                    "secondary-fixed-dim": "#bfc8ce",
                    "on-tertiary-container": "#6fe1af",
                    "on-secondary-container": "#5d666c",
                    "outline": "#737782",
                    "on-error-container": "#93000a",
                    "on-secondary-fixed-variant": "#3f484e",
                    "error": "#ba1a1a",
                    "secondary-fixed": "#dbe4eb",
                    "tertiary-fixed": "#86f8c5",
                    "secondary": "#576065",
                    "inverse-on-surface": "#eff1f3",
                    "surface-container-low": "#f2f4f6",
                    "on-secondary-fixed": "#141d22",
                    "on-primary": "#ffffff",
                    "on-surface": "#191c1e",
                    "surface-tint": "#265ea8",
                    "on-tertiary-fixed": "#002114",
                    "surface-dim": "#d8dadc",
                    "secondary-container": "#dbe4eb",
                    "on-surface-variant": "#424751",
                    "inverse-primary": "#a9c7ff",
                    "primary-container": "#1a56a0",
                    "tertiary-fixed-dim": "#69dbaa",
                    "tertiary-container": "#006344",
                    "inverse-surface": "#2d3133",
                    "surface-variant": "#e0e3e5",
                    "primary-fixed": "#d6e3ff",
                    "outline-variant": "#c2c6d3",
                    "surface-bright": "#f7f9fb"
            },
            "borderRadius": {
                    "DEFAULT": "0.25rem",
                    "lg": "0.5rem",
                    "xl": "0.75rem",
                    "full": "9999px"
            },
            "spacing": {
                    "xs": "4px",
                    "sm": "8px",
                    "md": "16px",
                    "base": "4px",
                    "xl": "32px",
                    "lg": "24px",
                    "gutter": "16px",
                    "container-max": "1280px"
            },
            "fontFamily": {
                    "display-lg-mobile": ["Inter"],
                    "label-md": ["Inter"],
                    "label-sm": ["Inter"],
                    "body-md": ["Inter"],
                    "body-lg": ["Inter"],
                    "headline-md": ["Inter"],
                    "display-lg": ["Inter"],
                    "title-lg": ["Inter"]
            },
            "fontSize": {
                    "display-lg-mobile": ["28px", {"lineHeight": "34px", "fontWeight": "700"}],
                    "label-md": ["12px", {"lineHeight": "16px", "letterSpacing": "0.01em", "fontWeight": "600"}],
                    "label-sm": ["11px", {"lineHeight": "14px", "fontWeight": "500"}],
                    "body-md": ["14px", {"lineHeight": "20px", "fontWeight": "400"}],
                    "body-lg": ["16px", {"lineHeight": "24px", "fontWeight": "400"}],
                    "headline-md": ["24px", {"lineHeight": "32px", "fontWeight": "600"}],
                    "display-lg": ["36px", {"lineHeight": "44px", "letterSpacing": "-0.02em", "fontWeight": "700"}],
                    "title-lg": ["20px", {"lineHeight": "28px", "fontWeight": "600"}]
            }
          },
        },
      }
    </script>
<style>
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        .step-progress-active {
            background: linear-gradient(90deg, #1a56a0 0%, #a9c7ff 100%);
        }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-background text-on-background font-body-md text-body-md min-h-screen flex flex-col">
<!-- TopAppBar -->
<header class="w-full top-0 sticky bg-primary shadow-md flex items-center justify-between px-md h-16 w-full z-50">
<div class="flex items-center gap-md">
<button class="hover:bg-primary-container/20 transition-colors active:scale-95 duration-150 p-sm rounded-full">
<span class="material-symbols-outlined text-on-primary">arrow_back</span>
</button>
<h1 class="font-display-lg-mobile text-display-lg-mobile font-bold text-on-primary">RealEstate Pro</h1>
</div>
<div class="flex items-center gap-md">
<div class="hidden md:flex gap-sm">
<span class="text-on-primary font-bold">Publier</span>
</div>
<div class="w-10 h-10 rounded-full bg-primary-fixed overflow-hidden flex items-center justify-center">
<img class="w-full h-full object-cover" data-alt="A close-up professional profile portrait of a modern real estate agent, shot in a bright studio with soft lighting. The aesthetic is clean and corporate, featuring a neutral background that complements the primary blue and white design system of a premium marketplace. High resolution, sharp focus, professional attire, approachable friendly expression." src="https://lh3.googleusercontent.com/aida-public/AB6AXuAEsHuVNVbS3RGWjrKzu4dFgFC4-3RLtjXe7upY1snKqnaaQoGaAwag2vi0Cpp0Sc1R8ok4uEl0UNugcc70FoDeQstmekkxo2KGcM_tGMpY0eHo2y3U2kH8YdQNm_juc4hUDST5rsmAE26N5MzJEW1sqqBybIeDUQfzibrm1s7a3dbrQMjJ9zKvEZKudywSkARZv4MpCLJkFMHZaQjale9GqeOKWWHWOmhKqL7D5wsau8_hKN5d1H1jSyX_QMsxLw4skrCZNaW0cuI"/>
</div>
</div>
</header>
<main class="flex-grow flex flex-col items-center p-md max-w-container-max mx-auto w-full md:pt-lg">
<!-- Progress Header -->
<section class="w-full max-w-2xl bg-primary-container rounded-xl p-lg mb-xl shadow-md text-on-primary-container">
<div class="flex justify-between items-end mb-md">
<div>
<h2 class="font-headline-md text-headline-md text-on-primary">Documents justificatifs</h2>
<p class="font-body-md text-body-md opacity-90 text-on-primary">Étape 3 sur 4</p>
</div>
<div class="text-right">
<span class="font-title-lg text-title-lg text-on-primary">75%</span>
</div>
</div>
<div class="w-full bg-white/20 h-2 rounded-full overflow-hidden">
<div class="h-full bg-on-primary-container w-[75%] transition-all duration-700 ease-out"></div>
</div>
</section>
<!-- Document List -->
<section class="w-full max-w-2xl flex flex-col gap-md">
<!-- Document 1: Titre foncier -->
<div class="bg-white p-md rounded-xl shadow-[0_4px_12px_rgba(26,86,160,0.05)] border border-outline-variant/30 flex items-center justify-between hover:shadow-[0_6px_16px_rgba(26,86,160,0.1)] transition-all duration-200">
<div class="flex items-center gap-md">
<div class="w-12 h-12 bg-primary-fixed/30 rounded-lg flex items-center justify-center">
<span class="material-symbols-outlined text-primary text-[28px]">description</span>
</div>
<div class="flex flex-col">
<h3 class="font-body-lg text-body-lg font-semibold text-on-background">Titre foncier / Acte de propriété</h3>
<div class="flex items-center gap-sm mt-1">
<span class="px-2 py-0.5 rounded-full bg-secondary-container text-on-secondary-container text-[11px] font-bold uppercase tracking-wider">À fournir</span>
</div>
</div>
</div>
<button class="w-10 h-10 rounded-lg bg-primary text-on-primary flex items-center justify-center hover:bg-primary-container transition-colors active:scale-95">
<span class="material-symbols-outlined">upload</span>
</button>
</div>
<!-- Document 2: Pièce d'identité (Validated) -->
<div class="bg-white p-md rounded-xl shadow-[0_4px_12px_rgba(26,86,160,0.05)] border border-outline-variant/30 flex items-center justify-between opacity-95">
<div class="flex items-center gap-md">
<div class="w-12 h-12 bg-tertiary-fixed/30 rounded-lg flex items-center justify-center">
<span class="material-symbols-outlined text-tertiary text-[28px]">badge</span>
</div>
<div class="flex flex-col">
<h3 class="font-body-lg text-body-lg font-semibold text-on-background">Pièce d'identité du propriétaire</h3>
<div class="flex items-center gap-sm mt-1">
<span class="px-2 py-0.5 rounded-full bg-tertiary-container text-on-tertiary-container text-[11px] font-bold uppercase tracking-wider flex items-center gap-1">
<span class="material-symbols-outlined text-[12px]" style="font-variation-settings: 'FILL' 1;">check_circle</span>
                                Validé
                            </span>
</div>
</div>
</div>
<button class="w-10 h-10 rounded-lg border border-outline-variant text-outline flex items-center justify-center cursor-not-allowed">
<span class="material-symbols-outlined">description</span>
</button>
</div>
<!-- Document 3: Plan cadastral -->
<div class="bg-white p-md rounded-xl shadow-[0_4px_12px_rgba(26,86,160,0.05)] border border-outline-variant/30 flex items-center justify-between hover:shadow-[0_6px_16px_rgba(26,86,160,0.1)] transition-all duration-200">
<div class="flex items-center gap-md">
<div class="w-12 h-12 bg-primary-fixed/30 rounded-lg flex items-center justify-center">
<span class="material-symbols-outlined text-primary text-[28px]">map</span>
</div>
<div class="flex flex-col">
<h3 class="font-body-lg text-body-lg font-semibold text-on-background">Plan cadastral <span class="text-on-surface-variant font-normal text-sm">(si terrain, optionnel)</span></h3>
<div class="flex items-center gap-sm mt-1">
<span class="px-2 py-0.5 rounded-full bg-secondary-container text-on-secondary-container text-[11px] font-bold uppercase tracking-wider">À fournir</span>
</div>
</div>
</div>
<button class="w-10 h-10 rounded-lg bg-primary text-on-primary flex items-center justify-center hover:bg-primary-container transition-colors active:scale-95">
<span class="material-symbols-outlined">upload</span>
</button>
</div>
<!-- Admin Note Card -->
<div class="mt-lg p-md bg-surface-container-low rounded-xl border-l-4 border-primary flex items-start gap-md">
<span class="material-symbols-outlined text-primary">info</span>
<p class="font-body-md text-body-md text-on-surface-variant">
                    Votre bien sera examiné sous <span class="font-bold text-on-surface">48-72h</span> par notre équipe après la soumission finale de votre dossier.
                </p>
</div>
</section>
<!-- Navigation Buttons -->
<section class="w-full max-w-2xl flex gap-md mt-xl mb-xl">
<button class="flex-1 py-4 px-md rounded-lg border-2 border-primary text-primary font-bold font-title-lg hover:bg-primary/5 transition-all active:scale-[0.98]">
                Retour
            </button>
<button class="flex-2 w-[60%] py-4 px-md rounded-lg bg-primary text-on-primary font-bold font-title-lg shadow-lg hover:bg-primary-container transition-all active:scale-[0.98] flex items-center justify-center gap-sm">
                Suivant
                <span class="material-symbols-outlined">chevron_right</span>
</button>
</section>
</main>
<!-- BottomNavBar -->
<nav class="md:hidden fixed bottom-0 left-0 w-full flex justify-around items-center h-16 bg-surface px-sm pb-safe border-t border-outline-variant shadow-sm z-50">
<button class="flex flex-col items-center justify-center text-on-surface-variant transition-all duration-200 active:scale-90">
<span class="material-symbols-outlined">dashboard</span>
<span class="font-label-md text-label-md">Dashboard</span>
</button>
<button class="flex flex-col items-center justify-center bg-primary-container text-on-primary-container rounded-full px-4 py-1 transition-all duration-200 active:scale-90">
<span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1;">add_circle</span>
<span class="font-label-md text-label-md">Publier</span>
</button>
<button class="flex flex-col items-center justify-center text-on-surface-variant transition-all duration-200 active:scale-90">
<span class="material-symbols-outlined">home_work</span>
<span class="font-label-md text-label-md">Mes Biens</span>
</button>
<button class="flex flex-col items-center justify-center text-on-surface-variant transition-all duration-200 active:scale-90">
<span class="material-symbols-outlined">person</span>
<span class="font-label-md text-label-md">Profil</span>
</button>
</nav>
<script>
        // Simple micro-interaction for upload buttons
        document.querySelectorAll('button').forEach(btn => {
            btn.addEventListener('click', function() {
                if(this.querySelector('span')?.textContent === 'upload') {
                    const originalIcon = this.querySelector('span').textContent;
                    this.querySelector('span').textContent = 'sync';
                    this.querySelector('span').classList.add('animate-spin');
                    
                    setTimeout(() => {
                        this.querySelector('span').textContent = 'check';
                        this.querySelector('span').classList.remove('animate-spin');
                        this.classList.remove('bg-primary');
                        this.classList.add('bg-tertiary');
                    }, 1500);
                }
            });
        });
    </script>
</body></html>




<!DOCTYPE html>

<html class="light" lang="fr"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Bien en attente de vérification - RealEstate Pro</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #f7f9fb;
        }
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
            vertical-align: middle;
        }
        @keyframes pulse-blue {
            0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(26, 86, 160, 0.7); }
            70% { transform: scale(1); box-shadow: 0 0 0 10px rgba(26, 86, 160, 0); }
            100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(26, 86, 160, 0); }
        }
        .animate-pulse-status {
            animation: pulse-blue 2s infinite;
        }
        .hourglass-float {
            animation: float 3s ease-in-out infinite;
        }
        @keyframes float {
            0% { transform: translateY(0px); }
            50% { transform: translateY(-10px); }
            100% { transform: translateY(0px); }
        }
        .glass-card {
            background: rgba(255, 255, 255, 0.8);
            backdrop-filter: blur(8px);
            border: 1px solid rgba(255, 255, 255, 0.3);
        }
    </style>
<script id="tailwind-config">
        tailwind.config = {
          darkMode: "class",
          theme: {
            extend: {
              "colors": {
                      "on-primary-fixed": "#001b3d",
                      "on-tertiary-fixed-variant": "#005138",
                      "on-error": "#ffffff",
                      "tertiary": "#004931",
                      "surface-container": "#eceef0",
                      "primary-fixed-dim": "#a9c7ff",
                      "primary": "#003e7e",
                      "surface-container-lowest": "#ffffff",
                      "on-primary-container": "#b3cdff",
                      "surface-container-high": "#e6e8ea",
                      "surface-container-highest": "#e0e3e5",
                      "background": "#f7f9fb",
                      "surface": "#f7f9fb",
                      "on-tertiary": "#ffffff",
                      "on-secondary": "#ffffff",
                      "on-background": "#191c1e",
                      "on-primary-fixed-variant": "#00468c",
                      "error-container": "#ffdad6",
                      "secondary-fixed-dim": "#bfc8ce",
                      "on-tertiary-container": "#6fe1af",
                      "on-secondary-container": "#5d666c",
                      "outline": "#737782",
                      "on-error-container": "#93000a",
                      "on-secondary-fixed-variant": "#3f484e",
                      "error": "#ba1a1a",
                      "secondary-fixed": "#dbe4eb",
                      "tertiary-fixed": "#86f8c5",
                      "secondary": "#576065",
                      "inverse-on-surface": "#eff1f3",
                      "surface-container-low": "#f2f4f6",
                      "on-secondary-fixed": "#141d22",
                      "on-primary": "#ffffff",
                      "on-surface": "#191c1e",
                      "surface-tint": "#265ea8",
                      "on-tertiary-fixed": "#002114",
                      "surface-dim": "#d8dadc",
                      "secondary-container": "#dbe4eb",
                      "on-surface-variant": "#424751",
                      "inverse-primary": "#a9c7ff",
                      "primary-container": "#1a56a0",
                      "tertiary-fixed-dim": "#69dbaa",
                      "tertiary-container": "#006344",
                      "inverse-surface": "#2d3133",
                      "surface-variant": "#e0e3e5",
                      "primary-fixed": "#d6e3ff",
                      "outline-variant": "#c2c6d3",
                      "surface-bright": "#f7f9fb"
              },
              "borderRadius": {
                      "DEFAULT": "0.25rem",
                      "lg": "0.5rem",
                      "xl": "0.75rem",
                      "full": "9999px"
              },
              "spacing": {
                      "xs": "4px",
                      "sm": "8px",
                      "md": "16px",
                      "base": "4px",
                      "xl": "32px",
                      "lg": "24px",
                      "gutter": "16px",
                      "container-max": "1280px"
              },
              "fontFamily": {
                      "display-lg-mobile": ["Inter"],
                      "label-md": ["Inter"],
                      "label-sm": ["Inter"],
                      "body-md": ["Inter"],
                      "body-lg": ["Inter"],
                      "headline-md": ["Inter"],
                      "display-lg": ["Inter"],
                      "title-lg": ["Inter"]
              },
              "fontSize": {
                      "display-lg-mobile": ["28px", { "lineHeight": "34px", "fontWeight": "700" }],
                      "label-md": ["12px", { "lineHeight": "16px", "letterSpacing": "0.01em", "fontWeight": "600" }],
                      "label-sm": ["11px", { "lineHeight": "14px", "fontWeight": "500" }],
                      "body-md": ["14px", { "lineHeight": "20px", "fontWeight": "400" }],
                      "body-lg": ["16px", { "lineHeight": "24px", "fontWeight": "400" }],
                      "headline-md": ["24px", { "lineHeight": "32px", "fontWeight": "600" }],
                      "display-lg": ["36px", { "lineHeight": "44px", "letterSpacing": "-0.02em", "fontWeight": "700" }],
                      "title-lg": ["20px", { "lineHeight": "28px", "fontWeight": "600" }]
              }
            },
          },
        }
    </script>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-surface">
<!-- TopAppBar -->
<header class="w-full top-0 sticky bg-primary dark:bg-primary-container text-on-primary dark:text-on-primary-container shadow-md z-50 flex items-center justify-between px-md h-16">
<div class="flex items-center gap-md">
<button class="hover:bg-primary-container/20 transition-colors p-2 rounded-full active:scale-95 duration-150">
<span class="material-symbols-outlined">menu</span>
</button>
<h1 class="font-display-lg-mobile text-display-lg-mobile font-bold text-on-primary">RealEstate Pro</h1>
</div>
<div class="flex items-center gap-md">
<div class="w-10 h-10 rounded-full overflow-hidden bg-surface-container-high border-2 border-on-primary/20">
<img class="w-full h-full object-cover" data-alt="A professional user profile avatar for a premium real estate application. The image features a friendly, middle-aged real estate professional with a warm smile, wearing business casual attire. The background is a soft-focus, modern architectural office space with bright, natural lighting. The visual style is crisp and high-definition, reflecting trust and reliability." src="https://lh3.googleusercontent.com/aida-public/AB6AXuD6Us5wfx91mowIyot1FG1G7CRaj1WGtMShD6pG9GF635yziAd1_C9z6KTZc-Mfsd4FR3hm5pjztHaFWiGjdjY2zuCUa9I_i1Vvj_6ukz45mf5BHCt7b1GkQpK8aAsuf_sPRpryrhDi0wa97bGNoN2uXVAoBiBBS-zS_WgBMSZFkg9Nw2HdfpPTMl7qpjLeO-mkJYEXFaCUr0CcgoHMCpILGEH1hc2TS17ZuLsWNoARWGND81dC9JljbG0y-bgt7YGAjAQQljLmQ5w"/>
</div>
</div>
</header>
<main class="max-w-screen-md mx-auto px-md py-xl mb-24">
<!-- Main Content Area -->
<div class="flex flex-col items-center text-center space-y-lg">
<!-- Animated Illustration Area -->
<div class="relative w-48 h-48 flex items-center justify-center bg-white rounded-full shadow-sm">
<div class="hourglass-float text-primary flex flex-col items-center">
<span class="material-symbols-outlined !text-7xl" style="font-variation-settings: 'FILL' 1;">hourglass_empty</span>
</div>
<!-- Orbiting decoration -->
<div class="absolute inset-0 border-2 border-dashed border-primary/20 rounded-full animate-[spin_10s_linear_infinite]"></div>
</div>
<!-- Title & Subtitle -->
<div class="space-y-sm">
<h2 class="font-display-lg-mobile text-display-lg-mobile font-bold text-primary">En cours de vérification</h2>
<p class="font-body-md text-body-md text-on-surface-variant max-w-sm mx-auto">
                    Nos experts analysent les documents et informations fournis pour assurer la qualité de notre service.
                </p>
</div>
<!-- Horizontal Timeline -->
<div class="w-full py-lg">
<div class="relative flex items-center justify-between w-full">
<!-- Background Line -->
<div class="absolute top-1/2 left-0 w-full h-1 bg-surface-container-highest -translate-y-1/2 rounded-full"></div>
<!-- Active Progress Line -->
<div class="absolute top-1/2 left-0 w-[41%] h-1 bg-primary -translate-y-1/2 rounded-full transition-all duration-1000"></div>
<!-- Steps -->
<div class="relative z-10 flex flex-col items-center w-1/4">
<div class="w-8 h-8 rounded-full bg-primary text-on-primary flex items-center justify-center shadow-md">
<span class="material-symbols-outlined !text-sm">check</span>
</div>
<span class="mt-2 font-label-md text-label-md text-primary">Soumis</span>
</div>
<div class="relative z-10 flex flex-col items-center w-1/4">
<div class="w-10 h-10 rounded-full bg-primary-container text-on-primary-container flex items-center justify-center shadow-lg animate-pulse-status ring-4 ring-white">
<span class="material-symbols-outlined !text-base">search</span>
</div>
<span class="mt-2 font-label-md text-label-md text-primary font-bold">Vérification</span>
</div>
<div class="relative z-10 flex flex-col items-center w-1/4">
<div class="w-8 h-8 rounded-full bg-surface-container-highest text-on-surface-variant flex items-center justify-center">
<span class="material-symbols-outlined !text-sm">calendar_month</span>
</div>
<span class="mt-2 font-label-md text-label-md text-on-surface-variant">Visite</span>
</div>
<div class="relative z-10 flex flex-col items-center w-1/4">
<div class="w-8 h-8 rounded-full bg-surface-container-highest text-on-surface-variant flex items-center justify-center">
<span class="material-symbols-outlined !text-sm">verified</span>
</div>
<span class="mt-2 font-label-md text-label-md text-on-surface-variant">Validé</span>
</div>
</div>
</div>
<!-- Compact Property Summary Card -->
<div class="w-full bg-surface-container-lowest p-md rounded-xl shadow-sm border border-outline-variant flex items-center gap-md">
<div class="w-24 h-24 rounded-lg overflow-hidden flex-shrink-0">
<img class="w-full h-full object-cover" data-alt="A luxury modern apartment interior featuring a spacious living room with floor-to-ceiling windows overlooking a serene city park. The decor is minimalist and elegant with a palette of soft whites, warm wood accents, and sophisticated blue textiles. Bright natural light floods the space, creating an airy and premium atmosphere consistent with a high-end real estate listing." src="https://lh3.googleusercontent.com/aida-public/AB6AXuCM6PkFOMAT4dGWSPDUfPSXIPXNlfQlQZOegPY3Q2NqqomeKZrnthjYv3kt54MzVwhtT-2SMlwUGxDhDKDIdwjel8w2z7q_R6_LtqHqBd5VzYjmh2XksO3TP-r3PFFPiq5nsP3qM_oygOmC1jZ51iASVBwRKJdu63QJsvpF7r7JsCT_XcwrS03oTnklzYXc728qtVRBY6ZZp2KBD21K2X8ni0-CkEwqwClFzFBtqaS6R_kSX7eDQEY3vqY4Btj0vnDIQsj9I7OSkHI"/>
</div>
<div class="text-left flex-1">
<div class="flex items-center gap-xs mb-1">
<span class="bg-tertiary-fixed text-on-tertiary-fixed-variant px-2 py-0.5 rounded-full font-label-sm text-label-sm">En attente</span>
</div>
<h3 class="font-title-lg text-title-lg text-on-background line-clamp-1">Appartement Haussmannien</h3>
<p class="font-body-md text-body-md text-on-surface-variant">Paris 8ème • 85m²</p>
<p class="font-bold text-primary mt-1">945 000 €</p>
</div>
</div>
<!-- Action Buttons -->
<div class="w-full grid grid-cols-1 md:grid-cols-2 gap-md pt-md">
<button class="w-full bg-primary text-on-primary py-4 rounded-lg font-title-lg flex items-center justify-center gap-sm shadow-md hover:bg-primary-container transition-all active:scale-95 duration-150">
<span class="material-symbols-outlined">track_changes</span>
                    Suivre le statut
                </button>
<button class="w-full border-2 border-primary text-primary py-4 rounded-lg font-title-lg flex items-center justify-center gap-sm hover:bg-primary/5 transition-all active:scale-95 duration-150">
<span class="material-symbols-outlined">add_circle</span>
                    Publier un autre bien
                </button>
</div>
<!-- Notification info note -->
<div class="w-full bg-secondary-fixed text-on-secondary-fixed-variant p-md rounded-lg flex items-start gap-md">
<span class="material-symbols-outlined text-primary mt-0.5">info</span>
<p class="font-body-md text-body-md text-left">
                    Vous recevrez une notification par <span class="font-bold">SMS</span> et <span class="font-bold">Email</span> dès que l'étape de vérification sera complétée. Habituellement sous 24-48h.
                </p>
</div>
</div>
</main>
<!-- Bottom Navigation -->
<nav class="fixed bottom-0 left-0 w-full flex justify-around items-center h-16 bg-surface px-sm pb-safe border-t border-outline-variant z-50">
<button class="flex flex-col items-center justify-center text-on-surface-variant hover:bg-surface-container-high transition-all p-2 rounded-lg">
<span class="material-symbols-outlined">dashboard</span>
<span class="font-label-md text-label-md">Dashboard</span>
</button>
<button class="flex flex-col items-center justify-center text-on-surface-variant hover:bg-surface-container-high transition-all p-2 rounded-lg">
<span class="material-symbols-outlined">add_circle</span>
<span class="font-label-md text-label-md">Publier</span>
</button>
<button class="flex flex-col items-center justify-center bg-primary-container text-on-primary-container rounded-full px-4 py-1 transition-all">
<span class="material-symbols-outlined">home_work</span>
<span class="font-label-md text-label-md">Mes Biens</span>
</button>
<button class="flex flex-col items-center justify-center text-on-surface-variant hover:bg-surface-container-high transition-all p-2 rounded-lg">
<span class="material-symbols-outlined">person</span>
<span class="font-label-md text-label-md">Profil</span>
</button>
</nav>
<script>
        // Micro-interaction for buttons
        document.querySelectorAll('button').forEach(button => {
            button.addEventListener('click', function(e) {
                let ripple = document.createElement('span');
                ripple.classList.add('ripple');
                this.appendChild(ripple);
                setTimeout(() => ripple.remove(), 600);
            });
        });
    </script>
</body></html>



<!DOCTYPE html>

<html class="light" lang="fr"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    "colors": {
                        "on-primary-fixed": "#001b3d",
                        "on-tertiary-fixed-variant": "#005138",
                        "on-error": "#ffffff",
                        "tertiary": "#004931",
                        "surface-container": "#eceef0",
                        "primary-fixed-dim": "#a9c7ff",
                        "primary": "#003e7e",
                        "surface-container-lowest": "#ffffff",
                        "on-primary-container": "#b3cdff",
                        "surface-container-high": "#e6e8ea",
                        "surface-container-highest": "#e0e3e5",
                        "background": "#f7f9fb",
                        "surface": "#f7f9fb",
                        "on-tertiary": "#ffffff",
                        "on-secondary": "#ffffff",
                        "on-background": "#191c1e",
                        "on-primary-fixed-variant": "#00468c",
                        "error-container": "#ffdad6",
                        "secondary-fixed-dim": "#bfc8ce",
                        "on-tertiary-container": "#6fe1af",
                        "on-secondary-container": "#5d666c",
                        "outline": "#737782",
                        "on-error-container": "#93000a",
                        "on-secondary-fixed-variant": "#3f484e",
                        "error": "#ba1a1a",
                        "secondary-fixed": "#dbe4eb",
                        "tertiary-fixed": "#86f8c5",
                        "secondary": "#576065",
                        "inverse-on-surface": "#eff1f3",
                        "surface-container-low": "#f2f4f6",
                        "on-secondary-fixed": "#141d22",
                        "on-primary": "#ffffff",
                        "on-surface": "#191c1e",
                        "surface-tint": "#265ea8",
                        "on-tertiary-fixed": "#002114",
                        "surface-dim": "#d8dadc",
                        "secondary-container": "#dbe4eb",
                        "on-surface-variant": "#424751",
                        "inverse-primary": "#a9c7ff",
                        "primary-container": "#1a56a0",
                        "tertiary-fixed-dim": "#69dbaa",
                        "tertiary-container": "#006344",
                        "inverse-surface": "#2d3133",
                        "surface-variant": "#e0e3e5",
                        "primary-fixed": "#d6e3ff",
                        "outline-variant": "#c2c6d3",
                        "surface-bright": "#f7f9fb"
                    },
                    "borderRadius": {
                        "DEFAULT": "0.25rem",
                        "lg": "0.5rem",
                        "xl": "0.75rem",
                        "full": "9999px"
                    },
                    "spacing": {
                        "xs": "4px",
                        "sm": "8px",
                        "md": "16px",
                        "base": "4px",
                        "xl": "32px",
                        "lg": "24px",
                        "gutter": "16px",
                        "container-max": "1280px"
                    },
                    "fontFamily": {
                        "display-lg-mobile": ["Inter"],
                        "label-md": ["Inter"],
                        "label-sm": ["Inter"],
                        "body-md": ["Inter"],
                        "body-lg": ["Inter"],
                        "headline-md": ["Inter"],
                        "display-lg": ["Inter"],
                        "title-lg": ["Inter"]
                    },
                    "fontSize": {
                        "display-lg-mobile": ["28px", {"lineHeight": "34px", "fontWeight": "700"}],
                        "label-md": ["12px", {"lineHeight": "16px", "letterSpacing": "0.01em", "fontWeight": "600"}],
                        "label-sm": ["11px", {"lineHeight": "14px", "fontWeight": "500"}],
                        "body-md": ["14px", {"lineHeight": "20px", "fontWeight": "400"}],
                        "body-lg": ["16px", {"lineHeight": "24px", "fontWeight": "400"}],
                        "headline-md": ["24px", {"lineHeight": "32px", "fontWeight": "600"}],
                        "display-lg": ["36px", {"lineHeight": "44px", "letterSpacing": "-0.02em", "fontWeight": "700"}],
                        "title-lg": ["20px", {"lineHeight": "28px", "fontWeight": "600"}]
                    }
                },
            },
        }
    </script>
<style>
        body {
            background-color: #f7f9fb;
            font-family: 'Inter', sans-serif;
            -webkit-tap-highlight-color: transparent;
        }
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        .active-pill {
            box-shadow: 0 4px 12px rgba(26, 86, 160, 0.15);
        }
        .custom-scroll-hide::-webkit-scrollbar {
            display: none;
        }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="text-on-surface">
<!-- TopAppBar -->
<header class="w-full top-0 sticky bg-primary dark:bg-primary-container text-on-primary dark:text-on-primary-container shadow-md z-50 flex items-center justify-between px-md h-16">
<div class="flex items-center gap-md">
<span class="material-symbols-outlined text-on-primary cursor-pointer active:scale-95 duration-150">menu</span>
<h1 class="font-display-lg-mobile text-display-lg-mobile font-bold text-on-primary">Mon Espace</h1>
</div>
<div class="flex items-center gap-md">
<div class="relative cursor-pointer active:scale-95 transition-transform">
<span class="material-symbols-outlined text-on-primary">notifications</span>
<span class="absolute top-0 right-0 w-2 h-2 bg-error rounded-full border-2 border-primary"></span>
</div>
<div class="w-10 h-10 rounded-full border-2 border-on-primary/20 overflow-hidden cursor-pointer active:scale-95 transition-transform">
<img class="w-full h-full object-cover" data-alt="A high-quality professional portrait of a smiling property owner in a modern business-casual attire, set against a blurred interior of a bright, contemporary real estate office with minimalist furniture and glass walls. The lighting is soft and flattering, emphasizing a trustworthy and premium corporate feel aligned with a blue and white color palette." src="https://lh3.googleusercontent.com/aida-public/AB6AXuDwYt-b2yGRvouACz5NZmvWIcvlyuHzVQrQhg83bJg5ovl6Jm-c18zPe7yo1TWJf_nyGK6hHyFFaPTKpziU1FApi0Ohtxhiywyw1KczVm9okNw3YFgrem-Xh1RQQMQDBx_wYPWl_KkuoKsg5z8Vnma6Gz7cPeR8MYqxWWVewVwpQ3XZtTLX8LMe3po3kKi2V4vst6VGvAk06asmInnREuVVDYp0r2DulbMTNkB6QW12Wdvlpg_qfXMh2p1n3ssh0X8d4EldV4g4FOA"/>
</div>
</div>
</header>
<main class="max-w-container-max mx-auto px-md py-lg mb-24 space-y-xl">
<!-- Section Client (Subtle Cards) -->
<section class="animate-in fade-in slide-in-from-bottom-4 duration-500">
<div class="bg-surface-container-lowest rounded-xl p-md shadow-[0_4px_12px_rgba(26,86,160,0.05)]">
<div class="flex overflow-x-auto gap-sm custom-scroll-hide pb-2">
<!-- Chip: Mes visites -->
<button class="flex items-center gap-sm bg-primary/10 text-primary px-md py-sm rounded-full whitespace-nowrap active:scale-95 transition-all">
<span class="material-symbols-outlined text-[20px]">calendar_today</span>
<span class="font-label-md text-label-md">Mes visites</span>
<span class="bg-primary text-on-primary px-2 py-0.5 rounded-full text-[10px] font-bold">3</span>
</button>
<!-- Chip: Mes réservations -->
<button class="flex items-center gap-sm bg-surface-container-high text-on-surface-variant px-md py-sm rounded-full whitespace-nowrap active:scale-95 transition-all">
<span class="material-symbols-outlined text-[20px]">event_available</span>
<span class="font-label-md text-label-md">Mes réservations</span>
<span class="bg-outline text-on-primary px-2 py-0.5 rounded-full text-[10px] font-bold">1</span>
</button>
<!-- Chip: Favoris -->
<button class="flex items-center gap-sm bg-surface-container-high text-on-surface-variant px-md py-sm rounded-full whitespace-nowrap active:scale-95 transition-all">
<span class="material-symbols-outlined text-[20px]" style="font-variation-settings: 'FILL' 1;">favorite</span>
<span class="font-label-md text-label-md">Favoris</span>
<span class="bg-outline text-on-primary px-2 py-0.5 rounded-full text-[10px] font-bold">12</span>
</button>
</div>
</div>
</section>
<!-- Section Propriétaire (Highlighted) -->
<section class="space-y-md animate-in fade-in slide-in-from-bottom-6 duration-700">
<div class="flex items-center justify-between">
<h2 class="font-headline-md text-headline-md text-primary">Espace Propriétaire</h2>
<button class="text-primary font-label-md text-label-md flex items-center gap-1">
                    Voir les stats <span class="material-symbols-outlined text-sm">chevron_right</span>
</button>
</div>
<!-- KPI Mini-Cards -->
<div class="grid grid-cols-3 gap-sm">
<div class="bg-primary-container text-on-primary-container p-md rounded-xl shadow-sm flex flex-col justify-between h-24">
<span class="material-symbols-outlined text-on-primary-container/70">home</span>
<div>
<div class="text-[20px] font-bold leading-none">08</div>
<div class="text-[10px] opacity-80 uppercase tracking-wider font-semibold">Biens actifs</div>
</div>
</div>
<div class="bg-surface-container-lowest border border-outline-variant/30 p-md rounded-xl shadow-sm flex flex-col justify-between h-24">
<span class="material-symbols-outlined text-primary">group</span>
<div>
<div class="text-[20px] font-bold text-on-surface leading-none">124</div>
<div class="text-[10px] text-on-surface-variant uppercase tracking-wider font-semibold">Visites reçues</div>
</div>
</div>
<div class="bg-surface-container-lowest border border-outline-variant/30 p-md rounded-xl shadow-sm flex flex-col justify-between h-24">
<span class="material-symbols-outlined text-tertiary">payments</span>
<div>
<div class="text-[20px] font-bold text-on-surface leading-none">2.4k€</div>
<div class="text-[10px] text-on-surface-variant uppercase tracking-wider font-semibold">Revenus mois</div>
</div>
</div>
</div>
<!-- Horizontal Property Cards -->
<div class="space-y-sm">
<!-- Card 1 -->
<div class="bg-surface-container-lowest rounded-xl p-sm flex gap-md shadow-[0_4px_12px_rgba(26,86,160,0.05)] border border-transparent hover:border-primary/20 transition-colors cursor-pointer group">
<div class="relative w-24 h-24 rounded-lg overflow-hidden flex-shrink-0">
<img class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" data-alt="A professional architectural photograph of a bright, high-end modern studio apartment in Paris. The interior features oak wood floors, minimalist furniture, and large windows with soft natural sunlight streaming in. The image is clean and bright, showcasing luxury real estate with a fresh, airy atmosphere in light-mode tones." src="https://lh3.googleusercontent.com/aida-public/AB6AXuBqP7CWZi_I4aanhm-qN5Z9_UtRRHYtwHVadQhcYlKfKLxO6B0_ZalZ_rrrMOeX02oVklmJWxtMtEJUPyvfQ3dh9CCSzPAh7pu6HGInsXzWRPYpYmL3-GZ4jqRvcinnun9vJqWtoYvkEyRqpO2CJmWFXsMFM8UvD34l8VhDNUfd4Ca9yXzhunl7bEc5NJXKCjRX2oOQjCdmTqF0DlwwSpNfWrzvMrih193G74jmFdfdlQa_QvmH5GfrQZVgsSbggalJRBB90NatI2M"/>
<span class="absolute top-1 left-1 bg-tertiary-fixed text-on-tertiary-fixed text-[9px] px-1.5 py-0.5 rounded font-bold uppercase">Loué</span>
</div>
<div class="flex flex-col justify-between py-1 flex-grow">
<div>
<h3 class="font-title-lg text-body-lg text-on-surface font-semibold line-clamp-1">Studio Lumineux - Paris 15</h3>
<div class="flex items-center gap-1 text-on-surface-variant text-label-sm">
<span class="material-symbols-outlined text-[14px]">location_on</span>
<span>Rue de Vaugirard</span>
</div>
</div>
<div class="flex items-center justify-between">
<div class="flex items-center gap-3">
<div class="flex items-center gap-1 text-primary">
<span class="material-symbols-outlined text-[16px]">visibility</span>
<span class="text-label-md font-bold">1.2k</span>
</div>
<div class="flex items-center gap-1 text-on-surface-variant">
<span class="material-symbols-outlined text-[16px]">chat_bubble</span>
<span class="text-label-md">14</span>
</div>
</div>
<span class="font-title-lg text-primary text-body-lg font-bold">850€<span class="text-xs font-normal">/mois</span></span>
</div>
</div>
</div>
<!-- Card 2 -->
<div class="bg-surface-container-lowest rounded-xl p-sm flex gap-md shadow-[0_4px_12px_rgba(26,86,160,0.05)] border border-transparent hover:border-primary/20 transition-colors cursor-pointer group">
<div class="relative w-24 h-24 rounded-lg overflow-hidden flex-shrink-0">
<img class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" data-alt="An elegant wide-angle shot of a modern 2-bedroom family apartment with a spacious balcony overlooking a city park. Contemporary interior design with soft grey tones, designer lighting, and premium finishes. The scene is bathed in golden hour light, creating a warm, inviting, and professional real estate presentation." src="https://lh3.googleusercontent.com/aida-public/AB6AXuC-wfhxpxmGQzn1w5xO15Wi5EUFQ6-oz1nAqqbqDbb-NhrzchJIDjgfJzFMEN44X5O-lOmKS4dZ3qfI41BuMOmySBHBaFGss1x-g_BHHDVQCnfdyVygLJpX7HmKdDHX1IvcQuZ5NG1jIY1j9rlMYbF_BVoOS3f1T0Hv-Z_QpNteKJ6o8r7075FT7QbDl_ACdImd2WA00zOKi753K2nlzLJqRX8qFKH0Ah2tDMPoXBgnYI9JnlZnb2vwwP9U3ie6VpfXkfQyvAMe9Jo"/>
<span class="absolute top-1 left-1 bg-primary text-on-primary text-[9px] px-1.5 py-0.5 rounded font-bold uppercase">Public</span>
</div>
<div class="flex flex-col justify-between py-1 flex-grow">
<div>
<h3 class="font-title-lg text-body-lg text-on-surface font-semibold line-clamp-1">T3 Moderne Balcon - Lyon 6</h3>
<div class="flex items-center gap-1 text-on-surface-variant text-label-sm">
<span class="material-symbols-outlined text-[14px]">location_on</span>
<span>Quai Charles de Gaulle</span>
</div>
</div>
<div class="flex items-center justify-between">
<div class="flex items-center gap-3">
<div class="flex items-center gap-1 text-primary">
<span class="material-symbols-outlined text-[16px]">visibility</span>
<span class="text-label-md font-bold">452</span>
</div>
<div class="flex items-center gap-1 text-on-surface-variant">
<span class="material-symbols-outlined text-[16px]">chat_bubble</span>
<span class="text-label-md">5</span>
</div>
</div>
<span class="font-title-lg text-primary text-body-lg font-bold">1,250€<span class="text-xs font-normal">/mois</span></span>
</div>
</div>
</div>
<!-- Card 3 -->
<div class="bg-surface-container-lowest rounded-xl p-sm flex gap-md shadow-[0_4px_12px_rgba(26,86,160,0.05)] border border-transparent hover:border-primary/20 transition-colors cursor-pointer group">
<div class="relative w-24 h-24 rounded-lg overflow-hidden flex-shrink-0">
<img class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" data-alt="A clean, professionally staged image of a high-ceiling loft conversion featuring exposed brick walls and massive industrial windows. The space is decorated in a modern minimalist style with a neutral color palette of whites, blacks, and wood accents. Bright morning light creates sharp, clean shadows, conveying a premium and verified real estate listing." src="https://lh3.googleusercontent.com/aida-public/AB6AXuATRAgm25hpggDubqnut6HiM4raf4R3WE4OqAhBos7rzeQbPAVntmJVPlt37aEo5qmYmX9xLtsOqSK7If3W8ap_JPemGnA1d-pH5VD3GQLOgKRHSQXu_VtD4CKZap4VBRr4LO-6pZIRKx3fMTymI9Eeiw_lGZC2CObrF6BZ2eKSlp5Ti2v-SfRQ-y7tSyagfbxVDTLUWeKaQrt0XSj6ZZxN9CUYiFOlL5WxpcoohUiqFU_ZqyNsaSP9NhT800NTtkce4bfEoMXZzEA"/>
<span class="absolute top-1 left-1 bg-outline text-on-primary text-[9px] px-1.5 py-0.5 rounded font-bold uppercase">Brouillon</span>
</div>
<div class="flex flex-col justify-between py-1 flex-grow">
<div>
<h3 class="font-title-lg text-body-lg text-on-surface font-semibold line-clamp-1">Loft Atypique - Bordeaux</h3>
<div class="flex items-center gap-1 text-on-surface-variant text-label-sm">
<span class="material-symbols-outlined text-[14px]">location_on</span>
<span>Quartier des Chartrons</span>
</div>
</div>
<div class="flex items-center justify-between">
<div class="flex items-center gap-3">
<div class="flex items-center gap-1 text-primary">
<span class="material-symbols-outlined text-[16px]">visibility</span>
<span class="text-label-md font-bold">0</span>
</div>
</div>
<span class="font-title-lg text-on-surface-variant text-body-lg font-bold italic">En attente</span>
</div>
</div>
</div>
</div>
</section>
</main>
<!-- FAB Button -->
<button class="fixed right-md bottom-20 w-14 h-14 bg-primary text-on-primary rounded-full shadow-lg flex items-center justify-center active:scale-90 transition-transform z-50">
<span class="material-symbols-outlined text-[32px]">add</span>
</button>
<!-- BottomNavBar (Shared Component Logic) -->
<nav class="fixed bottom-0 left-0 w-full flex justify-around items-center h-16 bg-surface px-sm pb-safe shadow-[0_-1px_4px_rgba(0,0,0,0.05)] z-50 border-t border-outline-variant">
<!-- Dashboard (Active) -->
<a class="flex flex-col items-center justify-center bg-primary-container text-on-primary-container rounded-full px-4 py-1 transition-all duration-200 active:scale-90" href="#">
<span class="material-symbols-outlined text-[24px]" style="font-variation-settings: 'FILL' 1;">dashboard</span>
<span class="font-label-md text-label-md">Dashboard</span>
</a>
<!-- Publier -->
<a class="flex flex-col items-center justify-center text-on-surface-variant hover:bg-surface-container-high transition-all duration-200 active:scale-90 px-2 py-1 rounded-lg" href="#">
<span class="material-symbols-outlined text-[24px]">add_circle</span>
<span class="font-label-md text-label-md">Publier</span>
</a>
<!-- Mes Biens -->
<a class="flex flex-col items-center justify-center text-on-surface-variant hover:bg-surface-container-high transition-all duration-200 active:scale-90 px-2 py-1 rounded-lg" href="#">
<span class="material-symbols-outlined text-[24px]">home_work</span>
<span class="font-label-md text-label-md">Mes Biens</span>
</a>
<!-- Profil -->
<a class="flex flex-col items-center justify-center text-on-surface-variant hover:bg-surface-container-high transition-all duration-200 active:scale-90 px-2 py-1 rounded-lg" href="#">
<span class="material-symbols-outlined text-[24px]">person</span>
<span class="font-label-md text-label-md">Profil</span>
</a>
</nav>
<script>
        // Micro-interactions and subtle scroll reveal
        document.addEventListener('DOMContentLoaded', () => {
            const cards = document.querySelectorAll('.group');
            cards.forEach((card, index) => {
                card.style.opacity = '0';
                card.style.transform = 'translateY(10px)';
                setTimeout(() => {
                    card.style.transition = 'all 0.4s ease-out';
                    card.style.opacity = '1';
                    card.style.transform = 'translateY(0)';
                }, 100 * index + 400);
            });

            // Handle bottom nav active states (simulated)
            const navItems = document.querySelectorAll('nav a');
            navItems.forEach(item => {
                item.addEventListener('click', (e) => {
                    navItems.forEach(nav => {
                        nav.classList.remove('bg-primary-container', 'text-on-primary-container', 'rounded-full');
                        nav.classList.add('text-on-surface-variant');
                        const icon = nav.querySelector('.material-symbols-outlined');
                        if (icon) icon.style.fontVariationSettings = "'FILL' 0";
                    });
                    item.classList.add('bg-primary-container', 'text-on-primary-container', 'rounded-full');
                    item.classList.remove('text-on-surface-variant');
                    const icon = item.querySelector('.material-symbols-outlined');
                    if (icon) icon.style.fontVariationSettings = "'FILL' 1";
                });
            });
        });
    </script>
</body></html>