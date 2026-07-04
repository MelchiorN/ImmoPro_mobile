Projet Marketplace 
Flutter,dart,clean architecture

<!DOCTYPE html><html class="light" lang="fr" style="width: 390px; height: 1204px; overflow: hidden; position: relative;"><head>
<meta charset="utf-8">
<meta content="width=device-width, initial-scale=1.0" name="viewport">
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&amp;family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@100..900&amp;display=swap" rel="stylesheet">
<style>
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        .hide-scrollbar::-webkit-scrollbar {
            display: none;
        }
        .hide-scrollbar {
            -ms-overflow-style: none;
            scrollbar-width: none;
        }
        .glass-effect {
            background: rgba(255, 255, 255, 0.8);
            backdrop-filter: blur(10px);
        }
        .active-pill {
            box-shadow: 0 4px 12px rgba(26, 86, 160, 0.2);
        }
    </style>
<script id="tailwind-config">
        tailwind.config = {
          darkMode: "class",
          theme: {
            extend: {
              "colors": {
                      "on-secondary-fixed-variant": "#3f484e",
                      "inverse-surface": "#2d3133",
                      "on-tertiary": "#ffffff",
                      "primary-fixed": "#d6e3ff",
                      "surface-container-high": "#e6e8ea",
                      "primary-container": "#1a56a0",
                      "secondary-fixed": "#dbe4eb",
                      "on-primary": "#ffffff",
                      "surface-container-highest": "#e0e3e5",
                      "on-error-container": "#93000a",
                      "on-background": "#191c1e",
                      "on-error": "#ffffff",
                      "on-primary-fixed": "#001b3d",
                      "surface-bright": "#f7f9fb",
                      "on-secondary-container": "#5d666c",
                      "surface-tint": "#265ea8",
                      "tertiary-fixed": "#86f8c5",
                      "surface": "#f7f9fb",
                      "on-tertiary-fixed-variant": "#005138",
                      "tertiary-container": "#006344",
                      "surface-variant": "#e0e3e5",
                      "inverse-on-surface": "#eff1f3",
                      "surface-dim": "#d8dadc",
                      "primary": "#003e7e",
                      "error-container": "#ffdad6",
                      "on-tertiary-fixed": "#002114",
                      "on-secondary-fixed": "#141d22",
                      "surface-container-low": "#f2f4f6",
                      "on-tertiary-container": "#6fe1af",
                      "surface-container": "#eceef0",
                      "on-primary-fixed-variant": "#00468c",
                      "background": "#f7f9fb",
                      "on-surface-variant": "#424751",
                      "primary-fixed-dim": "#a9c7ff",
                      "outline": "#737782",
                      "tertiary-fixed-dim": "#69dbaa",
                      "surface-container-lowest": "#ffffff",
                      "outline-variant": "#c2c6d3",
                      "on-surface": "#191c1e",
                      "tertiary": "#004931",
                      "on-primary-container": "#b3cdff",
                      "secondary-fixed-dim": "#bfc8ce",
                      "secondary-container": "#dbe4eb",
                      "secondary": "#576065",
                      "inverse-primary": "#a9c7ff",
                      "error": "#ba1a1a",
                      "on-secondary": "#ffffff"
              },
              "borderRadius": {
                      "DEFAULT": "0.25rem",
                      "lg": "0.5rem",
                      "xl": "0.75rem",
                      "full": "9999px"
              },
              "spacing": {
                      "base": "4px",
                      "xs": "4px",
                      "md": "16px",
                      "sm": "8px",
                      "xl": "32px",
                      "gutter": "16px",
                      "lg": "24px",
                      "container-max": "1280px"
              },
              "fontFamily": {
                      "title-lg": ["Inter"],
                      "display-lg-mobile": ["Inter"],
                      "label-sm": ["Inter"],
                      "display-lg": ["Inter"],
                      "headline-md": ["Inter"],
                      "body-lg": ["Inter"],
                      "label-md": ["Inter"],
                      "body-md": ["Inter"]
              },
              "fontSize": {
                      "title-lg": ["20px", {"lineHeight": "28px", "fontWeight": "600"}],
                      "display-lg-mobile": ["28px", {"lineHeight": "34px", "fontWeight": "700"}],
                      "label-sm": ["11px", {"lineHeight": "14px", "fontWeight": "500"}],
                      "display-lg": ["36px", {"lineHeight": "44px", "letterSpacing": "-0.02em", "fontWeight": "700"}],
                      "headline-md": ["24px", {"lineHeight": "32px", "fontWeight": "600"}],
                      "body-lg": ["16px", {"lineHeight": "24px", "fontWeight": "400"}],
                      "label-md": ["12px", {"lineHeight": "16px", "letterSpacing": "0.01em", "fontWeight": "600"}],
                      "body-md": ["14px", {"lineHeight": "20px", "fontWeight": "400"}]
              }
            },
          },
        }
    </script>
