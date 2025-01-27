# BabylonHx

BabylonHx is a direct port of BabylonJs engine to Haxe.

Visit http://paradoxplay.com/babylonhx for more info about the engine.

# Installation

To get started you'll need to download Haxe from here:

https://haxe.org/download/

That will also install Haxe library manager "haxelib" which you will use to install necessary libraries/frameworks.

Then you'll have to install runtime files for c++ backend for Haxe - HXCPP, execute from command line:

`haxelib install hxcpp`

Next we'll install Lime, which is a framework that includes tools and an libraries for building Haxe applications, including an OpenGL abstraction layer we use for rendering:

https://lime.openfl.org/

To install Lime execute from cmd line:

`haxelib install lime`

and after that execute:

`haxelib run lime setup`

When Lime is installed and configured you'll have to install dev tools for each platform you wish to build BabylonHx for, so if you want to build for Windows you should run this from cmd line:

`haxelib run lime setup windows`

This will start download process of VisualStudio and it will install and setup everything for you. For every other platform the process is the same, for example android:

Finally, you have to install "poly2trihx" library which is used by BabylonHx and "actuate" lib which is used in some examples:

`haxelib install poly2trihx`

`haxelib install actuate`

Now you should be ready to build BabylonHx.

Download complete repo from https://github.com/Falagard/BabylonHx and navigate to folder where you have downloaded files.

Then run from cmd line:

`haxelib run lime test project.xml html5`

this should build "BasicScene" sample and run it in your browser.

If you want to try a different scene, edit the MainLime.hx onPreloadComplete function to uncomment one of the sample scenes.

You can build for windows/android by changing build target:

`haxelib run lime test project.xml windows`
`haxelib run lime test project.xml android`

If you wish, you can also instal NME and Snow:
`haxelib install nme`
`haxelib git snow https://github.com/underscorediscovery/snow.git`

For Snow you'll also need to install Flow which is used to build Snow projects:
`haxelib git flow https://github.com/underscorediscovery/flow.git`

Then, to build for NME run:
`haxelib run nme build build.nmml android`

And for Snow:
`haxelib run flow build android`

OimoHx library used in some examples is located here: 

https://github.com/vujadin/OimoHx

and code for loading .OBJ, .STL and .PLY formats is located in BabylonHx_Extensions repo: https://github.com/vujadin/BabylonHx_Extensions

An that should be it.
Hopefully I haven't missed any critical step, feel free to ask if you run into any problems.

Find out about Babylon3D engine on its web site http://www.babylonjs.com/.

Documentation can be found here: http://doc.babylonjs.com/


