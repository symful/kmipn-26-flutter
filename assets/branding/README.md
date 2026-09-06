# SIGAP app icon

`sigap-icon.png` is the master artwork generated with the built-in image generation tool on 2026-09-06. Android launcher densities and the SPA favicon/apple-touch icon are derived from this artwork. Keep the original square image; Android supplies its launcher mask.

Generation prompt: “Create a polished app launcher icon for SIGAP, an Indonesian village infrastructure reporting app. One square 1024x1024 icon, full bleed solid dark teal background (#123e37), no rounded outer corners (operating system will mask it). Center a bold simple warm-white map pin combined with a gently curving road in negative space, with one small bright teal accent. Flat geometric vector-like artwork, crisp clean edges, strong recognizable silhouette at 16px, no text, no letters, no gradients, no shadows, no border, no mockup. Keep all important symbol geometry within central 65% for Android adaptive safe area. Professional civic utility identity, friendly and trustworthy. Return the single finished icon.”

Android 8+ uses `mipmap-anydpi-v26/ic_launcher.xml` with a teal adaptive background and the original artwork inset into the adaptive safe area. The round icon uses the same resource. Android 12+ day/night launch themes explicitly use this icon and teal background; older launch backgrounds also use teal. Keep these resources when regenerating legacy launcher PNGs to avoid the system-added white legacy-icon surround.

