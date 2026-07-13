<!DOCTYPE html><html lang="fr" class="light" style=""><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&amp;display=swap" rel="stylesheet"><link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=block" rel="stylesheet"><script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script><script id="tailwind-config">try{
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    "colors": {
                        "surface-variant": "#e0e3e5",
                        "surface-container-highest": "#e0e3e5",
                        "secondary-fixed": "#dbe4eb",
                        "on-tertiary-container": "#6fe1af",
                        "on-background": "#191c1e",
                        "primary": "#003e7e",
                        "on-error": "#ffffff",
                        "inverse-primary": "#a9c7ff",
                        "on-tertiary-fixed-variant": "#005138",
                        "tertiary-fixed": "#86f8c5",
                        "surface": "#f7f9fb",
                        "on-secondary-container": "#5d666c",
                        "primary-fixed-dim": "#a9c7ff",
                        "surface-container-low": "#f2f4f6",
                        "outline": "#737782",
                        "surface-container-lowest": "#ffffff",
                        "secondary-container": "#dbe4eb",
                        "on-tertiary": "#ffffff",
                        "on-secondary": "#ffffff",
                        "on-primary-container": "#b3cdff",
                        "on-secondary-fixed": "#141d22",
                        "surface-bright": "#f7f9fb",
                        "primary-fixed": "#d6e3ff",
                        "error-container": "#ffdad6",
                        "secondary-fixed-dim": "#bfc8ce",
                        "on-secondary-fixed-variant": "#3f484e",
                        "tertiary": "#004931",
                        "surface-container-high": "#e6e8ea",
                        "on-primary-fixed-variant": "#00468c",
                        "secondary": "#576065",
                        "surface-tint": "#265ea8",
                        "on-tertiary-fixed": "#002114",
                        "outline-variant": "#c2c6d3",
                        "on-surface": "#191c1e",
                        "inverse-on-surface": "#eff1f3",
                        "on-error-container": "#93000a",
                        "tertiary-container": "#006344",
                        "surface-container": "#eceef0",
                        "on-primary": "#ffffff",
                        "on-primary-fixed": "#001b3d",
                        "primary-container": "#1a56a0",
                        "background": "#f7f9fb",
                        "inverse-surface": "#2d3133",
                        "tertiary-fixed-dim": "#69dbaa",
                        "surface-dim": "#d8dadc",
                        "on-surface-variant": "#424751",
                        "error": "#ba1a1a"
                    },
                    "borderRadius": {
                        "DEFAULT": "0.25rem",
                        "lg": "0.5rem",
                        "xl": "0.75rem",
                        "full": "9999px"
                    },
                    "spacing": {
                        "gutter": "16px",
                        "base": "4px",
                        "md": "16px",
                        "xl": "32px",
                        "container-max": "1280px",
                        "xs": "4px",
                        "sm": "8px",
                        "lg": "24px"
                    },
                    "fontFamily": {
                        "display-lg-mobile": ["Inter"],
                        "title-lg": ["Inter"],
                        "headline-md": ["Inter"],
                        "display-lg": ["Inter"],
                        "body-lg": ["Inter"],
                        "label-sm": ["Inter"],
                        "label-md": ["Inter"],
                        "body-md": ["Inter"]
                    },
                    "fontSize": {
                        "display-lg-mobile": ["28px", {"lineHeight": "34px", "fontWeight": "700"}],
                        "title-lg": ["20px", {"lineHeight": "28px", "fontWeight": "600"}],
                        "headline-md": ["24px", {"lineHeight": "32px", "fontWeight": "600"}],
                        "display-lg": ["36px", {"lineHeight": "44px", "letterSpacing": "-0.02em", "fontWeight": "700"}],
                        "body-lg": ["16px", {"lineHeight": "24px", "fontWeight": "400"}],
                        "label-sm": ["11px", {"lineHeight": "14px", "fontWeight": "500"}],
                        "label-md": ["12px", {"lineHeight": "16px", "letterSpacing": "0.01em", "fontWeight": "600"}],
                        "body-md": ["14px", {"lineHeight": "20px", "fontWeight": "400"}]
                    }
                },
            },
        }
    }catch(_e){}</script><meta charset="utf-8"></head><body class="bg-surface text-on-surface min-h-screen pb-24">
