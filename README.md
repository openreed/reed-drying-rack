# Reed Drying Rack

[[以中文阅读](README_CN.md) | [Read in English](README.md)]

This repository hosts parametric 3D models of reed racks for oboe, bassoon, and English horn reeds. The models are built using [OpenSCAD](https://openscad.org/) and intended for 3D printing.


## Variants

### Recessed reed rack

The recessed reed rack holds reeds by recessed holes. This type of rack is easy to store and carry, but it does not support bassoon reeds. See `recessed-reed-rack.scad`.

![recessed_rack](./assets/recessed_rack.png)


### Protruding reed rack

The protruding reed rack holds reeds by their exposed staples. This design accommodates oboe, English horn, and bassoon reeds (internal staple parameters may differ); however, due to the inherent limitations of FDM (Fused Deposition Modeling) 3D printing, the staples may be more susceptible to breakage. See `protruding-reed-rack.scad`.

![protruding_rack](./assets/protruding_rack.png)