include <BOSL2/std.scad>

$fa = 3;
$fs = 0.3;

/*[基本参数 | Basic Parameters]*/
// 哨座锥数量, [X方向数量, Y方向数量] | Number of reed staples, [in X direction, in Y direction]

NumberOfStaples = [5,3];

// 哨座锥间距 | Reed staples spacing
StapleSpace = 14; 


/*[高级参数 | Advanced Parameters]*/
// 哨座锥底径 | Reed staple bottom diameter
StapleBottomDiameter = 6; 

// 哨座锥顶径 | Reed staple top diameter
StapleTopDiameter = 4;

// 哨座锥高度 | Reed staple height
StapleHeight = 16;  

// 底板厚度 | Thickness of the base plate
BaseThickness = 8;

// 哨座锥顶部圆角 | Staple top fillet
StapleTopFillet = 0.6;

// 哨座锥底部圆角 | Staple bottom fillet
StapleBottomFillet = 1.6;

// 边缘倒角 | Edge chamfer
EdgeChamfer = 0.6;


/*[内部参数 Internal Parameters]*/
TotalLength = NumberOfStaples[0]*StapleBottomDiameter + NumberOfStaples[0]*StapleSpace;  // 总长度 | total length
TotalWidth = NumberOfStaples[1]*StapleBottomDiameter + NumberOfStaples[1]*StapleSpace;  // 总宽度 | total width
EdgeRounding = StapleBottomDiameter/2 + StapleSpace/2;  // 边缘圆角半径 | rounding radius on edges
StapleCenterSpace = StapleSpace + StapleBottomDiameter;  // 哨座锥中心间距 | center-to-center distance between staples


// Functions
module reed_staple(BottomDiameter, 
                   TopDiameter, 
                   Height, 
                   BottomFillet, 
                   TopFillet){  
    cyl(d1=BottomDiameter, 
        d2=TopDiameter, 
        l=Height, 
        rounding2=TopFillet, 
        rounding1=-BottomFillet,
        anchor=BOTTOM);
}


// Main Body
translate([-TotalLength/2, -TotalWidth/2, 0]) // 将模型中心对齐到坐标原点 | Center the model at the origin
difference(){
    union() {
        // Base Cuboid
        cuboid(
            size=[TotalLength, TotalWidth, BaseThickness], 
            anchor=BOTTOM+FRONT+LEFT,
            rounding=EdgeRounding,
            edges="Z"
        );

        // Reed Staples
        for(i = [1:1:NumberOfStaples[0]]){
            for(j = [1:1:NumberOfStaples[1]]){
                translate([(i-0.5)*(StapleBottomDiameter+StapleSpace), (j-0.5)*(StapleBottomDiameter+StapleSpace), BaseThickness + 0.01])  // 第[i,j]个槽位位置
                    reed_staple(
                        BottomDiameter=StapleBottomDiameter, 
                        TopDiameter=StapleTopDiameter, 
                        Height=StapleHeight, 
                        BottomFillet=StapleBottomFillet, 
                        TopFillet=StapleTopFillet
                    );
            }
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
    translate([TotalLength/2, 0, BaseThickness])
        chamfer_edge_mask(l = TotalLength, chamfer=EdgeChamfer, orient=RIGHT);
    translate([0, TotalWidth/2, BaseThickness])
        chamfer_edge_mask(l = TotalWidth, chamfer=EdgeChamfer, orient=FRONT);
    translate([TotalLength, TotalWidth/2, BaseThickness])
        chamfer_edge_mask(l = TotalWidth, chamfer=EdgeChamfer, orient=BACK);
    translate([TotalLength/2, TotalWidth, BaseThickness])
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
    translate([EdgeRounding,EdgeRounding,BaseThickness])
        rotate_extrude(angle=90, start=0) left(EdgeRounding) zrot(45) square(EdgeChamfer * sqrt(2), center=true);
    translate([TotalLength-EdgeRounding,EdgeRounding,BaseThickness])
        rotate_extrude(angle=90, start=90) left(EdgeRounding) zrot(45) square(EdgeChamfer * sqrt(2), center=true);
    translate([TotalLength-EdgeRounding,TotalWidth-EdgeRounding,BaseThickness])
        rotate_extrude(angle=90, start=180) left(EdgeRounding) zrot(45) square(EdgeChamfer * sqrt(2), center=true);
    translate([EdgeRounding,TotalWidth-EdgeRounding,BaseThickness])
        rotate_extrude(angle=90, start=270) left(EdgeRounding) zrot(45) square(EdgeChamfer * sqrt(2), center=true);
}