<!-- Top App Bar -->
<header class="fixed top-0 left-0 w-full z-50 bg-primary-container shadow-sm flex justify-between items-center px-md py-sm">
<div class="flex items-center gap-md">

<button class="w-10 h-10 -ml-2 flex items-center justify-center rounded-full text-on-primary-container hover:bg-primary/10 transition-colors active:scale-95 duration-150">
<span class="material-symbols-outlined">arrow_back</span>
</button><h1 class="font-title-lg text-title-lg text-on-primary-container">Mes Biens</h1>
</div>

</header>
<main class="pt-20 px-gutter">
<!-- Tabs -->
<div class="sticky top-[64px] z-40 bg-surface/95 backdrop-blur-md pt-4 pb-2">
<div class="flex bg-surface-container-low rounded-xl p-1 relative">
<button class="flex-1 py-3 text-center z-10 font-label-md text-label-md transition-colors text-primary font-bold" id="tab-annonces" onclick="switchTab('annonces')">
                    Mes Annonces
                </button>
<button class="flex-1 py-3 text-center z-10 font-label-md text-label-md transition-colors text-secondary" id="tab-locations" onclick="switchTab('locations')">
                    Mes Locations
                </button>
<div class="active-tab-indicator absolute top-1 left-1 bottom-1 w-[calc(50%-4px)] bg-surface-container-lowest rounded-lg shadow-sm" id="tab-indicator"></div>
</div>
</div>
<!-- Section 1: Mes Annonces -->
<section class="mt-md space-y-md" id="section-annonces">
<div class="flex flex-col items-start gap-sm">
<h2 class="font-title-lg text-title-lg text-primary">Annonces actives</h2>
<div class="flex gap-xs overflow-x-auto hide-scrollbar pb-1">
    <button class="px-3 py-1 rounded-full bg-primary-container text-on-primary-container text-label-md font-label-md whitespace-nowrap">Tous</button>
    <button class="px-3 py-1 rounded-full border border-outline-variant/30 text-secondary text-label-md font-label-md whitespace-nowrap">En attente de vérif</button>
    <button class="px-3 py-1 rounded-full border border-outline-variant/30 text-secondary text-label-md font-label-md whitespace-nowrap">Publié</button>
