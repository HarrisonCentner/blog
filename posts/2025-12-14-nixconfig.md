----
title: A Dendritic Nixconfig
modified: 2025-12-14
meta_description: "Explanation of my NixOS config."
tags: NixOS
prerequisites: Nix
----

I use NixOS for my work and personal computers as well as all the computers in 
my homelab. My goals are:
1. keep the configurations of my devices synced, and
2. be able to quickly onboard a new device. 

<!--more-->

I use flakes in all my projects for hermeticity and compositionality. 
But I still wanted more structure in my nix configurations. 
`flake-parts` is a module system with opinionated rules on extensionality and handling of the
`system` attribute. By using `flake-parts`, I'm able to structure my 
nixconfig around functionality instead of where options are applied.

A style convention for `flake-parts` that I enjoy is the [dendritic nix pattern](https://dendrix.oeiuwq.com/Dendritic.html):
make every file a `flake-parts` module.
[NaN](https://not-a-number.io/2025/refactoring-my-infrastructure-as-code-configurations/#trade-offs) nicely 
described this "inversion of configuration control" as a switch from
"Host-Centric" to "Featue-Centric" configuration. Using [import-tree](https://github.com/vic/import-tree)
removes the boilerplate that I would otherwise incur from `flake-parts`
since one tends to create many more `.nix` files.

I've tried other nix module systems like [std](https://github.com/divnix/std) but I don't 
find them intuitive.


My nixconfig is [here](https://github.com/HarrisonCentner/nixconfig). 

