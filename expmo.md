Projet Marketplace 
Flutter,dart,clean architecture
<!DOCTYPE html>

<html class="light" lang="fr"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;600;700;800&amp;family=Hanken+Grotesk:wght@400;500;600&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
      tailwind.config = {
        darkMode: "class",
        theme: {
          extend: {
            "colors": {
                    "background": "#f7f9fb",
                    "on-tertiary-fixed": "#001d36",
                    "on-background": "#191c1e",
                    "surface-variant": "#e0e3e5",
                    "surface-dim": "#d8dadc",
                    "inverse-on-surface": "#eff1f3",
                    "on-tertiary": "#ffffff",
                    "on-secondary-container": "#294f84",
                    "on-primary": "#ffffff",
                    "secondary-fixed-dim": "#a8c8ff",
                    "primary": "#003e7e",
                    "surface-bright": "#f7f9fb",
                    "surface": "#f7f9fb",
                    "outline-variant": "#c2c6d3",
                    "on-primary-fixed-variant": "#00468c",
                    "error-container": "#ffdad6",
                    "surface-container-high": "#e6e8ea",
                    "tertiary-fixed-dim": "#9ecaff",
                    "on-error": "#ffffff",
                    "surface-container": "#eceef0",
                    "surface-container-highest": "#e0e3e5",
                    "inverse-primary": "#a9c7ff",
                    "tertiary": "#004170",
                    "on-tertiary-container": "#a8cfff",
                    "on-error-container": "#93000a",
                    "secondary": "#3a5f95",
                    "inverse-surface": "#2d3133",
                    "on-primary-fixed": "#001b3d",
                    "primary-container": "#1a56a0",
                    "on-tertiary-fixed-variant": "#00497c",
                    "on-surface": "#191c1e",
                    "surface-tint": "#265ea8",
                    "surface-container-low": "#f2f4f6",
                    "secondary-container": "#9fc2ff",
                    "tertiary-fixed": "#d1e4ff",
                    "surface-container-lowest": "#ffffff",
                    "on-secondary-fixed": "#001b3c",
                    "on-surface-variant": "#424751",
                    "error": "#ba1a1a",
                    "on-secondary-fixed-variant": "#1f477c",
                    "primary-fixed": "#d6e3ff",
                    "tertiary-container": "#005996",
                    "secondary-fixed": "#d5e3ff",
                    "outline": "#737782",
                    "primary-fixed-dim": "#a9c7ff",
                    "on-primary-container": "#b3cdff",
                    "on-secondary": "#ffffff"
            },
            "borderRadius": {
                    "DEFAULT": "0.25rem",
                    "lg": "0.5rem",
                    "xl": "0.75rem",
                    "full": "9999px"
            },
            "spacing": {
                    "stack-lg": "24px",
                    "gutter": "12px",
                    "stack-xl": "40px",
                    "stack-sm": "8px",
                    "stack-md": "16px",
                    "container-margin": "20px"
            },
            "fontFamily": {
                    "body-lg": ["Hanken Grotesk"],
                    "label-md": ["Hanken Grotesk"],
                    "headline-xl": ["Manrope"],
                    "label-sm": ["Hanken Grotesk"],
                    "headline-lg": ["Manrope"],
                    "body-md": ["Hanken Grotesk"],
                    "headline-lg-mobile": ["Manrope"]
            },
            "fontSize": {
                    "body-lg": ["18px", {"lineHeight": "1.6", "fontWeight": "400"}],
                    "label-md": ["14px", {"lineHeight": "1.2", "letterSpacing": "0.05em", "fontWeight": "600"}],
                    "headline-xl": ["32px", {"lineHeight": "1.2", "letterSpacing": "-0.02em", "fontWeight": "800"}],
                    "label-sm": ["12px", {"lineHeight": "1.2", "fontWeight": "500"}],
                    "headline-lg": ["24px", {"lineHeight": "1.3", "fontWeight": "700"}],
                    "body-md": ["16px", {"lineHeight": "1.6", "fontWeight": "400"}],
                    "headline-lg-mobile": ["20px", {"lineHeight": "1.3", "fontWeight": "700"}]
            }
          },
        },
      }
    </script>