</div>
</div>
<!-- Card 1: Publié -->
<div class="bg-surface-container-lowest rounded-xl p-md shadow-[0_4px_12px_rgba(26,86,160,0.05)] flex gap-md border border-outline-variant/10 active:scale-[0.98] transition-transform">
<div class="w-24 h-24 rounded-lg overflow-hidden shrink-0">
<img class="w-full h-full object-cover" data-alt="A modern luxury penthouse apartment interior in Paris, featuring floor-to-ceiling windows with a view of the city skyline. Bright daylight floods the room, highlighting premium materials like white marble floors and oak wood accents. Professional architectural photography style with a clean, airy atmosphere." src="https://lh3.googleusercontent.com/aida-public/AB6AXuCRoowAMiMHonDCoUSIgL-sXO-Vhgly98Rdgq7EcqLpIGr3OlGpo2yuxk6CXbPJ38nkTnpoO7kBEM00O_m2fJRPV8KzxbolTgoqcUNnVpCwpH5w-bTRK-s8PIxp-bHyXgsXCGjT4AZ2XOnVUsWks6oml8CDVxJyLWeRMRAa7C3UGIO1qr0ZGDKrmT3bxRX1O_rB1OTXNfWjWytkN3Arwyg9i726onYnTznPms-135agDmbjXAPz9QO8Ppl_unzJe198minU61T-Mco">
</div>
<div class="flex flex-col justify-between py-1 flex-1">
<div>
<div class="flex justify-between items-start">
<h3 class="font-label-md text-label-md text-on-surface line-clamp-1">Appartement Haussmannien - T3</h3>
<span class="bg-tertiary-fixed text-on-tertiary-fixed-variant px-2 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider">Publié</span>
</div>
<p class="font-headline-md text-headline-md text-primary mt-1">1 250 000 €</p>
</div>
<div class="flex items-center gap-xs text-secondary">
<span class="material-symbols-outlined text-[16px]" data-original-icon="location_on">location_on</span>
<span class="text-label-sm font-label-sm">Paris 8ème</span>
</div>
</div>
</div>
<!-- Card 2: En attente -->
<div class="bg-surface-container-lowest rounded-xl p-md shadow-[0_4px_12px_rgba(26,86,160,0.05)] flex gap-md border border-outline-variant/10 active:scale-[0.98] transition-transform">
<div class="w-24 h-24 rounded-lg overflow-hidden shrink-0">
<img class="w-full h-full object-cover" data-alt="A charming villa in the south of France, featuring a blue private swimming pool and a lush Mediterranean garden under a clear summer sky. The sunlight is vibrant and warm, casting soft shadows on the stone terrace. High-end real estate photography with a focus on vacation vibes and luxury living." src="https://lh3.googleusercontent.com/aida-public/AB6AXuCJy0dpnfhUXnFskMnONBUrnu8Ozl390jzUY__Qkn0QtEUet-IgLGKSmIHHq0bWWSINt1nKzMrQgYdke4liee7SCju7joeRhXukluttHnJaGqNWatsXLhz-TLZ7CGeScqRg1CG85AokbvH4bSoDEjfihjXLZsIiODx__Aywt6xBhjq1YnSA8QG4HSL-zHxE2BKSuIG3Fax6HHUQaqRhvKe65K1aYnmoHaXVljQS0lNIqRZrPtqZFl6_T3fcP-R67-MPyT8DiTD7GXs">
</div>
<div class="flex flex-col justify-between py-1 flex-1">
<div>
<div class="flex justify-between items-start">
<h3 class="font-label-md text-label-md text-on-surface line-clamp-1">Villa avec piscine - Côte d'Azur</h3>
<span class="bg-primary-fixed text-on-primary-fixed-variant px-2 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider">En vérification</span>
</div>
<p class="font-headline-md text-headline-md text-primary mt-1">890 000 €</p>
</div>
<div class="flex items-center gap-xs text-secondary">
<span class="material-symbols-outlined text-[16px]">location_on</span>
<span class="text-label-sm font-label-sm">Nice</span>
</div>
</div>
</div>
<!-- Card 3: Brouillon -->
<div class="bg-surface-container-lowest rounded-xl p-md shadow-[0_4px_12px_rgba(26,86,160,0.05)] flex gap-md border border-outline-variant/10 opacity-75 active:scale-[0.98] transition-transform">
<div class="w-24 h-24 rounded-lg overflow-hidden shrink-0 grayscale-[50%]">
<img class="w-full h-full object-cover" data-alt="A minimalist loft workspace in Bordeaux with exposed brick walls and industrial black metal windows. Soft afternoon light creates a calm, creative atmosphere. The photography is clean and professional, showcasing the raw potential of the urban property space." src="https://lh3.googleusercontent.com/aida-public/AB6AXuCpY4A9e7J5F_TB8IWtrkegR7E2kiLnoDiExMHMTl-mwB1VZxuAioeTWJ9r36o2oMBk5bFwEGgBKLdNAFRJIs55Ku2miHDVpy_UltlG6NhdsVjNGboK22PbaPMgxekRXLYBaR-vJE6HVTU7zADzTTpT-DBEnyeeTCEwrlrA3RdcmhQ8LP79Wy1oCoz9ClQomJ-YwrA_4E5xLLLBfx9v8Raggieed4PvmODlQP4NhSgr_VaJttGj1e5et8PjHD4gWHnRuLBYodXr0Fc">
</div>
<div class="flex flex-col justify-between py-1 flex-1">
<div>
<div class="flex justify-between items-start">
<h3 class="font-label-md text-label-md text-on-surface line-clamp-1">Loft Industriel - Plateau</h3>
<span class="bg-secondary-container text-on-secondary-container px-2 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider">Brouillon</span>
</div>
<p class="font-headline-md text-headline-md text-primary mt-1">450 000 €</p>
</div>
<div class="flex items-center gap-xs text-secondary">
<span class="material-symbols-outlined text-[16px]">history</span>
<span class="text-label-sm font-label-sm">Modifié il y a 2 jours</span>
</div>
</div>
</div>
</section>
<!-- Section 2: Mes Locations/Réservations (Hidden by default) -->
<section class="mt-md space-y-md hidden" id="section-locations">
<div class="flex justify-between items-center">
<h2 class="font-title-lg text-title-lg text-primary">Mes séjours</h2>
<span class="text-label-md font-label-md text-secondary bg-surface-container-high px-sm py-1 rounded-full">2 réservations</span>
</div>
<!-- Card 1: En cours -->
<div class="bg-surface-container-lowest rounded-xl overflow-hidden shadow-[0_4px_12px_rgba(26,86,160,0.05)] border border-outline-variant/10 active:scale-[0.99] transition-transform">
<div class="relative h-40">
<img class="w-full h-full object-cover" data-alt="A modern wooden cabin nestled in the snowy French Alps, surrounded by pine trees under a sunset sky with shades of pink and orange. Warm light glows from the cabin windows, creating a cozy and inviting contrast with the cold snow. Cinematic mountain lifestyle photography." src="https://lh3.googleusercontent.com/aida-public/AB6AXuAEgvK81KCFW_8hla8kCfZj-pcmNijnJvhjKuMuG0iPGIwdrk-6ImpOWBsthzfi5al-plll6YmWIWEDHqH5F2n2V4aEovvjru6NlyFTukhVFNT2YscN2-Nu3qleWf-w3E87lCA22ebvMOyvGZqkKIPrtgpnyCtejE23AKi8xNvnFlswadWVQC-4rncKYcNoKWzA3YWd7tnkticUUdTOtTkjJrwaEnmc5pK8LSnAw2ntbrmiD0yERPUwlVOCnX15MMfRM-fELyX8Owo">
<div class="absolute top-3 left-3 bg-tertiary-container text-on-tertiary-container px-3 py-1 rounded-full text-[11px] font-bold flex items-center gap-1">
<span class="w-1.5 h-1.5 rounded-full bg-on-tertiary-container animate-pulse"></span>
                        EN COURS
                    </div>
