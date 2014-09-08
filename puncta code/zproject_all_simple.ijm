input = "C:\\Users\\supersub\\Desktop\\Data\\2.8\\warped\\";
output = "C:\\Users\\supersub\\Desktop\\Data\\2.8\\rois\\10\\";

setBatchMode(true); 
list1 = getFileList(input);
for (i = 0; i < list1.length; i++)
        action1(input, output, list1[i]);
setBatchMode(false);
close();

list2 = getFileList(output);
for (i = 0; i < list2.length; i++)
        open(output + list2[i]);
setBatchMode(false);
run("Images to Stack");
run("StackReg", "transformation=[Rigid Body]");
//run("Subtract Background...", "rolling=15 sliding stack");
//run("Enhance Contrast...", "saturated=0.1 normalize process_all");
saveAs("tif", output + "2dtseries_");

//run("Particle Tracker 2D/3D", "radius=3 cutoff=0 per/abs=1 link=1 displacement=8");



function action1(input, output, filename) {
        open(input + filename);
        roiManager("Select", 0);
        run("Crop");
        run("Slice Keeper", "first=59 last=79 increment=1");
        run("Z Project...", "projection=[Max Intensity]");
        saveAs("tif", output + filename);
        close();
}
