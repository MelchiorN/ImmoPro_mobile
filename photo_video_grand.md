<!DOCTYPE html>

<html class="light" lang="fr"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Galerie Photos - Immobilier Pro</title>
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
                    "on-secondary-fixed-variant": "#3f484e",
                    "tertiary": "#004931",
                    "surface-container-highest": "#e0e3e5",
                    "on-primary-fixed": "#001b3d",
                    "inverse-surface": "#2d3133",
                    "error": "#ba1a1a",
                    "error-container": "#ffdad6",
                    "tertiary-container": "#006344",
                    "on-tertiary-fixed-variant": "#005138",
                    "outline-variant": "#c2c6d3",
                    "tertiary-fixed-dim": "#69dbaa",
                    "primary-fixed": "#d6e3ff",
                    "on-secondary-fixed": "#141d22",
                    "on-secondary-container": "#5d666c",
                    "primary": "#003e7e",
                    "surface": "#f7f9fb",
                    "on-surface": "#191c1e",
                    "on-primary-container": "#b3cdff",
                    "inverse-primary": "#a9c7ff",
                    "surface-container-high": "#e6e8ea",
                    "on-tertiary-container": "#6fe1af",
                    "surface-tint": "#265ea8",
                    "on-error": "#ffffff",
                    "secondary-container": "#dbe4eb",
                    "on-tertiary": "#ffffff",
                    "primary-fixed-dim": "#a9c7ff",
                    "primary-container": "#1a56a0",
                    "on-tertiary-fixed": "#002114",
                    "background": "#f7f9fb",
                    "surface-dim": "#d8dadc",
                    "surface-variant": "#e0e3e5",
                    "on-background": "#191c1e",
                    "surface-bright": "#f7f9fb",
                    "on-secondary": "#ffffff",
                    "secondary-fixed": "#dbe4eb",
                    "outline": "#737782",
                    "surface-container": "#eceef0",
                    "on-primary": "#ffffff",
                    "on-primary-fixed-variant": "#00468c",
                    "on-error-container": "#93000a",
                    "secondary": "#576065",
                    "inverse-on-surface": "#eff1f3",
                    "surface-container-low": "#f2f4f6",
                    "surface-container-lowest": "#ffffff",
                    "tertiary-fixed": "#86f8c5",
                    "on-surface-variant": "#424751",
                    "secondary-fixed-dim": "#bfc8ce"
            },
            "borderRadius": {
                    "DEFAULT": "0.25rem",
                    "lg": "0.5rem",
                    "xl": "0.75rem",
                    "full": "9999px"
            },
            "spacing": {
                    "md": "16px",
                    "base": "4px",
                    "lg": "24px",
                    "xs": "4px",
                    "xl": "32px",
                    "gutter": "16px",
                    "sm": "8px",
                    "container-max": "1280px"
            },
            "fontFamily": {
                    "label-sm": ["Inter"],
                    "label-md": ["Inter"],
                    "display-lg-mobile": ["Inter"],
                    "headline-md": ["Inter"],
                    "title-lg": ["Inter"],
                    "display-lg": ["Inter"],
                    "body-md": ["Inter"],
                    "body-lg": ["Inter"]
            },
            "fontSize": {
                    "label-sm": ["11px", {"lineHeight": "14px", "fontWeight": "500"}],
                    "label-md": ["12px", {"lineHeight": "16px", "letterSpacing": "0.01em", "fontWeight": "600"}],
                    "display-lg-mobile": ["28px", {"lineHeight": "34px", "fontWeight": "700"}],
                    "headline-md": ["24px", {"lineHeight": "32px", "fontWeight": "600"}],
                    "title-lg": ["20px", {"lineHeight": "28px", "fontWeight": "600"}],
                    "display-lg": ["36px", {"lineHeight": "44px", "letterSpacing": "-0.02em", "fontWeight": "700"}],
                    "body-md": ["14px", {"lineHeight": "20px", "fontWeight": "400"}],
                    "body-lg": ["16px", {"lineHeight": "24px", "fontWeight": "400"}]
            }
          },
        },
      }
    </script>
<style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #0D3A6E; /* Marine foncé spécifié */
            overflow: hidden;
        }
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        .active-thumb {
            border: 2px solid #a9c7ff; /* Primary fixed dim pour contraste sur fond bleu */
        }
        .gallery-gradient-top {
            background: linear-gradient(to bottom, rgba(13, 58, 110, 0.8) 0%, transparent 100%);
        }
        .gallery-gradient-bottom {
            background: linear-gradient(to top, rgba(13, 58, 110, 0.9) 0%, transparent 100%);
        }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="h-screen w-screen flex flex-col text-on-primary">
