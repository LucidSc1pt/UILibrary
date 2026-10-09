This is just my small project.

I don't know what I'm doing with Orion, but Orion Lib Modded is now working again!

I will update the Orion functionality when I done with this Turtle UI Lib.

> btw, does anyone know how to execute a ui library code on android phone without me having to upload it multiple times on github 😭

### Available Icons (Credits)

- [Lucide Icons](https://github.com/lucide-icons/lucide)
- [Craft Icons](https://www.figma.com/community/file/1415718327120418204)
- [Geist Icons](https://vercel.com/geist/icons)
- [Solar Icons](https://icones.js.org/collection/solar)
- [SF Symbols](https://sf-symbols-one.vercel.app/)
- [Gravity UI Icons](https://gravity-ui.com/ru/icons)

I'm used Footagesus and Rayfield icon link

```luau
local IconPacks = {
	lucide = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/refs/heads/main/icons.lua"))(),
	solar = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/solar/dist/Icons.lua"))(),
	craft = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/craft/dist/Icons.lua"))(),
	geist = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/geist/dist/Icons.lua"))(),
	sfsymbols = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/sfsymbols/dist/Icons.lua"))(),
	gravity = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/gravity/dist/Icons.lua"))()
}
```

### Documentation

* [Turtle UI Lib Documentation](TurtleUILib.md)