</head>
<body class="bg-background font-body-md text-on-background min-h-screen pb-32">
<!-- TopAppBar -->
<header class="bg-primary-container fixed top-0 left-0 w-full z-50 shadow-sm px-md py-sm flex justify-between items-center h-16">
<div class="flex items-center gap-md">
<img alt="ImmoPro Logo" class="h-8 w-auto" src="https://lh3.googleusercontent.com/aida/AP1WRLtLlkxItPBOstPMlUyM-mD-MxloRmDnaBvWhyTsqEqkBJKb5hA82LCA6znhK2sUvGtSmZnVVUpm72T3FxWseOkCluyVxARlcyGQuCuzGRFyrYKuEW1w0kKGR2RZYLbx3ys8pzyNfAhUf6sTv1SSAG49bYpu9-j8ANZyHJ8dlUdh5eCexa9sPo_UUMpoYk6-BW4dgRMb8tc3JyJAyFh06hI3D-R2uh7px5CaKEP6oDAME92UbhhSC7vvCsk">
</div>
<h1 class="font-title-lg text-on-primary-container hidden md:block">Bonjour Jean 👋</h1>
<h1 class="font-title-lg text-on-primary-container md:hidden">Bonjour Jean 👋</h1>
<div class="flex items-center gap-sm">
<button class="p-sm text-on-primary-container hover:bg-white/10 rounded-full transition-colors flex items-center justify-center">
<span class="material-symbols-outlined" data-icon="notifications">notifications</span>
</button>
<div class="w-10 h-10 rounded-full overflow-hidden border-2 border-on-primary-container/20">
<img class="w-full h-full object-cover" data-alt="A professional close-up portrait of a friendly real estate agent with a warm smile, wearing a clean white shirt, set against a blurred modern office background with soft blue tones and elegant lighting to convey trust and accessibility." src="https://lh3.googleusercontent.com/aida-public/AB6AXuCHI0_V8m1ggDHireYKd3r7D3oHci-Mw_3wpZQdCj-hsqo5IXwb-0xJd9lopRA3UsUgPU4GgPj8eZk3wUYmOnTsOe9DNENNg4uQDEvNRIcWWBrVjtp_SeNrF4Jw4cteHycLp0Y4574g3IKaYLj7b0pfwAWQZiQ3xrwaYlIwVC45GDG8ZqP3QMEUhnKt0_ACu-MVSZwv2BfF688Pa-KrKO7teqBESZrCltBkuyVipEIaE4tI_Pg9WpEChwuxMA853De8mIKNsVxIwuc">
</div>
</div>
</header>
<main class="mt-16">
<!-- Search Section -->
<section class="bg-[#EBF4FB] py-xl px-gutter">
<div class="max-w-container-max mx-auto">
<div class="relative group">
<div class="absolute inset-y-0 left-4 flex items-center pointer-events-none text-primary">
<span class="material-symbols-outlined" data-icon="search">search</span>
</div>
<input class="w-full h-14 pl-12 pr-12 rounded-full border-none shadow-[0_4px_12px_rgba(26,86,160,0.05)] focus:ring-2 focus:ring-primary-container bg-surface-container-lowest text-on-surface font-body-lg" placeholder="Où cherchez-vous ?" type="text">
<button class="absolute inset-y-0 right-4 flex items-center text-primary hover:scale-105 transition-transform">
<span class="material-symbols-outlined" data-icon="tune">tune</span>
</button>
</div>
</div>
</section>
<!-- Categories Chips -->
<section class="py-md overflow-hidden">
<div class="flex gap-sm px-gutter overflow-x-auto hide-scrollbar snap-x">