</div>
<div class="p-md">
<h3 class="font-title-lg text-title-lg text-on-surface">Chalet Alpin "Lumière"</h3>
<div class="mt-2 flex items-center gap-4">
<div class="flex items-center gap-xs text-secondary">
<span class="material-symbols-outlined text-[18px]">calendar_today</span>
<span class="text-label-md font-label-md">12 Jan - 19 Jan</span>
</div>
<div class="flex items-center gap-xs text-secondary">
<span class="material-symbols-outlined text-[18px]">location_on</span>
<span class="text-label-md font-label-md">Chamonix</span>
</div>
</div>
</div>
</div>
<!-- Card 2-->
<div class="bg-surface-container-lowest rounded-xl overflow-hidden shadow-[0_4px_12px_rgba(26,86,160,0.05)] border border-outline-variant/10 active:scale-[0.99] transition-transform">
<div class="relative h-40">
<img class="w-full h-full object-cover" data-alt="A sunny contemporary beach house in Biarritz with a large wooden deck and outdoor lounge furniture. The Atlantic Ocean is visible in the background with waves crashing against the cliffs. High-key lighting, vibrant ocean blues and sandy tones, clean corporate aesthetic for luxury vacation rentals." src="https://lh3.googleusercontent.com/aida-public/AB6AXuA7lENh7LOYVgtDSThOlolc_ozxDLI2vdtZ-oZhQ-Sq3rQpnTlOIzEmjVxcWbR2PrDrukdVCmVrMvFCD5GmepclaTgynY1qvg-Z9W5bEFBWZag-m79rSfDBnIQOepdFhZD9UovEPgluUy_D6Trb4LMpSZEXSD4xCyjDxkJvM2irnr0sRwNaIdORRrf8NxyNksNQLkGc9UBFa_sqj_d9SWdAbbkfGaSp2cAeBMGYOy_uneHtCsJ3aQyJ2SnziDbblsIH06SrnL4Nwj4">
<div class="absolute top-3 left-3 bg-primary-container text-on-primary-container px-3 py-1 rounded-full text-[11px] font-bold">
                        CONFIRMÉ
                    </div>
