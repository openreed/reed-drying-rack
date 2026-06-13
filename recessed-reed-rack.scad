include <BOSL2/std.scad>

$fa = 3;
$fs = 0.3;

/*[基本参数 | Basic Parameters]*/
//哨片槽数量, [X方向数量, Y方向数量] | Number of reed slots, [in X direction, in Y direction]
NumberOfSlots = [6,3];

//哨片槽间距 | Reed slot spacing
SlotSpace = 10;  


/*[高级参数 | Advanced Parameters]*/
// 哨片槽直径 | Reed slot diameter
SlotDiameter = 7.3; 

// 哨片槽深度 | Reed slot depth
SlotDepth = 12;  

// 哨座锥高度 | Staple cone height
StapleHeight = 3; 

// 哨座锥直径 | Staple cone diameter
StapleDiameter = 4; 

// 底部最薄处厚度 | Thickness between the bottom of the slot and the bottom of the rack
BaseThickness = 2; 

// 哨片槽倒角 | Reed slot chamfer
SlotChamfer = 0.6;

// 哨座锥倒角 | Staple cone chamfer
StapleChamfer = 0.4;

// 边缘倒角 | Edge chamfer
EdgeChamfer = 0.6;


/*[内部参数 Internal Parameters]*/
TotalLength = NumberOfSlots[0]*SlotDiameter + NumberOfSlots[0]*SlotSpace;  // 总长度 | total length
TotalWidth = NumberOfSlots[1]*SlotDiameter + NumberOfSlots[1]*SlotSpace;  // 总宽度 | total width
TotalHeight = BaseThickness + SlotDepth;  // 总高度 | total height
EdgeRounding = SlotDiameter/2 + SlotSpace/2;  // 边缘圆角半径 | rounding radius on edges
SlotCenterSpace = SlotSpace + SlotDiameter;  // 槽位中心间距 | center-to-center distance between slots


// Functions
module reed_slot(slot_depth, slot_diameter, slot_chamfer, staple_height, staple_diameter, staple_chamfer){
    // Create a reed slot with a staple cutout, anchored at the top
    difference(){
        cyl(h=slot_depth, d=slot_diameter, chamfer2=-slot_chamfer, anchor=TOP);
        translate([0,0,-slot_depth-0.01])
            cyl(h=staple_height+0.01, d=staple_diameter, chamfer2=staple_chamfer, anchor=BOTTOM);
    }
}


// Main Body
translate([-TotalLength/2, -TotalWidth/2, 0]) // 将模型中心对齐到坐标原点 | Center the model at the origin
difference(){
    // Base Cuboid
    cuboid(
        size=[TotalLength, TotalWidth, TotalHeight], 
        anchor=BOTTOM+FRONT+LEFT,
        rounding=EdgeRounding,
        edges="Z"
    );

    // Reed Slots
    for(i = [1:1:NumberOfSlots[0]]){
        for(j = [1:1:NumberOfSlots[1]]){
            translate([(i-0.5)*(SlotDiameter+SlotSpace), (j-0.5)*(SlotDiameter+SlotSpace), TotalHeight + 0.01])  // 第[i,j]个槽位位置
                reed_slot(
                    slot_depth=SlotDepth, 
                    slot_diameter=SlotDiameter, 
                    slot_chamfer=SlotChamfer, 
                    staple_height=StapleHeight, 
                    staple_diameter=StapleDiameter, 
                    staple_chamfer=StapleChamfer
            );
        }
    }

    // Chamfer Edges

    //// Bottom Edges
    translate([TotalLength/2, 0, 0])
        chamfer_edge_mask(l = TotalLength, chamfer=EdgeChamfer, orient=RIGHT);
    translate([0, TotalWidth/2, 0])
        chamfer_edge_mask(l = TotalWidth, chamfer=EdgeChamfer, orient=FRONT);
    translate([TotalLength, TotalWidth/2, 0])
        chamfer_edge_mask(l = TotalWidth, chamfer=EdgeChamfer, orient=BACK);
    translate([TotalLength/2, TotalWidth, 0])
        chamfer_edge_mask(l = TotalLength, chamfer=EdgeChamfer, orient=LEFT);
    //// Top Edges
    translate([TotalLength/2, 0, TotalHeight])
        chamfer_edge_mask(l = TotalLength, chamfer=EdgeChamfer, orient=RIGHT);
    translate([0, TotalWidth/2, TotalHeight])
        chamfer_edge_mask(l = TotalWidth, chamfer=EdgeChamfer, orient=FRONT);
    translate([TotalLength, TotalWidth/2, TotalHeight])
        chamfer_edge_mask(l = TotalWidth, chamfer=EdgeChamfer, orient=BACK);
    translate([TotalLength/2, TotalWidth, TotalHeight])
        chamfer_edge_mask(l = TotalLength, chamfer=EdgeChamfer, orient=LEFT);
    //// Bottom Corners
    translate([EdgeRounding,EdgeRounding,0])
        rotate_extrude(angle=90, start=0) left(EdgeRounding) zrot(45) square(EdgeChamfer * sqrt(2), center=true);
    translate([TotalLength-EdgeRounding,EdgeRounding,0])
        rotate_extrude(angle=90, start=90) left(EdgeRounding) zrot(45) square(EdgeChamfer * sqrt(2), center=true);
    translate([TotalLength-EdgeRounding,TotalWidth-EdgeRounding,0])
        rotate_extrude(angle=90, start=180) left(EdgeRounding) zrot(45) square(EdgeChamfer * sqrt(2), center=true);
    translate([EdgeRounding,TotalWidth-EdgeRounding,0])
        rotate_extrude(angle=90, start=270) left(EdgeRounding) zrot(45) square(EdgeChamfer * sqrt(2), center=true);
    //// Top Corners
    translate([EdgeRounding,EdgeRounding,TotalHeight])
        rotate_extrude(angle=90, start=0) left(EdgeRounding) zrot(45) square(EdgeChamfer * sqrt(2), center=true);
    translate([TotalLength-EdgeRounding,EdgeRounding,TotalHeight])
        rotate_extrude(angle=90, start=90) left(EdgeRounding) zrot(45) square(EdgeChamfer * sqrt(2), center=true);
    translate([TotalLength-EdgeRounding,TotalWidth-EdgeRounding,TotalHeight])
        rotate_extrude(angle=90, start=180) left(EdgeRounding) zrot(45) square(EdgeChamfer * sqrt(2), center=true);
    translate([EdgeRounding,TotalWidth-EdgeRounding,TotalHeight])
        rotate_extrude(angle=90, start=270) left(EdgeRounding) zrot(45) square(EdgeChamfer * sqrt(2), center=true);
}