</div>
</section>
<!-- Biens récents Section -->
<section class="py-xl">
<div class="px-gutter mb-md flex justify-between items-center">
<h2 class="font-headline-md text-on-background">Biens récents</h2>
<button class="text-primary font-label-md flex items-center gap-xs">
                    Voir tout <span class="material-symbols-outlined text-sm" data-icon="chevron_right">chevron_right</span>
</button>
</div>
<div class="flex gap-lg px-gutter overflow-x-auto hide-scrollbar pb-lg snap-x">
<!-- Property Card 1 -->
<div class="snap-start flex-none w-72 bg-surface-container-lowest rounded-xl shadow-[0_4px_12px_rgba(26,86,160,0.05)] overflow-hidden hover:shadow-lg transition-shadow">
<div class="relative h-48"><video autoplay="" class="w-full h-full object-cover" loop="" muted="" playsinline="" poster="https://lh3.googleusercontent.com/aida-public/AB6AXuCrww9Pr8cMbYfMFVFzBhQc5gWasEDWMP6MiFtDgixb70Sg-eM5UBmr3HUi6wYnjiIUwlsraczaZMT1hut3ZedR3Umg4VkNJygKNMc478RUBUNiKc1beLCNCBnKymD8uJeVlDMItXQPDfAkAaYzxIHndCho1paO6IbWXgKJPgTVJzgPrctu4l_3CqdSQZ0Tj1MuyZPCRivmiYUXXojau68ccSGTkrRWfFk0jmTpU7HKzM_fSjlLgy4OXkf0J9sUVdpogQtSwvdWkvk"><source src="#" type="video/mp4"></video><div class="absolute top-sm left-sm bg-tertiary-container text-on-tertiary-container px-sm py-1 rounded-full text-[10px] font-bold flex items-center gap-1"><span class="material-symbols-outlined text-[12px]" data-icon="verified" style="font-variation-settings: &quot;FILL&quot; 1;">verified</span>Vérifié ✓</div><div class="absolute bottom-sm right-sm bg-black/50 text-white px-sm py-1 rounded-full text-[10px] font-bold flex items-center gap-1 backdrop-blur-sm"><span class="material-symbols-outlined text-[14px]" data-icon="play_circle">play_circle</span>Vidéo</div></div>
<div class="p-md">
<p class="text-primary font-bold text-lg">450 000 €</p>
<p class="text-on-surface-variant font-body-md line-clamp-2 mt-1">Appartement T4 moderne avec vue mer, terrasse et parking privé.</p>
<div class="flex items-center gap-md mt-sm text-on-secondary-container/60 text-xs">
<div class="flex items-center gap-1"><span class="material-symbols-outlined text-sm" data-icon="bed">bed</span> 3</div>
<div class="flex items-center gap-1"><span class="material-symbols-outlined text-sm" data-icon="square_foot">square_foot</span> 85m²</div>
<div class="flex items-center gap-1"><span class="material-symbols-outlined text-sm" data-icon="location_on">location_on</span> Nice</div>
</div>
</div>
</div>
<!-- Property Card 2 -->
<div class="snap-start flex-none w-72 bg-surface-container-lowest rounded-xl shadow-[0_4px_12px_rgba(26,86,160,0.05)] overflow-hidden hover:shadow-lg transition-shadow">
<div class="relative h-48">
<img class="w-full h-full object-cover" data-alt="A charming Parisian style apartment building with ornate iron balconies and large windows overlooking a cobblestone street. The lighting is soft morning sunlight casting long, gentle shadows. The color palette consists of cream stone, dark slate rooftops, and pops of floral window boxes. Elegant, high-contrast urban landscape photography." src="https://lh3.googleusercontent.com/aida-public/AB6AXuA68W_k2pfItwZs7mSWW8SJviUEOjsddBu6gWrOF6hzqV1A9xaMjQlFF0mC89_ym1OtM17RQTv2YUaiNe_z2OkGqusZGqxrbiMDukk6prYal4NLh7O4bQxo48wqxZSGhgfnw4p65wcbOzHep-MyvG460nE2tcwq7ApXv80FpMV4nv6CzH9oHvKmqkt37yGwa8C7AVHqiIqss2wve_SZrNlr2zCDIPtQawt1-NSoObThWwUn08suGKpc6pVjJCxmlQjjbuv1MeNaDD4">
<div class="absolute top-sm left-sm bg-tertiary-container text-on-tertiary-container px-sm py-1 rounded-full text-[10px] font-bold flex items-center gap-1">
<span class="material-symbols-outlined text-[12px]" data-icon="verified" style="font-variation-settings: &quot;FILL&quot; 1;">verified</span>
                            Vérifié ✓
                        </div>