<style>
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
            display: inline-block;
            vertical-align: middle;
        }
        body {
            background-color: #f7f9fb;
            max-width: 480px;
            margin: 0 auto;
            min-height: 100vh;
            position: relative;
            box-shadow: 0 0 50px rgba(0,0,0,0.05);
        }
        .hide-scrollbar::-webkit-scrollbar { display: none; }
        .profile-header-gradient {
            background: linear-gradient(180deg, #003e7e 0%, #1a56a0 100%);
        }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="font-body-md text-on-surface hide-scrollbar">
<!-- Top AppBar (JSON Mapping) -->
<header class="flex items-center w-full h-16 px-container-margin sticky top-0 z-50 bg-primary-container text-on-primary-container">
<div class="flex items-center justify-between w-full">
<div class="flex items-center gap-4">
<span class="material-symbols-outlined cursor-pointer active:scale-95 transition-transform">arrow_back</span>
<h1 class="font-headline-lg-mobile text-headline-lg-mobile font-bold">Profil</h1>
</div>
<span class="material-symbols-outlined cursor-pointer active:scale-95 transition-transform">settings</span>
</div>
</header>
<main class="pb-24">
<!-- Blue Header Section -->
<section class="profile-header-gradient px-container-margin pt-stack-md pb-stack-xl flex flex-col items-center text-center rounded-b-[40px] shadow-lg">
<div class="relative mb-stack-md">
<div class="w-32 h-32 rounded-full border-4 border-white shadow-xl overflow-hidden bg-surface">
<img class="w-full h-full object-cover" data-alt="A professional and friendly portrait of Alex Dupont, a middle-aged male real estate professional with a warm smile. He has short styled brown hair and is wearing a crisp white dress shirt. The background is a blurred high-end interior office with soft natural lighting coming from a large window. The photo has a clean, high-key aesthetic with vibrant colors and professional depth of field." src="https://lh3.googleusercontent.com/aida-public/AB6AXuCi_rzfoORv9vr3xAHDoR0vE73rMtOEBeiF8HCg3AawFKNo-bn3OjDo2CC0MtGbIBbsjS_4U4UbE0JFhRw36ac3yH9w4pME7DTZ-7YDtOmaslsZKLChOMHAaGnAewG2AYOCUx0Iu12zxy855E2yc8pNfd75unlQ9I4J86P7Kt0Gr-dvXQAAZWiQvOWKdB7hPg_a2XX2R8hxESyrd2-qt8C5KH1vaxVIYnKx2_ugVebz4jXP6yDCxVXTNiVo4FBw7wozcP0oZ33uVmU"/>
</div>
<button class="absolute bottom-1 right-1 bg-white text-primary p-2 rounded-full shadow-lg flex items-center justify-center active:scale-90 transition-transform">
<span class="material-symbols-outlined text-[20px]">photo_camera</span>
</button>
</div>
<h2 class="font-headline-lg text-white mb-2">Alex Dupont</h2>
<div class="inline-flex items-center px-4 py-1.5 bg-white/20 backdrop-blur-md rounded-full border border-white/30 mb-stack-sm">
<span class="font-label-sm text-white">Client &amp; Propriétaire</span>
</div>
<div class="flex items-center gap-1 mt-2">
<span class="material-symbols-outlined text-secondary-container" style="font-variation-settings: 'FILL' 1;">star</span>
<span class="material-symbols-outlined text-secondary-container" style="font-variation-settings: 'FILL' 1;">star</span>
<span class="material-symbols-outlined text-secondary-container" style="font-variation-settings: 'FILL' 1;">star</span>
<span class="material-symbols-outlined text-secondary-container" style="font-variation-settings: 'FILL' 1;">star</span>
<span class="material-symbols-outlined text-secondary-container/50" style="font-variation-settings: 'FILL' 1;">star</span>
<span class="font-label-sm text-white/90 ml-1">4.8 (24 avis)</span>
</div>
</section>
<!-- Stats Row -->
<section class="px-container-margin -mt-8">
<div class="bg-surface-container-lowest rounded-xl p-stack-md shadow-sm border border-outline-variant/30 flex justify-between items-center text-center">
<div class="flex-1">
<p class="font-headline-lg-mobile text-primary font-bold">12</p>
<p class="font-label-sm text-on-surface-variant">Biens</p>
</div>
<div class="w-[1px] h-8 bg-outline-variant/50"></div>
<div class="flex-1">
<p class="font-headline-lg-mobile text-primary font-bold">45</p>
<p class="font-label-sm text-on-surface-variant">Visites</p>
</div>
<div class="w-[1px] h-8 bg-outline-variant/50"></div>
<div class="flex-1">
<p class="font-headline-lg-mobile text-primary font-bold">8</p>
<p class="font-label-sm text-on-surface-variant">Favoris</p>
</div>
</div>
</section>
<!-- Info Card -->
<section class="px-container-margin mt-stack-lg">
<div class="bg-surface-container-lowest rounded-xl shadow-sm border border-outline-variant/30 overflow-hidden">
<!-- Email Row -->
<div class="flex items-center justify-between p-stack-md border-b border-outline-variant/20">
<div class="flex flex-col">
<span class="font-label-sm text-outline uppercase tracking-wider">Email</span>
<div class="flex items-center gap-2 mt-0.5">
<span class="font-body-md text-on-surface">alex.dupont@email.com</span>
<div class="flex items-center gap-1 bg-primary/10 px-2 py-0.5 rounded-full">
<span class="material-symbols-outlined text-[14px] text-primary" style="font-variation-settings: 'FILL' 1;">verified</span>
<span class="text-[10px] font-bold text-primary uppercase">Vérifié</span>
</div>
</div>
</div>
</div>
<!-- Phone Row -->
<div class="flex items-center justify-between p-stack-md border-b border-outline-variant/20">
<div class="flex flex-col">
<span class="font-label-sm text-outline uppercase tracking-wider">Téléphone</span>
<span class="font-body-md text-on-surface mt-0.5">+33 6 12 34 56 78</span>
</div>
</div>
<!-- Country Row -->
<div class="flex items-center justify-between p-stack-md">
<div class="flex flex-col">
<span class="font-label-sm text-outline uppercase tracking-wider">Pays</span>
<div class="flex items-center gap-2 mt-0.5">
<img alt="France Flag" class="w-5 h-3.5 rounded-sm object-cover shadow-sm" src="https://lh3.googleusercontent.com/aida-public/AB6AXuAiMf6VzfUCKHmZg26c3-e50pyqcMbH4bXyaeCM46-S-2z0NrTOtFteZXHr7Vyv6qwzrcX7bjM7Aond7vB-P6-R6X9HNFoepZe1IhhlXicLWoz9gyIauIVnZUG8IrxBCunm4ciy_j6yYaUkSLaXaaKbvo7p__6JtrOGiK-GdArQGKKGLqgdfw3Qbf_yTBkxywkwu9gqNGT8Lg6waZrhICSeZD1uZhu9VErUgMueb76FeZCNAggp7ZOzjaJpk4If18Od0n_g2hk9JTU"/>
<span class="font-body-md text-on-surface">France</span>
</div>
</div>
</div>
</div>
</section>
<!-- Navigation Links -->
<section class="px-container-margin mt-stack-lg space-y-stack-sm">
<a class="flex items-center justify-between p-stack-md bg-surface-container-lowest rounded-xl border border-outline-variant/30 active:scale-[0.98] transition-all" href="#">
<div class="flex items-center gap-4">
<div class="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center">
<span class="material-symbols-outlined text-primary">person_edit</span>
</div>
<span class="font-body-md font-semibold text-on-surface">Modifier le profil</span>
</div>
<span class="material-symbols-outlined text-outline">chevron_right</span>
</a>
<a class="flex items-center justify-between p-stack-md bg-surface-container-lowest rounded-xl border border-outline-variant/30 active:scale-[0.98] transition-all" href="#">
<div class="flex items-center gap-4">
<div class="w-10 h-10 rounded-full bg-secondary/10 flex items-center justify-center">
<span class="material-symbols-outlined text-secondary">shield_lock</span>
</div>
<span class="font-body-md font-semibold text-on-surface">Sécurité &amp; 2FA</span>
</div>
<span class="material-symbols-outlined text-outline">chevron_right</span>
</a>
</section>
<!-- Logout -->
<section class="px-container-margin mt-stack-xl mb-12">
<button class="w-full py-4 border-2 border-error text-error font-bold rounded-xl flex items-center justify-center gap-2 active:bg-error/5 transition-colors">
<span class="material-symbols-outlined">logout</span>
                Déconnexion
            </button>
</section>
</main>
<!-- BottomNavBar (JSON Mapping & Semantic Logic) -->
<nav class="fixed bottom-0 w-full z-50 flex justify-around items-center px-4 py-3 max-w-[480px] mx-auto left-0 right-0 bg-surface-container-lowest shadow-[0_-4px_20px_rgba(0,30,61,0.04)] rounded-t-xl">
<div class="flex flex-col items-center justify-center text-on-surface-variant opacity-60 hover:text-primary transition-all duration-200 cursor-pointer">
<span class="material-symbols-outlined">home</span>
<span class="font-label-sm text-label-sm">Accueil</span>
</div>
<div class="flex flex-col items-center justify-center text-on-surface-variant opacity-60 hover:text-primary transition-all duration-200 cursor-pointer">
<span class="material-symbols-outlined">search</span>
<span class="font-label-sm text-label-sm">Recherche</span>
</div>
<div class="flex flex-col items-center justify-center text-on-surface-variant opacity-60 hover:text-primary transition-all duration-200 cursor-pointer">
<span class="material-symbols-outlined">add_circle</span>
<span class="font-label-sm text-label-sm">Publier</span>
</div>
<div class="flex flex-col items-center justify-center text-on-surface-variant opacity-60 hover:text-primary transition-all duration-200 cursor-pointer">
<span class="material-symbols-outlined">domain</span>
<span class="font-label-sm text-label-sm">Mes Biens</span>
</div>
<!-- Active State: Profil -->
<div class="flex flex-col items-center justify-center text-primary font-bold active:scale-90 transition-all duration-200 cursor-pointer">
<span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1;">person</span>
<span class="font-label-sm text-label-sm">Profil</span>
</div>
</nav>
<script>
        // Simple interactive feedback
        document.querySelectorAll('a, button').forEach(el => {
            el.addEventListener('click', (e) => {
                if(el.tagName === 'A') e.preventDefault();
                console.log('Interaction detected on:', el.innerText || 'Icon button');
            });
        });
    </script>
</body></html>
<!DOCTYPE html>

<html class="light" lang="fr"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Modifier le Profil | ImmoPro</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;600;700;800&amp;family=Hanken+Grotesk:wght@400;500;600&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<style>
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        .form-input-focus:focus {
            outline: none;
            border-color: #003e7e;
            box-shadow: 0 0 0 1px #003e7e;
        }
    </style>
<script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    "colors": {
                        "background": "#f7f9fb",
                        "on-tertiary-fixed": "#001d36",
                        "on-background": "#191c1e",
                        "surface-variant": "#e0e3e5",
                        "surface-dim": "#d8dadc",
                        "inverse-on-surface": "#eff1f3",
                        "on-tertiary": "#ffffff",
                        "on-secondary-container": "#294f84",
                        "on-primary": "#ffffff",
                        "secondary-fixed-dim": "#a8c8ff",
                        "primary": "#003e7e",
                        "surface-bright": "#f7f9fb",
                        "surface": "#f7f9fb",
                        "outline-variant": "#c2c6d3",
                        "on-primary-fixed-variant": "#00468c",
                        "error-container": "#ffdad6",
                        "surface-container-high": "#e6e8ea",
                        "tertiary-fixed-dim": "#9ecaff",
                        "on-error": "#ffffff",
                        "surface-container": "#eceef0",
                        "surface-container-highest": "#e0e3e5",
                        "inverse-primary": "#a9c7ff",
                        "tertiary": "#004170",
                        "on-tertiary-container": "#a8cfff",
                        "on-error-container": "#93000a",
                        "secondary": "#3a5f95",
                        "inverse-surface": "#2d3133",
                        "on-primary-fixed": "#001b3d",
                        "primary-container": "#1a56a0",
                        "on-tertiary-fixed-variant": "#00497c",
                        "on-surface": "#191c1e",
                        "surface-tint": "#265ea8",
                        "surface-container-low": "#f2f4f6",
                        "secondary-container": "#9fc2ff",
                        "tertiary-fixed": "#d1e4ff",
                        "surface-container-lowest": "#ffffff",
                        "on-secondary-fixed": "#001b3c",
                        "on-surface-variant": "#424751",
                        "error": "#ba1a1a",
                        "on-secondary-fixed-variant": "#1f477c",
                        "primary-fixed": "#d6e3ff",
                        "tertiary-container": "#005996",
                        "secondary-fixed": "#d5e3ff",
                        "outline": "#737782",
                        "primary-fixed-dim": "#a9c7ff",
                        "on-primary-container": "#b3cdff",
                        "on-secondary": "#ffffff"
                    },
                    "borderRadius": {
                        "DEFAULT": "0.25rem",
                        "lg": "0.5rem",
                        "xl": "0.75rem",
                        "full": "9999px"
                    },
                    "spacing": {
                        "stack-lg": "24px",
                        "gutter": "12px",
                        "stack-xl": "40px",
                        "stack-sm": "8px",
                        "stack-md": "16px",
                        "container-margin": "20px"
                    },
                    "fontFamily": {
                        "body-lg": ["Hanken Grotesk"],
                        "label-md": ["Hanken Grotesk"],
                        "headline-xl": ["Manrope"],
                        "label-sm": ["Hanken Grotesk"],
                        "headline-lg": ["Manrope"],
                        "body-md": ["Hanken Grotesk"],
                        "headline-lg-mobile": ["Manrope"]
                    },
                    "fontSize": {
                        "body-lg": ["18px", {"lineHeight": "1.6", "fontWeight": "400"}],
                        "label-md": ["14px", {"lineHeight": "1.2", "letterSpacing": "0.05em", "fontWeight": "600"}],
                        "headline-xl": ["32px", {"lineHeight": "1.2", "letterSpacing": "-0.02em", "fontWeight": "800"}],
                        "label-sm": ["12px", {"lineHeight": "1.2", "fontWeight": "500"}],
                        "headline-lg": ["24px", {"lineHeight": "1.3", "fontWeight": "700"}],
                        "body-md": ["16px", {"lineHeight": "1.6", "fontWeight": "400"}],
                        "headline-lg-mobile": ["20px", {"lineHeight": "1.3", "fontWeight": "700"}]
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
<body class="bg-background text-on-surface font-body-md antialiased min-h-screen pb-32">
<!-- TopAppBar -->
<header class="flex items-center w-full h-16 px-container-margin sticky top-0 z-50 bg-primary-container text-on-primary-container shadow-sm">
<button class="mr-4 active:scale-95 transition-transform duration-150 flex items-center justify-center">
<span class="material-symbols-outlined text-[24px]">arrow_back</span>
</button>
<h1 class="font-headline-lg-mobile text-headline-lg-mobile font-bold tracking-tight">Modifier le profil</h1>
</header>
<main class="max-w-[480px] mx-auto px-container-margin pt-stack-lg">
<!-- Profile Photo Section -->
<section class="flex flex-col items-center mb-stack-xl">
<div class="relative">
<div class="w-32 h-32 rounded-full overflow-hidden border-4 border-white shadow-sm">
<img class="w-full h-full object-cover" data-alt="A professional studio portrait of a successful real estate agent, high-key lighting, neutral background, clean aesthetic, high-quality photography consistent with a premium brand identity." src="https://lh3.googleusercontent.com/aida-public/AB6AXuC_wn-P-ESh42vg4IZ5dHJeiBRr3ZDuosPq5wiET4EhNYXGwrYP7yrO2idRpPqVnMTeKx354WsyJ9vtDqgJS_dt4n2B73ITOKsAD5CocnJ58p73JgWQefPGl9swZ6AQLu-KWOZhUg7dzzvNWxgs2iEbiIhGAbl4OBE1dG9y9hsllwj8MAwjDC3r4htWae85DFbyrBwsUSCkSMn-hyHhRWbtepms3XhUsppeYo5HVPcMQCcEdtqq-m98ZIwXtku5fvlN-EthjvggI8A"/>
</div>
<button class="absolute bottom-0 right-0 bg-primary text-on-primary w-10 h-10 rounded-full flex items-center justify-center shadow-md active:scale-90 transition-all">
<span class="material-symbols-outlined text-[20px]">photo_camera</span>
</button>
</div>
<button class="mt-4 text-primary font-label-md hover:opacity-80 transition-opacity">Changer la photo</button>
</section>
<!-- Form Section -->
<form class="space-y-stack-lg">
<!-- Nom & Prénom Grid -->
<div class="grid grid-cols-2 gap-gutter">
<div class="flex flex-col space-y-2">
<label class="text-label-sm font-semibold text-on-surface-variant uppercase tracking-wider">Prénom</label>
<input class="w-full h-12 px-4 rounded-lg border border-outline-variant bg-white font-body-md form-input-focus transition-all" type="text" value="Jean"/>
</div>
<div class="flex flex-col space-y-2">
<label class="text-label-sm font-semibold text-on-surface-variant uppercase tracking-wider">Nom</label>
<input class="w-full h-12 px-4 rounded-lg border border-outline-variant bg-white font-body-md form-input-focus transition-all" type="text" value="Dupont"/>
</div>
</div>
<!-- Email Section -->
<div class="flex flex-col space-y-2">
<label class="text-label-sm font-semibold text-on-surface-variant uppercase tracking-wider">Email</label>
<input class="w-full h-12 px-4 rounded-lg border border-outline-variant bg-white font-body-md form-input-focus transition-all" type="email" value="jean.dupont@immobilier.fr"/>
<div class="flex items-start gap-2 mt-1">
<span class="material-symbols-outlined text-[16px] text-tertiary mt-0.5">info</span>
<p class="text-label-sm text-on-surface-variant italic">Note : Une nouvelle vérification sera requise si vous modifiez votre adresse email.</p>
</div>
</div>
<!-- Téléphone Section -->
<div class="flex flex-col space-y-2">
<label class="text-label-sm font-semibold text-on-surface-variant uppercase tracking-wider">Téléphone</label>
<div class="relative flex items-center">
<span class="absolute left-4 material-symbols-outlined text-outline text-[20px]">call</span>
<input class="w-full h-12 pl-12 pr-4 rounded-lg border border-outline-variant bg-white font-body-md form-input-focus transition-all" type="tel" value="+33 6 12 34 56 78"/>
</div>
</div>
<!-- Location Grid -->
<div class="grid grid-cols-2 gap-gutter">
<div class="flex flex-col space-y-2">
<label class="text-label-sm font-semibold text-on-surface-variant uppercase tracking-wider">Pays</label>
<div class="relative">
<select class="w-full h-12 px-4 pr-10 appearance-none rounded-lg border border-outline-variant bg-white font-body-md form-input-focus transition-all">
<option selected="">🇫🇷 France</option>
<option>🇧🇪 Belgique</option>
<option>🇨🇭 Suisse</option>
<option>🇱🇺 Luxembourg</option>
<option>🇲🇦 Maroc</option>
</select>
<span class="absolute right-3 top-1/2 -translate-y-1/2 material-symbols-outlined text-outline pointer-events-none">expand_more</span>
</div>
</div>
<div class="flex flex-col space-y-2">
<label class="text-label-sm font-semibold text-on-surface-variant uppercase tracking-wider">Ville</label>
<input class="w-full h-12 px-4 rounded-lg border border-outline-variant bg-white font-body-md form-input-focus transition-all" type="text" value="Paris"/>
</div>
</div>
<!-- Action Buttons -->
<div class="pt-stack-xl flex flex-col space-y-4">
<button class="w-full h-14 bg-primary text-on-primary rounded-xl font-label-md text-[16px] shadow-sm hover:opacity-90 active:scale-95 transition-all" type="submit">
                    Enregistrer les modifications
                </button>
<button class="w-full h-14 bg-surface-container text-on-surface-variant rounded-xl font-label-md text-[16px] hover:bg-surface-variant active:scale-95 transition-all" type="button">
                    Annuler
                </button>
</div>
</form>
</main>
<!-- BottomNavBar (Suppressed for transactional screen logic, but defined in JSON. Per instructions, focus on content canvas.) -->
<nav class="fixed bottom-0 w-full z-50 flex justify-around items-center px-4 py-3 max-w-[480px] mx-auto left-0 right-0 bg-surface-container-lowest shadow-[0_-4px_20px_rgba(0,30,61,0.04)] rounded-t-xl">
<div class="flex flex-col items-center justify-center text-on-surface-variant opacity-60 font-label-sm text-label-sm">
<span class="material-symbols-outlined">home</span>
<span>Accueil</span>
</div>
<div class="flex flex-col items-center justify-center text-on-surface-variant opacity-60 font-label-sm text-label-sm">
<span class="material-symbols-outlined">search</span>
<span>Recherche</span>
</div>
<div class="flex flex-col items-center justify-center text-on-surface-variant opacity-60 font-label-sm text-label-sm">
<span class="material-symbols-outlined">add_circle</span>
<span>Publier</span>
</div>
<div class="flex flex-col items-center justify-center text-on-surface-variant opacity-60 font-label-sm text-label-sm">
<span class="material-symbols-outlined">domain</span>
<span>Mes Biens</span>
</div>
<!-- Active State Logic applied to Profil -->
<div class="flex flex-col items-center justify-center text-primary font-bold font-label-sm text-label-sm">
<span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1;">person</span>
<span>Profil</span>
</div>
</nav>
<script>
        // Micro-interactions for form feedback
        document.querySelectorAll('input, select').forEach(element => {
            element.addEventListener('focus', () => {
                element.parentElement.querySelector('label').classList.add('text-primary');
            });
            element.addEventListener('blur', () => {
                element.parentElement.querySelector('label').classList.remove('text-primary');
            });
        });

        // Simple form submission feedback
        const form = document.querySelector('form');
        form.addEventListener('submit', (e) => {
            e.preventDefault();
            const btn = e.target.querySelector('button[type="submit"]');
            const originalText = btn.innerText;
            btn.innerText = "Enregistrement...";
            btn.disabled = true;
            btn.classList.add('opacity-70');
            
            setTimeout(() => {
                btn.innerText = "Succès !";
                btn.classList.remove('bg-primary');
                btn.classList.add('bg-green-600');
                setTimeout(() => {
                    btn.innerText = originalText;
                    btn.classList.add('bg-primary');
                    btn.classList.remove('bg-green-600');
                    btn.disabled = false;
                    btn.classList.remove('opacity-70');
                }, 2000);
            }, 1200);
        });
    </script>
</body></html>
<!DOCTYPE html><html class="light" lang="fr" style=""><head>
<meta charset="utf-8">
<meta content="width=device-width, initial-scale=1.0" name="viewport">
<title>Sécurité - Premium Real Estate</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;600;700;800&amp;family=Hanken+Grotesk:wght@400;500;600&amp;display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet">
<script id="tailwind-config">
      tailwind.config = {
        darkMode: "class",
        theme: {
          extend: {
            "colors": {
                    "background": "#f7f9fb",
                    "on-tertiary-fixed": "#001d36",
                    "on-background": "#191c1e",
                    "surface-variant": "#e0e3e5",
                    "surface-dim": "#d8dadc",
                    "inverse-on-surface": "#eff1f3",
                    "on-tertiary": "#ffffff",
                    "on-secondary-container": "#294f84",
                    "on-primary": "#ffffff",
                    "secondary-fixed-dim": "#a8c8ff",
                    "primary": "#003e7e",
                    "surface-bright": "#f7f9fb",
                    "surface": "#f7f9fb",
                    "outline-variant": "#c2c6d3",
                    "on-primary-fixed-variant": "#00468c",
                    "error-container": "#ffdad6",
                    "surface-container-high": "#e6e8ea",
                    "tertiary-fixed-dim": "#9ecaff",
                    "on-error": "#ffffff",
                    "surface-container": "#eceef0",
                    "surface-container-highest": "#e0e3e5",
                    "inverse-primary": "#a9c7ff",
                    "tertiary": "#004170",
                    "on-tertiary-container": "#a8cfff",
                    "on-error-container": "#93000a",
                    "secondary": "#3a5f95",
                    "inverse-surface": "#2d3133",
                    "on-primary-fixed": "#001b3d",
                    "primary-container": "#1a56a0",
                    "on-tertiary-fixed-variant": "#00497c",
                    "on-surface": "#191c1e",
                    "surface-tint": "#265ea8",
                    "surface-container-low": "#f2f4f6",
                    "secondary-container": "#9fc2ff",
                    "tertiary-fixed": "#d1e4ff",
                    "surface-container-lowest": "#ffffff",
                    "on-secondary-fixed": "#001b3c",
                    "on-surface-variant": "#424751",
                    "error": "#ba1a1a",
                    "on-secondary-fixed-variant": "#1f477c",
                    "primary-fixed": "#d6e3ff",
                    "tertiary-container": "#005996",
                    "secondary-fixed": "#d5e3ff",
                    "outline": "#737782",
                    "primary-fixed-dim": "#a9c7ff",
                    "on-primary-container": "#b3cdff",
                    "on-secondary": "#ffffff"
            },
            "borderRadius": {
                    "DEFAULT": "0.25rem",
                    "lg": "0.5rem",
                    "xl": "0.75rem",
                    "full": "9999px"
            },
            "spacing": {
                    "stack-lg": "24px",
                    "gutter": "12px",
                    "stack-xl": "40px",
                    "stack-sm": "8px",
                    "stack-md": "16px",
                    "container-margin": "20px"
            },
            "fontFamily": {
                    "body-lg": ["Hanken Grotesk"],
                    "label-md": ["Hanken Grotesk"],
                    "headline-xl": ["Manrope"],
                    "label-sm": ["Hanken Grotesk"],
                    "headline-lg": ["Manrope"],
                    "body-md": ["Hanken Grotesk"],
                    "headline-lg-mobile": ["Manrope"]
            },
            "fontSize": {
                    "body-lg": ["18px", {"lineHeight": "1.6", "fontWeight": "400"}],
                    "label-md": ["14px", {"lineHeight": "1.2", "letterSpacing": "0.05em", "fontWeight": "600"}],
                    "headline-xl": ["32px", {"lineHeight": "1.2", "letterSpacing": "-0.02em", "fontWeight": "800"}],
                    "label-sm": ["12px", {"lineHeight": "1.2", "fontWeight": "500"}],
                    "headline-lg": ["24px", {"lineHeight": "1.3", "fontWeight": "700"}],
                    "body-md": ["16px", {"lineHeight": "1.6", "fontWeight": "400"}],
                    "headline-lg-mobile": ["20px", {"lineHeight": "1.3", "fontWeight": "700"}]
            }
          },
        },
      }
    </script>
<style>
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        .password-strength-fill {
            transition: width 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        }
        body {
            background-color: #f7f9fb;
            max-width: 480px;
            margin: 0 auto;
            min-height: 100vh;
            position: relative;
        }
        .custom-shadow {
            box-shadow: 0 4px 20px rgba(0, 30, 61, 0.04);
        }
        .toggle-dot {
            transition: all 0.3s ease-in-out;
        }
        input:checked ~ .toggle-dot {
            transform: translateX(100%);
        }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="font-body-md text-on-surface">
<!-- TopAppBar -->
<header class="flex items-center w-full h-16 px-container-margin sticky top-0 z-50 bg-primary-container text-on-primary-container">
<button class="active:scale-95 transition-transform duration-150 hover:opacity-80">
<span class="material-symbols-outlined">arrow_back</span>
</button>
<h1 class="ml-4 font-headline-lg-mobile text-headline-lg-mobile font-bold">Sécurité</h1>
</header>
<main class="px-container-margin py-stack-lg space-y-stack-lg pb-32">
<!-- Section 1: Mot de passe -->
<section class="bg-surface-container-lowest p-stack-md rounded-xl border border-outline-variant/30 custom-shadow">
<div class="flex items-center gap-3 mb-stack-md">
<span class="material-symbols-outlined text-primary">lock</span>
<h2 class="font-headline-lg-mobile text-headline-lg-mobile">Mot de passe</h2>
</div>
<div class="space-y-stack-md">
  <div class="space-y-1">
    <label class="text-label-sm uppercase tracking-wider text-outline">Ancien mot de passe</label>
    <input class="w-full bg-surface-container-low border border-outline-variant rounded-lg p-3 focus:border-primary focus:ring-1 focus:ring-primary outline-none transition-all" type="password" placeholder="••••••••">
  </div>
  <div class="space-y-1">
    <label class="text-label-sm uppercase tracking-wider text-outline">Nouveau mot de passe</label>
    <input class="w-full bg-surface-container-low border border-outline-variant rounded-lg p-3 focus:border-primary focus:ring-1 focus:ring-primary outline-none transition-all" type="password" placeholder="••••••••">
    <div class="h-1.5 w-full bg-surface-variant rounded-full overflow-hidden mt-2">
      <div class="flex h-full gap-0.5">
        <div class="h-full w-1/4 bg-primary"></div>
        <div class="h-full w-1/4 bg-primary"></div>
        <div class="h-full w-1/4 bg-outline-variant/30"></div>
        <div class="h-full w-1/4 bg-outline-variant/30"></div>
      </div>
    </div>
    <p class="text-label-sm text-outline mt-1">Force du mot de passe : Moyen</p>
  </div>
  <div class="space-y-1">
    <label class="text-label-sm uppercase tracking-wider text-outline">Confirmer le nouveau mot de passe</label>
    <input class="w-full bg-surface-container-low border border-outline-variant rounded-lg p-3 focus:border-primary focus:ring-1 focus:ring-primary outline-none transition-all" type="password" placeholder="••••••••">
  </div>
  <div class="flex flex-col gap-3 pt-2">
    <button class="w-full py-3 px-4 bg-primary-container text-on-primary-container rounded-lg font-label-md hover:opacity-90 active:scale-95 transition-all">
      Valider les changements
    </button>
    <button class="w-full py-3 px-4 border border-outline-variant text-on-surface-variant rounded-lg font-label-md hover:bg-surface-container-low active:scale-95 transition-all">
      Annuler
    </button>
  </div>
</div>
<!-- Change Password Form (Hidden by default) -->

</section>
<!-- Section 2: 2FA -->
<section class="bg-surface-container-lowest p-stack-md rounded-xl border border-outline-variant/30 custom-shadow">
<div class="flex items-center justify-between mb-stack-md">
<div class="flex items-center gap-3">
<span class="material-symbols-outlined text-primary">verified_user</span>
<h2 class="font-headline-lg-mobile text-headline-lg-mobile">Double authentification</h2>
</div>
<label class="relative inline-flex items-center cursor-pointer">
<input class="sr-only" id="tfa-toggle" onchange="toggle2FA(this)" type="checkbox">
<div class="w-11 h-6 bg-surface-variant rounded-full peer peer-checked:bg-primary-container transition-colors"></div>
<div class="toggle-dot absolute left-1 top-1 bg-white w-4 h-4 rounded-full shadow-sm peer-checked:translate-x-5 transition-transform"></div>
</label>
</div>
<p class="text-on-surface-variant font-body-md mb-stack-md">Ajoutez une couche de sécurité supplémentaire à votre compte.</p>
<div class="hidden border-t border-outline-variant/30 pt-stack-md flex flex-col items-center" id="qr-section">
<div class="bg-white p-4 rounded-xl border border-outline-variant/20 mb-stack-md">
<img class="w-40 h-40 object-contain" data-alt="A clean, minimalist QR code displayed on a high-end smartphone screen within a bright, contemporary real estate office setting. The composition uses a crisp white background with subtle deep blue accents, maintaining a professional and secure atmosphere. Soft directional lighting enhances the technological feel of the setup." src="https://lh3.googleusercontent.com/aida-public/AB6AXuD_vuMLtRUG3-AuKtSZXzrRi2QuU6sTpOJZT-l1ehrENgb2WOxtkxR5f4240a6qK6ccFsBep4lQliZQf7Lt-F15asSCzALEYss7ElObMZxVIIzjJAfQcHzM-LPxBaldiwk29d5HSWh6zt059hRSSzDZHLqg_xjJPNzyGErGII7RcGHSSmJwW12KkdMXgFHAy3CMxBlc8NBb7SWzuntKm4hxLRr44J7hIvapkr9eciVlL-mzrRJuLeGmuHyiuihmz0yqDVPh7hMs_u8">
</div>
<p class="text-center text-label-sm text-outline px-4">Scannez ce code avec votre application d'authentification (Google Authenticator, Authy, etc.)</p>
</div>
</section>
<!-- Section 3: Sessions actives -->
<section class="bg-surface-container-lowest p-stack-md rounded-xl border border-outline-variant/30 custom-shadow">
<div class="flex items-center gap-3 mb-stack-lg">
<span class="material-symbols-outlined text-primary">devices</span>
<h2 class="font-headline-lg-mobile text-headline-lg-mobile">Sessions actives</h2>
</div>
<div class="space-y-stack-md">
<!-- Device 1 -->
<div class="flex items-center justify-between p-stack-sm rounded-lg hover:bg-surface-container-low transition-colors">
<div class="flex items-center gap-3">
<div class="w-10 h-10 rounded-full bg-primary-fixed flex items-center justify-center text-primary">
<span class="material-symbols-outlined">smartphone</span>
</div>
<div>
<p class="font-label-md text-on-surface">iPhone 13</p>
<p class="text-label-sm text-outline">Paris, France • En ligne</p>
</div>
</div>
<button class="text-error font-label-md px-3 py-1.5 rounded-lg hover:bg-error/5 active:scale-95 transition-all">Déconnecter</button>
</div>
<!-- Device 2 -->
<div class="flex items-center justify-between p-stack-sm rounded-lg hover:bg-surface-container-low transition-colors">
<div class="flex items-center gap-3">
<div class="w-10 h-10 rounded-full bg-primary-fixed flex items-center justify-center text-primary">
<span class="material-symbols-outlined">laptop_mac</span>
</div>
<div>
<p class="font-label-md text-on-surface">Mac Studio</p>
<p class="text-label-sm text-outline">Nice, France • Il y a 2h</p>
</div>
</div>
<button class="text-error font-label-md px-3 py-1.5 rounded-lg hover:bg-error/5 active:scale-95 transition-all">Déconnecter</button>
</div>
<!-- Device 3 -->
<div class="flex items-center justify-between p-stack-sm rounded-lg hover:bg-surface-container-low transition-colors">
<div class="flex items-center gap-3">
<div class="w-10 h-10 rounded-full bg-primary-fixed flex items-center justify-center text-primary">
<span class="material-symbols-outlined">tablet_mac</span>
</div>
<div>
<p class="font-label-md text-on-surface">iPad Pro</p>
<p class="text-label-sm text-outline">Lyon, France • Hier</p>
</div>
</div>
<button class="text-error font-label-md px-3 py-1.5 rounded-lg hover:bg-error/5 active:scale-95 transition-all">Déconnecter</button>
</div>
</div>

</section>
</main>
<!-- BottomNavBar -->
<nav class="fixed bottom-0 w-full z-50 flex justify-around items-center px-4 py-3 max-w-[480px] mx-auto left-0 right-0 bg-surface-container-lowest shadow-[0_-4px_20px_rgba(0,30,61,0.04)] rounded-t-xl">
<a class="flex flex-col items-center justify-center text-on-surface-variant opacity-60 hover:text-primary transition-all duration-200 active:scale-90" href="#">
<span class="material-symbols-outlined">home</span>
<span class="font-label-sm text-label-sm">Accueil</span>
</a>
<a class="flex flex-col items-center justify-center text-on-surface-variant opacity-60 hover:text-primary transition-all duration-200 active:scale-90" href="#">
<span class="material-symbols-outlined">search</span>
<span class="font-label-sm text-label-sm">Recherche</span>
</a>
<a class="flex flex-col items-center justify-center text-on-surface-variant opacity-60 hover:text-primary transition-all duration-200 active:scale-90" href="#">
<span class="material-symbols-outlined">add_circle</span>
<span class="font-label-sm text-label-sm">Publier</span>
</a>
<a class="flex flex-col items-center justify-center text-on-surface-variant opacity-60 hover:text-primary transition-all duration-200 active:scale-90" href="#">
<span class="material-symbols-outlined">domain</span>
<span class="font-label-sm text-label-sm">Mes Biens</span>
</a>
<a class="flex flex-col items-center justify-center text-primary font-bold transition-all duration-200 active:scale-90" href="#">
<span class="material-symbols-outlined" style="font-variation-settings: &quot;FILL&quot; 1;">person</span>
<span class="font-label-sm text-label-sm">Profil</span>
</a>
</nav>
<script>
        function togglePasswordForm() {
            const display = document.getElementById('password-display-state');
            const form = document.getElementById('password-form');
            if (display.classList.contains('hidden')) {
                display.classList.remove('hidden');
                form.classList.add('hidden');
            } else {
                display.classList.add('hidden');
                form.classList.remove('hidden');
            }
        }

        function updateStrength(value) {
            const bar = document.getElementById('strength-bar');
            let strength = 0;
            if (value.length > 0) {
                strength = Math.min(value.length * 10, 100);
            }
            bar.style.width = strength + '%';
            
            if (strength < 40) {
                bar.className = 'h-full w-0 password-strength-fill bg-error';
            } else if (strength < 70) {
                bar.className = 'h-full w-0 password-strength-fill bg-secondary';
            } else {
                bar.className = 'h-full w-0 password-strength-fill bg-primary';
            }
        }

        function toggle2FA(checkbox) {
            const qrSection = document.getElementById('qr-section');
            if (checkbox.checked) {
                qrSection.classList.remove('hidden');
                qrSection.classList.add('animate-in', 'fade-in', 'duration-500');
            } else {
                qrSection.classList.add('hidden');
            }
        }

        // Simple button active state visual feedback
        document.querySelectorAll('button').forEach(btn => {
            btn.addEventListener('click', () => {
                btn.style.opacity = '0.7';
                setTimeout(() => btn.style.opacity = '1', 100);
            });
        });
    </script>


</body></html>
Mettre a jour le bouton profil de la navbar avec les info du client connecte.