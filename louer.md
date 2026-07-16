<!DOCTYPE html>

<html class="light" lang="fr"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>ImmoPro - Sélection de la durée</title>
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
                    "on-secondary-container": "#54647a",
                    "on-secondary-fixed-variant": "#38485d",
                    "on-error": "#ffffff",
                    "secondary-container": "#d0e1fb",
                    "on-secondary-fixed": "#0b1c30",
                    "on-surface": "#191c1e",
                    "surface-tint": "#265ea8",
                    "on-tertiary-fixed": "#311300",
                    "inverse-surface": "#2d3133",
                    "inverse-primary": "#a9c7ff",
                    "surface-container-high": "#e6e8ea",
                    "surface-container": "#eceef0",
                    "on-secondary": "#ffffff",
                    "error-container": "#ffdad6",
                    "on-error-container": "#93000a",
                    "inverse-on-surface": "#eff1f3",
                    "outline": "#737782",
                    "secondary-fixed": "#d3e4fe",
                    "surface-container-low": "#f2f4f6",
                    "tertiary": "#673000",
                    "on-background": "#191c1e",
                    "outline-variant": "#c2c6d3",
                    "primary": "#003e7e",
                    "primary-container": "#1a56a0",
                    "on-tertiary-container": "#ffbf95",
                    "on-tertiary-fixed-variant": "#723600",
                    "surface-bright": "#f7f9fb",
                    "primary-fixed-dim": "#a9c7ff",
                    "background": "#f7f9fb",
                    "tertiary-fixed-dim": "#ffb786",
                    "secondary": "#505f76",
                    "on-surface-variant": "#424751",
                    "surface-container-highest": "#e0e3e5",
                    "surface-dim": "#d8dadc",
                    "on-tertiary": "#ffffff",
                    "primary-fixed": "#d6e3ff",
                    "error": "#ba1a1a",
                    "tertiary-container": "#8a4300",
                    "on-primary-fixed": "#001b3d",
                    "secondary-fixed-dim": "#b7c8e1",
                    "on-primary-fixed-variant": "#00468c",
                    "on-primary-container": "#b3cdff",
                    "on-primary": "#ffffff",
                    "surface-variant": "#e0e3e5",
                    "tertiary-fixed": "#ffdcc6",
                    "surface": "#f7f9fb",
                    "surface-container-lowest": "#ffffff"
            },
            "borderRadius": {
                    "DEFAULT": "0.125rem",
                    "lg": "0.25rem",
                    "xl": "0.5rem",
                    "full": "0.75rem"
            },
            "spacing": {
                    "margin-desktop": "40px",
                    "max-width": "1280px",
                    "sm": "8px",
                    "lg": "24px",
                    "margin-mobile": "16px",
                    "xs": "4px",
                    "base": "4px",
                    "gutter": "16px",
                    "md": "16px",
                    "xl": "32px"
            },
            "fontFamily": {
                    "headline-md": ["Inter"],
                    "label-md": ["Inter"],
                    "label-sm": ["Inter"],
                    "body-lg": ["Inter"],
                    "body-md": ["Inter"],
                    "headline-lg-mobile": ["Inter"],
                    "body-sm": ["Inter"],
                    "headline-xl": ["Inter"],
                    "headline-lg": ["Inter"]
            },
            "fontSize": {
                    "headline-md": ["20px", {"lineHeight": "28px", "fontWeight": "600"}],
                    "label-md": ["14px", {"lineHeight": "20px", "letterSpacing": "0.05em", "fontWeight": "600"}],
                    "label-sm": ["12px", {"lineHeight": "16px", "fontWeight": "500"}],
                    "body-lg": ["18px", {"lineHeight": "28px", "fontWeight": "400"}],
                    "body-md": ["16px", {"lineHeight": "24px", "fontWeight": "400"}],
                    "headline-lg-mobile": ["24px", {"lineHeight": "32px", "fontWeight": "600"}],
                    "body-sm": ["14px", {"lineHeight": "20px", "fontWeight": "400"}],
                    "headline-xl": ["36px", {"lineHeight": "44px", "letterSpacing": "-0.02em", "fontWeight": "700"}],
                    "headline-lg": ["28px", {"lineHeight": "36px", "letterSpacing": "-0.01em", "fontWeight": "600"}]
            }
          },
        },
      }
    </script>