</div>
<div class="p-md">
<p class="text-primary font-bold text-lg">315 000 €</p>
<p class="text-on-surface-variant font-body-md line-clamp-2 mt-1">Charmant studio rénové, cœur historique, calme et lumineux.</p>
<div class="flex items-center gap-md mt-sm text-on-secondary-container/60 text-xs">
<div class="flex items-center gap-1"><span class="material-symbols-outlined text-sm" data-icon="bed">bed</span> 1</div>
<div class="flex items-center gap-1"><span class="material-symbols-outlined text-sm" data-icon="square_foot">square_foot</span> 35m²</div>
<div class="flex items-center gap-1"><span class="material-symbols-outlined text-sm" data-icon="location_on">location_on</span> Lyon</div>
</div>
</div>
</div>
<!-- Property Card 3 -->
<div class="snap-start flex-none w-72 bg-surface-container-lowest rounded-xl shadow-[0_4px_12px_rgba(26,86,160,0.05)] overflow-hidden hover:shadow-lg transition-shadow">
<div class="relative h-48">
<img class="w-full h-full object-cover" data-alt="A cozy mountain chalet made of dark wood and stone, nestled among snow-capped pine trees in the French Alps. Warm yellow light glows from the windows against a crisp, blue twilight sky. The scene is serene and luxurious, captured in a clean, professional travel photography style with sharp details and balanced exposures." src="https://lh3.googleusercontent.com/aida-public/AB6AXuCz9lJPNovz2urtIzh4boR2gSkMDU-TtGZLAK8f_u4azDT7eHvmzwj5LpsVEaIABmnudylh1befdNJx4SZ_KZ3e409dlZuaLL2rBEljC1HLycfH9pZc1UhmETLGqx5L2UaMjMcC-RBVW3K7ZZNoobJYcN_5dwgBoEAd3-0FyUIP3mUGKfePhT7u1qA_2SxfcYiHId2vCeMYPI7MATrlc1TBtwP8tX0e5rmIOIc5gPAXu1Wak9NPe__ZukKse7m5hwBBzL-Vdm5pq8s">
<div class="absolute top-sm left-sm bg-tertiary-container text-on-tertiary-container px-sm py-1 rounded-full text-[10px] font-bold flex items-center gap-1">
<span class="material-symbols-outlined text-[12px]" data-icon="verified" style="font-variation-settings: &quot;FILL&quot; 1;">verified</span>
                            Vérifié ✓
                        </div>
