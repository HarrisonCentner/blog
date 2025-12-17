----
title: A Dendritic Nixconfig
modified: 2025-12-14
meta_description: "Explanation of my NixOS config."
tags: NixOS
prerequisites: Nix
----

I use NixOS for my work, personal, and homelab computers. 
My goals are:
1. maintain synced device configurations, and
2. quickly onboard new devices. 

<!--more-->

I use flakes for hermeticity and compositionality. 
But I still want more structure. 
`flake-parts` is a module system with opinionated rules on extensionality and handling the
`system` attribute. By using `flake-parts`, I'm able to structure my 
nixconfig around functionality.

A style convention for `flake-parts` that I enjoy is the [dendritic nix pattern](https://dendrix.oeiuwq.com/Dendritic.html):
make every file a `flake-parts` module.
[NaN](https://not-a-number.io/2025/refactoring-my-infrastructure-as-code-configurations/#trade-offs) nicely 
described this "inversion of configuration control" as a switch from
"Host-Centric" to "Featue-Centric" configuration. Using [import-tree](https://github.com/vic/import-tree)
removes the boilerplate that I would otherwise incur from `flake-parts`,
since one tends to create many more `.nix` files.

I've tried other nix module systems like [std](https://github.com/divnix/std), but I don't 
find them intuitive.

My nixconfig is [here](https://github.com/HarrisonCentner/nixconfig). 