<!-- Immersive Photo Canvas -->
<div class="absolute inset-0 z-0">
<img class="w-full h-full object-cover" data-alt="A luxurious modern living room with floor-to-ceiling windows overlooking a sunset coastline. The interior features a plush velvet sectional sofa in charcoal grey, a minimalist marble coffee table, and warm ambient recessed lighting. The atmosphere is sophisticated and high-end, captured in a clean light-mode architectural photography style with rich textures and deep shadows that highlight the premium finishes." src="https://lh3.googleusercontent.com/aida-public/AB6AXuBvAKJT66fBF7Q09BnLQ2rNlrU6NDNs_fptrQLt_HunkkqmPG0Z9NahoBu_0snwmvT1HGw2wUT_lg9qN5Ymg6yQuSxr0si-qiHFdhwCSe3b_iVoqnyhyOykEdMujOdLPPMQJ7Z9oXDsrMcD2C7Y9uEdJVJvfSRg_S1gam5jZGePazl6R67qZ-ArZUt42HVlJr0MzefAHZ9GvxMs8NVkNiDMVra1mrIEqbeMU-pOxGkjbdVraRD7fvAWjVOn1I4dgu7QU8DTIfrJyKY"/>
</div>
<!-- Header Overlay -->
<header class="fixed top-0 left-0 w-full z-20 gallery-gradient-top px-lg py-md flex items-center justify-between">
<button class="w-10 h-10 flex items-center justify-center rounded-full hover:bg-white/10 transition-colors duration-200">
<span class="material-symbols-outlined text-on-primary">close</span>
</button>
<div class="flex flex-col items-center">
<span class="font-label-md text-label-md text-on-primary tracking-widest">3 / 8</span>
</div>
<button class="w-10 h-10 flex items-center justify-center rounded-full hover:bg-white/10 transition-colors duration-200">
<span class="material-symbols-outlined text-on-primary">share</span>
</button>
</header>
<!-- Bottom Interface -->
<footer class="fixed bottom-0 left-0 w-full z-20 gallery-gradient-bottom pt-xl pb-lg px-lg">
<div class="max-w-container-max mx-auto flex flex-col gap-md">
<!-- Thumbnails Strip -->
<div class="flex items-center gap-sm overflow-x-auto pb-md no-scrollbar scroll-smooth">
<!-- Thumb 1 -->
<div class="flex-shrink-0 w-20 h-20 rounded-xl overflow-hidden cursor-pointer opacity-80 hover:opacity-100 transition-opacity">
<img class="w-full h-full object-cover" data-alt="Close-up shot of a high-end designer kitchen in a modern villa, featuring integrated professional appliances and polished quartz countertops. The lighting is crisp and bright, reflecting off the clean white surfaces, maintaining a premium and organized aesthetic." src="https://lh3.googleusercontent.com/aida-public/AB6AXuBJu_vhRbG28W9x1xHzf-O652Y_DTMbJ2r-9SmakNi__sRMe3a4KOneZR5CXPYp6wD5sc7bUZYK6uvLk-28aVnGclZoD4Tilla8qgEkgxGiiKFUT_LHRcHvXa93p_tGrfrO17w9ZLYPTppIP1Gq8EK8uz6-DYdqlRbAzs4yPbmQ-NgWQpzxNs9zc0IRIQ9yMLgPn1dmpq-VDBzWnU_zdY-d3vW-cBjdb46Hd5GRK3C80Bi7O5_k0XvTa3JIN9wLL7k-0kcd3XeBQNQ"/>
</div>
<!-- Thumb 2 -->
<div class="flex-shrink-0 w-20 h-20 rounded-xl overflow-hidden cursor-pointer opacity-80 hover:opacity-100 transition-opacity">
<img class="w-full h-full object-cover" data-alt="A master bedroom in a luxury estate, showing a king-sized bed with crisp white linens and a minimalist wood headboard. Large sliding glass doors lead to a private balcony with sea views. High-end light-mode architectural style." src="https://lh3.googleusercontent.com/aida-public/AB6AXuCUMREfbODHNR0gNBS91k--BZ5Kr9J_Dk2cg7szsMRAnypaLezcgSEWcQDK198tYNmC96dvcbkojImyMmeEs9R78Jh_r5GM0D-zXIhyd226Zxxtb3I-FZ6s2wUipUrgrRzM7SmMp54p4elrMzVIKe1LGO62ui179xYx74lSX7OPouQ1vaWZE6ErgsyLAXXQ7ftDB8yLZ2hpBwHnkowQvhj4A3cywfio36nblVKaBdNg4_1OuGMEA8AZooDvLdBIyxJ52Ke68svQQ3w"/>
</div>
<!-- Active Thumb 3 -->
<div class="flex-shrink-0 w-20 h-20 rounded-xl overflow-hidden cursor-pointer active-thumb shadow-lg scale-105 transition-transform">
<img class="w-full h-full object-cover" data-alt="The main living area of a modern villa, featuring expansive floor-to-ceiling glass windows and elegant contemporary furniture. The composition emphasizes the open-plan architecture and the seamless indoor-outdoor flow under a bright, clear sky." src="https://lh3.googleusercontent.com/aida-public/AB6AXuADomBxoBG9VJG8gFC5UQ90vTf_Q3HThT-lVZRaW66Zy68ICpAICki01iEKzrvus9Re7F5bhIvBEY94_tocsClE-XqPP4SMkm_gHcJ3ag4ox_k50Mt_4QxqIK61BOgMqgMvuqQGTFumA6ecTeusPOMLTxPxekRWhPRAs4vIngXjQXivnkSXk2oTUZqt8paQO1BxnuFgk-W3m_meKb3alah6Gxh_KAyEECe0VkNAGoJZ3MhnotzcLSYbzrelv8zD_Rtstgf7cDfpy44"/>
</div>
<!-- Thumb 4 -->
<div class="flex-shrink-0 w-20 h-20 rounded-xl overflow-hidden cursor-pointer opacity-80 hover:opacity-100 transition-opacity">
<img class="w-full h-full object-cover" data-alt="A luxurious bathroom with a freestanding stone bathtub and gold-finished fixtures. The walls are lined with light-toned travertine marble, and a small olive tree in a terracotta pot adds a touch of natural warmth to the modern space." src="https://lh3.googleusercontent.com/aida-public/AB6AXuC5KCYrP_tq7oDFQC5j9mm8YHXUPJyng9TSW9zSkDpUJ8DBxklsFwEt0iB1cZ11QUTw50qcsJHWKZskPlgZl_CbcbrVsv1uXvJNoeg4PnDo_4YoCCZL88WyW9ES3ZxvVcpNPaUIPVVrECXO9GF-QKs0dlMT1jK127QsBXjT3_wvIy4BY5sZgFJ7jW89DudFW47vYTGyHRMiHIlI-amKpPXp4Gfrc_B1p3NxAtDPu1I76Nij5ffoZ-gZ5ttpFeDSqUslFpn8nBP89W4"/>
</div>
<!-- Thumb 5 -->
<div class="flex-shrink-0 w-20 h-20 rounded-xl overflow-hidden cursor-pointer opacity-80 hover:opacity-100 transition-opacity">
<img class="w-full h-full object-cover" data-alt="Outdoor infinity pool area at dusk, with the water glowing under soft integrated blue LED lights. The surrounding deck is made of smooth hardwood, furnished with elegant white lounge chairs under a starry sky." src="https://lh3.googleusercontent.com/aida-public/AB6AXuAwTS7Tog0Yj-xcfZyiu61JehlkrfAIkvPlZHPocNXddPvAB1Es-CfC6r4ElOrdS0os5TkbolpERzXwmZJAvIEbYFq41OOuuV_nTuED9VTsowTfta6kvXahiVpVsVeK-HE3wMhzCD07CB5xDCaM0oqjk_c-uDrGHsq7mb7nV023euI8DGp1R-LkpDeGZ6Hs4-RS4qK_5SRIAn_eWu7QglRGZ2-gsR7FWRfLIWjxI-CSy_OWQ5gZ0Ou_vjYHVXKlpqeJbors2qdqGVU"/>
</div>
<!-- Thumb 6 -->
<div class="flex-shrink-0 w-20 h-20 rounded-xl overflow-hidden cursor-pointer opacity-80 hover:opacity-100 transition-opacity">
<img class="w-full h-full object-cover" data-alt="A professional home office space with a large oak desk and ergonomic chair. The room is flooded with natural light from a skylight, creating an ideal productive environment within a high-end residential property." src="https://lh3.googleusercontent.com/aida-public/AB6AXuDVn2HTSbI7oGSNUUhWi1HwzYag4_cHqZejE9IbdsuBdL012bwP0SGiiuXmJ-4tt1SMpW1vn4ahgQOY_uIHX3HvD1q5PbiJfAxOyiErGBRTHoCLr77TlIR4bvXTzniO440ckNHllYW_lHo5yMdC1vNkWoyMLveVnHgnufkt7OF-idb_lrxEHvMBDS6Ov6znqfDDmKdbhqfXg2tMq_0c7HEyRxIC87LoPj9hkivQvQ3p-ykdii1vs1o5Q8k4dPowwwr2y7ZBjh33LJM"/>
</div>
<!-- Thumb 7 -->
<div class="flex-shrink-0 w-20 h-20 rounded-xl overflow-hidden cursor-pointer opacity-80 hover:opacity-100 transition-opacity">
<img class="w-full h-full object-cover" data-alt="A spacious walk-in closet with custom walnut cabinetry and integrated LED shelf lighting. Each section is perfectly organized with high-end designer clothing and accessories, reflecting a wealthy lifestyle and superior craftsmanship." src="https://lh3.googleusercontent.com/aida-public/AB6AXuApF1KqovqeOPH9tnOoO88yYPTv8_CKQcegUcXcQMItblp6v1GIXhKBnPzX0_47xoRc-FC-RHdOxqOV6mHjdSp6RdZInKwKh5O_KsAtVZjCKZZGsXa6aOjlUBvHkvrb75AM8cdsVj103RhbhGkddUt8VnESWfd_KzRIdfIUIx4ywVxq06kTxMrGZPEKn9yxUerN-lNftQhUBu2ol5v8J9IaeiL1jf9oW4UTlq-iyPlPLRh4kKtox0RyEwDdsNO0A4H63S6EfxQpDgI"/>
</div>
<!-- Thumb 8 -->
<div class="flex-shrink-0 w-20 h-20 rounded-xl overflow-hidden cursor-pointer opacity-80 hover:opacity-100 transition-opacity">
<img class="w-full h-full object-cover" data-alt="A view of the villa exterior at sunset, showing the clean geometric lines of the modern architecture against a dramatic orange and purple sky. The landscaping is manicured with palm trees and soft uplighting on the white facade." src="https://lh3.googleusercontent.com/aida-public/AB6AXuB9yo7HOldO94Hpd2ARCNfID4FKp2yVD8Bx1k78iwDrX-idoHbmmcmItiKWDiEuWmxRQTWkHsirYaMWghAs7glQa3F8c36Z9U0gz0o83de90AvWsbrfF8-zshYDQmRK4nbA_nbnye2MvIKbqfMbMcLBaWLWCnV0Qbl8B5gmH87FyXSUMse4_EcEWGrspkhdUhWF-civIcxuoTYNstPfWNAx73iu6IJ7JPX9LowF9oHQ6xV1k7XQTWpPaAog0axM6kvoQ7NNHtZEnAY"/>
</div>
</div>
<!-- Bottom Actions -->
<div class="flex justify-between items-center">
<div class="flex flex-col">
<h2 class="font-title-lg text-title-lg text-on-primary">Salon Principal</h2>
<p class="font-body-md text-body-md text-on-primary/70">Villa des Oliviers, Cannes</p>
</div>
<button class="bg-primary-fixed-dim text-on-primary-fixed w-14 h-14 rounded-full shadow-xl flex items-center justify-center active:scale-95 transition-all duration-150">
<span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1;">download</span>
</button>
</div>
</div>
</footer>
<!-- Interactive Layer (Navigation Arrows) -->
<div class="absolute inset-y-0 left-0 w-24 z-10 flex items-center justify-center group cursor-pointer">
<div class="w-12 h-12 rounded-full bg-white/5 opacity-0 group-hover:opacity-100 flex items-center justify-center transition-opacity duration-300">
<span class="material-symbols-outlined text-on-primary">chevron_left</span>
</div>
</div>
<div class="absolute inset-y-0 right-0 w-24 z-10 flex items-center justify-center group cursor-pointer">
<div class="w-12 h-12 rounded-full bg-white/5 opacity-0 group-hover:opacity-100 flex items-center justify-center transition-opacity duration-300">
<span class="material-symbols-outlined text-on-primary">chevron_right</span>
</div>
</div>
<script>
        // Micro-interaction: Simple hover effects for thumbnails and basic nav simulation
        document.querySelectorAll('.flex-shrink-0').forEach(thumb => {
            thumb.addEventListener('click', function() {
                document.querySelectorAll('.flex-shrink-0').forEach(t => {
                    t.classList.remove('active-thumb', 'scale-105');
                    t.classList.add('opacity-80');
                });
                this.classList.add('active-thumb', 'scale-105');
                this.classList.remove('opacity-80');
            });
        });

        // Prevention of context menu on images for "premium" feel
        document.addEventListener('contextmenu', event => event.preventDefault());
    </script>
<style>
        .no-scrollbar::-webkit-scrollbar {
            display: none;
        }
        .no-scrollbar {
            -ms-overflow-style: none;
            scrollbar-width: none;
        }
    </style>
</body></html>