</div>
<div class="p-md">
<p class="text-primary font-bold text-lg">890 000 €</p>
<p class="text-on-surface-variant font-body-md line-clamp-2 mt-1">Chalet d'exception, accès pistes, prestations haut de gamme.</p>
<div class="flex items-center gap-md mt-sm text-on-secondary-container/60 text-xs">
<div class="flex items-center gap-1"><span class="material-symbols-outlined text-sm" data-icon="bed">bed</span> 5</div>
<div class="flex items-center gap-1"><span class="material-symbols-outlined text-sm" data-icon="square_foot">square_foot</span> 210m²</div>
<div class="flex items-center gap-1"><span class="material-symbols-outlined text-sm" data-icon="location_on">location_on</span> Megève</div>
</div>
</div>
</div>
</div>
</section>
<!-- Près de vous Section -->
<section class="py-xl px-gutter">
<h2 class="font-headline-md text-on-background mb-md">Près de vous</h2>
<div class="relative h-64 rounded-xl overflow-hidden shadow-lg border border-outline-variant/30">
<div class="absolute inset-0 bg-gray-100" data-location="Paris, France">
<img class="w-full h-full object-cover" data-alt="A detailed, high-quality satellite and vector hybrid map of a Parisian neighborhood. The map shows clean white and light grey streets, pale green parks, and subtle blue river accents. Superimposed on the map are several bright blue modern pin icons and subtle circular pulses to indicate hotspots. Professional digital cartography aesthetic." src="https://lh3.googleusercontent.com/aida-public/AB6AXuC6sEQYgli_38cswRI1Xov5D5uHUskShSEno2f-190toKxisPbl9XizLeqtLC0_Kvn-u8iaDXVRAUGFC_DPN51Y25Maa2fstFzR7ri_Tu1gHrqFLqTBc-2YeCvEvhHTEeA_h9jeCU0u__W39gASC5nXH52yxQ5jLPZ8DimIpwkKRnsZrCFTKd_DTPEKBDpZlCBYMaWOTkQ3rer3LNcHu-I46PizdwZ8p-o3K2C4iE5s_wQji8ij56W8rOwvA-TuKqM--Llo948e64A">
</div>
<!-- Stylized Pins Overlay -->
<div class="absolute inset-0 pointer-events-none">
<div class="absolute top-1/4 left-1/3 p-2 bg-primary text-on-primary rounded-full shadow-lg flex items-center justify-center transform -translate-x-1/2 -translate-y-1/2 animate-bounce" style="animation-duration: 3s;">
<span class="material-symbols-outlined text-sm" data-icon="location_on" style="font-variation-settings: &quot;FILL&quot; 1;">location_on</span>
</div>
<div class="absolute top-1/2 left-2/3 p-2 bg-primary text-on-primary rounded-full shadow-lg flex items-center justify-center transform -translate-x-1/2 -translate-y-1/2 animate-bounce" style="animation-duration: 2.5s; animation-delay: 0.5s;">
<span class="material-symbols-outlined text-sm" data-icon="location_on" style="font-variation-settings: &quot;FILL&quot; 1;">location_on</span>
</div>
<div class="absolute bottom-1/4 right-1/4 p-2 bg-primary text-on-primary rounded-full shadow-lg flex items-center justify-center transform -translate-x-1/2 -translate-y-1/2 animate-bounce" style="animation-duration: 3.5s; animation-delay: 1s;">
<span class="material-symbols-outlined text-sm" data-icon="location_on" style="font-variation-settings: &quot;FILL&quot; 1;">location_on</span>
</div>
</div>
<!-- Map UI Controls -->
<div class="absolute bottom-sm right-sm flex flex-col gap-sm">
<button class="w-10 h-10 bg-surface-container-lowest rounded-lg shadow-md flex items-center justify-center text-primary pointer-events-auto">
<span class="material-symbols-outlined" data-icon="add">add</span>
</button>
<button class="w-10 h-10 bg-surface-container-lowest rounded-lg shadow-md flex items-center justify-center text-primary pointer-events-auto">
<span class="material-symbols-outlined" data-icon="remove">remove</span>
</button>
</div>
<div class="absolute top-sm right-sm pointer-events-auto">
<button class="px-md py-sm bg-surface-container-lowest rounded-full shadow-md text-primary font-label-md flex items-center gap-sm">
<span class="material-symbols-outlined text-sm" data-icon="my_location">my_location</span>
                        Ma position
                    </button>
