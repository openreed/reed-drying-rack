// Shared drying rack geometry. Units: mm.
// Profile: [fitting-cone base diameter, nominal tip diameter, cone height,
//           root diameter, center spacing].
function drying_profile(family) =
    assert(family == "oboe" || family == "oboe_english_horn" || family == "bassoon" || family == "custom",
           str("Unknown reed family: ", family))
    // "oboe" is an alias for the combined oboe and English horn profile.
    family == "bassoon" ? [5.4, 4.0, 14, 12, 24] : [4.8, 4.14, 12, 10, 20];

function drying_diameter(bottom, tip, height, z) =
    bottom + (tip-bottom)*z/height;

// Rounded plate centered in XY, underside at Z=0.
module drying_plate(size, thickness, radius=4, chamfer=0.6) {
    eps = 0.01;
    assert(len(size) == 2 && min(size) > 0, "Plate size must be positive");
    assert(radius > chamfer && 2*radius <= min(size), "Invalid plate radius");
    assert(chamfer >= 0 && 2*chamfer < thickness, "Invalid plate chamfer");
    // Four-circle hull covers the 1x1 limiting case too (a circular plate).
    module outline(inset=0) {
        hull()
            for (x = [-1, 1], y = [-1, 1])
                translate([x*(size[0]/2-radius), y*(size[1]/2-radius)])
                    circle(r=radius-inset);
    }
    if (chamfer == 0)
        linear_extrude(height=thickness) outline();
    else
        hull() {
            linear_extrude(height=eps) outline(chamfer);
            translate([0, 0, chamfer])
                linear_extrude(height=thickness-2*chamfer) outline();
            translate([0, 0, thickness-eps])
                linear_extrude(height=eps) outline(chamfer);
        }
}

// Origin: top of plate. The fitting cone starts at Z=root_height.
// A solid, continuous flare joins the cone to the plate without a shoulder.
module drying_mandrel(bottom, tip, height, root_diameter, root_height=3,
                      tip_chamfer=0.3) {
    overlap = 0.4;
    root_radius = root_diameter/2;
    cone_radius = bottom/2;
    radial_taper = (bottom-tip)/(2*height);
    radial_flare = root_radius-cone_radius;
    steps = max(16, ceil(root_height/0.1));

    assert(bottom > tip && tip > 0, "Need bottom > tip > 0");
    assert(height > 0 && tip_chamfer >= 0 && tip_chamfer < height,
           "Invalid insertion height or lead-in");
    assert(tip > 2*tip_chamfer, "Lead-in removes the entire tip");
    assert(root_diameter >= bottom+2, "Root must extend at least 1 mm radially");
    assert(root_height >= 1, "RootHeight must be at least 1 mm");
    assert(root_height*radial_taper <= radial_flare,
           "Root is too tall for the selected flare and cone taper");

    // Cubic Bezier: horizontal at the plate, tangent to the cone at its top.
    p0 = [root_radius, 0];
    p1 = [root_radius-radial_flare/2, 0];
    p2 = [cone_radius+root_height*radial_taper/2, root_height/2];
    p3 = [cone_radius, root_height];
    function root_point(t) =
        pow(1-t,3)*p0 + 3*pow(1-t,2)*t*p1 +
        3*(1-t)*t*t*p2 + pow(t,3)*p3;

    rotate_extrude(convexity=4)
        polygon(concat(
            [[0, -overlap], [root_radius, -overlap], p0],
            [for (i = [1:steps]) root_point(i/steps)],
            tip_chamfer > 0 ?
                [[drying_diameter(bottom, tip, height, height-tip_chamfer)/2,
                  root_height+height-tip_chamfer],
                 [tip/2-tip_chamfer, root_height+height]] :
                [[tip/2, root_height+height]],
            [[0, root_height+height]]
        ));
}
