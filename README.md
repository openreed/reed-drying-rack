# Reed Drying Rack

[[以中文阅读](README_CN.md) | [Read in English](README.md)]

This repository hosts parametric 3D models of reed racks for oboe, bassoon, and English horn reeds. The models are built using [OpenSCAD](https://openscad.org/) and intended for 3D printing.


## Variants

### Recessed reed rack

The recessed reed rack holds reeds by recessed holes. This type of rack is easy to store and carry, but it does not support bassoon reeds. See `recessed-reed-rack.scad`.

![recessed_rack](./assets/recessed_rack.png)


### Protruding reed rack

The protruding rack supports finished reeds on short holding pins. Open [protruding-reed-rack.scad](protruding-reed-rack.scad) and choose a `ReedFamily`:

- **`oboe_english_horn` (current default)**: fitting-cone base **4.8**, nominal tip **4.14**, cone length **12 mm**; center spacing 20 mm.
- `bassoon`: fitting-cone base 5.4, nominal tip 4.0, cone length 14 mm; center spacing 24 mm.

Each pin has a solid, smoothly flared root joining it to the plate. The cross grooves and abrupt stop shoulders have been removed. The fitting cone and root form one continuous profile. The protruding rack uses native OpenSCAD; the recessed rack still requires BOSL2.

![Solid root detail and complete rack](./assets/protruding-rack-preview.png)

The root is **3 mm high**, with a default base diameter of **10 mm** for oboe/English horn or 12 mm for bassoon. The fitting-cone dimensions above it are preserved. The base diameter is measured at the root's upper edge. Without a flat stop, reeds rest at their natural position on the flare; seating height can differ slightly from the previous model. The 0.3 mm axial lead-in reduces the final flat tip diameter by 0.6 mm, giving **3.54 mm** for the combined profile.

The current [oboe/English horn STL](3D_files/mandrel-v2/rack-oboe-english-horn.stl) has an 8×4 layout and measures **160 × 80 × 23 mm**. The [bassoon STL](3D_files/mandrel-v2/rack-bassoon.stl) measures **192 × 96 × 25 mm**. Historical fit geometry is retained inside `fit-tests/`; the main model defines the current root. The [research record](docs/mandrel-research.md) documents sources and the iteration history in Chinese.

`DiameterCompensation` changes both fitting diameters: positive thickens, negative thins. For manual cone dimensions, select `ReedFamily="custom"` before editing `StapleBottomDiameter`, `StapleTopDiameter` and `StapleHeight`. `RootHeight` controls the reinforced transition height. `RootDiameter=0` selects the instrument default; a positive value overrides it. `StapleCenterSpacing` is center-to-center spacing; zero selects the profile default.

For FDM, inspect the sliced pins and roots. With a 0.4 mm nozzle, start with six perimeters and use local 100% infill for pins and roots; the plate need not be solid. Solid CAD geometry does not automatically produce solid infill. The smooth transition is intended to reduce stress concentration; bending performance still requires physical testing.

The matching JSON file supplies named OpenSCAD Customizer presets. Run `python3 scripts/validate-models.py` to export and check all six STL files under the existing ignored `3D_files/mandrel-v2/` directory. Print in mm at 100% scale.

The former `oboe` profile name remains an alias for the combined profile. `rack-oboe-a5.stl` is a historical reference; use the complete rack exports above for the current design.
