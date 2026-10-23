// OpenReed protruding reed drying rack. Units: mm.
// Native OpenSCAD geometry for oboe, English horn and bassoon reeds.
use <lib/drying-mandrel.scad>
$fa = 3;
$fs = 0.25;

/* [基本参数 | Basic Parameters] */
// 哨片类型 | Reed type
ReedFamily = "oboe_english_horn"; // [oboe_english_horn:Oboe and English horn, bassoon:Bassoon, custom:Custom]
// 锥柱数量 [X, Y] | Number of mandrels [X, Y]
NumberOfStaples = [8, 4];
// 中心距，0 使用预设 20 / 24 mm | Center spacing; 0 uses profile spacing
StapleCenterSpacing = 0;
// 直径补偿：正值加粗，负值减细，同时作用于底径和顶径 | DIAMETRAL print correction
DiameterCompensation = 0; // [-0.4:0.05:0.4]
// 底板厚度 | Base thickness
BaseThickness = 8;

/* [自定义锥柱 | Custom Mandrel] */
// 以下三项仅在 ReedFamily=custom 时使用；底径从加固根部上缘测量 | Custom profile only
StapleBottomDiameter = 4.8;
// 名义锥线顶径，导入倒角会进一步收小末端 | Nominal tip before lead-in bevel
StapleTopDiameter = 4.14;
// 加固根部上方的配合锥段长度 | Length of the fitting cone above the root
StapleHeight = 12;

/* [高级参数 | Advanced Parameters] */
// 圆滑加固根部高度 | Height of the smooth reinforced root
RootHeight = 3;
// 根部最大直径，0 使用预设 10 / 12 mm | Root diameter; 0 uses profile default
RootDiameter = 0;
// 顶部导入倒角轴向长度；不是根部圆角 | Axial lead-in bevel
TipChamfer = 0.3;
// 底板上下边缘倒角 | Plate edge chamfer
EdgeChamfer = 0.6;

/* [Hidden] */
Profile = drying_profile(ReedFamily);
BottomDiameter = (ReedFamily == "custom" ? StapleBottomDiameter : Profile[0])
                 + DiameterCompensation;
TopDiameter = (ReedFamily == "custom" ? StapleTopDiameter : Profile[1])
              + DiameterCompensation;
MandrelHeight = ReedFamily == "custom" ? StapleHeight : Profile[2];
EffectiveRootDiameter = RootDiameter > 0 ? RootDiameter : Profile[3];
CenterSpacing = StapleCenterSpacing > 0 ? StapleCenterSpacing : Profile[4];
TotalLength = NumberOfStaples[0] * CenterSpacing;
TotalWidth = NumberOfStaples[1] * CenterSpacing;
EdgeRounding = min(CenterSpacing / 2, 10);

assert(len(NumberOfStaples) == 2 &&
       NumberOfStaples[0] >= 1 && NumberOfStaples[1] >= 1 &&
       floor(NumberOfStaples[0]) == NumberOfStaples[0] &&
       floor(NumberOfStaples[1]) == NumberOfStaples[1],
       "NumberOfStaples must contain two positive integers");
assert(StapleCenterSpacing >= 0, "Center spacing must be nonnegative");
assert(RootDiameter >= 0, "RootDiameter must be nonnegative");
assert(CenterSpacing > EffectiveRootDiameter + 2,
       "Center spacing must leave room around each root");
assert(BaseThickness >= 2, "BaseThickness must be at least 2 mm");

union() {
    drying_plate([TotalLength, TotalWidth], BaseThickness,
                 EdgeRounding, EdgeChamfer);
    for (i = [0 : NumberOfStaples[0]-1])
        for (j = [0 : NumberOfStaples[1]-1])
            translate([(i-(NumberOfStaples[0]-1)/2)*CenterSpacing,
                       (j-(NumberOfStaples[1]-1)/2)*CenterSpacing,
                       BaseThickness])
                drying_mandrel(bottom=BottomDiameter, tip=TopDiameter,
                               height=MandrelHeight,
                               root_diameter=EffectiveRootDiameter,
                               root_height=RootHeight,
                               tip_chamfer=TipChamfer);
}