</div>
<div class="p-md">
<h3 class="font-title-lg text-title-lg text-on-surface">Villa Mer &amp; Surf</h3>
<div class="mt-2 flex items-center gap-4">
<div class="flex items-center gap-xs text-secondary">
<span class="material-symbols-outlined text-[18px]">calendar_today</span>
<span class="text-label-md font-label-md">05 Mar - 12 Mar</span>
</div>
<div class="flex items-center gap-xs text-secondary">
<span class="material-symbols-outlined text-[18px]">location_on</span>
<span class="text-label-md font-label-md">Biarritz</span>
</div>
</div>
</div>
</div>
</section>
</main>
<!-- Bottom Nav Bar -->
<nav class="fixed bottom-0 left-0 w-full flex justify-around items-center bg-surface-container-lowest dark:bg-inverse-surface px-gutter pb-safe z-50 h-20 border-t border-outline-variant/30 shadow-[0_-4px_12px_rgba(26,86,160,0.05)]">
<button class="flex flex-col items-center justify-center text-secondary dark:text-secondary-fixed-dim hover:opacity-80 transition-opacity active:scale-90 duration-150">
<span class="material-symbols-outlined">home</span>
<span class="font-label-md text-label-md mt-1">Accueil</span>
</button>
<button class="flex flex-col items-center justify-center text-secondary dark:text-secondary-fixed-dim hover:opacity-80 transition-opacity active:scale-90 duration-150">
<span class="material-symbols-outlined">search</span>
<span class="font-label-md text-label-md mt-1">Recherche</span>
</button>
<!-- Center Action Button (Add) -->
<div class="relative -top-6">
<button class="w-14 h-14 bg-primary text-on-primary rounded-full shadow-lg flex items-center justify-center active:scale-95 transition-transform">
<span class="material-symbols-outlined text-[32px]">add</span>
</button>
</div>
<button class="flex flex-col items-center justify-center text-primary dark:text-primary-fixed-dim font-bold hover:opacity-80 transition-opacity active:scale-90 duration-150">
<span class="material-symbols-outlined" style="font-variation-settings: &quot;FILL&quot; 1;">favorite</span>
<span class="font-label-md text-label-md mt-1">Mes Biens</span>
</button>
<button class="flex flex-col items-center justify-center text-secondary dark:text-secondary-fixed-dim hover:opacity-80 transition-opacity active:scale-90 duration-150">
<span class="material-symbols-outlined">person</span>
<span class="font-label-md text-label-md mt-1">Profil</span>
</button>
</nav>
<script>
        function switchTab(tab) {
            const sectionAnnonces = document.getElementById('section-annonces');
            const sectionLocations = document.getElementById('section-locations');
            const tabAnnonces = document.getElementById('tab-annonces');
            const tabLocations = document.getElementById('tab-locations');
            const indicator = document.getElementById('tab-indicator');

            if (tab === 'annonces') {
                sectionAnnonces.classList.remove('hidden');
                sectionLocations.classList.add('hidden');
                tabAnnonces.classList.add('text-primary', 'font-bold');
                tabAnnonces.classList.remove('text-secondary');
                tabLocations.classList.add('text-secondary');
                tabLocations.classList.remove('text-primary', 'font-bold');
                indicator.style.transform = 'translateX(0)';
            } else {
                sectionAnnonces.classList.add('hidden');
                sectionLocations.classList.remove('hidden');
                tabLocations.classList.add('text-primary', 'font-bold');
                tabLocations.classList.remove('text-secondary');
                tabAnnonces.classList.add('text-secondary');
                tabAnnonces.classList.remove('text-primary', 'font-bold');
                indicator.style.transform = 'translateX(100%)';
            }
            
            // Haptic feedback simulation
            if (window.navigator && window.navigator.vibrate) {
                window.navigator.vibrate(5);
            }
        }
    </script>

</body></html>