</div>
</div>
</section>
</main>
<!-- BottomNavBar -->
<nav class="fixed bottom-0 left-0 w-full bg-surface-container-lowest dark:bg-inverse-surface h-20 shadow-[0_-4px_12px_rgba(26,86,160,0.05)] border-t border-outline-variant/30 px-gutter pb-safe z-50 flex justify-around items-center">
<a class="flex flex-col items-center justify-center text-primary dark:text-primary-fixed-dim font-bold transition-all scale-100 hover:opacity-80 active:scale-90" href="#">
<span class="material-symbols-outlined" data-icon="home" style="font-variation-settings: &quot;FILL&quot; 1;">home</span>
<span class="font-label-md text-label-md">Accueil</span>
</a>
<a class="flex flex-col items-center justify-center text-secondary dark:text-secondary-fixed-dim transition-all hover:opacity-80 active:scale-90" href="#">
<span class="material-symbols-outlined" data-icon="search">search</span>
<span class="font-label-md text-label-md">Recherche</span>
</a>
<!-- Central Plus Button -->
<div class="relative -top-6">
<button class="w-14 h-14 bg-primary-container text-on-primary rounded-full shadow-lg flex items-center justify-center transition-all hover:scale-110 active:scale-95 border-4 border-surface-container-lowest">
<span class="material-symbols-outlined text-3xl" data-icon="add">add</span>
</button>
<span class="absolute -bottom-6 left-1/2 -translate-x-1/2 font-label-md text-secondary dark:text-secondary-fixed-dim">Vendre</span>
</div>
<a class="flex flex-col items-center justify-center text-secondary dark:text-secondary-fixed-dim transition-all hover:opacity-80 active:scale-90" href="#">
<span class="material-symbols-outlined" data-icon="favorite">favorite</span>
<span class="font-label-md text-label-md">Mes Biens</span>
</a>
<a class="flex flex-col items-center justify-center text-secondary dark:text-secondary-fixed-dim transition-all hover:opacity-80 active:scale-90" href="#">
<span class="material-symbols-outlined" data-icon="person">person</span>
<span class="font-label-md text-label-md">Profil</span>
</a>
</nav>
<script>
        // Micro-interaction for property card scrolling
        const horizontalSliders = document.querySelectorAll('.hide-scrollbar');
        horizontalSliders.forEach(slider => {
            let isDown = false;
            let sx;
            let sl;

            slider.addEventListener('mousedown', (e) => {
                isDown = true;
                slider.classList.add('cursor-grabbing');
                sx = e.pageX - slider.offsetLeft;
                sl = slider.scrollLeft;
            });
            slider.addEventListener('mouseleave', () => {
                isDown = false;
                slider.classList.remove('cursor-grabbing');
            });
            slider.addEventListener('mouseup', () => {
                isDown = false;
                slider.classList.remove('cursor-grabbing');
            });
            slider.addEventListener('mousemove', (e) => {
                if(!isDown) return;
                e.preventDefault();
                const x = e.pageX - slider.offsetLeft;
                const walk = (x - sx) * 2;
                slider.scrollLeft = sl - walk;
            });
        });

        // Simple search focus effect
        const searchInput = document.querySelector('input[type="text"]');
        searchInput.addEventListener('focus', () => {
            searchInput.parentElement.classList.add('scale-[1.01]');
            searchInput.parentElement.style.transition = 'transform 0.2s ease-out';
        });
        searchInput.addEventListener('blur', () => {
            searchInput.parentElement.classList.remove('scale-[1.01]');
        });
    </script>


</body></html>Faire la page d'accueil;celle apres inscription du client .Que l'ecran ne deborde pas jusqu'a la barre de notification.Permettre que la video se joue automatiquemen.