<style>
        body { font-family: 'Inter', sans-serif; background-color: #f7f9fb; }
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
            display: inline-block;
            line-height: 1;
            text-transform: none;
            letter-spacing: normal;
            word-wrap: normal;
            white-space: nowrap;
            direction: ltr;
        }
        .step-active { width: 33.33%; height: 4px; background-color: #003e7e; }
        .step-inactive { width: 66.66%; height: 4px; background-color: #e2e8f0; }
        .custom-shadow { box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.05); }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-surface text-on-surface flex flex-col min-h-screen">
<!-- TopAppBar -->
<header class="bg-primary-container text-on-primary docked full-width top-0 z-50">
<div class="flex items-center px-4 h-16 w-full">
<button aria-label="Retour" class="material-symbols-outlined mr-4 p-2 hover:bg-primary/10 transition-colors duration-200 rounded-full">arrow_back</button>
<h1 class="font-headline-md text-headline-md text-on-primary">Louer ce bien</h1>
</div>
</header>
<main class="flex-grow flex flex-col w-full max-w-max-width mx-auto px-margin-mobile md:px-margin-desktop py-lg">
<!-- Progress Step Indicator -->
<div class="w-full flex mb-xl rounded-full overflow-hidden">
<div class="step-active"></div>
<div class="step-inactive"></div>
</div>
<div class="grid grid-cols-1 lg:grid-cols-12 gap-gutter">
<!-- Left Side: Property Summary Card -->
<div class="lg:col-span-5 order-1 lg:order-2">
<div class="bg-surface-container-lowest border border-outline-variant rounded-xl overflow-hidden custom-shadow">
<div class="relative h-48 md:h-64">
<img class="w-full h-full object-cover" data-alt="A luxurious, sun-drenched modern apartment interior in Abidjan Plateau with high ceilings, large windows overlooking the city skyline, and premium minimalist furniture. The lighting is warm and golden, reflecting off polished wooden floors. The overall aesthetic is clean, professional, and high-end, aligning with a corporate real estate brand." src="https://lh3.googleusercontent.com/aida-public/AB6AXuCST6bRaj_wreGVqRreJ5nsp1FCyfTD_jQQo5lU5VaVCsmXMmhSZ4XFkzvlmyyo4Q3-WgTykhqFZGKWs87MDgR3m_pd6_f6xsPgGy9pGBZeFJnxwRpY7kkPMeqpu36YZgk9E2dGMjFXbDjo5dHU2vhv4t-uyjPmBgpU6K2-NryYkkkpCpyaC1yA3nkTGCwcN_QAvdocoOZ1pRY68QM0Ps_APnA-x9yA2O9tFy2U9ZlGZ3x8w3wO7JHh5JKoUgYEjhbnRBq-js_QYuA"/>
<div class="absolute top-4 left-4">
<span class="bg-primary text-on-primary px-3 py-1 rounded-full text-label-sm font-label-sm uppercase tracking-wider">Disponible</span>
</div>
</div>
<div class="p-md">
<h2 class="font-headline-md text-headline-md mb-xs">Appartement Plateau</h2>
<div class="flex items-center text-on-surface-variant mb-md">
<span class="material-symbols-outlined text-[18px] mr-1">location_on</span>
<span class="text-body-sm font-body-sm">Cité Administrative, Abidjan</span>
</div>
<div class="pt-md border-t border-outline-variant flex justify-between items-end">
<div>
<p class="text-on-surface-variant text-label-sm font-label-sm uppercase">Loyer mensuel</p>
<p class="text-primary font-headline-md text-headline-md">450.000 FCFA<span class="text-body-sm font-body-sm text-on-surface-variant">/mois</span></p>
</div>
</div>
</div>
</div>
</div>
<!-- Right Side: Duration Form -->
<div class="lg:col-span-7 order-2 lg:order-1">
<div class="bg-surface-container-lowest border border-outline-variant rounded-xl p-md md:p-xl custom-shadow">
<h3 class="font-headline-lg text-headline-lg mb-lg">Détails de la location</h3>
<!-- Min Duration Banner -->
<div class="bg-secondary-container text-on-secondary-container px-md py-sm rounded-lg flex items-center mb-xl">
<span class="material-symbols-outlined mr-2">info</span>
<span class="text-body-md font-body-md">Durée minimale : 3 mois</span>
</div>
<form class="space-y-xl" onsubmit="return false;">
<!-- Date Picker (Locked) -->
<div class="flex flex-col">
<label class="text-on-surface-variant font-label-md text-label-md mb-xs">Date de début prévue</label>
<div class="relative">
<input class="w-full bg-surface-container-low border border-outline-variant rounded px-md py-sm text-on-surface-variant cursor-not-allowed font-body-md" disabled="" type="text" value="12/06/2024 (Aujourd'hui)"/>
<span class="material-symbols-outlined absolute right-3 top-2.5 text-on-surface-variant">calendar_today</span>
</div>
</div>
<!-- Duration Stepper -->
<div class="flex flex-col">
<label class="text-on-surface-variant font-label-md text-label-md mb-xs">Durée de la location (mois)</label>
<div class="flex items-center bg-surface-container-lowest border border-outline-variant rounded h-14">
<button aria-label="Diminuer" class="w-16 h-full flex items-center justify-center hover:bg-surface-container transition-colors" onclick="updateStepper(-1)">
<span class="material-symbols-outlined">remove</span>
</button>
<input class="flex-grow text-center border-none focus:ring-0 font-headline-md text-headline-md bg-transparent" id="duration" max="36" min="3" readonly="" type="number" value="6"/>
<button aria-label="Augmenter" class="w-16 h-full flex items-center justify-center hover:bg-surface-container transition-colors" onclick="updateStepper(1)">
<span class="material-symbols-outlined">add</span>
</button>
</div>
</div>
<!-- End Date & Summary -->
<div class="bg-surface-container-low rounded-xl p-md space-y-md">
<div class="flex justify-between items-center">
<span class="text-on-surface-variant font-body-md">Date de fin estimée :</span>
<span class="font-label-md text-label-md" id="end-date">12/12/2024</span>
</div>
<div class="flex justify-between items-center pt-md border-t border-outline-variant">
<span class="text-on-surface-variant font-body-lg">Total à payer</span>
<span class="text-primary font-headline-xl text-headline-xl" id="total-price">2.700.000 FCFA</span>
</div>
</div>
</form>
</div>
</div>
</div>
</main>
<!-- Spacer for fixed bottom bar on mobile -->
<div class="h-24 md:h-0"></div>
<!-- BottomNavBar -->
<nav class="fixed bottom-0 w-full z-50 flex justify-around items-center px-margin-mobile py-sm bg-surface shadow-lg border-t border-outline-variant">
<!-- We prioritize the primary action "Continuer" as requested -->
<div class="w-full max-w-max-width mx-auto flex items-center justify-between gap-md">
<div class="hidden md:flex flex-col">
<span class="text-on-surface-variant text-label-sm uppercase font-label-sm">Prix total estimé</span>
<span class="text-primary font-headline-md text-headline-md">2.700.000 FCFA</span>
</div>
<button class="w-full md:w-auto flex flex-col items-center justify-center bg-primary text-on-primary rounded-xl px-12 py-3 active:scale-95 transition-transform hover:bg-primary-container">
<div class="flex items-center gap-2">
<span class="font-label-md text-label-md">Continuer</span>
<span class="material-symbols-outlined text-[18px]">arrow_forward</span>
</div>
</button>
</div>
</nav>
<script>
        const monthlyRate = 450000;
        const durationInput = document.getElementById('duration');
        const totalPriceEl = document.getElementById('total-price');
        const endDateEl = document.getElementById('end-date');

        function updateStepper(val) {
            let current = parseInt(durationInput.value);
            let next = current + val;
            if (next >= 3 && next <= 36) {
                durationInput.value = next;
                updateDisplay(next);
            }
        }

        function updateDisplay(months) {
            // Price calculation
            const total = months * monthlyRate;
            totalPriceEl.textContent = total.toLocaleString('fr-FR') + ' FCFA';
            
            // Simplified date calculation (start is assumed 12/06/2024)
            const startDate = new Date(2024, 5, 12); // June 12, 2024
            startDate.setMonth(startDate.getMonth() + months);
            
            const day = String(startDate.getDate()).padStart(2, '0');
            const month = String(startDate.getMonth() + 1).padStart(2, '0');
            const year = startDate.getFullYear();
            
            endDateEl.textContent = `${day}/${month}/${year}`;
            
            // Sync with bottom bar if needed (on desktop view)
            const desktopPrice = document.querySelector('nav .text-primary');
            if (desktopPrice) desktopPrice.textContent = total.toLocaleString('fr-FR') + ' FCFA';
        }
    </script>
</body></html>